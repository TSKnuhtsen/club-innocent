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

data "archive_file" "this" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/deploy.zip"
}

resource "google_storage_bucket" "this" {
  name = "${var.project_name}-${random_pet.this.id}-artifacts"

  project  = var.project_id
  location = var.region

  force_destroy = true
}

resource "google_service_account" "this" {
  account_id = "${var.project_name}-gcf-sa"
  display_name = "${var.project_name}-gcf-sa"
}

resource "google_project_iam_binding" "cloud-run-invoker" {
  project = var.project_id
  role    = "roles/run.invoker"

  members = [
    "serviceAccount:${google_service_account.this.email}"
  ]
}

resource "google_project_iam_binding" "storage-object-viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.this.email}"
  ]
}

resource "google_project_iam_binding" "bigquery-data-editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.this.email}"
  ]
}

resource "google_project_iam_binding" "bigquery-job-user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.this.email}"
  ]
}

resource "google_storage_bucket_object" "this" {
  name   = "upload-from-gs-to-bigquery.${data.archive_file.this.output_sha256}.zip"
  source = "${path.module}/deploy.zip"

  content_type = "application/zip"

  bucket = google_storage_bucket.this.id
}

resource "google_cloudfunctions2_function" "this" {
  name = "${var.project_name}-upload-from-gs-to-bigquery"

  build_config {
    runtime     = "python39"
    entry_point = "function_handler"
    source {
      storage_source {
        bucket = google_storage_bucket.this.name
        object = google_storage_bucket_object.this.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 180

    environment_variables = {
      BIGQUERY_PROJECT = var.project_id
      BIGQUERY_DATASET = var.dataset_id
    }

    service_account_email = google_service_account.this.email
  }

  location = var.region
}