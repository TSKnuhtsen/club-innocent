terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

resource "random_pet" "this" {
  length = 2
}

resource "google_storage_bucket" "this" {
  name = "${var.project_name}-${random_pet.this.id}-data"

  project  = var.project_id
  location = var.region

  force_destroy = true
}

resource "google_storage_bucket_object" "this" {
  name   = var.object_name
  source = var.source_path

  content_type = "text/plain"

  bucket = google_storage_bucket.this.id
}