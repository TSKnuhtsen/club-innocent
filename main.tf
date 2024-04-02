provider "google" {
  project = var.project_id
  region  = var.region
}

module "raw_data" {
  source = "./raw-data"

  project_id   = var.project_id
  project_name = var.project_name

  object_name = "titanic.parquet"
  source_path = "./titanic.parquet"

  region = var.region
}

module "big_query" {
  source = "./big-query"

  dataset_id   = "titanic"
  dataset_name = "titanic"

  region = var.region
}

module "upload_function" {
  source = "./upload-function"

  project_id   = var.project_id
  project_name = var.project_name

  dataset_id = module.big_query.dataset_id

  region = var.region
}