resource "aws_s3_bucket" "fitness_images_terraform" {
  bucket = "fitness-app-images-terraform-2026"

  tags = {
    Name = "fitness-images-terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "fitness_images_access" {
  bucket                  = aws_s3_bucket.fitness_images_terraform.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "fitness_images_policy" {
  bucket = aws_s3_bucket.fitness_images_terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.fitness_images_terraform.arn}/*"
    }]
  })
}

resource "aws_s3_bucket" "fitness_thumbnails" {
  bucket        = "fitness-thumbnails-terraform-2026"
  force_destroy = true

  tags = {
    Name = "fitness-thumbnails"
  }
}

resource "aws_s3_bucket_public_access_block" "thumbnails_access" {
  bucket                  = aws_s3_bucket.fitness_thumbnails.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "thumbnails_policy" {
  bucket     = aws_s3_bucket.fitness_thumbnails.id
  depends_on = [aws_s3_bucket_public_access_block.thumbnails_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.fitness_thumbnails.arn}/*"
    }]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "fitness-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "thumbnail_generator" {
  function_name = "fitness-thumbnail-generator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = "lambda.zip"

  timeout     = 30
  memory_size = 256

  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.fitness_thumbnails.bucket
    }
  }

  tags = {
    Name = "fitness-thumbnail-generator"
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.thumbnail_generator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.fitness_images_terraform.arn
}

resource "aws_s3_bucket_notification" "originals_trigger" {
  bucket = aws_s3_bucket.fitness_images_terraform.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.thumbnail_generator.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}