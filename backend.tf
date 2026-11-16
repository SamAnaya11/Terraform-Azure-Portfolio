# =============================================================================
# backend.tf
# Dónde guarda Terraform el state de la web: un blob en Azure Storage.
#
# IMPORTANTE: aquí NO se pueden usar variables ni locals (el backend se lee en
# "terraform init", antes que nada). Los valores se escriben a mano.
# Salen de los outputs de bootstrap/ (cd bootstrap; terraform output).
#
# No contiene secretos: sin permisos de Entra ID el nombre no da acceso a nada.
# =============================================================================

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-portfolio-tfstate"
    storage_account_name = "stportfoliotfs283ojl" # output "storage_account_tfstate" de bootstrap/
    container_name       = "tfstate"
    key                  = "portfolio-dev.tfstate" # nombre del blob con el state

    # Entrar con tu identidad de Entra ID (az login) en lugar de con la clave
    # de la cuenta. Requiere el rol "Storage Blob Data Contributor".
    use_azuread_auth = true
  }
}
