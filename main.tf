terraform {
  backend "s3" {
    bucket  = "cloudapi-terraform-state"
    key     = "state/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
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

  lifecycle {
    prevent_destroy = true   # Prevent accidental deletion
    ignore_changes  = [name] # Ignore table recreation
  }
}


data "aws_iam_role" "existing_lambda_role" {
  name = "ResumeAPI-role-p6hwze50"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./lambda_function"  # Package entire directory to capture changes
  output_path = "lambda_function.zip"
}


resource "aws_lambda_function" "Resume_func" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "Resume_func"
  role             = data.aws_iam_role.existing_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256  # ✅ Ensures redeployment on code change
}



resource "aws_apigatewayv2_api" "Resume_API" {
  name          = "Resume_API"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_gateway" {
  api_id           = aws_apigatewayv2_api.Resume_API.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.Resume_func.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}


resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.Resume_API.id
  route_key = "ANY /{proxy+}" # Catch-all route
  target    = "integrations/${aws_apigatewayv2_integration.lambda_gateway.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.Resume_API.id
  name        = "default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5 # Allows a burst of 10 requests
    throttling_rate_limit  = 2 # Limits requests to 5 per second
  }
}


resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.Resume_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.Resume_API.execution_arn}/*/*"
}

