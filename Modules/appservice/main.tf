data "azurerm_storage_account" "logs" {
  name                = "monstorage1753057890"
  resource_group_name = "rg-terraform"
}

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
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "WEBSITE_FRAMEWORK_VERSION"  = var.azurerm_framework_version
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
        sas_url           = "https://${data.azurerm_storage_account.logs.name}.blob.core.windows.net/logging?${data.azurerm_storage_account_sas.logging_sas.sas}"
        retention_in_days = 7
      }
    }

    http_logs {
      azure_blob_storage {
        sas_url           = "https://${data.azurerm_storage_account.logs.name}.blob.core.windows.net/logging?${data.azurerm_storage_account_sas.logging_sas.sas}"
        retention_in_days = 7
      }
    }
  }

  auth_settings_v2 {
    auth_enabled           = true
    default_provider       = "azureactivedirectory"
    unauthenticated_action = "RedirectToLoginPage"

    active_directory_v2 {
      client_id            = var.client_id
      tenant_auth_endpoint = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
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

data "azurerm_storage_account_sas" "logging_sas" {
  connection_string = data.azurerm_storage_account.logs.primary_connection_string

  https_only = true
  start      = timestamp()
  expiry     = timeadd(timestamp(), "168h") # 7 jours

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  resource_types {
    service   = false
    container = true
    object    = true
  }

  permissions {
    read    = true
    list    = true
    write   = false
    delete  = false
    add     = false
    create  = false
    update  = false
    process = false
    filter  = false
    tag     = false
  }
}
