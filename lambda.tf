data "archive_file" "lambda-archive" {
  type        = "zip"
  source_file = "tides/tide.py"
  output_path = "tides/packages/lambda_function.zip"
}

resource "aws_lambda_function" "tides-ical" {
  filename         = "tides/packages/lambda_function.zip"
  function_name    = "time-and-tide"
  role             = aws_iam_role.role_for_lambda.arn
  handler          = "tide.handler"
  source_code_hash = data.archive_file.lambda-archive.output_base64sha256
  runtime          = "python3.7"
  timeout          = 15
  memory_size      = 128
  layers           = [aws_lambda_layer_version.python3-10-requirements-layer.arn]
}

resource "aws_lambda_layer_version" "python3-10-requirements-layer" {
  filename            = "tides/packages/Python3-10.zip"
  layer_name          = "Python3-10-tides"
  source_code_hash    = filebase64sha256("tides/packages/Python3-10.zip")
  compatible_runtimes = ["python3.6", "python3.7"]

  provisioner "local-exec" {
    command = "tides/build.sh"
  }
}
