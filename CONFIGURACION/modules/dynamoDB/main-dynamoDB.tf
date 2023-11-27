resource "aws_dynamodb_table" "dynamoDB" {
  name         = var.nombre-dynamo              # Nombre de la tabla
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash-key.name              # El identificador de la tabla

  attribute {                                   # Definimos la columna principal. 
    name       = var.hash-key.name
    type       = var.hash-key.type
  }

}