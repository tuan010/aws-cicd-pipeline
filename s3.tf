resource "aws_s3_bucket" "lvn-codepipeline-artifacts" {
  bucket = "lvn-pipeline-artifacts"
  acl = "private"
}