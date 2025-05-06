terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.97.0"
      }
    }

    backend "s3" {
        bucket = "terraform-state-bucket-taro937184"
        key = "morefix/state.tfstate"
        region = "us-west-2"
    }

    required_version = ">=1.11.0"
}