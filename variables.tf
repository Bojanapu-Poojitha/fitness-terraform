variable "aws_region" {

  description = "ap-south-1"
}
variable "db_username" {

  default     = "postgres"

}

variable "db_password"{
    description="rds password"
}
variable "db_name"{
    default="fitness_db"
}
variable "key_pair_name" {
 
  description = "ec2 key pair"
}
