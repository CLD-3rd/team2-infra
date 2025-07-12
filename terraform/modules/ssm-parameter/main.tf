resource "aws_ssm_parameter" "this" {
  name  = var.key_name
  type  = "SecureString"
  value = var.value
  tags  = var.tags
}