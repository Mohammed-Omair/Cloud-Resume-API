terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "state/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_dynamodb_table" "resume_table" {
  name         = "Resume"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"

  attribute {
    name = "Id"
    type = "S"
  }
}

resource "aws_lambda_function" "resume_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "ResumeAPI"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.resume_table.name
      AWS_REGION     = "us-east-2"
    }
  }
}

resource "aws_api_gateway_rest_api" "resume_api" {
  name        = "ResumeAPI"
  description = "API Gateway for Resume Data"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_rest_api.resume_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.resume_lambda.invoke_arn
}
