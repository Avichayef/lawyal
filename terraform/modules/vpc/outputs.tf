# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.ly_vpc.id
}

# Output public subnet ID
output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

# Output private subnet ID
output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}
