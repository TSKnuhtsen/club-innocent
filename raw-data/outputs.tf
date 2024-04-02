output "bucket_url" {
  value = google_storage_bucket.this.url
}

output "object_url" {
  value = "${google_storage_bucket.this.url}/${google_storage_bucket_object.this.output_name}"
}