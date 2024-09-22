# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0



module "set_up_snowflake_integration" {
  source = "./split-snowflake-role"
  aws_region="us-west-2"
s3_bucketname="snowflake-s3-bucket1-test-terraform2"
s3_bucketname_tag = "snowflake-s3-bucket1-test-terraform2"
s3_bucketname_env ="DEV"
snowflakeRole = "Snowflake_S3_integration_retest"
snowflakes3policyname = "Snowflake_S3_integration_policy2"
snowflakeS3StorageIntegration = "S3_Storage2"

  }


module "revise-arn" {
    source="./aws-update-role"

storage_integration_arn = module.set_up_snowflake_integration.storage_integration
external_id =module.set_up_snowflake_integration.external_id
policy_arn = module.set_up_snowflake_integration.snowflake3policyarn
snowflakeRole = "Snowflake_S3_integration_retest"

depends_on=[module.set_up_snowflake_integration]

}
