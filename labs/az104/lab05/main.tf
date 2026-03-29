terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.58.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_managed_disk" "res-0" {
  create_option                     = "FromImage"
  disk_access_id                    = ""
  disk_encryption_set_id            = ""
  disk_iops_read_only               = 0
  disk_iops_read_write              = 500
  disk_mbps_read_only               = 0
  disk_mbps_read_write              = 60
  disk_size_gb                      = 127
  edge_zone                         = ""
  gallery_image_reference_id        = ""
  hyper_v_generation                = "V2"
  image_reference_id                = "/Subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/Providers/Microsoft.Compute/Locations/SwedenCentral/Publishers/MicrosoftWindowsServer/ArtifactTypes/VMImage/Offers/WindowsServer/Skus/2025-datacenter-g2/Versions/26100.32522.260306"
  location                          = "swedencentral"
  max_shares                        = 0
  name                              = "CoreServicesVM_OsDisk_1_f5113c6ed44b4b47bc3e91190c4f7704"
  network_access_policy             = "AllowAll"
  on_demand_bursting_enabled        = false
  optimized_frequent_attach_enabled = false
  os_type                           = "Windows"
  performance_plus_enabled          = false
  public_network_access_enabled     = true
  resource_group_name               = "AZ104-RG5"
  secure_vm_disk_encryption_set_id  = ""
  security_type                     = ""
  source_resource_id                = ""
  source_uri                        = ""
  storage_account_id                = ""
  storage_account_type              = "Standard_LRS"
  tags = {
    managed-by = "az-104"
  }
  tier                   = ""
  trusted_launch_enabled = false
  upload_size_bytes      = 0
  zone                   = ""
}
resource "azurerm_managed_disk" "res-1" {
  create_option                     = "FromImage"
  disk_access_id                    = ""
  disk_encryption_set_id            = ""
  disk_iops_read_only               = 0
  disk_iops_read_write              = 500
  disk_mbps_read_only               = 0
  disk_mbps_read_write              = 60
  disk_size_gb                      = 127
  edge_zone                         = ""
  gallery_image_reference_id        = ""
  hyper_v_generation                = "V2"
  image_reference_id                = "/Subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/Providers/Microsoft.Compute/Locations/SwedenCentral/Publishers/MicrosoftWindowsServer/ArtifactTypes/VMImage/Offers/WindowsServer/Skus/2025-datacenter-g2/Versions/26100.32522.260306"
  location                          = "swedencentral"
  max_shares                        = 0
  name                              = "ManufacturingVM_OsDisk_1_3e0c9b4f76004fd089a056f374ec5cda"
  network_access_policy             = "AllowAll"
  on_demand_bursting_enabled        = false
  optimized_frequent_attach_enabled = false
  os_type                           = "Windows"
  performance_plus_enabled          = false
  public_network_access_enabled     = true
  resource_group_name               = "AZ104-RG5"
  secure_vm_disk_encryption_set_id  = ""
  security_type                     = ""
  source_resource_id                = ""
  source_uri                        = ""
  storage_account_id                = ""
  storage_account_type              = "Standard_LRS"
  tags = {
    managed-by = "az-104"
  }
  tier                   = ""
  trusted_launch_enabled = false
  upload_size_bytes      = 0
  zone                   = ""
}
resource "azurerm_windows_virtual_machine" "res-2" {
  admin_password                                         = "" # Masked sensitive attribute
  admin_username                                         = "localadmin"
  allow_extension_operations                             = true
  automatic_updates_enabled                              = true
  availability_set_id                                    = ""
  bypass_platform_safety_checks_on_user_schedule_enabled = false
  capacity_reservation_group_id                          = ""
  computer_name                                          = "CoreServicesVM"
  custom_data                                            = "" # Masked sensitive attribute
  dedicated_host_group_id                                = ""
  dedicated_host_id                                      = ""
  disk_controller_type                                   = "SCSI"
  edge_zone                                              = ""
  enable_automatic_updates                               = true
  encryption_at_host_enabled                             = false
  eviction_policy                                        = ""
  extensions_time_budget                                 = "PT1H30M"
  hotpatching_enabled                                    = false
  license_type                                           = ""
  location                                               = "swedencentral"
  max_bid_price                                          = -1
  name                                                   = "CoreServicesVM"
  network_interface_ids                                  = [azurerm_network_interface.res-4.id]
  os_managed_disk_id                                     = "/subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/resourceGroups/az104-rg5/providers/Microsoft.Compute/disks/CoreServicesVM_OsDisk_1_f5113c6ed44b4b47bc3e91190c4f7704"
  patch_assessment_mode                                  = "ImageDefault"
  patch_mode                                             = "AutomaticByOS"
  platform_fault_domain                                  = -1
  priority                                               = "Regular"
  provision_vm_agent                                     = true
  proximity_placement_group_id                           = ""
  reboot_setting                                         = ""
  resource_group_name                                    = "az104-rg5"
  secure_boot_enabled                                    = false
  size                                                   = "Standard_D2s_v3"
  source_image_id                                        = ""
  tags = {
    managed-by = "az-104"
  }
  timezone                          = ""
  user_data                         = ""
  virtual_machine_scale_set_id      = ""
  vm_agent_platform_updates_enabled = true
  vtpm_enabled                      = false
  zone                              = ""
  additional_capabilities {
    hibernation_enabled = false
    ultra_ssd_enabled   = false
  }
  os_disk {
    caching                          = "ReadWrite"
    disk_encryption_set_id           = ""
    disk_size_gb                     = 127
    name                             = "CoreServicesVM_OsDisk_1_f5113c6ed44b4b47bc3e91190c4f7704"
    secure_vm_disk_encryption_set_id = ""
    security_encryption_type         = ""
    storage_account_type             = "Standard_LRS"
    write_accelerator_enabled        = false
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}
resource "azurerm_windows_virtual_machine" "res-3" {
  admin_password                                         = "" # Masked sensitive attribute
  admin_username                                         = "localadmin"
  allow_extension_operations                             = true
  automatic_updates_enabled                              = true
  availability_set_id                                    = ""
  bypass_platform_safety_checks_on_user_schedule_enabled = false
  capacity_reservation_group_id                          = ""
  computer_name                                          = "ManufacturingVM"
  custom_data                                            = "" # Masked sensitive attribute
  dedicated_host_group_id                                = ""
  dedicated_host_id                                      = ""
  disk_controller_type                                   = "SCSI"
  edge_zone                                              = ""
  enable_automatic_updates                               = true
  encryption_at_host_enabled                             = false
  eviction_policy                                        = ""
  extensions_time_budget                                 = "PT1H30M"
  hotpatching_enabled                                    = false
  license_type                                           = ""
  location                                               = "swedencentral"
  max_bid_price                                          = -1
  name                                                   = "ManufacturingVM"
  network_interface_ids                                  = [azurerm_network_interface.res-5.id]
  os_managed_disk_id                                     = "/subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/resourceGroups/az104-rg5/providers/Microsoft.Compute/disks/ManufacturingVM_OsDisk_1_3e0c9b4f76004fd089a056f374ec5cda"
  patch_assessment_mode                                  = "ImageDefault"
  patch_mode                                             = "AutomaticByOS"
  platform_fault_domain                                  = -1
  priority                                               = "Regular"
  provision_vm_agent                                     = true
  proximity_placement_group_id                           = ""
  reboot_setting                                         = ""
  resource_group_name                                    = "az104-rg5"
  secure_boot_enabled                                    = false
  size                                                   = "Standard_D2s_v3"
  source_image_id                                        = ""
  tags = {
    managed-by = "az-104"
  }
  timezone                          = ""
  user_data                         = ""
  virtual_machine_scale_set_id      = ""
  vm_agent_platform_updates_enabled = true
  vtpm_enabled                      = false
  zone                              = ""
  additional_capabilities {
    hibernation_enabled = false
    ultra_ssd_enabled   = false
  }
  os_disk {
    caching                          = "ReadWrite"
    disk_encryption_set_id           = ""
    disk_size_gb                     = 127
    name                             = "ManufacturingVM_OsDisk_1_3e0c9b4f76004fd089a056f374ec5cda"
    secure_vm_disk_encryption_set_id = ""
    security_encryption_type         = ""
    storage_account_type             = "Standard_LRS"
    write_accelerator_enabled        = false
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }
}
resource "azurerm_network_interface" "res-4" {
  accelerated_networking_enabled = true
  auxiliary_mode                 = ""
  auxiliary_sku                  = ""
  dns_servers                    = []
  edge_zone                      = ""
  internal_dns_name_label        = ""
  ip_forwarding_enabled          = false
  location                       = "swedencentral"
  name                           = "coreservicesvm562"
  resource_group_name            = "az104-rg5"
  tags = {
    managed-by = "az-104"
  }
  ip_configuration {
    gateway_load_balancer_frontend_ip_configuration_id = ""
    name                                               = "ipconfig1"
    primary                                            = true
    private_ip_address                                 = "10.0.0.4"
    private_ip_address_allocation                      = "Dynamic"
    private_ip_address_version                         = "IPv4"
    public_ip_address_id                               = ""
    subnet_id                                          = "/subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/resourceGroups/az104-rg5/providers/Microsoft.Network/virtualNetworks/CoreServicesVnet/subnets/Core"
  }
}
resource "azurerm_network_interface" "res-5" {
  accelerated_networking_enabled = true
  auxiliary_mode                 = ""
  auxiliary_sku                  = ""
  dns_servers                    = []
  edge_zone                      = ""
  internal_dns_name_label        = ""
  ip_forwarding_enabled          = false
  location                       = "swedencentral"
  name                           = "manufacturingvm331"
  resource_group_name            = "az104-rg5"
  tags = {
    managed-by = "az-104"
  }
  ip_configuration {
    gateway_load_balancer_frontend_ip_configuration_id = ""
    name                                               = "ipconfig1"
    primary                                            = true
    private_ip_address                                 = "172.16.0.4"
    private_ip_address_allocation                      = "Dynamic"
    private_ip_address_version                         = "IPv4"
    public_ip_address_id                               = ""
    subnet_id                                          = "/subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/resourceGroups/az104-rg5/providers/Microsoft.Network/virtualNetworks/ManufacturingVnet/subnets/Manufacturing"
  }
}
resource "azurerm_network_security_group" "res-6" {
  location            = "swedencentral"
  name                = "CoreServicesVM-nsg"
  resource_group_name = "az104-rg5"
  security_rule       = []
  tags = {
    managed-by = "az-104"
  }
}
resource "azurerm_network_security_group" "res-7" {
  location            = "swedencentral"
  name                = "ManufacturingVM-nsg"
  resource_group_name = "az104-rg5"
  security_rule       = []
  tags = {
    managed-by = "az-104"
  }
}
resource "azurerm_route_table" "res-8" {
  bgp_route_propagation_enabled = false
  location                      = "swedencentral"
  name                          = "rt-CoreServices"
  resource_group_name           = "az104-rg5"
  route = [{
    address_prefix         = "10.0.0.0/16"
    name                   = "PerimetertoCore"
    next_hop_in_ip_address = "10.0.1.7"
    next_hop_type          = "VirtualAppliance"
  }]
  tags = {
    managed-by = "az-104"
  }
}
resource "azurerm_virtual_network" "res-9" {
  address_space                  = ["10.0.0.0/16"]
  bgp_community                  = ""
  dns_servers                    = []
  edge_zone                      = ""
  flow_timeout_in_minutes        = 0
  location                       = "swedencentral"
  name                           = "CoreServicesVnet"
  private_endpoint_vnet_policies = "Disabled"
  resource_group_name            = "az104-rg5"
  subnet = [{
    address_prefixes                              = ["10.0.0.0/24"]
    default_outbound_access_enabled               = false
    delegation                                    = []
    id                                            = "/subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/resourceGroups/az104-rg5/providers/Microsoft.Network/virtualNetworks/CoreServicesVnet/subnets/Core"
    name                                          = "Core"
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
    route_table_id                                = azurerm_route_table.res-8.id
    security_group                                = ""
    service_endpoint_policy_ids                   = []
    service_endpoints                             = []
    }, {
    address_prefixes                              = ["10.0.1.0/24"]
    default_outbound_access_enabled               = false
    delegation                                    = []
    id                                            = "/subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/resourceGroups/az104-rg5/providers/Microsoft.Network/virtualNetworks/CoreServicesVnet/subnets/perimeter"
    name                                          = "perimeter"
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
    route_table_id                                = ""
    security_group                                = ""
    service_endpoint_policy_ids                   = []
    service_endpoints                             = []
  }]
  tags = {
    managed-by = "az-104"
  }
}
resource "azurerm_virtual_network" "res-10" {
  address_space                  = ["172.16.0.0/16"]
  bgp_community                  = ""
  dns_servers                    = []
  edge_zone                      = ""
  flow_timeout_in_minutes        = 0
  location                       = "swedencentral"
  name                           = "ManufacturingVnet"
  private_endpoint_vnet_policies = "Disabled"
  resource_group_name            = "az104-rg5"
  subnet = [{
    address_prefixes                              = ["172.16.0.0/24"]
    default_outbound_access_enabled               = false
    delegation                                    = []
    id                                            = "/subscriptions/059f28d7-325c-43a5-adaf-228ac5a85c86/resourceGroups/az104-rg5/providers/Microsoft.Network/virtualNetworks/ManufacturingVnet/subnets/Manufacturing"
    name                                          = "Manufacturing"
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
    route_table_id                                = ""
    security_group                                = ""
    service_endpoint_policy_ids                   = []
    service_endpoints                             = []
  }]
  tags = {
    managed-by = "az-104"
  }
}
resource "azurerm_network_interface_security_group_association" "res-11" {
  network_interface_id      = azurerm_network_interface.res-4.id
  network_security_group_id = azurerm_network_security_group.res-6.id
}
resource "azurerm_network_interface_security_group_association" "res-12" {
  network_interface_id      = azurerm_network_interface.res-5.id
  network_security_group_id = azurerm_network_security_group.res-7.id
}
