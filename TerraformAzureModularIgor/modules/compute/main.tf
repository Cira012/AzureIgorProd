resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = var.ssh_key_bits
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.resource_group_name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.resource_group_name}-vm"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B2s"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "bootstrap" {
  name               = "bootstrap-script-v2"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
{}
SETTINGS

  protected_settings = <<PROTECTED
{
  "script": "${base64encode(file("${path.root}/scripts/bootstrap_site.sh"))}"
}
PROTECTED
}
