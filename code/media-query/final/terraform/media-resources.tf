resource "random_id" "resource_names" {
  byte_length = 8
  prefix = "media-query-"
}


resource "aws_s3_bucket" "media_bucket" {
  bucket_prefix = "media-query"
}

resource "aws_dynamodb_table" "media_table" {
  name = "${random_id.resource_names.dec}"
  hash_key = "name"
  attribute {
    name = "name"
    type = "S"
  }
  read_capacity = 5
  write_capacity = 5
}


resource "aws_sns_topic" "video_topic" {
}

resource "aws_iam_role_policy" "media_policy" {
  name = "media_policy"
  role = "${aws_iam_role.media_role.id}"

  policy = "${data.aws_iam_policy_document.allow_publish.json}"
}

resource "aws_iam_role" "media_role" {
  name_prefix = "media-query-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rekognition.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "allow_publish" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [
      "${aws_sns_topic.video_topic.id}",
    ]

  }
}
