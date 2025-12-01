# -------------------------------------------
# RANDOM ID FOR UNIQUE BUCKET NAME
# -------------------------------------------
resource "random_id" "bucket_id" {
  byte_length = 4
}

# -------------------------------------------
# S3 BUCKET FOR CODEPIPELINE ARTIFACTS
# -------------------------------------------
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket        = "pipeline-bucket-${random_id.bucket_id.hex}"
  force_destroy = true
}

# -------------------------------------------
# ECR REPOSITORY
# -------------------------------------------
resource "aws_ecr_repository" "ecr_app" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# -------------------------------------------
# CODEBUILD PROJECT (BUILD PHASE)
# -------------------------------------------
resource "aws_codebuild_project" "build_project" {
  name         = "build-project-app"
  service_role = var.codebuild_service_role   # ROLE FORNECIDA PELO PROFESSOR

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type      = "GITHUB"
    location  = var.github_repo_url
    buildspec = "buildspec-build.yml"
  }
}

# -------------------------------------------
# CODEBUILD PROJECT (DEPLOY PHASE)
# -------------------------------------------
resource "aws_codebuild_project" "deploy_project" {
  name         = "deploy-project-app"
  service_role = var.codebuild_service_role   # ROLE FORNECIDA PELO PROFESSOR

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "GITHUB"
    location  = var.github_repo_url
    buildspec = "buildspec-deploy.yml"
  }
}

# -------------------------------------------
# CODEPIPELINE (USANDO A MESMA ROLE DO CODEBUILD)
# -------------------------------------------
resource "aws_codepipeline" "app_pipeline" {
  name     = var.pipeline_name
  role_arn = var.codebuild_service_role   # ← ESSA É A CORREÇÃO IMPORTANTE!

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = "main"
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "CodeBuild_Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "CodeBuild_Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_project.name
      }
    }
  }
}
