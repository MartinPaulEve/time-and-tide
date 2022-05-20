resource "aws_api_gateway_domain_name" "subdomain" {
  certificate_arn = var.ssl_certificate_arn
  domain_name     = var.domain_name
}

resource "aws_route53_record" "subdomain" {
  name    = aws_api_gateway_domain_name.subdomain.domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.subdomain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.subdomain.cloudfront_zone_id
  }
}