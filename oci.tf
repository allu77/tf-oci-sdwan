provider "oci" {
  tenancy_ocid      = var.tenancy_ocid
  user_ocid         = var.user_ocid
  fingerprint       = var.fingerprint
  private_key_path  = var.private_key_path
  region            = var.region
}


data "oci_identity_availability_domains" "oci_ads" {
    compartment_id = var.compartment_ocid
}

locals {
  sdwan_availability_domain = data.oci_identity_availability_domains.oci_ads.availability_domains[var.sdwan_availability_domain].name
}
