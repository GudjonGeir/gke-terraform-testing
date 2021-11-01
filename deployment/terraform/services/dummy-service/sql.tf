resource "google_compute_global_address" "private_ip_address" {
  # provider = google-beta

  name          = "dummy-sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.terraform_remote_state.vpc.outputs.primary_network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  # provider = google-beta

  network                 = data.terraform_remote_state.vpc.outputs.primary_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  # provider = google-beta

  name   = "dummy-db"
  region = "us-central1"
  database_version = "POSTGRES_13"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = data.terraform_remote_state.vpc.outputs.primary_network_id
    }
  }
}

resource "google_sql_user" "users" {
  name     = "dummy-service"
  instance = google_sql_database_instance.instance.name
  password = "this-needs-to-be-changed"
}
