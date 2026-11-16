# Capturas de pantalla

Convención de nombres: `NN_descripcion.png`, en minúsculas y con guiones bajos
(los nombres distinguen mayúsculas: deben coincidir exactamente con el README).

## Fase 1 – Lo básico

| Archivo                                   | Qué muestra                                             |
|-------------------------------------------|---------------------------------------------------------|
| `01_web_publicada.png`                    | La web publicada en el endpoint de static website       |
| `02_web_404.png`                          | La página 404 personalizada (`/noexiste`)               |
| `03_static_website_portal.png`            | Portal: Data management > Static website                |
| `04_contenedor_web.png`                   | Portal: contenedor `$web` con los 3 archivos            |
| `05_terraform_state_list.png`             | `terraform state list` con los 7 recursos               |
| `06_experimento_A_in_place.png`           | Plan del experimento A (`~ update in-place`)            |
| `07_experimento_C_forces_replacement.png` | Plan del experimento C (`forces replacement`)           |

## Fase 2 – Variables y outputs

| Archivo                     | Qué muestra                                          |
|-----------------------------|------------------------------------------------------|
| `08_plan_sin_cambios.png`   | Plan de la refactorización: solo cambios en outputs  |
| `09_terraform_output.png`   | Salida de `terraform output`                         |
| `10_validacion_error.png`   | Error de validación de `entorno`                     |
| `10b_terraform_console.png` | Expresiones evaluadas en `terraform console`         |

## Fase 3 – Estado remoto

| Archivo                         | Qué muestra                                                         |
|---------------------------------|---------------------------------------------------------------------|
| `11_bootstrap_apply.png`        | `terraform apply` de bootstrap/ con sus outputs                     |
| `12_migrate_state.png`          | `terraform init -migrate-state` copiando el state                   |
| `13_contenedor_tfstate.png`     | Portal: contenedor `tfstate` con `portfolio-dev.tfstate`            |
| `14_lease_bloqueado.png`        | Portal: el blob del state con *Lease state: Leased* durante un apply |
| `15_drift_plan.png`             | Plan detectando los cambios hechos a mano en el portal              |

## Fase 4 – CI/CD con GitHub Actions y OIDC

| Archivo                         | Qué muestra                                                                 |
|---------------------------------|-----------------------------------------------------------------------------|
| `16_bootstrap_oidc_state.png`   | `terraform state list` de bootstrap/ con la identidad de GitHub             |
| `18_github_environments.png`    | GitHub: environment `dev` (required reviewers y solo rama `main`)           |
| `19b_oidc_backend_init.png`     | GitHub Actions: `terraform init` del backend remoto por OIDC                |
| `20_aprobacion_apply.png`       | GitHub Actions: el job apply desplegando en `dev` tras la aprobación        |
| `21_pipeline_verde.png`         | GitHub Actions: validar, plan y apply en verde (merge a `main`)             |
| `22_rama_solo_plan.png`         | GitHub Actions: push a una rama, apply *skipped*                            |
| `23_fmt_falla.png`              | GitHub Actions: `fmt -check` parando el pipeline                            |

La numeración tiene huecos (17 y 19) porque esas capturas no se hicieron.

⚠️ Antes de añadir una captura, revisa que no se vea tu ID de suscripción, tenant o cliente, ni tu correo.
