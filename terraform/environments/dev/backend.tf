terraform{
    backend "s3"{}
    bucket="retailstore-bucket-s3"
    key="dev/terraform.tfstate"
    region="us-east-1"
}