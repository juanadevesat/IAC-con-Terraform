resource "aws_apprunner_service" "apprunner" {
  service_name = var.nombre-apprunner

  source_configuration {
    authentication_configuration {
      connection_arn = var.connection_arn_github
    }
    code_repository {
      code_configuration {
        code_configuration_values {
          build_command = var.build_command
          port          = var.port
          runtime       = var.runtime
          start_command = var.start_command
        }
        configuration_source = "API"
      }
      repository_url = var.repository_url
      source_code_version {
        type  = var.source_code_version.type
        value = var.source_code_version.value
      }
    }
  }

  network_configuration {
    egress_configuration {
      egress_type       = "DEFAULT"
    }
  }

  tags = {
    Name = var.nombre-apprunner
  }
}