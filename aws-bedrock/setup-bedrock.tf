# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


data "aws_caller_identity" "locals" {}
data "aws_partition" "locals" {}
data "aws_region" "locals" {}

locals {
  account_id = data.aws_caller_identity.locals.account_id
  partition  = data.aws_partition.locals.partition
  region     = data.aws_region.locals.name
}

data "aws_bedrock_foundation_model" "this" {
  model_id = var.bedrock_model
}

data "aws_bedrock_foundation_model" "second-model" {
  model_id="amazon.titan-embed-text-v1"
}

data "aws_bedrock_foundation_model" "third_model" {
  model_id="anthropic.claude-3-sonnet-20240229-v1:0"
}


resource "aws_iam_policy" "bedrock-invoke-policy" {
  name = var.bedrock_invoke_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["bedrock:InvokeModel"]
        Effect   = "Allow"
        Resource = [data.aws_bedrock_foundation_model.this.model_arn,data.aws_bedrock_foundation_model.second-model.model_arn,
        data.aws_bedrock_foundation_model.third_model.model_arn]
      }
    ]
  })
  depends_on=[data.aws_bedrock_foundation_model.this]
}


resource "aws_s3_bucket" "api-specs-bucket" {
  bucket = "terraform-bedrock-api-specs-buckt"
}

resource "null_resource" "download-api-specs" {
  provisioner "local-exec" {
    command= <<-EOT
    aws s3 cp ./image/amazon-bedrock-agents-quickstart/agent_aws_openapi.json s3://${aws_s3_bucket.api-specs-bucket.bucket}/agent_aws_openapi.json
  EOT
  }
}

resource "aws_iam_policy" "retrieve-schema-policy" {
  name = var.bedrock_retrieve_schema_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::bedrockreinvent/agent_aws_openapi.json",
                "${aws_s3_bucket.api-specs-bucket.arn}/agent_aws_openapi.json"]
      }
    ]
  })

}


resource "aws_bedrockagent_agent" "example" {
  agent_name                  = var.agent_name
  agent_resource_role_arn     = aws_iam_role.bedrock-role.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = var.bedrock_model
  instruction = var.agent_instruction

depends_on = [aws_iam_role.bedrock-role]
}

resource "aws_ecr_repository" "agent-ecr" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
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

output "token_endpoint" {
  value = "sample ecr endpoint = ${data.aws_ecr_authorization_token.token.proxy_endpoint}/${var.ecr_name}:latest"
}


# build docker image
resource "docker_image" "my-docker-image" {
  ##name="my-bedrock-test"
  name = replace("${data.aws_ecr_authorization_token.token.proxy_endpoint}/${var.ecr_name}:latest","https://","")
  build {
    context = "./image/amazon-bedrock-agents-quickstart/."
  }
  platform = "linux/arm64"
}

# push image to ecr repo
resource "docker_registry_image" "bedrock-agent" {
  name = docker_image.my-docker-image.name
}

data "aws_iam_policy_document" "lambda-execution-policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "iam-for-lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda-execution-policy.json
   managed_policy_arns   = [aws_iam_policy.bedrock-invoke-policy.arn]
}



resource "aws_lambda_function" "bedrock-claude-lambda" {
  function_name = var.lambda_function_name
  role=aws_iam_role.iam-for-lambda.arn
  package_type="Image"
  memory_size=512
  timeout=30

  ##handler="index.py"
  ##runtime="python3.11"
  image_uri=replace("${data.aws_ecr_authorization_token.token.proxy_endpoint}/${var.ecr_name}:latest","https://","")


}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda-logging" {
  name        = "lambda_logging_${var.lambda_function_name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam-for-lambda.name
  policy_arn = aws_iam_policy.lambda-logging.arn
}


resource "aws_iam_policy" "lambda-invoke-policy" {
  name = var.lambda_invoke_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["lambda:InvokeFunction"]
        Effect   = "Allow"
        Resource = aws_lambda_function.bedrock-claude-lambda.arn
      }
    ]
  })
}




resource "aws_iam_role" "bedrock-role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "bedrock.amazonaws.com"
        }
      Condition = { 
        StringEquals = {"aws:SourceAccount" = local.account_id}
        ArnLike = {"aws:SourceArn" = "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"}
      }
    }

    ]
    Version = "2012-10-17"
  })
  description           = null
  force_detach_policies = false
  managed_policy_arns   = [aws_iam_policy.retrieve-schema-policy.arn, aws_iam_policy.bedrock-invoke-policy.arn, aws_iam_policy.lambda-invoke-policy.arn]
  max_session_duration  = 3600
  name                  = var.bedrock_role //AmazonBedrockExecutionRoleForAgents_workshop
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}

  depends_on=[aws_iam_policy.retrieve-schema-policy, aws_iam_policy.bedrock-invoke-policy]

}



resource "aws_bedrockagent_agent_action_group" "claude-group" {
  action_group_name          = "example"
  agent_id                   = aws_bedrockagent_agent.example.agent_id
  agent_version              = "DRAFT"
  action_group_state         = "ENABLED"
  skip_resource_in_use_check = true
  action_group_executor {
    lambda = aws_lambda_function.bedrock-claude-lambda.arn
  }
  api_schema {
    s3 {
      s3_bucket_name =  aws_s3_bucket.api-specs-bucket.bucket
      s3_object_key  = "agent_aws_openapi.json"
    }
  }
}