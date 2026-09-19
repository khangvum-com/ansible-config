terraform {
  required_version = ">= 1.16.0"

  cloud {
    organization = "khangvum"

    workspaces {
      name = "homelab-iac"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      # version = "~> 5.0"
      version = "5.22.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}