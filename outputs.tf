output "ec2_public_ip" {
  value       = aws_instance.fitness_ec2.public_ip
  
}

output "rds_endpoint" {
  value       = aws_db_instance.fitness_rds.endpoint

}

output "s3_bucket_name" {
  value       = aws_s3_bucket.fitness_images_terraform.bucket
}
output "ec2_eip_ip" {
  value = aws_eip.fitness_eip.public_ip
}