resource "aws_codebuild_project" "lvn-tf-plan" {
  name          = "lvn-tf-cicd-plan2"
  description   = "Plan stage for terraform"
  service_role  = aws_iam_role.lvn-tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/plan-buildspec.yml")
 }
}

resource "aws_codebuild_project" "lvn-tf-apply" {
  name          = "lvn-tf-cicd-apply"
  description   = "Apply stage for terraform"
  service_role  = aws_iam_role.lvn-tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/apply-buildspec.yml")
 }
}


resource "aws_codepipeline" "lvn-cicd_pipeline" {

    name = "lvn-tf-cicd"
    role_arn = aws_iam_role.lvn-tf-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.lvn-codepipeline-artifacts.id
    }

    stage {
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["lvn-tf-code"]
            configuration = {
                FullRepositoryId = "tuan010/aws-cicd-pipeline"
                BranchName   = "master"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Plan"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["lvn-tf-code"]
            configuration = {
                ProjectName = "lvn-tf-cicd-plan"
            }
        }
    }

    stage {
        name ="Deploy"
        action{
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["lvn-tf-code"]
            configuration = {
                ProjectName = "lvn-tf-cicd-apply"
            }
        }
    }

}