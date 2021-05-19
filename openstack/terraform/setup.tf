terraform {
  required_version = ">= 0.15.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.42.0"
    }
  }
}

locals {
  nodes_todo = [for i, entry in flatten([
    for flavor, count in var.node_flavor_counts : [
      for i in range(count) : {
        flavor       = flavor,
        flavor_index = i,
        id           = "${replace(flavor, ".", "-")}-${i + 1}"
      }
    ]
    ]) : {
    index         = i,
    flavor        = entry.flavor,
    flavor_index  = entry.flavor_index,
    instance_name = "${var.cluster_name}-master-${entry.id}"
  }]

  nodes_yaml = {
    all = {
      vars = {
        k8s_version                  = "1.20.6"
        ansible_ssh_private_key_file = "../terraform/ssh.key"
        ansible_user                 = "root"
      }
      children = {
        nodes = {
          hosts = {
            for flavor, count in var.node_flavor_counts : "${var.cluster_name}-master-${flavor}-[1:${count}]" => {}
          }
        }
        bootstrapper = {
          hosts = {
            "${var.cluster_name}-master-${keys(var.node_flavor_counts)[0]}-1" = {}
          }
        }
      }
    }
  }
}


## values for the configuration parameters here can be found by
## downloading the openrc.sh file (tools > OpenStack RC file)
# https://www.terraform.io/docs/providers/openstack/index.html#configuration-reference
provider "openstack" {
}

variable "cluster_name" {
  description = "name of the k8s cluster"
  default     = "pocketdune"
}

variable "base_image" {
  description = "base image name to use for instances"
  default     = "C8 - x86_64 [2021-05-01]"
}

resource "openstack_compute_keypair_v2" "pocketdune" {
  name = var.cluster_name
}

resource "openstack_compute_instance_v2" "okd-dev-master" {
  for_each = {
    for entry in local.nodes_todo : entry.instance_name => entry
  }

  name                = each.key
  image_name          = var.base_image
  flavor_name         = each.value.flavor
  key_pair            = openstack_compute_keypair_v2.pocketdune.name
  stop_before_destroy = true
  config_drive        = true

  metadata = {
    landb-alias      = "${var.cluster_name}--LOAD-${each.value.index + 1}-"
    k8s-cluster-name = var.cluster_name
  }
}

resource "local_file" "ansible_hosts" {
  content  = "${yamlencode(local.nodes_yaml)}"
  filename = "${path.module}/../ansible/hosts.yaml"
}

resource "local_file" "ssh_key" {
  content         = "${openstack_compute_keypair_v2.pocketdune.private_key}"
  file_permission = "0600"
  filename        = "ssh.key"
}