output "vpc_id" {
  value = aws_vpc.my-vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.pub-sub-1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.pub-sub-2.id
}


output "alb_certificate_arn" {
  value = aws_acm_certificate_validation.alb.certificate_arn
}

output "cloudfront_certificate_arn" {
  value = aws_acm_certificate_validation.cloudfront.certificate_arn
}