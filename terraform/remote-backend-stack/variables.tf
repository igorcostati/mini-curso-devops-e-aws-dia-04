variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "labs-dvn-mini-curso-devops-e-aws"
  }
}

variable "assume_role" {
  type = object({
    region   = string
    role_arn = string
  })
  default = {
    region   = "us-east-1"
    role_arn = "arn:aws:iam::273444517440:role/labs-dvn-mini-curso-devops-e-aws-role"
  }
}

variable "remote_backend" {
  type = object({
    s3_bucket_name              = string
    dynamodb_table_name         = string
    dynamodb_table_billing_mode = string
    dynamodb_table_hash_key     = string
    hash_key_atribute_name      = string
    hash_key_atribute_type      = string


  })
  default = {
    s3_bucket_name              = "labs-dvn-mini-curso-remote-backend"
    dynamodb_table_name         = "labs-dvn-mini-curso-remote-backend"
    dynamodb_table_billing_mode = "PAY_PER_REQUEST"
    dynamodb_table_hash_key     = "LockID"
    hash_key_atribute_name      = "LockID"
    hash_key_atribute_type      = "S"
  }

}