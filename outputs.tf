data "aws_availability_zones" "available" {
  state = "available"
}

output "PublicSubnet1_ID" {
  description = "ID of Public Subnet 1"
  value       = aws_subnet.PublicSubnet1.id
}

output "PublicSubnet2_ID" {
  description = "ID of Public Subnet 2"
  value       = aws_subnet.PublicSubnet2.id
}

output "PrivateSubnet1_ID" {
  description = "ID of Private Subnet 1"
  value       = aws_subnet.PrivatSubnet1.id
}

output "PrivateSubnet2_ID" {
  description = "ID of Private Subnet 2"
  value       = aws_subnet.PrivatSubnet2.id
}

output "AvailabilityZones" {
  description = "Available AZs in the region"
  value       = data.aws_availability_zones.available.names
}

output "LoadBalancer_DNS" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.LoadBalancer.dns_name
}

output "LoadBalancer_ARN" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.LoadBalancer.arn
}

output "ASG_Name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.ASG.name
}
