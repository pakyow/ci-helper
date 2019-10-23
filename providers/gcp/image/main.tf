provider "google" {
  # credentials expected through GOOGLE_CREDENTIALS envar
  project = "${var.gcp_project}"
  region = "${var.gcp_region}"
}

module "image" {
  source = "../modules/image"

  family = "${var.image_family}"
  name = "${var.image_name}"
  source_disk_url = "${var.source_disk_url}"
}
