resource "aws_s3_bucket" "bucketS3" {
  bucket        = var.nombre-bucket 			# Referencia al nombre del bucket
  force_destroy = true 					          # Permitimos porque los ficheros en este proyecto son temporales

    tags        = {
    Name        = var.nombre-bucket
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ciclo-vida-S3" {
  bucket     = aws_s3_bucket.bucketS3.id
  rule {
    status   = "Enabled"
    id       = "expire_all_files"			# Elimina todos los ficheros
    expiration {
        days = 1						# edad de los ficheros cuando se eliminan
    }
  }
}