provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "vijay-terraform-cicd-test"
    dynamodb_table = "vijay-terraform"
    key            = "test/poc_codepipeline/terraform.tfstate"
    region         = "us-east-1"
  }
}
