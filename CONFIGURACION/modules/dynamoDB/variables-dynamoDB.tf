variable "nombre-dynamo" {
  description = "nombre de la base de datos en dynamoDb"
  type        = string
}

variable "hash-key" {
  description = "Columna principal de la dynamoDB"
  type        = map(string)
}