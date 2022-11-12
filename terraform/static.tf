resource "aws_s3_bucket" "site" {
  bucket = local.site_bucket
  tags = {
    project = var.project
  }
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.bucket
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }

}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.bucket
  policy = jsonencode({
    Statement = [{
      Action = ["s3:GetObject"],
      Effect = "Allow",
      Resource = ["${aws_s3_bucket.site.arn}/*"]
      Principal = {
        AWS = ["*"]
      }
    }]
  })
}

resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.site.id
  acl = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "site" {
  bucket = aws_s3_bucket.site.bucket
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["https://${var.root_domain}", "https://www.${var.root_domain}"]
  }
}

resource "aws_cloudfront_function" "index" {
  name = "${var.project}AppendIndex"
  runtime = "cloudfront-js-1.0"
  code = file("../lambda/index.js")
  publish = true
}

resource "aws_cloudfront_distribution" "site" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id = local.origin
  }
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  custom_error_response {
    error_code = 404
    response_code = 404
    response_page_path = "/404.html"
  }
  aliases = [var.root_domain,"www.${var.root_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    function_association {
      event_type = "viewer-request"
      function_arn = aws_cloudfront_function.index.arn
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  tags = {
    project = var.project
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
    acm_certificate_arn = aws_acm_certificate_validation.site.certificate_arn
  }
}
