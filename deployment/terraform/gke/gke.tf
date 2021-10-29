data "google_project" "project" {
}

data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket  = "tf-state-dev-ggj-gke-testing"
    prefix  = "terraform/vpc"
  }
}

# TODO: Read https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account
resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}


resource "google_container_cluster" "primary" {
  name               = "my-test-cluster"
  location           = "us-central1-a"

  network    = data.terraform_remote_state.vpc.outputs.primary_network_id
  subnetwork = data.terraform_remote_state.vpc.outputs.k8s_subnet_id

  ip_allocation_policy {
    cluster_secondary_range_name  = data.terraform_remote_state.vpc.outputs.k8s_ranges.service_range
    services_secondary_range_name = data.terraform_remote_state.vpc.outputs.k8s_ranges.pod_range
  }

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

# TODO: https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms
# TODO: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  cluster    = google_container_cluster.primary.name
  node_count = 2

  location           = "us-central1-a"
  node_locations = ["us-central1-a", "us-central1-b"]

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
