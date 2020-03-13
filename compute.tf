// Retrieving image from market place. First we need to get the EULA agreement and sign it

resource "oci_core_app_catalog_listing_resource_version_agreement" "sdwan_agreement" {
  listing_id               = var.sdwan_listing_id
  listing_resource_version = var.sdwan_listing_version
}

resource "oci_core_app_catalog_subscription" "sdwan_image_subscription" {
  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.sdwan_agreement.eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.sdwan_agreement.listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.sdwan_agreement.listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.sdwan_agreement.oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.sdwan_agreement.signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.sdwan_agreement.time_retrieved

  timeouts {
    create = "20m"
  }
}

// Then we subscribe to the image with the desired version to get this avilable to deploy a compute instance

data "oci_core_app_catalog_subscriptions" "sdwan_image_subscription" {
  compartment_id  = var.compartment_ocid
  listing_id      = var.sdwan_listing_id

  filter {
    name   = "listing_resource_version"
    values = [ var.sdwan_listing_version ]
  }
}

// Finally we can deploy the image

resource "oci_core_instance" "sdwan_edge" {
    #Required
    availability_domain   = local.sdwan_availability_domain
    compartment_id        = var.compartment_ocid
    shape                 = var.sdwan_vm_shape
    display_name          = "sdwan-edge"

    create_vnic_details {
        subnet_id     = oci_core_subnet.mgmt.id
        display_name  = "sdwan_vnic_mgmt"
        nsg_ids       = [ oci_core_network_security_group.mgmt.id ]
    }

    source_details {
        source_id = oci_core_app_catalog_subscription.sdwan_image_subscription.listing_resource_id
        source_type = "image"
    }

    launch_options {
        network_type = "VFIO"
    }   

}

resource "oci_core_vnic_attachment" "public_vnic" {
    create_vnic_details {
        subnet_id     = oci_core_subnet.public.id
        display_name  = "sdwan_vnic_public"
        nsg_ids       = [ oci_core_network_security_group.public.id ]
    }
    instance_id = oci_core_instance.sdwan_edge.id
}

resource "oci_core_vnic_attachment" "private_vnic" {
    create_vnic_details {
        subnet_id               = oci_core_subnet.private.id
        display_name            = "sdwan_vnic_private"
        nsg_ids                 = [ oci_core_network_security_group.private.id ]
        skip_source_dest_check  = true
        assign_public_ip        = false
    }
    instance_id = oci_core_instance.sdwan_edge.id
}

// Looks like IPs are not returned as attribute with oci_core_vnic_attachment, getting them as data

data "oci_core_vnic" "public_vnic_data" {
  vnic_id     = oci_core_vnic_attachment.public_vnic.vnic_id
}

data "oci_core_vnic" "private_vnic_data" {
  vnic_id     = oci_core_vnic_attachment.private_vnic.vnic_id
}