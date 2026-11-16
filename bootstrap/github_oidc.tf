# =============================================================================
# bootstrap/github_oidc.tf
# Identidad de GitHub Actions en Azure, SIN contraseñas (OIDC / credencial federada).
#
#   GitHub firma un token temporal  ->  Entra ID comprueba issuer + audience + subject
#   ->  si coinciden con una credencial federada, da acceso como este service principal.
# =============================================================================

# Quién soy yo en Entra ID (para ser propietario de la aplicación)
data "azuread_client_config" "actual" {}

locals {
  # Ámbito del RG de la web, construido como texto (NO con un data source):
  # si el RG no existe (p. ej. al destruir), un data source haría fallar todo bootstrap.
  scope_rg_web = "/subscriptions/${data.azurerm_client_config.actual.subscription_id}/resourceGroups/rg-${var.prefijo}-${var.entorno_web}"
}

# -----------------------------------------------------------------------------
# App registration: el "carnet de identidad" de GitHub en tu tenant
# -----------------------------------------------------------------------------
resource "azuread_application" "github" {
  display_name = "sp-${var.prefijo}-github-actions"
  owners       = [data.azuread_client_config.actual.object_id]
}

# Service principal: la "instancia" de la aplicación a la que se asignan roles
resource "azuread_service_principal" "github" {
  client_id = azuread_application.github.client_id
  owners    = [data.azuread_client_config.actual.object_id]
}

# -----------------------------------------------------------------------------
# Credenciales federadas: una por environment de GitHub.
# El subject debe coincidir EXACTAMENTE con el que envía GitHub.
# -----------------------------------------------------------------------------
resource "azuread_application_federated_identity_credential" "plan" {
  application_id = azuread_application.github.id
  display_name   = "github-environment-plan"
  description    = "GitHub Actions, job plan (cualquier rama)"
  issuer         = "https://token.actions.githubusercontent.com"
  audiences      = ["api://AzureADTokenExchange"]
  subject        = "${var.github_subject_prefijo}:environment:plan"
}

resource "azuread_application_federated_identity_credential" "dev" {
  application_id = azuread_application.github.id
  display_name   = "github-environment-dev"
  description    = "GitHub Actions, job apply (solo main, con aprobación)"
  issuer         = "https://token.actions.githubusercontent.com"
  audiences      = ["api://AzureADTokenExchange"]
  subject        = "${var.github_subject_prefijo}:environment:${var.entorno_web}"
}

# -----------------------------------------------------------------------------
# Permisos mínimos (RBAC)
# skip_service_principal_aad_check: el SP recién creado tarda en replicarse;
# esto evita el error "PrincipalNotFound" en el primer apply.
# -----------------------------------------------------------------------------

# Gestionar la web: Contributor SOLO sobre rg-portfolio-dev
resource "azurerm_role_assignment" "github_contributor_web" {
  scope                            = local.scope_rg_web
  role_definition_name             = "Contributor"
  principal_id                     = azuread_service_principal.github.object_id
  skip_service_principal_aad_check = true
}

# Leer/escribir/bloquear el state: SOLO sobre la Storage del state
resource "azurerm_role_assignment" "github_blob_tfstate" {
  scope                            = azurerm_storage_account.tfstate.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = azuread_service_principal.github.object_id
  skip_service_principal_aad_check = true
}
