data "ns_connection" "jwt_authorizer" {
  name     = "jwt-authorizer"
  contract = "datastore/aws/*"
  optional = true
}

locals {
  // Generic JWT authorizer info emitted by the connected datastore. The gateway does not
  // need to know it is Cognito-specific: it only needs an issuer and the allowed audiences.
  jwt_issuer      = try(data.ns_connection.jwt_authorizer.outputs.jwt_issuer, "")
  jwt_audiences   = try(data.ns_connection.jwt_authorizer.outputs.jwt_audiences, [])
  enable_jwt_auth = local.jwt_issuer != ""

  // When a JWT-capable datastore is connected, secure all routes with the JWT authorizer.
  route_authorization_type = local.enable_jwt_auth ? "JWT" : "NONE"
  route_authorizer_id      = local.enable_jwt_auth ? aws_apigatewayv2_authorizer.jwt[0].id : null
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  count = local.enable_jwt_auth ? 1 : 0

  api_id           = aws_apigatewayv2_api.this.id
  name             = "${local.resource_name}-jwt"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = local.jwt_audiences
    issuer   = local.jwt_issuer
  }
}
