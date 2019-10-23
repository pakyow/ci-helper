provider "google" {
  # credentials expected through GOOGLE_CREDENTIALS envar
  project = "${var.gcp_project}"
  region = "${var.gcp_region}"
}

module "instance" {
  source = "../modules/instance"

  name = "${var.instance_name}"
  region = "${var.gcp_region}"
  ssh_public_key = "${var.ssh_public_key}"
  source_image = "${var.source_image}"
}
