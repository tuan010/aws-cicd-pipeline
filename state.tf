terraform {
    backend "s3" {
        bucket = "lvn-aws-cicd-pipeline"
        encrypt = true
        key =  "terraform.tfstate"
        region = "ap-northeast-1"
        access_key = "AKIAQIPNDBF5I3QBJGVN"
        secret_key = "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"
    }
}