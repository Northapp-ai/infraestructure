resource "aws_apigatewayv2_api" "this" {
  name          = "north-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = {
    for route in var.routes :
    "${route.method} ${route.path}" => route
  }

  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = each.value.lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
  for_each = aws_apigatewayv2_integration.lambda

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.key
  target    = "integrations/${each.value.id}"
}

resource "aws_lambda_permission" "api" {
  for_each = {
    for route in var.routes :
    route.lambda_name => route
  }

  statement_id  = "AllowInvokeFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
