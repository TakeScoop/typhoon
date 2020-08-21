resource "aws_s3_bucket" "ignition_configs" {
  bucket = "${var.cluster_name}-ignition-configs"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }
}
