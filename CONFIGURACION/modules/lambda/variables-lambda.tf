variable "permisos" {
  description = "Permisos asociados a la lambda"
  type        = set(string)
}

variable "nombre-lambda" {
  description = "nombre de la lambda"
  type        = string
}

variable "handler-lambda" {
  description = "TO DO"
  type = string
}

variable "runtime-lambda" {
  description = "Lenguaje de la función"
  type        = string
}

variable "codigo-fuente" {
  description = "Código fuente de la lambda en formato zip"
  type = string
}