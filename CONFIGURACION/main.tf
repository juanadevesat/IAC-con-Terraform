terraform {
  cloud {
    organization = "Juan-personal"

    workspaces {
      name = "Juan-EjFinal-terraform"
    }
  }
}

# -----------------------------------------------------
# ---------------------- PARTE 1 ----------------------

locals {
  
  region                   = "eu-west-3" # Paris
  
  nombre-bucket            = "s3terraformejfinal"

  nombre-dynamo            = "DBjuan-EjFinal-terraform"
  columna-principal-dynamo = { name="ID", type="N" }
  
  nombre-lambda            = "copia-de-s3-a-dynamodb"
  permisos-para-lambda     = ["AmazonDynamoDBFullAccess", "AmazonS3ReadOnlyAccess"]
  nombre-app               = "main"
  funcion-en-app           = "lambda_handler"
  runtime-lambda           = "python3.12"
  codigo-fuente            = "src.zip" # en formato zip

}

data "aws_iam_policy" "permisos" {
  count = length(local.permisos-para-lambda)

  name = local.permisos-para-lambda[count.index]
}

provider "aws" {
  region = local.region
}

module "dynamoDB" {
  source        = "./modules/dynamoDB"
  nombre-dynamo = local.nombre-dynamo
  hash-key      = local.columna-principal-dynamo
}

module "bucketS3" {
  source        = "./modules/bucketS3"
  nombre-bucket = local.nombre-bucket
}

module "lambda" {
  source         = "./modules/lambda"
  nombre-lambda  = local.nombre-lambda
  permisos       = [ for permiso in data.aws_iam_policy.permisos : permiso.arn ]
  handler-lambda = "${local.nombre-app}.${local.funcion-en-app}"
  runtime-lambda = local.runtime-lambda
  codigo-fuente  = local.codigo-fuente
}

resource "aws_lambda_permission" "permitir_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.arn-lambda
  principal     = "s3.amazonaws.com"
  source_arn    = module.bucketS3.info-bucket.arn
}

resource "aws_s3_bucket_notification" "lambda-trigger" {
  bucket                = module.bucketS3.info-bucket.id

  lambda_function {
    lambda_function_arn = module.lambda.arn-lambda
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.permitir_bucket
  ]
}


# -----------------------------------------------------
# ---------------------- PARTE 2 ----------------------

locals {
  nombre-apprunner      = "apprunner-EjFinal-terraform"
  connection_arn_github = "arn:aws:apprunner:eu-west-3:757967241514:connection/github-containers/8a91462f6503486ca4558e011a7700e6"
  build_command         = "pip install -r web/requirements.txt"
  puerto                = "5000"
  runtime               = "PYTHON_3"
  start_command         = "python web/app.py"
  url_repositorio       = "https://github.com/juanadevesat/juan-EjFinal-terraform"
  source_code_version   = {type = "BRANCH", value = "main"}
  conf_instancia        = {cpu = "1 vCPU", memory = "2 GB"}
  politicas_instancia    = ["AmazonDynamoDBReadOnlyAccess", "AmazonS3FullAccess"]
}

data "aws_iam_policy" "politicas-apprunner" {
  count = length(local.politicas_instancia)

  name = local.politicas_instancia[count.index]
}

module "apprunner" {
  source = "./modules/apprunner"

  nombre-apprunner      = local.nombre-apprunner
  connection_arn_github = local.connection_arn_github
  build_command         = local.build_command
  port                  = local.puerto
  runtime               = local.runtime
  start_command         = local.start_command
  repository_url        = local.url_repositorio
  source_code_version   = local.source_code_version
  conf_instance         = local.conf_instancia
  policies              = [ for politica in data.aws_iam_policy.politicas-apprunner : politica.arn ]
}