
output "k8s_ranges" {
  value = {
    service_range = local.k8s_services_range_name 
    pod_range = local.k8s_pod_range_name 
  }
}

output "primary_network_id" {
  value    = google_compute_network.primary.id
}

output "k8s_subnet_id" {
  value = google_compute_subnetwork.kubernetes_subnet.id
}
