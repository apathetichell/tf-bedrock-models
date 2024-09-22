## Action group Lambda function
/*data "archive_file" "forex_api_zip" {
  type             = "zip"
  source_file      = "${path.module}/lambda/forex_api/index.py"
  output_path      = "${path.module}/tmp/forex_api.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "forex_api" {
  function_name = "ForexAPI"
  role          = aws_iam_role.lambda_forex_api.arn
  description   = "A Lambda function for the forex API action group"
  filename      = data.archive_file.forex_api_zip.output_path
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  # source_code_hash is required to detect changes to Lambda code/zip
  source_code_hash = data.archive_file.forex_api_zip.output_base64sha256
}


resource "aws_lambda_permission" "forex_api" {
  action         = "lambda:invokeFunction"
  function_name  = aws_lambda_function.forex_api.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = local.account_id
  source_arn     = "arn:aws:bedrock:${local.region}:${local.account_id}:agent/*"
}



# get authorization credentials to push to ecr
data "aws_ecr_authorization_token" "token" {}

# configure docker provider
provider "docker" {
  registry_auth {
      address = data.aws_ecr_authorization_token.token.proxy_endpoint
      username = data.aws_ecr_authorization_token.token.user_name
      password  = data.aws_ecr_authorization_token.token.password
    }
}

# build docker image
resource "docker_image" "my-docker-image" {
  name = "${data.aws_ecr_authorization_token.token.proxy_endpoint}/my-ecr-repo:latest"
  build {
    context = ".\amazon-bedrock-agents-quickstars\."
  }
  platform = "linux/arm64"
}

# push image to ecr repo
resource "docker_registry_image" "media-handler" {
  name = docker_image.my-docker-image.name
}
*/