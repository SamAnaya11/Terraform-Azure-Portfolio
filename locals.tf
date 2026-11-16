# =============================================================================
# locals.tf
# Valores calculados una sola vez y reutilizados. Se usan como local.<nombre>.
# A diferencia de las variables, NO se pueden cambiar desde fuera.
# =============================================================================

locals {
  # Nombres de los recursos (convención: tipo-prefijo-entorno)
  nombre_grupo_recursos = "rg-${var.prefijo}-${var.entorno}"

  # La Storage Account no admite guiones: "st" + prefijo + sufijo aleatorio
  # Ejemplo: stportfoliohft32q
  nombre_storage = "st${var.prefijo}${random_string.sufijo.result}"

  # Etiquetas comunes para TODOS los recursos.
  # merge() une mapas; si una clave se repite, gana el ÚLTIMO mapa.
  # Por eso las etiquetas fijas van al final: etiquetas_extra no puede pisarlas.
  etiquetas_comunes = merge(
    var.etiquetas_extra,
    {
      proyecto       = var.prefijo
      entorno        = var.entorno
      gestionado_por = "terraform"
    }
  )

  # ID del contenedor especial "$web" (lo crea Azure al activar static website).
  # Formato: <ID de la Storage Account>/blobServices/default/containers/$web
  # Los blobs lo necesitan en "storage_container_id".
  id_contenedor_web = "${azurerm_storage_account.web.id}/blobServices/default/containers/$web"
}
