resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = merge(var.tags, {
    Name = "${var.name}-EIP"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.subnet_id

  tags = merge(var.tags, {
    Name = var.name
  })

  depends_on = [aws_eip.nat]
}