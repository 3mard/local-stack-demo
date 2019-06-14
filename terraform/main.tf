provider "aws" {
  access_key                  = "mock_access_key"
  region                      = "us-east-1"
  s3_force_path_style         = true
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4567"
    cloudformation = "http://localhost:4581"
    cloudwatch     = "http://localhost:4582"
    dynamodb       = "http://localhost:4569"
    es             = "http://localhost:4578"
    firehose       = "http://localhost:4573"
    iam            = "http://localhost:4593"
    kinesis        = "http://localhost:4568"
    lambda         = "http://localhost:4574"
    route53        = "http://localhost:4580"
    redshift       = "http://localhost:4577"
    s3             = "http://localhost:4572"
    secretsmanager = "http://localhost:4584"
    ses            = "http://localhost:4579"
    sns            = "http://localhost:4575"
    sqs            = "http://localhost:4576"
    ssm            = "http://localhost:4583"
    stepfunctions  = "http://localhost:4585"
    sts            = "http://localhost:4592"
  }
}

data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "sfn_assume_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["states.eu-west-1.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_add" {
  name               = "iam_for_lambda_add"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_policy.json}"
}

resource "aws_iam_role" "iam_for_lambda_square" {
  name               = "iam_for_lambda_square"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_policy.json}"
}

resource "aws_iam_role" "iam_for_sfn" {
  name               = "iam_for_sfn"
  assume_role_policy = "${data.aws_iam_policy_document.sfn_assume_policy.json}"
}

resource "aws_iam_role_policy_attachment" "lambda-invocation" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

resource "aws_lambda_function" "add_lambda" {
  filename      = "${path.cwd}/../dist/local-stack-take-one.zip"
  function_name = "add"
  role          = "${aws_iam_role.iam_for_lambda_add.arn}"
  handler       = "index.add"

  runtime = "nodejs8.10"
}

resource "aws_lambda_function" "square_lambda" {
  filename      = "${path.cwd}/../dist/local-stack-take-one.zip"
  function_name = "square"
  role          = "${aws_iam_role.iam_for_lambda_square.arn}"
  handler       = "index.square"

  runtime = "nodejs8.10"
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = "${aws_iam_role.iam_for_sfn.arn}"

  definition = <<EOF
{
  "Comment": "my cool step functiond",
  "StartAt": "AddNumbers",
  "States": {
    "AddNumbers": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.add_lambda.arn}",
      "Next":"SquareNumber"
    },
    "SquareNumber": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.square_lambda.arn}",
      "End": true
    }
  }
}
EOF
}
