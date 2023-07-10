resource "azurerm_resource_group" "ntier" {
    name = var.resourcegroup_details.name
    location = var.resourcegroup_details.location
}
resource "azurerm_linux_virtual_machine" "aws" {
  resource_group_name = var.resourcegroup_details.name
  location            = var.resourcegroup_details.location
  name = format("aws-%s",terraform.workspace)
  size = "Standard_B1s"
  admin_username = "qtdevops"
  admin_password = "qttesting@1234"
  network_interface_ids = [
    azurerm_network_interface.web_nic.id
  ]
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

}
resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    version = "1.4"
  }
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y"
    ]

    connection {
     host = azurerm_linux_virtual_machine.aws.public_ip_address
     user = "qtdevops"
     password = "qttesting@1234"

    }
  }

  depends_on = [
    azurerm_linux_virtual_machine.aws
  ]
}  



  