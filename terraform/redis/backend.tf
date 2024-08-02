terraform {
  backend "s3" {
    bucket         = "s3 bucket name 
    key            = "terraform/terraform.tfstate"
    region         = "Region" # Change to your desired region
    encrypt        = true
  }
}
