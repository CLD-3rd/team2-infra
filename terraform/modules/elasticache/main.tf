resource "aws_elasticache_cluster" "this" {
  cluster_id           = var.cluster_id
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = var.port
  subnet_group_name    = var.create_subnet_group ? aws_elasticache_subnet_group.this[0].name : (var.subnet_group_name != null ? var.subnet_group_name : null)
  security_group_ids   = var.security_group_ids

  transit_encryption_enabled = var.transit_encryption_enabled

  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window         = var.snapshot_window

  tags = var.tags
}