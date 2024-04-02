terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

resource "google_bigquery_dataset" "this" {
  dataset_id    = var.dataset_id
  friendly_name = var.dataset_name

  location = var.region

  delete_contents_on_destroy = true
}