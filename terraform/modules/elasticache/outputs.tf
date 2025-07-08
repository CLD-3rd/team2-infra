output "cluster_id" {
  description = "The cache cluster identifier"
  value       = aws_elasticache_cluster.this.cluster_id
}

output "cluster_address" {
  description = "The DNS name of the cache cluster without the port appended"
  value       = aws_elasticache_cluster.this.cluster_address
}

output "configuration_endpoint" {
  description = "The configuration endpoint to allow host discovery"
  value       = aws_elasticache_cluster.this.configuration_endpoint
}

output "cache_nodes" {
  description = "List of node objects including id, address, port and availability_zone"
  value       = aws_elasticache_cluster.this.cache_nodes
}