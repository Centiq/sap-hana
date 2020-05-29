variable "resource-group" {
  description = "Details of the resource group"
}

variable "subnet-app" {
  description = "Details of the SAP Application subnet"
}

variable "nsg-app" {
  description = "Details of the SAP Application subnet NSG"
}

variable "scs-instance-number" {
  description = "Instance Number for the SCS instance"
  default = "01"
}

variable "ers-instance-number" {
  description = "Instance Number for the ERS instance in HA deployments"
  default = "02"
}

locals {
  # Filter the list of databases to only HANA platform entries
  hana-databases = [
    for database in var.databases : database
    if database.platform == "HANA"
  ]

  sid = locals.hana-databases[0].instance.sid

  # Ports used for specific ASCS and ERS
  lb-ports = {
    "scs" = [
      3200 + tonumber(var.scs-instance-number),           # e.g. 3201
      3600 + tonumber(var.scs-instance-number),           # e.g. 3601
      3900 + tonumber(var.scs-instance-number),           # e.g. 3901
      8100 + tonumber(var.scs-instance-number),           # e.g. 8101
      50013 + (tonumber(var.scs-instance-number) * 100),  # e.g. 50113
      50014 + (tonumber(var.scs-instance-number) * 100),  # e.g. 50114
      50016 + (tonumber(var.scs-instance-number) * 100),  # e.g. 50116
    ]

    "ers" = [
      3200 + tonumber(var.ers-instance-number),          # e.g. 3202
      3300 + tonumber(var.ers-instance-number),          # e.g. 3302
      50013 + (tonumber(var.ers-instance-number) * 100), # e.g. 50213
      50014 + (tonumber(var.ers-instance-number) * 100), # e.g. 50214
      50016 + (tonumber(var.ers-instance-number) * 100), # e.g. 50216
    ]
  }

  # TODO: logic for generating instance number specific ports
}
