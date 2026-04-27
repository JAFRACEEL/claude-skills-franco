---
name: sistemafrd-context
description: Carga contexto arquitectónico del proyecto SistemaFRD (sistema de gestión de personal y planillas para empresa peruana de construcción FRD). Úsalo SIEMPRE que el usuario mencione SistemaFRD, FRD, planilla, prorrateo, tareas/asistencia/órdenes de trabajo, o cuando se trabaje en C:\SistemaFRD. Incluye stack (React 19 + FastAPI 0.110 + MongoDB), inventario de 26 módulos en producción, 7 roles, riesgos críticos vivos, reglas de oro de negocio y protocolo de autoverificación obligatorio.
---

# SistemaFRD — Contexto del proyecto

> Snapshot: 2026-04-26. Si el código real difiere de este snapshot, el código manda — actualiza este skill cuando detectes drift importante.

---

## 1. Visión general

**SistemaFRD** es el sistema interno de gestión de personal, tareas, planillas y operaciones de **INVERSIONES GENERALES FRD EIRL** — empresa peruana de ingeniería, diseño y construcción (Grupo FRD). Lo usan en producción real con trabajadores en obra, cobros a clientes y planilla quincenal/mensual. **No es un prototipo.**

**Flujo principal del negocio:**

1. Admin/Master inicia sesión con Google OAuth.
2. Crea fichas de trabajadores con sueldo base.
3. Asigna tareas con periodo (diario/semanal/mensual) y ubicación/proyecto.
4. El sistema proratea automáticamente el 50% del sueldo variable entre las tareas del mes.
5. Trabajadores desde celular ven tareas, suben fotos ANTES/DESPUÉS, marcan completadas.
6. Al cierre del mes: Sueldo fijo (50%) + Variable ganado − Adelantos − Descuentos = Neto.
7. Admin exporta planilla mensual y boletas individuales en PDF (ReportLab).

**Working directory:** `C:\SistemaFRD\` — repo git, branch principal `main`. Deploy automático a Railway en cada push.

---

## 2. Stack y versiones

### Frontend
| Tecnología | Versión | Notas |
|---|---|---|
| React | 19.0.0 | Hooks, sin Server Components |
| react-router-dom | 7.5.1 | BrowserRouter + 5 guards de ruta |
| react-scripts + CRACO | 5.0.1 + 7.1.0 | CRACO para alias `@/*` y watch options |
| TailwindCSS | 3.4.17 | + tailwindcss-animate + tailwind-merge |
| shadcn/ui | new-york | 45 componentes Radix instalados |
| @phosphor-icons/react | 2.1.10 | Iconos primarios (regular/fill) |
| lucide-react | 0.507.0 | Solo fallback de shadcn |
| sonner | 2.0.3 | Toasts (top-right) |
| recharts, leaflet, pdfjs-dist, date-fns | varios | Visualización, mapas, PDF, fechas |

### Backend
| Tecnología | Versión | Notas |
|---|---|---|
| Python | 3.9+ | Sin pyproject, solo requirements.txt |
| FastAPI | 0.110.1 | + uvicorn 0.25.0 |
| Motor | 3.3.1 | Driver async MongoDB |
| Pydantic | >=2.6.4 | v2 (BaseModel, model_dump) |
| ReportLab + fpdf2 | 4.4.10 + 2.8.7 | 15 generadores PDF en `pdf_utils.py` |
| APScheduler | 3.11.2 | Tareas programadas (descuentos diarios @ 23:59 Lima) |
| Cloudinary | >=1.40.0 | Almacenamiento de fotos (migrado desde Emergent) |
| google-auth | >=2.0.0 | OAuth |
| anthropic | >=0.39.0 | Claude API para escaneo IA de comprobantes |

### Base de datos y servicios
- **MongoDB Atlas** (cloud) — DB `sistemafrd` (prod), `test_database` (dev). Async via Motor. **47 collections, cero índices explícitos detectados.**
- **Cloudinary** — fotos
- **Google OAuth** — auth primaria
- **Anthropic Claude** — escaneo IA de comprobantes
- **Railway** — deploy producción (`sistemafrd-production.up.railway.app` + `clever-rejoicing-production.up.railway.app`). Sin staging.

### ⚠️ Notas críticas sobre dependencias (no obvio del package.json)
- **`axios` está instalado pero NO se usa.** Todas las 26 páginas usan `fetch` nativo inline. No introduzcas axios en código nuevo a menos que sea decisión consciente del usuario.
- **`react-hook-form` y `zod` están instalados pero NO se usan.** Validación de formularios es 100% manual con `useState` + `if (!form.x) toast.error(...)`. Mismo criterio: no los uses sin alineación con el usuario.
- **`@emergentbase/visual-edits`** está en devDependencies pero probablemente deprecated post-migración a Cloudinary.

---

## 3. Inventario de 26 módulos (en producción)

| # | Módulo | Frontend | Endpoints | Collections | Roles |
|---|---|---|---|---|---|
| 1 | Auth & Users | `Login`, `AuthCallback`, `UserManagement` | 6+OAuth | users, user_sessions | public, master |
| 2 | Dashboard | `Dashboard.jsx` (1,178) | 2 | (cross) | todos |
| 3 | Workers | `Workers.jsx` | 9 | workers | admin, master |
| 4 | Tasks + Recurring | `Tasks`, `WorkerPortal` (2,328) | 18 | tasks, recurring_tasks | admin, master, worker |
| 5 | Locations | `Tasks`, `Maestros` | 5 | locations | admin, master |
| 6 | Payroll | `Payroll.jsx` | 5 | (calculado) | admin, master |
| 7 | Advances + Discounts | `Advances.jsx` | 5+5 | advances, discounts, attendance_discounts | admin, master |
| 8 | Attendance + Overtime | `Asistencia.jsx` (2,214) | 25+7 | attendance, attendance_settings, early_exit_requests, overtime_* | admin, master, jefe_ops |
| 9 | Daily Reports | `WorkerPortal.jsx` | 4 | daily_reports | técnico, master |
| 10 | Work Orders | `Ordenes.jsx` (1,778) | **18** | work_orders, ot_materials | admin, master, jefe_ops |
| 11 | Warehouse + POs | `Almacen.jsx` (1,393) | 13+4 | warehouse_*, inventory_items, purchase_orders | almacenero, admin |
| 12 | Petty Cash | `CajaChica.jsx` (1,074) | 13 | petty_cash_config/movements/arqueos | admin, master |
| 13 | Expenses | `Gastos.jsx` (1,565) | **20+** | expense_requests, expenses (legacy) | admin, master, worker |
| 14 | Receipts (escaneo IA) | `Comprobantes.jsx` (1,140) | 5 | receipts, unified_receipts, scanned_receipts ⚠️ | admin, master |
| 15 | Reimbursements | `Gastos.jsx` (sub-flow) | 2 | (cross) | admin, worker |
| 16 | Clients | `Clients.jsx` | 5 | clients | admin, master |
| 17 | Client Requests | `Requests.jsx` (1,917) | 11 | client_requests | admin, master, worker |
| 18 | Service Budgets | `Presupuestos.jsx` | 5 | service_budgets | admin, master |
| 19 | Tax Calendar (OSCE) | `Contable.jsx` | 4 | tax_calendar | admin, master |
| 20 | Accounting Packages | `Contable.jsx` | 7 | accounting_packages | admin, master |
| 21 | Company Accounts | `CompanyAccounts.jsx` | CRUD | company_accounts, company_account_movements | master |
| 22 | Maestros (catálogos) | `Maestros.jsx` (1,369) | 16 (4×4) | herramientas, equipos, subcontratistas, proveedores | admin, master |
| 23 | Projects | `Proyectos.jsx` | 5 | projects | admin, master |
| 24 | Calendario Ocurrencias | `CalendarioOcurrencias.jsx` | (consume work-orders) | (cross) | admin, master |
| 25 | Role Modules (RBAC) | `GestionModulos.jsx` | 4 | role_modules | master |
| 26 | Reports | `Reports.jsx` | 6+PDFs | (cross) | admin, master, jefe_ops |
| + | Mis Funciones | `MisFunciones.jsx` | (estático) | — | todos |

**Totales:** 285 endpoints, 88 modelos Pydantic, 47 collections, 15 generadores PDF.

**Páginas grandes a tener cuidado al editar:** WorkerPortal (2,328), Asistencia (2,214), Requests (1,917), Ordenes (1,778), Gastos (1,565), Almacen (1,393), Maestros (1,369), Dashboard (1,178), Comprobantes (1,140), CajaChica (1,074). Lee por secciones, no completas.

---

## 4. Roles y autorización

### Constantes exactas (backend `server.py:30-33`)
```python
ADMIN_ROLES        = {"admin", "administrador", "master"}
FIELD_SUPERVISORS  = {"jefe_operaciones"}
NON_ADMIN_ROLES    = {"worker", "tecnico", "maestro", "almacenero"}
ALL_VALID_ROLES    = ADMIN_ROLES | FIELD_SUPERVISORS | NON_ADMIN_ROLES
```

7 roles totales (worker ≈ tecnico). **Nota crítica:** "admin" y "administrador" coexisten — `_normalize_approver_role()` convierte `admin → administrador` internamente, pero el frontend tiene checks contra ambos en distintos archivos. Verifica siempre cuál usar antes de hardcodear.

### Dependencies de protección backend (4 funciones)
| Dependency | Quién pasa | Uso aprox |
|---|---|---|
| `get_current_user()` | Cualquier autenticado | ~200 endpoints |
| `require_admin()` | `ADMIN_ROLES` | ~80 endpoints |
| `require_field_or_admin()` | `ADMIN_ROLES ∪ FIELD_SUPERVISORS` | ~15 endpoints |
| `require_master()` | Solo `"master"` | ~10 endpoints |
| `get_current_user_pdf()` | Variante flexible (acepta `share_token` query param) | PDFs públicos firmados |

### Guards de ruta frontend (`App.js`, 5 guards)
- `MasterRoute` — solo master, redirect `/dashboard`
- `AdminRoute` — `["admin", "administrador", "master"]`, redirect `/dashboard`
- `FieldRoute` — admins + jefe_ops + almacenero + maestro, redirect `/mis-tareas`
- `WorkerRoute` — cualquier autenticado
- `PrivateRoute` — cualquier autenticado
- `ModuleRoute` — verifica `roleModules[mk] === false` (RBAC dinámico)

### RBAC dinámico
Master puede habilitar/deshabilitar 24 módulos por rol desde `GestionModulos.jsx` → guarda en collection `role_modules`. `AuthContext.checkAuth()` carga estos módulos al login y `AdminLayout.buildNav()` filtra el sidebar.

### "Ver como" (ViewAsContext)
Solo Master. Permite simular la vista de otros 5 roles (administrador, jefe_operaciones, almacenero, maestro, tecnico) re-fetcheando `roleModules` para el rol simulado. Banner amarillo persistente mientras está activo.

### Auth técnico
- **Session-based** (no JWT real, aunque PyJWT está instalado).
- Token en `localStorage.getItem("session_token")`.
- TTL 7 días en `db.user_sessions.expires_at`.
- **No hay refresh token** — al expirar redirige a login.
- Headers: `Authorization: Bearer <token>` o alternativo `session-token: <token>`.

---

## 5. Riesgos críticos vivos ⚠️

> Estos 3 riesgos son los que más probable causen incidentes. Tenlos en mente al planear cualquier feature nueva.

### Riesgo 1 — Cero índices MongoDB explícitos
**Qué:** 698 operaciones MongoDB inline sobre 47 collections, sin un solo `create_index()` detectado en el código. Las queries hoy son rápidas porque hay poco volumen. **Con crecimiento de `attendance`, `tasks`, `expenses`, `unified_receipts` la performance se degradará linealmente** y el Dashboard / reportes mensuales empezarán a fallar por timeout.
**Qué hacer:** Antes de agregar features nuevas que generen volumen, crear `backend/setup_indexes.py` idempotente con índices para las 10 collections más consultadas: attendance, tasks, expenses, unified_receipts, work_orders, advances, discounts, requests, petty_cash_movements, daily_reports.

### Riesgo 2 — Auth ownership implícita (parcialmente fixed)
**Qué:** Endpoints como `/api/<recurso>/{worker_id}` que solo dependen de `get_current_user` SIN validar que el usuario sea dueño del recurso. Cualquier técnico autenticado puede leer datos ajenos. El commit `e569190` arregló `/payroll/*`, `/reimbursements`, `/unified-receipts/{id}/link`, pero el patrón sigue siendo riesgoso para endpoints nuevos.
**Qué hacer:** Cada vez que escribas un endpoint nuevo con `{worker_id}` / `{receipt_id}` / similar como path param, **APLICA EL SNIPPET DE OWNERSHIP** (sección 7 de este skill).

### Riesgo 3 — Migración de receipts incompleta
**Qué:** Coexisten 3 collections (`receipts`, `unified_receipts`, `scanned_receipts`) con un script `backend/migrate_unified_receipts.py` cuyo estado de ejecución es desconocido. Distintos endpoints pueden estar leyendo de distintas collections, generando inconsistencias.
**Qué hacer:** Antes de tocar el flujo de comprobantes, preguntar al usuario qué collection es la canónica y si el script de migración ya corrió en producción. No agregar lecturas/escrituras nuevas hasta tener claridad.

---

## 6. Reglas de oro del negocio (inmutables)

Estas 4 reglas son la espina dorsal del flujo operativo de FRD. **Cualquier feature nueva debe respetarlas — no las cuestiones, refuérzalas.**

```
01. SIN ORDEN DE TRABAJO — ninguna obra empieza
02. SIN VALE DE ALMACÉN — ningún material sale
03. SIN APROBACIÓN FORMAL — ningún gasto se paga
04. SIN COMPROBANTE — ningún ciclo se cierra
```

### Fórmula de prorrateo de planilla (clave del producto)
```
Sueldo Fijo     = base_salary * 0.50      (siempre se paga)
Sueldo Variable = base_salary * 0.50      (se divide entre tareas del mes)
Valor por tarea = (base_salary * 0.50) / total_tareas_del_mes
Neto            = (fijo + sum(tareas_completadas * valor)) − adelantos − descuentos
```

Si una tarea no se completa, el trabajador NO gana esa porción del variable. Por eso es crítico que el sistema permita cerrar tareas a tiempo (módulo "Tareas Pendientes" pendiente en el roadmap — ver CLAUDE.md FASE 1A).

---

## 7. Patrón ownership backend (CRÍTICO — copia-pega)

Cada vez que un endpoint backend reciba `{worker_id}`, `{receipt_id}` u otro identificador de recurso como path param, **AGREGA ESTE BLOQUE INMEDIATAMENTE DESPUÉS DEL `Depends(get_current_user)`**:

```python
@api_router.get("/payroll/{worker_id}")
async def get_worker_payroll(
    worker_id: str,
    user = Depends(get_current_user)
):
    # ★ OWNERSHIP CHECK — obligatorio para evitar leakage entre técnicos
    if user.get("role") not in ADMIN_ROLES:
        own = await get_worker_for_user(user)
        if not own or own.get("worker_id") != worker_id:
            raise HTTPException(status_code=403, detail="No tienes acceso a este recurso")
    # ... resto del endpoint
```

**Reglas:**
- Si el rol está en `ADMIN_ROLES` → ve todo (no se valida ownership).
- Si NO es admin → debe ser dueño del recurso.
- Para recursos cuya relación con el worker no es directa (ej: receipts), agrega un join intermedio: cargar el receipt → verificar que `receipt["worker_id"]` coincide.

**Patrón equivalente para `body: dict`:** Si en vez de path param usas un campo en el body, valida también con la misma lógica antes de procesar.

---

## 8. Convenciones de código

### Frontend
| Aspecto | Convención |
|---|---|
| Páginas (`pages/`) | **Default export** (`export default function Dashboard()`) |
| Componentes shadcn (`ui/`) | **Named export** (`export function Button()`) |
| Componentes custom (`components/`) | Mix — verifica antes de importar |
| `data-testid` | **kebab-case** siempre (`add-worker-btn`, `month-select`) |
| HTTP | `fetch` nativo inline (NO axios). Construye headers con `{ Authorization: \`Bearer ${token()}\` }` |
| Constantes globales | UPPER_SNAKE_CASE fuera del componente (`const API`, `const MONTHS`, `const STATUS_CFG`) |
| Tailwind | Bracket notation para colores corporativos: `bg-[#1a2744]`, `text-[#4db8e8]`, `border-[#e85d26]` |
| Iconos | `@phosphor-icons/react` (regular por defecto, `weight="fill"` para activos) |
| Toasts | `toast.success()`, `toast.error(err.detail \|\| "Error")` con sonner |
| Layout admin | Siempre envolver con `<AdminLayout>...</AdminLayout>` |
| Tipografía | Chivo (títulos) + IBM Plex Sans (cuerpo) — ya cargadas en `index.css` |
| Moneda | `S/. 1,234.56` (formato `Number(x).toFixed(2)`) |
| Idioma UI | Español. Variables/funciones en inglés |

### Backend
| Aspecto | Convención |
|---|---|
| Router | `api_router = APIRouter(prefix="/api")` registrado al final con `app.include_router(api_router)` |
| Modelos | Pydantic v2 `BaseModel` (NO usar `body: dict` para nuevo código) |
| IDs | Prefijo por dominio: `wrk_`, `task_`, `adv_`, `dsc_`, `ph_`, `ot_`, etc. |
| DB | Motor async — todas las queries con `await db.collection.find_one(...)` |
| Auth | Inyección con `Depends(require_admin)`, `Depends(require_master)`, etc. |
| Errores | `raise HTTPException(status_code=400, detail="...")` inline (no middleware global) |
| Fechas | ISO 8601 strings, `datetime.now(LIMA_TZ).isoformat()` |
| TZ | `LIMA_TZ = ZoneInfo("America/Lima")` — sistema asume operación en Perú |
| PDFs | Funciones en `pdf_utils.py`, usar `_cached_logo_bytes()` para el logo FRD |

### Patrón de componente típico (referencia: `Ordenes.jsx`)
```javascript
// 1. Imports en orden estricto: React → router → AdminLayout → icons → sonner → custom
// 2. Constantes globales fuera del componente (API, token, STATUS_CFG, EMPTY_FORM, TABS)
// 3. Default export
// 4. Estado con useState (sin reducer)
// 5. fetchData con useCallback + AbortController + showLoading param para evitar skeleton remount
// 6. useEffect carga inicial + manejo de searchParams
// 7. Handlers con validación inline + fetch + toast
// 8. JSX: AdminLayout > header > tabs > section-card > tabla > modales
```

---

## 9. Sistema de aprobación de gastos

**Importante:** TODOS los gastos requieren aprobación. NO hay auto-aprobación por monto. (Excepción: comprobantes escaneados de caja chica directa — flujo separado.)

### Niveles por monto (`server.py:5694-5725`)
| Nivel | Monto S/. | Cadena de aprobación | `current_approver_role` |
|---|---|---|---|
| nivel_1 | ≤ 200 | Admin O Jefe Ops → listo | `"administrador"` |
| nivel_2 | 201-500 | Admin O Jefe Ops → listo | `"administrador"` |
| nivel_3 | 501-1,500 | Admin → Master → listo | `"administrador"` luego `"master"` |
| nivel_4 | > 1,500 | Admin → Master → listo | `"administrador"` luego `"master"` |

### Constantes frontend (`Gastos.jsx:879-880`)
```javascript
APPROVER_ROLES_FE = ["admin", "master", "administrador", "jefe_operaciones"]
ADMIN_EQUIV       = ["admin", "administrador"]
```

### Reglas de visibilidad de botones
- **canApprove:** requiere `exp.current_approver_role` en `ADMIN_EQUIV`.
- **canReject:** NO verifica `current_approver_role` — solo que el rol esté en `APPROVER_ROLES_FE`.

### Origen de gastos
- `desde_ot` — vinculado a OT, auto-enviado a aprobación.
- `reembolso` — trabajador ya pagó de su bolsillo, auto-enviado.
- Otros → se crea como borrador, requiere envío manual.

---

## 10. Protocolo de autoverificación obligatorio

> **Antes de reportar "listo ✅" al usuario en cualquier cambio de código, ejecuta los 8 pasos.** Reportar sin ejecutarlo es una violación de las reglas del proyecto. El usuario (Franco) confía en este protocolo.

| # | Paso | Comando / criterio |
|---|---|---|
| 1 | Backend sanity check | `cd backend && python -c "from server import app; print('OK')"` |
| 2 | Build frontend | `cd frontend && npx craco build 2>&1 \| tail -20` → "Compiled successfully" sin errors |
| 3 | Verificación de bundle | grep del cambio clave en el bundle generado |
| 4 | Auto code review | LEER el diff aplicado, verificar imports, paréntesis, indentación, JSX válido, nada fuera de scope |
| 5 | Parse JSX | `npx babel <archivo> --presets=@babel/preset-react` sin errores |
| 6 | Scope audit | listar hunks modificados + justificar cada uno dentro del scope declarado. Si algún hunk toca código no relacionado → ABORT |
| 7 | Visual test (si aplica) | screenshot con puppeteer/playwright si están instalados; si no, marcar "manual test pendiente" |
| 8 | Reporte final | tabla ✅/❌ por paso + commit hash + archivos y líneas modificadas + estado |

### Reglas de corte
- **Cualquier ❌ → ABORT.** No seguir al siguiente paso. Reportar el error exacto al usuario.
- **Si el reporte final tiene algún ❌ → NO hacer push.** Esperar decisión.
- **Nunca decir "listo ✅"** si no se ejecutó el protocolo completo.

---

## 11. Lecciones aprendidas vivas (no las repitas)

| Lección | Detalle |
|---|---|
| **Ownership implícita** | Endpoints `{worker_id}` sin verificación de owner permitían leakage entre técnicos. Fix parcial en commit `e569190`. **Aplica el snippet de la sección 7 en cada endpoint nuevo.** |
| **`int(body.get())` puede crashear** | Endpoints con `body: dict` que hacen `int(body.get("month"))` crashean con 500 si el cliente envía no-enteros. Envuelve en try/except + valida rango. Aplicado en `/attendance/bulk-regularize`, `/attendance/process-discounts`. |
| **Falsos positivos de subagentes** | Subagentes de diagnóstico sobre-reportan. `?.toFixed()` con optional chaining NO crashea — solo muestra `undefined`. **Verifica el código real** antes de aplicar fix sugerido por subagente, los números de línea pueden estar desactualizados. |
| **`console.log` dejado en producción** | `Asistencia.jsx:161` tiene `console.log("[edit-attendance] body:", ...)`. Si tocas ese archivo, quítalo. |
| **Constantes duplicadas** | `MONTHS` está duplicada en 14 páginas, `STATUS_CFG` en 6+. No agregues más duplicados — si necesitas una constante nueva en >2 lugares, plantea al usuario crear `src/constants/`. |
| **Roles hardcodeados inconsistentes** | Algunos archivos usan `["admin", "administrador", "master"]` y otros `["master", "administrador"]`. Verifica el patrón existente en el archivo antes de copiar. |
| **`server.py` está creciendo** | De 8,258 líneas (CLAUDE.md original) a **12,355 líneas** hoy (+50%). El monolito ya es difícil de navegar. No lo agraves: usa Grep para localizar la sección antes de leer. Si vas a agregar un dominio entero nuevo, plantea al usuario modularizar en `backend/routers/`. |
| **Migración receipts inconclusa** | 3 collections de receipts coexisten. Antes de tocar comprobantes, pregunta cuál es la canónica. |

---

## 12. Cuándo activar este skill / dónde buscar más

### Activa este skill SIEMPRE que:
- El usuario mencione **SistemaFRD, FRD, Inversiones FRD** explícitamente
- El usuario hable de **planilla, prorrateo, sueldo variable, boleta, adelantos, descuentos**
- El usuario mencione **tareas, asistencia, órdenes de trabajo (OT), almacén, caja chica, gastos, comprobantes**
- El usuario mencione **trabajadores, técnicos, jefe de operaciones, almacenero, maestro de obra**
- El working directory sea `C:\SistemaFRD\` o cualquier subcarpeta
- El usuario pida modificar `server.py`, `pdf_utils.py`, o cualquier archivo bajo `frontend/src/pages/` o `frontend/src/components/` del proyecto
- El usuario pida diseñar un módulo nuevo "para FRD"

### NO actives este skill cuando:
- El usuario trabaja en otro proyecto (verifica el working directory)
- La pregunta es genérica de React/FastAPI sin mención de FRD

### Dónde buscar más detalle (en orden de profundidad)
1. **`C:\SistemaFRD\.claude\CLAUDE.md`** — fuente de verdad operativa actualizada del proyecto: comandos pytest/yarn, regla de trabajo obligatoria, bucle de mejora autónoma, último estado de sesión, roadmap. **Léelo siempre al inicio de una sesión real de trabajo.**
2. **`references/full-audit.md`** (en este mismo skill) — auditoría completa de 590 líneas con las 10 secciones: stack, estructura, módulos, patrones, auth, estilo, configs, deuda técnica, docs, resumen ejecutivo.
3. **`C:\SistemaFRD\design_guidelines.json`** — paleta de colores, tipografía, layouts, componentes. Fuente única de verdad visual.
4. **`C:\SistemaFRD\memory\PRD.md`** — producto y changelog reciente (último update 2026-04-08).
5. **`C:\SistemaFRD\.claude\commands\`** — slash commands del proyecto: `/analizar`, `/auditar`, `/testear`, `/produccion-audit`.

### Si detectas drift entre este skill y la realidad
Avísale al usuario y propón actualizar el skill. No lo modifiques unilateralmente — los snapshots viven a una fecha y deben actualizarse en bloque, no por parches sueltos.

---

**Snapshot del proyecto:** 2026-04-26 · **Skill creado tras auditoría inicial completa**
