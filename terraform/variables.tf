variable "github_repo_url" {
  type        = string
  default     = "https://github.com/VictorAGuerra/AWS-CI-CD"
}

variable "github_owner" {
  type    = string
  default = "VictorAGuerra"
}

variable "github_repo" {
  type    = string
  default = "AWS-CI-CD"
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token"
}

variable "ecr_repo_name" {
  type    = string
  default = "ecr-app"
}

variable "pipeline_name" {
  type    = string
  default = "app-pipeline"
}

variable "codebuild_service_role" {
  type    = string
  default = "arn:aws:iam::325583868777:role/service-role/codebuild-asn-demo-lab-service-role"
}
