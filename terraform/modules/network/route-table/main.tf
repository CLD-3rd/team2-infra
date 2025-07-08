resource "aws_route_table" "this" {
  count  = length(var.route_tables)
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.route_tables[count.index].routes
    content {
      cidr_block     = route.value.cidr_block
      gateway_id     = route.value.gateway_id
      nat_gateway_id = route.value.nat_gateway_id
    }
  }

  tags = merge(
    {
      Name = var.route_tables[count.index].name
    },
    var.route_tables[count.index].tags
  )
}

resource "aws_route_table_association" "this" {
  count = sum([for rt in var.route_tables : length(rt.subnet_ids)])
  
  subnet_id      = local.subnet_route_associations[count.index].subnet_id
  route_table_id = local.subnet_route_associations[count.index].route_table_id
}

locals {
  subnet_route_associations = flatten([
    for rt_idx, rt in var.route_tables : [
      for subnet_id in rt.subnet_ids : {
        subnet_id      = subnet_id
        route_table_id = aws_route_table.this[rt_idx].id
      }
    ]
  ])
}