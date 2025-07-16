resource "aws_elasticache_subnet_group" "this" {
  count      = var.create_subnet_group ? 1 : 0
  name       = "${var.cluster_id}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_id}-subnet-group"
    }
  )
}