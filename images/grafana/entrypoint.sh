#!/bin/bash

sed -e "s+^  basicAuthPassword:.*+  basicAuthPassword: \"$POSTGRES_PASSWORD\"+" \
/etc/grafana/provisioning/datasources/ers.yaml  > ers.yaml.updated \
&& mv ers.yaml.updated /etc/grafana/provisioning/datasources/ers.yaml

exec grafana-server
