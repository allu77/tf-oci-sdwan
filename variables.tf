// Authentication

variable tenancy_ocid {
  type        = string
  description = "The OCID of the tenant we need to deploy to"
}

variable user_ocid {
  type        = string
  description = "The OCID of the user deploying the SD-WAN node"
}

variable private_key_path {
  type        = string
  description = "Path of the user's private key on this file system"
}

variable fingerprint {
  type        = string
  description = "fingerprint of the user's public key as uploaded to OCI"
}

variable region {
  type        = string
  description = "OCI region where the SD-WAN node will be deployed"
}

variable compartment_ocid {
  type        = string
  description = "Compartment to which all the created resrouces will be attached"
}





// Networking

variable vcn_ocid {
  type        = string
  description = "OCID of the VCN where the SD-WAN node will be deployed. A new one will be created if not provided"
  default     = ""
}

variable vcn_cidr {
  type        = string
  description = "CIDR of the VCN that will be created to deploy  the SD-WAN node"
  default     = "172.31.15.0/28"
}

variable subnet_mgmt_cidr {
  type        = string
  description = "CIDR of the management VCN that will be created to deploy the SD-WAN node"
  default     = "172.31.15.0/30"
}

variable subnet_public_cidr {
  type        = string
  description = "CIDR of the management VCN that will be created to deploy the SD-WAN node"
  default     = "172.31.15.4/30"
}

variable subnet_private_cidr {
  type        = string
  description = "CIDR of the management VCN that will be created to deploy the SD-WAN node"
  default     = "172.31.15.8/30"
}





// Overridable defaults

variable sdwan_listing_id { 
  type        = string
  description = "OCID of the Oracle SD-WAN Edge listing on OCI marketplace"
  default = "ocid1.appcataloglisting.oc1..aaaaaaaaxzf5m5xhk5rwovcq2237qrr2nsp6jfxm4posvpv4rwlm74zn6fba"
}

variable sdwan_listing_version { 
  type        = string
  description = "Software version of the SD-WAN node to deploy"
  default = "8.2.1.0.0"
}

variable sdwan_availability_domain {
  type        = number
  description = "Availabily domain where Oracle SD-WAN Edge will be delivered - Index withing the available ADs, starting from 0"
  default     = 0
}

variable sdwan_vm_shape {
  type        = string
  description = "VM Shape for the SD-WAN Edge instance"
  default     = "VM.Standard2.4"
}

variable sdwan_dedicated_private_vnic {
  type        = bool
  description = "Whether to have a 2 tiers network layout (default) or a single tier (i.e. public and private on the same interface)"
  default     = true
}