resource "aws_iam_role" "lambda_role" {
  name = "rol-${var.nombre-lambda}"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})

managed_policy_arns  = var.permisos
}

data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/src/"
output_path = "${path.module}/src/src.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/src/src.zip"
  function_name = var.nombre-lambda
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler-lambda

  runtime = var.runtime-lambda
}