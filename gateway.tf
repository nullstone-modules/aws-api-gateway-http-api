data "ns_connection" "api-gateway" {
  name     = "api-gateway"
  contract = "ingress/aws/api-gateway"
}

locals {
  public_urls = flatten([for u in data.ns_connection.api-gateway.outputs.public_urls : [for p in var.paths : { url = "${u}/${p}" }]])
  domain_name = data.ns_connection.api-gateway.outputs.domain_name
}
