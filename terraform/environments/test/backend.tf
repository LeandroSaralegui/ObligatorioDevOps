terraform {
  backend "s3" {
    bucket         = "retailstore-bucket-s3"
    key            = "test/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}