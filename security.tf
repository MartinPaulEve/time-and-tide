resource "aws_iam_role" "role_for_lambda" {
  name = "role-lambda"

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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_attachement" {
  role       = aws_iam_role.role_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "aws_arn" "api_gw_deployment_arn" {
    arn = module.api-gateway.execution_arn
}

resource "aws_lambda_permission" "apigw-post" {
    statement_id  = "AllowAPIGatewayInvokePOST"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.tides-ical.function_name
    principal     = "apigateway.amazonaws.com"

    // "arn:aws:execute-api:us-east-1:473097069755:708lig5xuc/dev/POST1/cloudability-church-ws"
    //source_arn = "arn:aws:execute-api:${data.aws_arn.api_gw_deployment_arn.region}:${data.aws_arn.api_gw_deployment_arn.account}:${module.api-gateway.id}/*/POST/ical"
}