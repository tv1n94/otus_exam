terraform {
  required_providers {
    ah = {
      source  = "advancedhosting/ah"
      version = "0.1.7"
    }
  }
}

provider "ah" {
  access_token = var.ah_token
}