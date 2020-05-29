# Create SCS NIC
resource "azurerm_network_interface" "nics-scs" {
  name                          = "scs-nic-1"
  location                      = var.resource-group[0].location
  resource_group_name           = var.resource-group[0].name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "scs-nic-1-ip"
    subnet_id                     = "TBC"
    private_ip_address            = "10.1.3.10"
    private_ip_address_allocation = "static"
  }
}

# Associate NIC with
resource "azurerm_network_interface_security_group_association" "nic-scs-nsg" {
  network_interface_id      = azurerm_network_interface.nics-scs.id
  network_security_group_id = "TBC"
}

# TODO: Load Balancer
resource "azurerm_lb" "scs-lb" {
  name                = "scs-${locals.sid}-lb"
  resource_group_name = var.resource-group[0].name
  location            = var.resource-group[0].location

  frontend_ip_configuration {
    name                          = "scs-${locals.sid}-lb-feip"
    subnet_id                     = var.subnet-sap-db[0].id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.3.5"
  }
}

resource "azurerm_lb_backend_address_pool" "scs-lb-back-pool" {
  resource_group_name = var.resource-group[0].name
  loadbalancer_id     = azurerm_lb.scs-lb.id
  name                = "scs-${locals.sid}-lb-bep"
}

resource "azurerm_lb_probe" "scs-lb-health-probe" {
  resource_group_name = var.resource-group[0].name
  loadbalancer_id     = azurerm_lb.scs-lb.id
  name                = "scs-${locals.sid}-lb-hp"
  port                = "620${var.scs_instance_number}"
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# TODO: LB Rules


# TODO: LB/NIC Association


# TODO: Availability Set


# TODO: VM(s)


# TODO: Disk(s)


# TODO: Disk Attachment


# TODO: NIC Attachment
