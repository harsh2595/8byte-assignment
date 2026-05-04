terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_UNIQUE_STATE_BUCKET"
    key            = "8byte-assignment/staging/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "8byte-terraform-locks"
    encrypt        = true
  }
}
