resource "azurerm_service_plan" "plan" {
  name                = "plan-tfdemo-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-tfdemo-australiaeast"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  https_only = true
  site_config {
    #app_command_line = "dotnet DotNetCoreSqlDb.dll"
    http2_enabled = true
    always_on     = false
    application_stack {
      dotnet_version = "6.0"
    }
  }

  app_settings = {
    # https://docs.microsoft.com/azure/azure-monitor/app/azure-web-apps-net-core?tabs=Windows%2Clinux&WT.mc_id=DOP-MVP-5001655#application-settings-definitions
    "APPINSIGHTS_INSTRUMENTATIONKEY"              = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"       = azurerm_application_insights.appinsights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"  = "~3"
    "XDT_MicrosoftApplicationInsights_Mode"       = "recommended"
    "XDT_MicrosoftApplicationInsights_PreemptSdk" = "1"
  }

  connection_string {
    name  = "MyDbConnection"
    type  = "SQLAzure"
    value = "Server=${azurerm_mssql_server.mssql.fully_qualified_domain_name};Database=${azurerm_mssql_database.database.name};User ID=${var.mssql_administrator_login};Password=${var.mssql_administrator_password};Application Name=App Service"
  }

  identity {
    type = "SystemAssigned"
  }


}