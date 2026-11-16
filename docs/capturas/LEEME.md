# Capturas de pantalla

Convención de nombres: `NN_descripcion.png`, en minúsculas y con guiones bajos
(los nombres distinguen mayúsculas: deben coincidir exactamente con el README).

## Fase 1 (hechas)

| Archivo                                   | Qué muestra                                             |
|-------------------------------------------|---------------------------------------------------------|
| `01_web_publicada.png`                    | La web publicada en el endpoint de static website       |
| `02_web_404.png`                          | La página 404 personalizada (`/noexiste`)               |
| `03_static_website_portal.png`            | Portal: Data management > Static website                |
| `04_contenedor_web.png`                   | Portal: contenedor `$web` con los 3 archivos            |
| `05_terraform_state_list.png`             | `terraform state list` con los 7 recursos               |
| `06_experimento_A_in_place.png`           | Plan del experimento A (`~ update in-place`)            |
| `07_experimento_C_forces_replacement.png` | Plan del experimento C (`forces replacement`)           |

## Fase 2 (hechas)

| Archivo                     | Qué muestra                                          |
|-----------------------------|------------------------------------------------------|
| `08_plan_sin_cambios.png`   | Plan de la refactorización: solo cambios en outputs  |
| `09_terraform_output.png`   | Salida de `terraform output`                         |
| `10_validacion_error.png`   | Error de validación de `entorno`                     |
| `10b_terraform_console.png` | Expresiones evaluadas en `terraform console`         |

## Fase 3 (hechas)

| Archivo                         | Qué muestra                                                         |
|---------------------------------|---------------------------------------------------------------------|
| `11_bootstrap_apply.png`        | `terraform apply` de bootstrap/ con sus outputs                     |
| `12_migrate_state.png`          | `terraform init -migrate-state` copiando el state                   |
| `13_contenedor_tfstate.png`     | Portal: contenedor `tfstate` con `portfolio-dev.tfstate`            |
| `14_lease_bloqueado.png`        | Portal: el blob del state con *Lease state: Leased* durante un apply |
| `15_drift_plan.png`             | Plan detectando el cambio hecho a mano en el portal                 |

## Fase 4 (pendientes)

| Archivo                          | Qué capturar                                                              |
|----------------------------------|---------------------------------------------------------------------------|
| `16_bootstrap_oidc_plan.png`     | Plan de bootstrap con los 6 recursos nuevos (app, SP, credenciales, roles) |
| `17_credenciales_federadas.png`  | Portal: App registration > Certificates & secrets > Federated credentials |
| `18_github_environments.png`     | GitHub: Settings > Environments (plan y dev con reglas)                   |
| `19_aadsts700213.png`            | (Si ocurre) el error con el subject real                                  |
| `20_aprobacion_apply.png`        | GitHub: el job apply esperando "Review deployments"                       |
| `21_pipeline_verde.png`          | GitHub: validar, plan y apply en verde                                    |
| `22_fmt_falla.png`               | Experimento: `fmt -check` parando el pipeline                             |

⚠️ En el portal de Entra ID se ven el client ID, el tenant ID y tu correo: recórtalos o táchalos.

⚠️ Antes de subir una captura, revisa que no se vea tu ID de suscripción, tenant ni correo.
