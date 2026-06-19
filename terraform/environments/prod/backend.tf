terraform {
  backend "s3" {
    bucket         = "retailstore-bucket-s3"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}