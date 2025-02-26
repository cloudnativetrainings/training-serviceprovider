terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.15.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }

  required_version = ">= 1.5.0"
}

provider "google" {
  project = var.main_project_id
  region  = var.region
  zone    = var.zone
}

provider "local" {}
