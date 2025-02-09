variable "s3_bucket_name" {
  description = "Bucket with taxi data"
  default     = "ny-taxi-data-zc2025"
}

variable "clickhouse_password" {
  description = "Password for ClickHouse user"
  type        = string
  sensitive   = true
}