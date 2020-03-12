locals {
    vcn_ocid = var.vcn_ocid == "" ? oci_core_vcn.sdwan_vcn[0].id : var.vcn_ocid
}

resource "oci_core_vcn" "sdwan_vcn" {
    count           = var.vcn_ocid == "" ? 1 : 0

    cidr_block      = var.vcn_cidr
    compartment_id  = var.compartment_ocid
    display_name    = "sdwan-vcn"
}




resource "oci_core_internet_gateway" "internet_gateway" {
    count           = var.vcn_ocid == "" ? 1 : 0

    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-igw"
    enabled         = true
}




resource "oci_core_route_table" "public" {
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-route-public"

    route_rules {
        network_entity_id   = oci_core_internet_gateway.internet_gateway[0].id
        destination         = "0.0.0.0/0"
        destination_type    = "CIDR_BLOCK"
        description         = "Default route for internet access"
    }
}

resource "oci_core_route_table" "private" {
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-route-private"
}




resource "oci_core_network_security_group" "mgmt" {
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-nsg-mgmt"
}

resource "oci_core_network_security_group_security_rule" "mgmt_ssh" {
    #Required
    network_security_group_id   = oci_core_network_security_group.mgmt.id
    description                 = "Inbound SSH"

    direction                   = "INGRESS"
    protocol                    = "6"

    destination                 = var.subnet_mgmt_cidr
    destination_type            = "CIDR_BLOCK"

    source                      = "0.0.0.0/0"
    source_type                 = "CIDR_BLOCK"

    stateless                   = false

    tcp_options {

        destination_port_range {
            max = "22"
            min = "22"
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_http" {
    #Required
    network_security_group_id   = oci_core_network_security_group.mgmt.id
    description                 = "Inbound HTTP"

    direction                   = "INGRESS"
    protocol                    = "6"

    destination                 = var.subnet_mgmt_cidr
    destination_type            = "CIDR_BLOCK"

    source                      = "0.0.0.0/0"
    source_type                 = "CIDR_BLOCK"

    stateless                   = false

    tcp_options {

        destination_port_range {
            max = "80"
            min = "80"
        }
    }
}

resource "oci_core_network_security_group_security_rule" "mgmt_https" {
    #Required
    network_security_group_id   = oci_core_network_security_group.mgmt.id
    description                 = "Inbound HTTPS"

    direction                   = "INGRESS"
    protocol                    = "6"

    destination                 = var.subnet_mgmt_cidr
    destination_type            = "CIDR_BLOCK"

    source                      = "0.0.0.0/0"
    source_type                 = "CIDR_BLOCK"

    stateless                   = false

    tcp_options {

        destination_port_range {
            max = "443"
            min = "443"
        }
    }
}





resource "oci_core_network_security_group" "public" {
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-nsg-public"
}

resource "oci_core_network_security_group_security_rule" "public_trp_in" {
    #Required
    network_security_group_id   = oci_core_network_security_group.public.id
    description                 = "Talari Reliable Protocol"

    direction                   = "INGRESS"
    protocol                    = "17"

    destination                 = "0.0.0.0/0"
    destination_type            = "CIDR_BLOCK"

    source                      = var.subnet_public_cidr
    source_type                 = "CIDR_BLOCK"

    stateless                   = true

    udp_options {

        destination_port_range {
            max = "2156"
            min = "2156"
        }
    }
}


resource "oci_core_network_security_group_security_rule" "public_trp_out" {
    #Required
    network_security_group_id   = oci_core_network_security_group.public.id
    description                 = "Talari Reliable Protocol"

    direction                   = "EGRESS"
    protocol                    = "17"

    destination                 = var.subnet_public_cidr
    destination_type            = "CIDR_BLOCK"

    source                      = "0.0.0.0/0"
    source_type                 = "CIDR_BLOCK"

    stateless                   = true

    udp_options {

        source_port_range {
            max = "2156"
            min = "2156"
        }
    }
}



















resource "oci_core_subnet" "mgmt" {
    cidr_block      = var.subnet_mgmt_cidr
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-mgmt"
    route_table_id  = oci_core_route_table.public.id
}

resource "oci_core_subnet" "public" {
    cidr_block      = var.subnet_public_cidr
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-public"
    route_table_id  = oci_core_route_table.public.id
}

resource "oci_core_subnet" "private" {
    cidr_block      = var.subnet_private_cidr
    compartment_id  = var.compartment_ocid
    vcn_id          = local.vcn_ocid
    display_name    = "sdwan-private"
    route_table_id  = oci_core_route_table.private.id

    prohibit_public_ip_on_vnic = true
}

