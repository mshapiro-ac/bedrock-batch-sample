data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# This is the LLM model that we will be using for our batch job
data "aws_bedrock_foundation_model" "claude_haiku_model" {
  model_id = "anthropic.claude-3-5-haiku-20241022-v1:0"
}

# The role that our Bedrock batch job will assume
data "aws_iam_policy_document" "bedrock_batch_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:model-customization-job/*"]
    }
  }
}

# the policy document that will allow our Bedrock batch job to access the S3 buckets
data "aws_iam_policy_document" "bedrock_bucket_policy_doc" {
  statement {
    sid       = "AllowS3Access"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.prompt_input_bucket.arn, "${aws_s3_bucket.inference_output_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "bedrock_bucket_policy" {
  name_prefix = "BedrockBatch-"
  description = "Policy for Bedrock batch notes test jobs"
  policy      = data.aws_iam_policy_document.bedrock_bucket_policy_doc.json
}

resource "aws_iam_role" "bedrock_batch_role" {
  name_prefix = "BedrockBatch-"
  description = "Role for the Bedrock batch notes test job"
  
  assume_role_policy = data.aws_iam_policy_document.bedrock_batch_role_policy.json
  managed_policy_arns = [aws_iam_policy.bedrock_bucket_policy.arn]
}

# I don't think there is a "aws_bedrock_batch_inference_job" resource for terraform
# resource  "aws_bedrock_batch_inference_job" "medical_notes_job" {
#   model_id      = "us.anthropic.claude-3-5-haiku-20241022-v1:0" 
#   role_arn      = aws_iam_role.bedrock_batch_role.arn
  
#   input_data_config {
#     s3_input_config {
#       s3_uri = "${aws_s3_bucket.prompt_input_bucket.bucket_uri}/input-data/"
#     }
#   }
  
#   output_data_config {
#     s3_output_config {
#       s3_uri = "${aws_s3_bucket.inference_output_bucketoutput_bucket.bucket_uri}/output-data/"
#     }
#   }

#   job_name     = "medical-notes-batch-job"
#   max_tokens   = 4096
#   temperature  = 0.2
# }

# resource "aws_bedrock_inference_profile" "notes_sample_profile" {
#   name                = "notes-sample-profile"
#   model_id            = "us.anthropic.claude-3-5-haiku-20241022-v1:0"
#   inference_parameters = jsonencode({
#     max_tokens  = 4096,
#     temperature = 0.2
#   })
# }

