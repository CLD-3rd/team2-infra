resource "aws_db_subnet_group" "this" {
  count      = var.create_subnet_group ? 1 : 0
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-subnet-group"
    }
  )
}