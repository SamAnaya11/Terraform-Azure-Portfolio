# =============================================================================
# outputs.tf
# Valores que Terraform muestra al terminar el apply.
# Consúltalos en cualquier momento con: terraform output
# =============================================================================

output "url_web" {
  description = "URL pública de la web estática."
  value       = azurerm_storage_account.web.primary_web_endpoint
}

output "nombre_grupo_recursos" {
  description = "Nombre del grupo de recursos."
  value       = azurerm_resource_group.main.name
}

output "nombre_storage_account" {
  description = "Nombre de la Storage Account que aloja la web."
  value       = azurerm_storage_account.web.name
}
