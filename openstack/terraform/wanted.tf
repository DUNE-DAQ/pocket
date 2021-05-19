variable "node_flavor_counts" {
  description = "map of flavors, and number of master/worker nodes to deploy with that flavor"
  default = {
    "m2.medium" = 2
  }
}