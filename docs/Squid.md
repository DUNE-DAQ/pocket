# Squid TLS Bumping and Artifact Caching

## Overview

Squid can operate as a normal HTTP forward proxy or as a TLS bumping proxy.

A normal Squid proxy can cache HTTP traffic because it can see:

* request URLs
* HTTP headers
* response headers
* response content

For HTTPS traffic, a normal proxy only sees the initial `CONNECT` request:

```
CONNECT ghcr.io:443 HTTP/1.1
```

The actual HTTP request is encrypted:

```
GET /v2/example/image/manifests/latest
GET /v2/example/image/blobs/sha256:...
```

Without TLS bumping, Squid only forwards encrypted bytes and cannot cache individual HTTPS objects - such as OCI images or RPMs.

TLS bumping allows Squid to terminate the client TLS connection, inspect the HTTP request, and create a separate TLS connection to the upstream server.

```
Client
  |
  | TLS connection
  |
  v
Squid
  |
  | TLS connection
  |
  v
Registry / Web Server
```

Squid becomes a trusted man-in-the-middle proxy.

---

# TLS Bumping Trust Model

When TLS bumping is enabled, Squid generates certificates dynamically.

For example, when a client accesses:

```
https://ghcr.io
```

Squid creates a certificate that looks like:

```
Subject:
    CN=ghcr.io

Issuer:
    Artifact Cache Proxy CA
```

The client normally expects the certificate to be issued by a public certificate authority.

Therefore, every client using the TLS bumping proxy must trust the Squid-generated CA certificate.

Without this trust:

```
x509: certificate signed by unknown authority
```

will occur.

---

# Squid CA Certificate Requirements

The TLS bump CA should be:

* internally generated
* protected like a root CA
* distributed only to systems that require proxy access
* rotated according to organizational policy

Let's Encrypt issues certificates for public DNS names. It cannot act as a private CA for dynamically generated certificates such as:

```
docker.io
ghcr.io
quay.io
registry.redhat.io
```

The TLS bump CA is separate from any public certificate used by Squid's administrative endpoints.

Example CA generation:

```bash
openssl req \
    -new \
    -newkey rsa:4096 \
    -days XXXXXXX \
    -nodes \
    -x509 \
    -keyout squid-ca.key \
    -out squid-ca.crt \
    -subj "/CN=Artifact Cache Proxy CA"
```

Protect:

```
squid-ca.key
```

The public certificate:

```
squid-ca.crt
```

is what clients receive.

---

# Client Trust Installation

Every client using TLS bumping must install the Squid CA certificate into its trusted CA store.

## RHEL / AlmaLinux

Copy the CA:

```bash
cp squid-ca.crt /etc/pki/ca-trust/source/anchors/
```

Update the trust database:

```bash
update-ca-trust
```

Verify:

```bash
trust list
```

## Containers

Host trust and container trust are separate.

A Podman host trusting the CA does not automatically mean a container image trusts it.

Container images may need the CA installed into:

```
/etc/pki/ca-trust/
/etc/ssl/certs/
```

depending on the base distribution.

---

# Squid TLS Bump Configuration

The TLS bump configuration requires:

1. An HTTPS listener.
2. A certificate generation helper.
3. TLS bump rules.

Example additions:

```conf
#
# TLS bump certificate generation
#

sslcrtd_program /usr/lib64/squid/security_file_certgen \
    -s /var/lib/squid/ssl_db \
    -M 64MB

sslcrtd_children 8 startup=2 idle=2


#
# TLS bump listener
#

https_port 3129 ssl-bump \
    cert=/etc/squid/ssl_cert/squid-ca.crt \
    key=/etc/squid/ssl_cert/squid-ca.key \
    generate-host-certificates=on \
    dynamic_cert_mem_cache_size=16MB


#
# TLS bump stages
#

acl step1 at_step SslBump1

ssl_bump peek step1
ssl_bump bump all
```

Initialize the certificate database:

```bash
/usr/lib64/squid/security_file_certgen \
    -c \
    -s /var/lib/squid/ssl_db \
    -M 64MB
```

The exact helper path depends on the Linux distribution package.

---

# Client Proxy Configuration

Clients still use a normal proxy configuration.

Example:

```bash
export HTTPS_PROXY=http://squid.example.org:3128
export HTTP_PROXY=http://squid.example.org:3128
```

The difference is not the proxy setting. The difference is that the client MUST trust the Squid CA as it will terminate the TLS connections and make new ones on your behalf.

---

# Minimal Non-TLS Squid Configuration

This configuration is suitable for HTTP-cacheable workloads such as CVMFS and RPM repositories.

TLS bumping sections should be added where marked below if HTTPS object caching is required.

```conf
#
# squid.conf
#

http_port 3128

visible_hostname artifact-cache


#
# Access control
#

acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16


#
# Allowed ports
#

acl SSL_ports port 443

acl Safe_ports port 80
acl Safe_ports port 443


http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

http_access allow localnet
http_access deny all


#
# Cache storage
#

cache_mem 1024 MB

cache_dir rock /var/spool/squid 500000 max-size=10 GB

maximum_object_size 10 GB
minimum_object_size 0 KB


#
# TLS bump additions go here:
#
# - https_port ssl-bump listener
# - sslcrtd_program
# - ssl_bump rules
#


#
# Immutable CVMFS objects
#

refresh_pattern -i /cvmfs/ \
    43200 100% 43200 \
    override-expire \
    ignore-no-cache \
    ignore-private


#
# RPM metadata
#

refresh_pattern -i /repodata/repomd\.xml$ \
    0 20% 60 \
    reload-into-ims


#
# RPM packages
#

refresh_pattern -i \.rpm$ \
    43200 100% 43200 \
    override-expire \
    ignore-no-cache \
    ignore-private


#
# Default
#

refresh_pattern . \
    0 20% 1440
```

---

# Security Considerations

TLS bumping changes Squid from a cache into a trusted TLS inspection component.

Consider:

* The Squid CA private key must be protected.
* Any client trusting the CA allows Squid to impersonate HTTPS sites.
* Access should be limited to artifact-fetching clients.
* Avoid using the same CA for general browsing inspection.
* Monitor CA expiration and replacement procedures.

For long-lived infrastructure, a dedicated artifact cache proxy with a dedicated CA is generally easier to operate than a general-purpose TLS inspection proxy.

---

# Recommended Architecture

For software distribution systems only:

```
              Artifact Clients
                    |
                    |
              Squid TLS Bump
                    |
        +-----------+-----------+
        |           |           |
      ghcr.io    quay.io    CVMFS
```

This provides:

* one cache endpoint
* no per-registry configuration
* shared caching across clients
* reduced external bandwidth usage

The tradeoff is the operational responsibility of maintaining a trusted TLS interception CA.

You should not use this as a general purpose proxy as it decodes encrypted traffic.
