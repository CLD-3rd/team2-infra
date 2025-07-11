resource "aws_ssm_parameter" "grafana_password" {
  name  = var.key_name
  type  = "SecureString"
  value = var.value
  tags  = var.tags
}