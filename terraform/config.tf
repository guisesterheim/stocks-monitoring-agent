terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key    = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = "true"
    # bucket is passed at init time via -backend-config in commands.sh
  }
}

provider "aws" {
  region = "us-east-1"
}
