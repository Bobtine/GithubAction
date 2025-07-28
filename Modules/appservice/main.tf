resource "azurerm_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "B1"
}

resource "azurerm_windows_web_app" "app" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  identity {
    type = "SystemAssigned"
  }
 
  site_config {
    always_on = true
  }

 app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"             = "1"
  }
  
connection_string {
  name  = "DefaultConnection"
  type  = "SQLAzure"
  value = "Server=tcp:${var.sql_server_fqdn},1433;Database=${var.sql_database_name};Authentication=Active Directory Managed Identity;"
}

logs {
    application_logs {
      file_system_level = "Verbose"
      azure_blob_storage {
        level             = "Verbose"
        sas_url           = "https://${azurerm_storage_account.logs.name}.blob.core.windows.net/logging?${azurerm_storage_account_sas.logging_sas.sas}"
        retention_in_days = 7
      }
    }

    http_logs {
      file_system {
        retention_in_mb   = 35
        retention_in_days = 7
      }

      azure_blob_storage {
        sas_url           = "https://${azurerm_storage_account.logs.name}.blob.core.windows.net/logging?${azurerm_storage_account_sas.logging_sas.sas}"
        retention_in_days = 7
      }
    }
  }

  depends_on = [azurerm_storage_account_sas.logging_sas]

 auth_settings_v2 {
    auth_enabled           = true
    default_provider       = "azureactivedirectory"
    unauthenticated_action = "RedirectToLoginPage"

    active_directory_v2 {
      client_id = var.client_id
      tenant_auth_endpoint  = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
    }

    login {
      token_store_enabled = true
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_windows_web_app.app.id
  subnet_id      = var.appservice_subnet_id
}

resource "azurerm_storage_account_sas" "logging_sas" {
  storage_account_name = var.compte_storage_account_name
  resource_group_name  = var.resource_group_name
  https_only           = true
  start                = timestamp()
  expiry               = timeadd(timestamp(), "168h") # 7 jours

  services   = "b" # Blob uniquement
  resource_types = "co" # Container + Object
  permissions = "rl" # Read + List

  content_types_to_include = ["application/json"]
}
