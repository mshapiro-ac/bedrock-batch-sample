resource "aws_s3_bucket" "prompt_input_bucket" {
  bucket = "axiscare-bedrock-test-input-bucket"
}

resource "aws_s3_bucket" "inference_output_bucket" {
  bucket = "axiscare-bedrock-test-output-bucket"
}

resource "aws_s3_bucket" "prompt_source_bucket" {
  bucket = "axiscare-prompt-source-bucket"
}