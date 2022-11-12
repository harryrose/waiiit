resource "aws_acm_certificate" "site" {
  domain_name = var.root_domain
  subject_alternative_names = ["www.${var.root_domain}"]

  validation_method = "DNS"
  tags = {
    project = var.project
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}