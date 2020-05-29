variable "resource-group" {
  description = "Details of the resource group"
}

variable "subnet-app" {
  description = "Details of the SAP Application subnet"
}

variable "nsg-app" {
  description = "Details of the SAP Application subnet NSG"
}

locals {
  # Filter the list of databases to only HANA platform entries
  hana-databases = [
    for database in var.databases : database
    if database.platform == "HANA"
  ]

  sid = locals.hana-databases[0].instance.sid

  # Ports used for specific ASCS and ERS
  scs_lb_ports = {
    "scs" = [
      "3200",
      "3600",
      "3900",
      "8100",
      "50013",
      "50014",
      "50016",
    ]

    "ers" = [
      "3200",
      "3300",
      "50013",
      "50014",
      "50016",
    ]
  }

  # TODO: logic for generating instance number specific ports
}
