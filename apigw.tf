  module "api-gateway" {
    source        = "./terraform-aws-api-gateway"

    name        = "tides-api-gateway"
    environment = "prod"
    label_order = ["name", "environment"]
    enabled     = true

  # Api Gateway Resource
    path_parts = ["ical"]

  # Api Gateway Method
    method_enabled = true
    http_methods   = ["GET"]

  # Api Gateway Integration
    integration_types        = ["AWS_PROXY"]
    integration_http_methods = ["POST"]
    uri                      = [aws_lambda_function.tides-ical.invoke_arn]

  # Api Gateway Method Response
    status_codes = [200]
    response_models = [{}]
    response_parameters = [{"method.response.header.Content-Type" = true}]

  # Api Gateway Integration Response
    integration_response_parameters = []
    response_templates = [{
      "text/calendar" = <<EOF
      $inputRoot.body
  EOF
    }, {}]




  # Api Gateway Deployment
    deployment_enabled = true
    stage_name         = "deploy"

  # Api Gateway Stage
    stage_enabled = true
    stage_names   = ["prod"]

  # Api Gateway Client Certificate
    cert_enabled     = true
    cert_description = "clouddrove"

  # Api Gateway Gateway Response
    gateway_response_count = 2
    response_types         = ["UNAUTHORIZED", "RESOURCE_NOT_FOUND"]
    gateway_status_codes   = ["401", "404"]

  # Api Gateway Model
    model_count   = 1
    model_names   = ["ical"]
    content_types = ["text/calendar"]

  }

resource "aws_api_gateway_base_path_mapping" "path_map" {
  api_id      = module.api-gateway.id
  stage_name  = "deploy"
  domain_name = aws_api_gateway_domain_name.subdomain.domain_name
}