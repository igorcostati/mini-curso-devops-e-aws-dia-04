output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

output "public_subnets_arns" {
  value = aws_subnet.public[*].arn
}

output "private_subnets_ids" {
  value = aws_subnet.private[*].id
}   