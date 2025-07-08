resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.domain_name
  tags  = var.tags
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

resource "aws_route53_record" "this" {
  count   = length(var.records)
  zone_id = local.zone_id
  name    = var.records[count.index].name
  type    = var.records[count.index].type

  dynamic "alias" {
    for_each = var.records[count.index].alias != null ? [var.records[count.index].alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  ttl     = var.records[count.index].alias == null ? var.records[count.index].ttl : null
  records = var.records[count.index].alias == null ? var.records[count.index].records : null
}