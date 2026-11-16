# =============================================================================
# bootstrap/outputs.tf
# =============================================================================

# --- Valores para ../backend.tf ---------------------------------------------

output "grupo_recursos_tfstate" {
  description = "Grupo de recursos de la Storage del state (resource_group_name en backend.tf)."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_tfstate" {
  description = "Nombre de la Storage del state (storage_account_name en backend.tf)."
  value       = azurerm_storage_account.tfstate.name
}

output "contenedor_tfstate" {
  description = "Contenedor del state (container_name en backend.tf)."
  value       = azurerm_storage_container.tfstate.name
}

# --- Valores para los GitHub Secrets (Fase 4) --------------------------------
# sensitive = true: no se muestran en plan/apply (evita que salgan en capturas).
# Para verlos: terraform output -raw <nombre>

output "github_client_id" {
  description = "Secret AZURE_CLIENT_ID: client ID de la aplicación de GitHub Actions."
  value       = azuread_application.github.client_id
  sensitive   = true
}

output "tenant_id" {
  description = "Secret AZURE_TENANT_ID: ID del tenant de Entra ID."
  value       = data.azurerm_client_config.actual.tenant_id
  sensitive   = true
}

output "subscription_id" {
  description = "Secret AZURE_SUBSCRIPTION_ID: ID de la suscripción."
  value       = data.azurerm_client_config.actual.subscription_id
  sensitive   = true
}
