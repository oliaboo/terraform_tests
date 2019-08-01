variable "image_id" {
  type = string
}

resource "google_compute_disk" "non-default" {
  name  = "test-disk"
  labels = {
    environment = "dev"
  }
  image = "gce-uefi-images/windows-1803-core"
  physical_block_size_bytes = 4096
}
