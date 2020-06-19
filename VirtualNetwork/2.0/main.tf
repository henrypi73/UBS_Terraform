terraform {
  backend "azurerm" {}
}
provider "azurerm" {
features {}
}
data azurerm_resource_group "vnet" {
  name = "${var.resource_group_name_vnet}"
}

resource azurerm_virtual_network "vnet" {
  name                = "${var.resource_name_vnet}"
  resource_group_name = data.azurerm_resource_group.vnet.name
  location            = data.azurerm_resource_group.vnet.location
  address_space       = "${var.address_space}"
  dns_servers         = "${var.dns_servers}"
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "subnet" {
  count                = length("${var.subnet_names}")
  name                 = "${var.subnet_names}"[count.index]
  resource_group_name  = data.azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "${var.subnet_prefixes}"[count.index]
}

data "azurerm_subnet" "import" {
  for_each             = "${var.nsg_ids}"
  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = [azurerm_subnet.subnet]
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = "${var.nsg_ids}"
  subnet_id                 = data.azurerm_subnet.import[each.key].id
  network_security_group_id = each.value

  depends_on = [data.azurerm_subnet.import]
}
data azurerm_log_analytics_workspace "log_analytics_workspace" {
  name                = "${var.workspace_id}"
  resource_group_name = "${var.workspace_rgname}"
}

data "azurerm_monitor_diagnostic_categories" "diagnostics" {
  resource_id = azurerm_virtual_network.vnet.id
  depends_on  = [azurerm_virtual_network.vnet]
}

resource "azurerm_monitor_diagnostic_setting" "diagnostics" {
  name                       = "default"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostics.logs

    content {
      category = log.key
      enabled  = true

      retention_policy {
        enabled = false
        days    = 7
      }
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostics.metrics

    content {
      category = metric.key
      enabled  = true

      retention_policy {
        enabled = false
        days    = 7
      }
    }
  }

  lifecycle {
    ignore_changes = [
      log,
      metric
    ]
  }
  depends_on = [azurerm_virtual_network.vnet]
}