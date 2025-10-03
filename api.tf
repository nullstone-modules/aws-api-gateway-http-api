resource "aws_apigatewayv2_api" "this" {
  name          = local.resource_name
  protocol_type = "HTTP"
  tags          = local.tags
}

resource "aws_apigatewayv2_api_mapping" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  domain_name = local.domain_name
  stage       = aws_apigatewayv2_stage.default.id
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = local.function_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 15000
  passthrough_behavior   = "WHEN_NO_MATCH"
}

locals {
  normalized_paths = toset([for p in var.paths : "/${trim(p, "/")}"])
}

resource "aws_apigatewayv2_route" "this" {
  for_each = local.normalized_paths

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY ${each.value}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
  tags        = local.tags
}
