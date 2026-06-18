output "public_urls" {
  value = local.public_urls
}

output "permissions" {
  value = [
    {
      sid_prefix = "AllowGatewayAccess"
      action     = "lambda:InvokeFunction"
      principal  = "apigateway.amazonaws.com"
      source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*"
    }
  ]
}
