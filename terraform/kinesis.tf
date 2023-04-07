resource "aws_kinesis_firehose_delivery_stream" "firehose_coffee_tips" {
  destination = "extended_s3"
  name        = var.bucket
  depends_on = [aws_s3_bucket.bucket]

  extended_s3_configuration {
    bucket_arn = aws_s3_bucket.bucket.arn
    role_arn = aws_iam_role.firehose_iam_role.arn
    prefix = var.kinesis_prefix
    error_output_prefix = var.kinesis_error_output_prefix
    buffer_interval = var.buffer_interval
    buffer_size = var.buffer_size
    compression_format = var.compression_format

    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = aws_lambda_function.lambda_coffee_tips.arn
        }
      }
    }
  }
}

data "aws_iam_policy_document" "firehose_iam_policy_document_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_iam_role" {
  name = "firehose_iam_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_iam_policy_document_assume_role.json
}

resource "aws_iam_policy" "firehose_policies" {
  name = "kinesis_policies"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:GetObject",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource":  [
          "arn:aws:s3:::${var.bucket}/*",
          "arn:aws:s3:::${var.bucket}*",
        ]
      },
      {
        "Action": [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ],
        "Effect": "Allow",
        "Resource":  [aws_lambda_function.lambda_coffee_tips.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_iam_policies_attach" {
  policy_arn = aws_iam_policy.firehose_policies.arn
  role       = aws_iam_role.firehose_iam_role.name
}
