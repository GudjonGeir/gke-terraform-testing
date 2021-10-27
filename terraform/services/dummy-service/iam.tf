locals {
  k8s_namespace = "application"
  ksa_name = "dummy-service"
}

data "google_project" "project" {
}

resource "google_service_account" "service_account" {
  account_id   = "dummy-service"
  display_name = "Dummy Service"
}


resource "google_project_iam_binding" "project" {
  project = data.google_project.project.id
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.service_account.name
  role               = "roles/iam.serviceAccountUser"

  members = [
   "serviceAccount:${data.google_project.project.id}.svc.id.goog[${local.k8s_namespace}/${local.ksa_name}]",
  ]
}

