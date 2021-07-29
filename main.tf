provider "aws" {
    profile= "default"
    shared_credentials_file = "~//aws/credentials" 
    region = "eu-west-1"
}

resource "aws_lambda_function" "lambda_function" {
  role             = "${aws_iam_role.lambda_exec_role.arn}"
  handler          = "${var.handler}"
  runtime          = "python3.8"
  filename         = "lambda.zip"
  function_name    = "aandrei_anagram_validator"
  source_code_hash = base64sha256("lambda.zip")
}

resource "aws_iam_role" "lambda_exec_role" {
name        = "lambda_exec_test"
path        = "/"
description = "Role used by lambda allowing access to other AWS services"
assume_role_policy = <<EOF
{
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
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "Lists policies which allow access to S3 and to write logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:HeadObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::*",
        "arn:aws:s3:::/*"
      ]
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
 role = "${aws_iam_role.lambda_exec_role.id}"
 policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_s3_bucket" "anagram-validator" {
    bucket = "aandrei-anagram-fd-testing"
    #acl = "${var.acl_value}"   
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.anagram-validator.arn}"
}

#this will trigger a lambda when an s3:ObjectCreated event happens
resource "aws_s3_bucket_notification" "bucket_terraform_notification" {
   bucket = "${aws_s3_bucket.anagram-validator.id}"
   lambda_function {
       lambda_function_arn = "${aws_lambda_function.lambda_function.arn}"
       events = ["s3:ObjectCreated:*"]
   }

   depends_on = [ aws_lambda_permission.allow_bucket ]
}