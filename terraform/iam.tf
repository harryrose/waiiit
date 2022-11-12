resource "aws_iam_user" "ci" {
  name = "ci.${var.root_domain}"
  tags = {
    project = var.project
  }
}

resource "aws_iam_access_key" "ci" {
  user = aws_iam_user.ci.name
}

resource "aws_iam_user_policy_attachment" "ci" {
  user = aws_iam_user.ci.name
  policy_arn = aws_iam_policy.ci.arn
}

resource "aws_iam_policy" "ci" {
  name = "ci.${var.root_domain}"
  description = "policy allowing access required for ci/cd"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject",
        "s3:DeleteObjects",
        "s3:ListObjects",
        "s3:ListObjectsV2"
      ],
      Resource = [
        aws_s3_bucket.site.arn,
        "${aws_s3_bucket.site.arn}/*"
      ]
    },{
      Effect = "Allow"
      Action = [
        "cloudfront:CreateInvalidation"
      ],
      Resource = [
        aws_cloudfront_distribution.site.arn
      ]
    }]
  })
}