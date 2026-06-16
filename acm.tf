provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_route53_zone" "main" {
  name         = "sakshi.store"
  private_zone = false
}


resource "aws_acm_certificate" "alb_cert" {
  domain_name       = "sakshi.store"
  validation_method = "DNS"
}


resource "aws_acm_certificate" "cloudfront_cert" {
  provider = aws.virginia

  domain_name               = "sakshi.store"
  subject_alternative_names = ["*.sakshi.store"]
  validation_method         = "DNS"
}


resource "aws_route53_record" "alb_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options :
    dvo.resource_record_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_route53_record" "cloudfront_validation" {
  for_each = toset([
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options :
    dvo.resource_record_name
  ])

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value
  type    = "CNAME"
  ttl     = 60
  records = [
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options :
    dvo.resource_record_value
    if dvo.resource_record_name == each.value
  ]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [
    for r in aws_route53_record.alb_validation : r.fqdn
  ]
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.virginia

  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [
    for r in aws_route53_record.cloudfront_validation : r.fqdn
  ]
}