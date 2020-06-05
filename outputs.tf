
output "core_direct_invoke_url" {
  value = "${aws_alb.core.dns_name}"
}

output "core_friendly_invoke_url" {
  value = "https://${aws_route53_record.core.fqdn}"
}
