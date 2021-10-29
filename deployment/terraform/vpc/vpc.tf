resource "google_compute_network" "primary" {
  name                    = "primary"
  auto_create_subnetworks = false
}

locals {
  k8s_services_range_name = "services-range"
  k8s_pod_range_name = "pod-range"
}
resource "google_compute_subnetwork" "kubernetes_subnet" {
  name          = "kubernetes-subnet"
  ip_cidr_range = "10.2.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.primary.id
  secondary_ip_range {
    range_name    = local.k8s_services_range_name
    ip_cidr_range = "192.168.64.0/20"
  }

  secondary_ip_range {
    range_name    = local.k8s_pod_range_name
    ip_cidr_range = "192.168.128.0/18"
  }
}

