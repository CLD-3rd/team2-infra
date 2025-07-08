resource "aws_subnet" "this" {
  count                   = length(var.subnets)
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnets[count.index].cidr_block
  availability_zone       = var.subnets[count.index].availability_zone
  map_public_ip_on_launch = var.subnets[count.index].public

  tags = merge(
    {
      Name = var.subnets[count.index].name
    },
    var.subnets[count.index].tags
  )
}