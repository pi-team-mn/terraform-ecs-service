resource "aws_route53_record" "core" {
  name    = "${var.application_name}${var.env == "master" ? "" : "-${var.env}"}.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_alb.core.dns_name
    zone_id                = aws_alb.core.zone_id
  }
}
