terraform {
  backend "gcs" {
    bucket  = "tf-state-dev-ggj-gke-testing"
    prefix  = "terraform/gke"
  }
}

