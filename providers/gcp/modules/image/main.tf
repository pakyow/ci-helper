variable "family" {
}

variable "name" {
}

variable "source_disk_url" {
}

resource "google_compute_image" "example" {
  family = "${var.family}"
  name = "${var.name}"
  source_disk = "${var.source_disk_url}"
}
