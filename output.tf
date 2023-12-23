output "public_ip" {
  value = azurerm_linux_virtual_machine.this.public_ip_address
}
