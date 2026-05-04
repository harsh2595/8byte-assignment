terraform {
  backend "s3" {
    bucket         = "harsh2595-8byte-assignment-tfstate-ap-south-1"
    key            = "8byte-assignment/staging/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "8byte-terraform-locks"
    encrypt        = true
  }
}
