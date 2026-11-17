# CLAUDE.md – Contexto del proyecto

## Qué es
Proyecto **demostrativo de Terraform**: web estática de portafolio (tarjeta de presentación)
alojada en una Azure Storage Account con "static website", creada 100 % con Terraform.
El objetivo es mostrar buenas prácticas de IaC, con cada decisión documentada.

## Modo de trabajo (obligatorio)
- **Explicación previa**: antes de escribir cada archivo `.tf`, explicar con claridad qué hace
  cada bloque (provider, resource, variable, output, backend...).
- **El usuario ejecuta TODOS los comandos** (terraform init/plan/apply/destroy, az ...).
  Claude escribe archivos y da los comandos explicados (qué hace cada parte, qué crea, si cuesta dinero).
  **Claude no ejecuta comandos de Terraform ni de Azure CLI.**
- Trabajo **por fases**. Al terminar cada fase: parar, resumir lo implementado, explicar cómo comprobarlo
  en el portal de Azure (**portal en inglés**: usar los nombres de menú en inglés) y esperar confirmación.
- Terminal: **PowerShell en Windows** (comandos con sintaxis PowerShell: `$env:VAR = ...`, backtick para
  continuar líneas).
- Autenticación: sesión de `az login`. El ID de suscripción se pasa por `$env:ARM_SUBSCRIPTION_ID`,
  nunca en el código.

## Fases
1. **Básico** – provider azurerm fijado, RG, Storage Account Standard LRS, static website, subida de
   index.html / 404.html / estilos.css. init/plan/apply/destroy, state, experimento de plan.
2. **Ordenar** – variables (descripción + validación), outputs (URL), terraform.tfvars.example, locals con tags.
3. **Estado remoto** – backend azurerm, problema del huevo y la gallina (carpeta `bootstrap/`), experimento de drift.
4. **(Opcional) CI/CD** – GitHub Actions: fmt, validate, plan en cada push; apply en main; OIDC con
   credencial federada (sin secretos de Azure). Ojo: GitHub puede enviar el subject con IDs inmutables
   (`repo:usuario@ID/repo@ID:ref:refs/heads/main`), la credencial federada debe coincidir exactamente.

## Reglas técnicas
- Terraform instalado: **v1.17.2**. `required_version = ">= 1.9.0, < 2.0.0"`.
- Provider `hashicorp/azurerm ~> 4.20` (usar `azurerm_storage_account_static_website`, no el bloque
  `static_website` obsoleto). `.terraform.lock.hcl` se sube a Git.
- Región: **spaincentral**. Prefijo de nombres: **portfolio** (`rg-portfolio-dev`, `stportfolio<sufijo>`).
- **Coste mínimo**; avisar siempre de cualquier cosa que pueda cobrarse.
- Nunca subir secretos, IDs de suscripción/tenant, `*.tfstate`, `*.tfvars` reales, `.terraform/`.
- Nombres de archivos de la web **idénticos en todas partes** (Azure Storage y Linux distinguen mayúsculas):
  `index.html`, `404.html`, `estilos.css` (todo minúsculas).
- Código claro y legible, **comentado en español**.
- Web: solo HTML + CSS, sin frameworks ni JS innecesario. Marcadores tipo `[TU NOMBRE]`, `[TITULAR]`,
  `[ENLACE_PROYECTO_1]` para que el usuario rellene.

## Documentación
- `README.md` en español: qué es, arquitectura (diagrama en texto), prácticas de Terraform implementadas, comandos,
  tabla Bicep vs Terraform, costes, cómo destruirlo, problemas encontrados, capturas en `docs/capturas/`.
- Actualizar el README al terminar cada fase.

## Decisiones técnicas tomadas
- Blobs: usar `storage_container_id` (`local.id_contenedor_web` = ID de la Storage +
  `/blobServices/default/containers/$web`). `storage_account_name` y `storage_container_name` están obsoletos.
- Variables `prefijo` y `entorno` son obligatorias (sin default). En CI (Fase 4) no habrá terraform.tfvars:
  pasar los valores con `TF_VAR_prefijo` / `TF_VAR_entorno` en el workflow.
- Capturas: `docs/capturas/NN_descripcion.png` (minúsculas, guion bajo).
- Estado remoto: `bootstrap/` (state LOCAL) crea `rg-portfolio-tfstate` + Storage `stportfoliotfs<sufijo>`
  (versionado, soft delete 7 días, `prevent_destroy`) + contenedor `tfstate` + rol
  "Storage Blob Data Contributor" para el usuario. La raíz usa `backend.tf` con `use_azuread_auth = true`
  y key `portfolio-dev.tfstate`. En la Fase 4 la identidad de GitHub necesitará ese mismo rol.
- Destruir en orden: primero la raíz, luego bootstrap (quitando antes `prevent_destroy`).

## Estado final: ✅ PROYECTO COMPLETADO (las 4 fases)
- Fase 1: ✅ desplegada en `stportfoliohft32q` (`rg-portfolio-dev`), experimentos A/B/C, capturas 01-07.
- Fase 2: ✅ refactorización sin cambios, experimentos A-D, capturas 08-10b.
- Fase 3: ✅ Storage del state `stportfoliotfs283ojl` (`rg-portfolio-tfstate`), state migrado, drift y bloqueo
  probados, capturas 11-15. El state local antiguo está fuera del proyecto; `bootstrap/terraform.tfstate` sigue
  en local (fuera de Git, con copia de seguridad aparte).
- Fase 4: ✅ repo PÚBLICO `SamAnaya11/Terraform-Azure-Portfolio`. Identidad con Terraform en
  `bootstrap/github_oidc.tf` (azuread ~> 3.0), subject con IDs inmutables (funcionó a la primera), environments
  `plan` y `dev` (required reviewers + solo `main`), 3 secrets. Experimentos rama/PR/fmt hechos. Capturas
  16, 18, 19b, 20-23 (no existen 17 ni 19).
- Finales de línea: `core.autocrlf false` + `.gitattributes` (`* text=auto eol=lf`), porque `filemd5()` de los
  blobs depende de los bytes exactos (Windows vs runner Linux).
- Limitaciones documentadas en el README: una sola identidad para plan y apply; state de bootstrap local;
  "Allow administrators to bypass" activado en `dev`; un solo entorno; sin dominio/CDN.

## Si se retoma el proyecto
- Cualquier cambio en `web/` o en los `.tf` se despliega con push a `main` + aprobación en GitHub.
- Antes de cada commit: `terraform fmt -recursive`, búsqueda de GUIDs con `git grep --cached` y
  `git ls-files --eol` (todo LF).
- Mantener README y `docs/capturas/LEEME.md` sincronizados con los nombres reales de las capturas.

## Decisiones de la Fase 4
- Environments de GitHub: `plan` (sin reglas, cualquier rama) y `dev` (solo `main` + required reviewers).
  Subject = `<github_subject_prefijo>:environment:<env>`; si GitHub usa IDs inmutables, se ajusta la variable
  `github_subject_prefijo` en bootstrap con el valor que muestre el error AADSTS700213.
  Default actual (IDs inmutables): `repo:SamAnaya11@200885290/Terraform-Azure-Portfolio@1460302292`.
- Workflow solo con `push` + `workflow_dispatch` (sin `pull_request`: repo público, forks).
- Secrets del repo: AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID (masking en logs).
- El job apply re-planifica (no se pasa el plan como artifact porque contiene datos sensibles del state).
