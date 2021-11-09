
resource "aws_iam_role" "lambda" {
  name = "LambdaFunctionRole-${var.lambda_function_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "secretsmanager.amazonaws.com"
          ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.logs.arn
    ]
  }
}

resource "aws_iam_policy" "secret" {
  name        = "secret_manager"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
               "secretsmanager:*"
            ],
            "Resource": [
                "*"
            ]
            
        }
    ]
}
EOF
}
# resource "aws_iam_policy" "secret_rotation" {
#   name        = "secret_rotation"
#   path        = "/"
#   description = "IAM policy for logging from a lambda"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Id": "default",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "secretsmanager.amazonaws.com"
#       },
#       "Action": "lambda:InvokeFunction",
#       "Resource": [
#         "aws_lambda_function.lambda.arn"
#         ]
#    } 
#   ]  
  
# }
# EOF
# }

resource "aws_iam_policy" "lambda" {
  name   = "LambdaFunctionLoggingPolicy-${var.lambda_function_name}"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_role_policy_attachment" "secret" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.secret.arn
}
# resource "aws_iam_role_policy_attachment" "secret_rotation" {
#   role       = aws_iam_role.lambda.name
#   policy_arn = aws_iam_policy.secret_rotation.arn
# }

resource "aws_lambda_function" "lambda" {
  filename      = "lambda.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  }



resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "secretsmanager.amazonaws.com"
  #source_arn    = "arn:aws:events:eu-west-1:111122223333:rule/RunDaily"
  # qualifier     = aws_lambda_alias.test_alias.name
}
