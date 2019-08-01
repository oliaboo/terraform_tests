provider "google" {
  credentials = "/home/boo/Downloads/scalr-development-ca0dcdb80414.json"
  project     = "scalr-labs"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}


resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "n1-standard-1"
  zone         = "asia-northeast1"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "gce-uefi-images/windows-1803-core"
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_network" "default" {
  name                    = "test-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = "test-network"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "us-central1-a"
  private_ip_google_access = true
}

data "google_client_config" "current" {}

data "google_container_engine_versions" "default" {
  project = "scalr-labs"
  zone = "us-central1-a"
}


resource "google_container_cluster" "terraform_cluster_1" {
  name               = "test-network"
  zone               = "us-central1-a"
  initial_node_count = 1
  network            = "${google_compute_subnetwork.default.name}"
  subnetwork         = "${google_compute_subnetwork.default.name}"
  enable_legacy_abac = true
  remove_default_node_pool = true

  provisioner "local-exec" {
    when    = "destroy"
    command = "sleep 90"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = "${google_container_cluster.terraform_cluster_1.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_disk" "default" {
  name  = "test-disk"
  labels = {
    environment = "dev"
  }
  image = "gce-uefi-images/windows-1803-core"
  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "custom" {
  name         = "test_custom"
  machine_type = "custom-6-23040"
  zone         = "us-east1"

  tags = ["zzz"]

  boot_disk {
    initialize_params {
      type = "pd-ssd"
      size = 10
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
  }
}
