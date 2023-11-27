variable "nombre-apprunner" {
    description = "Nombre para el servicio de apprunner"
    type = string
}

variable "connection_arn_github" {
    description = "ARN de la conexión entre github y AppRunner. Imprescindible para conexion con repositorios github"
    type = string
}

variable "build_command" {
    description = "Comando de AppRunner que se ejecuta para crear la aplicación"
    type = string
}

variable "port" {
    description = "Puerto que escucha su aplicación en el contenedor"
    type = string
}

variable "runtime" {
    description = "Tipo de entorno de ejecución para crear y ejecutar un servicio App Runner"
    type = string
}

variable "start_command" {
    description = "Comando de AppRunner que se ejecuta para iniciar la aplicación"
    type = string
}

variable "repository_url" {
    description = "Ubicación del repositorio que contiene el código fuente"
    type = string
}

variable "source_code_version" {
    description = "bloque admite los siguientes argumentos: type: Tipo de identificador. Valores válidos: BRANCH; value: rama que se utiliza"
    type = map(string)
}