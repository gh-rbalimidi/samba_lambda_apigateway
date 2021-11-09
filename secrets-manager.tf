resource "aws_secretsmanager_secret" "auth" {
  name = "auth6"
}

resource "aws_secretsmanager_secret_rotation" "auth" {
  secret_id           = aws_secretsmanager_secret.auth.id
  rotation_lambda_arn = aws_lambda_function.lambda.arn

  rotation_rules {
    automatically_after_days = 30
  }
}