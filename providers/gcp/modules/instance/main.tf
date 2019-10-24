variable "disk_size_gb" {
  default = 10
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "name" {
}

variable "region" {
}

variable "ssh_public_key" {
}

variable "ssh_user" {
  default = "root"
}

variable "source_image" {
  default = "ubuntu-1804-lts"
}

variable "zone" {
  default = "a"
}

resource "google_compute_instance" "default" {
  name         = "${var.name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region}-${var.zone}"

  boot_disk {
    initialize_params {
      size = "${var.disk_size_gb}"
      image = "${var.source_image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // ephemeral
    }
  }

  scheduling {
    automatic_restart = false
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

