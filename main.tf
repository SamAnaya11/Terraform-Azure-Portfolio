# =============================================================================
# main.tf
# Recursos de Azure. Los valores vienen de variables.tf (var.*) y locals.tf (local.*).
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Grupo de recursos: la "carpeta" donde vivirá todo el proyecto
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = local.nombre_grupo_recursos # rg-portfolio-dev
  location = var.ubicacion               # spaincentral
  tags     = local.etiquetas_comunes
}

# -----------------------------------------------------------------------------
# 2. Sufijo aleatorio para que el nombre de la Storage Account sea único
#    (los nombres de Storage Account son globales en todo Azure).
#    Se genera una vez y se guarda en el state: no cambia en cada apply.
# -----------------------------------------------------------------------------
resource "random_string" "sufijo" {
  length  = 6
  upper   = false # Storage Account solo admite minúsculas...
  special = false # ...y nada de símbolos
  numeric = true  # números sí
}

# -----------------------------------------------------------------------------
# 3. Storage Account: donde se guardan los archivos de la web
# -----------------------------------------------------------------------------
resource "azurerm_storage_account" "web" {
  name                = local.nombre_storage # ej: stportfoliohft32q (máx. 24 caracteres)
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  account_kind             = "StorageV2"          # necesario para "static website"
  account_tier             = "Standard"           # rendimiento estándar (el barato)
  account_replication_type = var.tipo_replicacion # LRS: 3 copias en un datacenter (el más barato)

  # Seguridad básica
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false # los contenedores normales NO son públicos
  # (la web estática sigue siendo pública: usa su propio endpoint, no el acceso público a blobs)

  tags = local.etiquetas_comunes
}

# -----------------------------------------------------------------------------
# 4. Activar "static website" en la Storage Account
#    Azure crea automáticamente el contenedor especial "$web"
# -----------------------------------------------------------------------------
resource "azurerm_storage_account_static_website" "web" {
  storage_account_id = azurerm_storage_account.web.id
  index_document     = "index.html" # página que se sirve en la raíz "/"
  error_404_document = "404.html"   # página que se sirve si la ruta no existe
}

# -----------------------------------------------------------------------------
# 5. Subida de los archivos de la web al contenedor "$web"
#    OJO: los nombres distinguen mayúsculas. "index.html" ≠ "Index.html"
#
#    storage_container_id sustituye a storage_account_name + storage_container_name
#    (obsoletos en azurerm 4.x, se eliminan en la 5.0).
# -----------------------------------------------------------------------------
resource "azurerm_storage_blob" "index" {
  name                 = "index.html"
  storage_container_id = local.id_contenedor_web
  type                 = "Block"
  source               = "${path.module}/web/index.html"
  content_type         = "text/html; charset=utf-8"

  # Huella del archivo: si cambias index.html en tu PC, cambia el MD5
  # y Terraform vuelve a subirlo (es ForceNew: el blob se reemplaza).
  content_md5 = filemd5("${path.module}/web/index.html")

  # El contenedor "$web" no existe hasta que se activa static website.
  # Como no hay referencia directa a ese recurso, indicamos la dependencia a mano.
  depends_on = [azurerm_storage_account_static_website.web]
}

resource "azurerm_storage_blob" "error_404" {
  name                 = "404.html"
  storage_container_id = local.id_contenedor_web
  type                 = "Block"
  source               = "${path.module}/web/404.html"
  content_type         = "text/html; charset=utf-8"
  content_md5          = filemd5("${path.module}/web/404.html")

  depends_on = [azurerm_storage_account_static_website.web]
}

resource "azurerm_storage_blob" "estilos" {
  name                 = "estilos.css"
  storage_container_id = local.id_contenedor_web
  type                 = "Block"
  source               = "${path.module}/web/estilos.css"
  content_type         = "text/css; charset=utf-8" # CSS, no HTML
  content_md5          = filemd5("${path.module}/web/estilos.css")

  depends_on = [azurerm_storage_account_static_website.web]
}
