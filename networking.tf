locals {
    vcn_ocid = var.vcn_ocid == "" ? oci_core_vcn.sdwan_vcn[0].id : var.vcn_ocid
}

resource "oci_core_vcn" "sdwan_vcn" {
    count           = var.vcn_ocid == "" ? 1 : 0

    cidr_block      = var.vcn_cidr
    compartment_id  = var.compartment_ocid
    display_name    = "sdwan-vcn"
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
    count           = var.vcn_ocid == "" ? 1 : 0

    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-igw"
    enabled         = true
}

resource "oci_core_subnet" "mgmt" {
    cidr_block      = var.subnet_mgmt_cidr
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-mgmt"
}

resource "oci_core_subnet" "public" {
    cidr_block      = var.subnet_public_cidr
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-public"
}

resource "oci_core_subnet" "private" {
    cidr_block      = var.subnet_private_cidr
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-private"

    prohibit_public_ip_on_vnic = true
}

