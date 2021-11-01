
data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket  = "tf-state-dev-ggj-gke-testing"
    prefix  = "terraform/vpc"
  }
}

