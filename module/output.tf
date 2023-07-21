output "instance_public_ips" {
  value = aws_instance.mine_it_ec2_instance[*].public_ip
}

output "vpc_id" {
  value = aws_vpc.mine_it_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.mine_it_public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.mine_it_private_subnets[*].id
}

output "s3_bucket_id" {
  value = aws_s3_bucket.mine_it_s3_bucket.id
}