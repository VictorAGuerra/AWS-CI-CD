output "pipeline_bucket" {
  value = aws_s3_bucket.pipeline_bucket.bucket
}

output "ecr_repo_url" {
  value = aws_ecr_repository.ecr_app.repository_url
}

output "pipeline_name" {
  value = aws_codepipeline.app_pipeline.name
}
