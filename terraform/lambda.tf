data "aws_iam_policy_document" "lambda_iam_policy_document_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_iam_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_iam_policy_document_assume_role.json
}

resource "aws_s3_object" "s3_object_upload" {
  depends_on = [aws_s3_bucket.bucket]
  bucket = var.bucket
  key    = var.lambda_filename
  source = var.file_location
  etag = filemd5(var.file_location)
}

resource "aws_lambda_function" "lambda_coffee_tips" {
  function_name = var.lambda_transformation
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = var.lambda_handler
  source_code_hash = aws_s3_object.s3_object_upload.key
  s3_bucket     = var.bucket
  s3_key        = var.lambda_filename
  runtime       = var.runtime
  timeout       = var.timeout
}

resource "aws_iam_policy" "lambda_policies" {
  name = "lambda-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect": "Allow",
        "Resource":  ["*"]
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

resource "aws_iam_role_policy_attachment" "lambda_iam_role_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policies.arn
  role       = aws_iam_role.lambda_iam_role.name
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_coffee_tips.function_name
  principal     = "firehose.amazonaws.com"
  source_arn    = aws_kinesis_firehose_delivery_stream.firehose_coffee_tips.arn
}