# Auditoría Inicial — SistemaFRD

**Fecha:** 2026-04-26
**Modo:** Solo lectura (ningún archivo de código modificado)
**Alcance:** Backend FastAPI + Frontend React + Configs + Documentación
**Método:** 4 subagentes en paralelo (Backend / Páginas Frontend / Core Frontend / Configs+Docs)

---

## 1. STACK Y VERSIONES

### Frontend
- **Framework:** React **19.0.0** + React DOM 19.0.0
- **Bundler / scripts:** react-scripts 5.0.1 + **CRACO 7.1.0** (override CRA)
- **Routing:** react-router-dom **7.5.1**
- **Estilos:** TailwindCSS **3.4.17** + tailwindcss-animate 1.0.7 + tailwind-merge 3.2.0
- **Sistema UI:** shadcn/ui estilo **new-york** (confirmado en `components.json`) — 45 componentes Radix instalados
- **Iconos:** **@phosphor-icons/react** ^2.1.10 (primario) + lucide-react ^0.507.0 (fallback shadcn)
- **HTTP:** axios ^1.8.4 instalado pero **no usado** — todas las páginas usan `fetch` nativo
- **Toasts:** sonner ^2.0.3
- **Formularios:** react-hook-form ^7.56.2 + zod ^3.24.4 + @hookform/resolvers ^5.0.1 instalados pero **no usados en ninguna página** (validación 100% manual)
- **Gráficos:** recharts ^3.6.0
- **Fechas:** date-fns ^4.1.0 + react-day-picker 8.10.1
- **PDF:** pdfjs-dist ^5.6.205 (visor)
- **Mapas:** leaflet ^1.9.4
- **Otros:** cmdk, embla-carousel-react, vaul, next-themes, input-otp, class-variance-authority, clsx, ajv
- **Package manager:** yarn 1.22.22

### Backend
- **Framework:** **FastAPI 0.110.1** + uvicorn 0.25.0
- **Lenguaje:** Python (sin versión declarada — asumible 3.9+ por motor/asyncio)
- **DB driver:** **Motor 3.3.1** (MongoDB async) + pymongo 4.5.0
- **Validación:** Pydantic >=2.6.4 (Pydantic v2)
- **Auth:** PyJWT >=2.10.1 + bcrypt 4.1.3 + passlib >=1.7.4 + python-jose >=3.3.0
- **PDFs:** ReportLab 4.4.10 + fpdf2 2.8.7
- **Tareas programadas:** APScheduler 3.11.2
- **HTTP async:** httpx >=0.27.0
- **Object storage:** **Cloudinary >=1.40.0** (migrado desde Emergent)
- **OAuth Google:** google-auth >=2.0.0 + requests-oauthlib >=2.0.0
- **IA:** **anthropic >=0.39.0** (Claude API para escaneo de comprobantes con visión)
- **Datos:** pandas >=2.2.0, numpy >=1.26.0
- **Tooling:** black, isort, flake8, mypy, pytest >=8.0.0
- **AWS:** boto3 >=1.34.129 (presente, uso desconocido)

### Base de datos
- **Motor:** MongoDB Atlas (cloud) — async via Motor
- **DB name:** `sistemafrd` (producción) / `test_database` (dev)
- **Conexión:** `motor.motor_asyncio.AsyncIOMotorClient(MONGO_URL)` — inicialización en `server.py` línea ~50
- **Collections detectadas:** **47**
- **Índices explícitos:** **NINGUNO detectado en código** ⚠️

### Otros servicios
- **Cloudinary:** Almacenamiento de fotos (3 vars: CLOUD_NAME, API_KEY, API_SECRET)
- **Google OAuth:** Autenticación primaria (CLIENT_ID, CLIENT_SECRET)
- **Anthropic Claude:** Escaneo IA de comprobantes
- **Railway:** Deploy producción (backend en `sistemafrd-production.up.railway.app`, frontend en `clever-rejoicing-production.up.railway.app`)

---

## 2. ESTRUCTURA DE CARPETAS

### Backend (3 niveles)

```
backend/
├── server.py                        ← MONOLITO (~12,355 líneas, creció ~4K vs CLAUDE.md)
├── pdf_utils.py                     ← 1,981 líneas, 15 generadores PDF
├── migrate_unified_receipts.py      ← Script de migración (~7K)
├── test_env.py                      ← Helper para tests
├── requirements.txt                 ← 33 dependencias
├── .env                             ← NO commiteado (correcto)
└── tests/
    ├── test_frd_api.py
    ├── test_payroll_v2.py
    ├── test_role_modules.py
    ├── test_attendance.py
    ├── test_expenses.py
    ├── test_warehouse.py
    ├── test_work_orders.py
    └── ... (43 archivos pytest total)
```

**Carpetas clave:** Solo `backend/` y `backend/tests/`. **No hay separación por dominio** (routers, models, services).

### Frontend (3 niveles)

```
frontend/
├── package.json                     ← React 19, 60+ deps
├── craco.config.js                  ← Alias @/* + watch options + plugin opcional
├── tailwind.config.js               ← HSL vars + tailwindcss-animate
├── components.json                  ← shadcn new-york + base color neutral
├── jsconfig.json                    ← @/* → src/*
├── README.md                        ← OBSOLETO (CRA default)
├── public/
│   ├── index.html
│   ├── logo-frd.jpg
│   └── pdf.worker.min.mjs
└── src/
    ├── App.js                       ← Router + 5 guards + 27 rutas
    ├── App.css
    ├── index.js
    ├── index.css                    ← Google Fonts (Chivo + IBM Plex) + shadcn vars
    ├── context/
    │   ├── AuthContext.js           ← Auth + check-in integrado
    │   └── ViewAsContext.js         ← "Ver como" (solo Master)
    ├── components/
    │   ├── AdminLayout.jsx          ← Sidebar + checkout flotante
    │   ├── ErrorBoundary.jsx        ← Class component, top-level
    │   ├── PdfBtn.jsx
    │   ├── PdfPreviewModal.jsx
    │   ├── CheckInModal.jsx         ← Gate de asistencia con GPS
    │   ├── GastoOTModal.jsx
    │   ├── SmartSelect.jsx          ← Autocompletado con debounce
    │   ├── ReceiptPicker.jsx
    │   ├── ReceiptScanModal.jsx
    │   ├── MaterialRequestModal.jsx
    │   ├── EquipmentRequestModal.jsx
    │   ├── SubcontractRequestModal.jsx
    │   ├── OTResourcePanel.jsx
    │   └── ui/                      ← 45 componentes shadcn (accordion, dialog, etc.)
    ├── pages/                       ← 26 páginas (default export)
    ├── data/
    │   └── roleContent.js           ← Responsabilidades + Reglas de Oro
    ├── hooks/
    │   └── use-toast.js             ← ⚠️ Wrap custom + Sonner (dual setup)
    └── lib/
        └── utils.js                 ← Solo cn()
```

**Carpetas clave:**
- `pages/` — 26 default exports
- `components/` — 13 componentes custom
- `components/ui/` — 45 shadcn (named exports)
- `context/` — 2 React Contexts globales
- **NO existe** `services/`, `hooks/` (más allá de use-toast), `constants/`, `schemas/`

---

## 3. MÓDULOS EXISTENTES

> **Resumen:** 26 módulos detectados. Todos en estado **completo / producción**. Cero módulos deprecados, cero módulos en desarrollo abierto. Patrón uniforme de roles con minor inconsistencias.

| # | Módulo | Frontend | Backend (endpoints) | Collections Mongo | Roles | Estado |
|---|---|---|---|---|---|---|
| 1 | **Auth & Users** | `Login.jsx`, `AuthCallback.jsx`, `UserManagement.jsx` | 6 endpoints `/auth/*` + 2 OAuth | `users`, `user_sessions` | public + master | ✅ Completo |
| 2 | **Dashboard** | `Dashboard.jsx` (1,178 líneas) | 2 endpoints `/dashboard/*` | (cross-domain) | todos los roles | ✅ Completo |
| 3 | **Workers** | `Workers.jsx` | 9 endpoints `/workers/*` | `workers` | admin, master | ✅ Completo |
| 4 | **Tasks** | `Tasks.jsx`, `WorkerPortal.jsx` | 10 + 8 (recurring) endpoints | `tasks`, `recurring_tasks` | admin, master, worker | ✅ Completo |
| 5 | **Recurring Tasks** | `Tasks.jsx` (modal) | 8 endpoints `/recurring-tasks/*` | `recurring_tasks` | admin, master | ✅ Completo |
| 6 | **Locations** | `Tasks.jsx`, `Maestros.jsx` | 5 endpoints `/locations/*` | `locations` | admin, master | ✅ Completo |
| 7 | **Payroll** | `Payroll.jsx` | 5 endpoints `/payroll/*` | (calculado de tasks/advances/discounts) | admin, master | ✅ Completo |
| 8 | **Advances** | `Advances.jsx` | 3 endpoints `/advances/*` | `advances` | admin, master | ✅ Completo |
| 9 | **Discounts** | `Advances.jsx` | 2 + 5 (attendance) endpoints | `discounts`, `attendance_discounts` | admin, master | ✅ Completo |
| 10 | **Attendance** | `Asistencia.jsx` (2,214 líneas) | **25+** endpoints `/attendance/*` | `attendance`, `attendance_settings`, `early_exit_requests` | admin, master, jefe_ops | ✅ Completo |
| 11 | **Overtime** | `Asistencia.jsx` (sub-tab) | 7 endpoints `/overtime/*` | `overtime_requests`, `overtime_memos` | admin, master | ✅ Completo |
| 12 | **Daily Reports** | `WorkerPortal.jsx` | 4 endpoints `/daily-reports/*` | `daily_reports` | técnico, master | ✅ Completo |
| 13 | **Work Orders** | `Ordenes.jsx` (1,778 líneas) | **18** endpoints `/work-orders/*` | `work_orders`, `ot_materials` | admin, master, jefe_ops | ✅ Completo |
| 14 | **Warehouse** | `Almacen.jsx` (1,393 líneas) | 13 endpoints `/warehouse/*` + `/inventory/*` | `warehouse_vouchers`, `warehouse_verifications`, `inventory_items` | almacenero, admin | ✅ Completo |
| 15 | **Petty Cash** | `CajaChica.jsx` (1,074 líneas) | 13 endpoints `/petty-cash/*` | `petty_cash_config`, `petty_cash_movements`, `petty_cash_arqueos` | admin, master | ✅ Completo |
| 16 | **Expenses** | `Gastos.jsx` (1,565 líneas) | **20+** endpoints `/expenses/*` | `expense_requests`, `expenses` (legacy) | admin, master, worker | ✅ Completo (cadena N1-N4) |
| 17 | **Receipts (escaneo IA)** | `Comprobantes.jsx` (1,140 líneas) | 5 endpoints `/receipts/*` | `receipts`, `unified_receipts`, `scanned_receipts` | admin, master | ✅ Completo (Anthropic) |
| 18 | **Reimbursements** | `Gastos.jsx` (sub-flow) | 2 endpoints `/reimbursements/*` | (queries cross-collection) | admin, worker | ✅ Completo |
| 19 | **Clients** | `Clients.jsx` | 5 endpoints `/clients/*` | `clients` | admin, master | ✅ Completo |
| 20 | **Client Requests** | `Requests.jsx` (1,917 líneas) | **11** endpoints `/requests/*` | `client_requests` | admin, master, worker | ✅ Completo |
| 21 | **Service Budgets** | `Presupuestos.jsx` | 5 endpoints `/service-budgets/*` | `service_budgets` | admin, master | ✅ Completo |
| 22 | **Purchase Orders** | `Almacen.jsx` (sub-tab) | 4 endpoints `/purchase-orders/*` | `purchase_orders` | almacenero, admin | ✅ Completo |
| 23 | **Tax Calendar (OSCE)** | `Contable.jsx` | 4 endpoints `/tax-calendar/*` | `tax_calendar` | admin, master | ✅ Completo |
| 24 | **Accounting Packages** | `Contable.jsx` | 7 endpoints `/accounting-packages/*` | `accounting_packages` | admin, master | ✅ Completo |
| 25 | **Company Accounts** | `CompanyAccounts.jsx` | (CRUD básico) | `company_accounts`, `company_account_movements` | master | ✅ Completo |
| 26 | **Maestros (catálogos)** | `Maestros.jsx` (1,369 líneas) | 16 endpoints (4 × herramientas/equipos/subcontratistas/proveedores) | `herramientas`, `equipos`, `subcontratistas`, `proveedores` | admin, master | ✅ Completo |
| 27 | **Projects** | `Proyectos.jsx` | 5 endpoints `/projects/*` | `projects` | admin, master | ✅ Completo |
| 28 | **Calendario Ocurrencias** | `CalendarioOcurrencias.jsx` | (consume `/work-orders/*/occurrences`) | (cross-domain) | admin, master | ✅ Completo |
| 29 | **Role Modules (RBAC)** | `GestionModulos.jsx` | 4 endpoints `/role-modules/*` | `role_modules` | master | ✅ Completo |
| 30 | **Mis Funciones** | `MisFunciones.jsx` | (estático, no consume API) | — | todos | ✅ Completo |
| 31 | **Reports** | `Reports.jsx` | 6+ endpoints `/reports/*` + PDF endpoints | (cross-domain) | admin, master, jefe_ops | ✅ Completo |

**Totales:**
- **285 endpoints** (281 en `api_router` + 4 en `app` para OAuth)
- **47 collections** MongoDB
- **88 modelos Pydantic** v2
- **15 generadores PDF** en `pdf_utils.py`

---

## 4. PATRONES DE CÓDIGO DETECTADOS

### Convenciones de naming
- **Componentes React:** PascalCase (`Dashboard`, `Ordenes`, `WorkerPortal`)
- **Subcomponentes locales:** PascalCase dentro del archivo (`DetailModal`, `StatusDropdown`, `ConformityPanel`)
- **Variables / funciones:** camelCase (`fetchData`, `handleSave`, `editingOrder`, `showModal`)
- **Constantes de configuración:** UPPER_SNAKE_CASE (`API`, `STATUS_CFG`, `MONTHS`, `EMPTY_FORM`)
- **`data-testid`:** kebab-case (`add-worker-btn`, `month-select`, `ot-row-${id}`) — **cobertura parcial** (botones principales sí, inputs internos no)
- **Endpoints:** snake_case en path con guiones (`/work-orders/{id}/conformity`, `/petty-cash/movements`)
- **IDs Mongo:** Prefijos por dominio (`user_`, `wrk_`, `task_`, `adv_`, `ph_`)

### Patrón de componente típico (ref: `Ordenes.jsx`, 1,778 líneas)

```javascript
// 1. Imports (orden estricto)
import { useState, useEffect, useCallback } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import AdminLayout from "@/components/AdminLayout";
import { Plus, X, ... } from "@phosphor-icons/react";
import { toast } from "sonner";
import { SmartSelect } from "@/components/SmartSelect";

// 2. Constantes globales (fuera del componente)
const API = `${process.env.REACT_APP_BACKEND_URL}/api`;
const token = () => localStorage.getItem("session_token");
const STATUS_CFG = { ... };
const TABS = [ ... ];
const EMPTY_FORM = { ... };

// 3. Default export
export default function Ordenes() {
  // 4. Estados (agrupados lógicamente, sin reducer)
  const [orders, setOrders] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);
  const [loading, setLoading] = useState(true);

  // 5. fetchData con useCallback + AbortController
  const fetchData = useCallback(async (showLoading = true) => {
    if (showLoading) setLoading(true);
    try {
      const h = { Authorization: `Bearer ${token()}` };
      const res = await fetch(`${API}/work-orders`, { headers: h });
      if (res.ok) setOrders(await res.json());
    } catch (err) {
      if (err?.name !== "AbortError") console.warn("fetch error:", err);
    } finally {
      if (showLoading) setLoading(false);
    }
  }, []);

  // 6. useEffect carga inicial + manejo searchParams
  useEffect(() => { fetchData(true); }, [fetchData]);

  // 7. Handlers (validación inline, fetch inline, toast inline)
  const handleSave = async () => {
    if (!form.title.trim()) { toast.error("Título obligatorio"); return; }
    // fetch + toast
  };

  // 8. JSX: AdminLayout > header > tabs > section-card > tabla > modales
  return <AdminLayout>...</AdminLayout>;
}
```

### Patrón de router FastAPI

```python
# server.py es UN MONOLITO. Patrón:
api_router = APIRouter(prefix="/api")  # ← prefijo único

@api_router.post("/work-orders", response_model=WorkOrder)
async def create_work_order(
    data: WorkOrderCreate,           # ← Pydantic v2 model
    user = Depends(require_admin)    # ← dependency injection
):
    if not data.title:
        raise HTTPException(status_code=400, detail="Título requerido")

    doc = data.model_dump()
    doc["order_id"] = f"ot_{uuid4().hex[:12]}"
    doc["created_at"] = datetime.now(LIMA_TZ).isoformat()
    doc["created_by"] = user["user_id"]

    await db.work_orders.insert_one(doc)
    return doc

# Al final del archivo:
app.include_router(api_router)  # ← DESPUÉS del CORS middleware ✅
```

### Patrón de modelo Pydantic v2

```python
class WorkOrderCreate(BaseModel):
    title: str
    description: Optional[str] = None
    client_id: Optional[str] = None
    work_order_type: str
    priority: str = "normal"
    estimated_amount: Optional[float] = None
    start_date: Optional[str] = None
    due_date: Optional[str] = None
    assigned_to: Optional[List[str]] = []
```

- 88 BaseModel detectadas
- Mix con uso de `body: dict` en algunos endpoints (~20 casos) — **inconsistencia**

### Manejo de errores en frontend
- **Patrón 1 (40%):** `try/catch` + `finally` con `setLoading(false)`
- **Patrón 2 (50%):** `.then().catch().finally()` chain
- **Toast inline (100%):** `toast.error(err.detail || "Error")` después de `res.json().catch(() => ({}))`
- **AbortController:** Solo en Dashboard, Ordenes, Contable, Comprobantes, Gastos
- **ErrorBoundary:** Solo en Ordenes, GestionModulos, Requests (3 de 26 páginas) — **falta en `WorkerPortal.jsx` (2,328 líneas)**
- **Silent catch:** Algunas páginas hacen `.catch(() => {})` perdiendo el error sin notificar

### Manejo de errores en backend
- **HTTPException inline:** **367 usos**, sin middleware global
- Distribución de status codes:
  - 400: 165 (validaciones)
  - 404: 143 (recurso no existe)
  - 403: 43 (autorización)
  - 401: 12 (autenticación)
  - 500: 4 (server error explícito)
- Logger configurado pero uso inconsistente

### Llamadas API (frontend)
- **Cliente HTTP:** `fetch` nativo en **todas las 26 páginas**
- **`axios` está instalado pero no usado** ⚠️
- **Cero servicio centralizado:** Cada página construye `${API}/...`, `Authorization: Bearer ${token()}`, parseo de JSON, manejo de error
- Token leído desde `localStorage.getItem("session_token")`
- Headers construidos inline: `{ Authorization: "Bearer ...", "Content-Type": "application/json" }`

### Patrón de formularios
- **react-hook-form: 0 páginas** (instalado pero no usado)
- **zod: 0 páginas** (instalado pero no usado)
- **useState manual: 100% de las 26 páginas**
- Validación inline con `if (!form.field)` + `toast.error("...")`
- Mensajes de error duplicados literales entre páginas

---

## 5. SISTEMA DE AUTENTICACIÓN Y ROLES

### Mecanismo
- **Tipo:** Session-based con Bearer token (no JWT real, aunque PyJWT está instalado)
- Login: Google OAuth → backend genera `session_token` → guardado en `db.user_sessions` (TTL 7 días)
- Frontend almacena `session_token` en `localStorage`
- Cada request envía `Authorization: Bearer <session_token>` o header alternativo `session-token: <token>`
- Validación: `db.user_sessions.find_one({"session_token": token})` por request
- **No hay refresh token** — al expirar (7 días), redirect a login

### Roles definidos exactos (constantes en `server.py:30-33`)
```python
ADMIN_ROLES        = {"admin", "administrador", "master"}
FIELD_SUPERVISORS  = {"jefe_operaciones"}
NON_ADMIN_ROLES    = {"worker", "tecnico", "maestro", "almacenero"}
ALL_VALID_ROLES    = ADMIN_ROLES | FIELD_SUPERVISORS | NON_ADMIN_ROLES
```

**7 roles totales:** master, admin, administrador, jefe_operaciones, almacenero, maestro, tecnico (+ alias `worker` ≈ tecnico)

⚠️ **Inconsistencia "admin" vs "administrador":** El backend tiene `_normalize_approver_role()` que convierte `admin → administrador`, pero el frontend tiene checks contra ambos en distintos archivos (Dashboard usa `["admin", "administrador", "master"]`, Ordenes usa `["master", "administrador", "jefe_operaciones"]`).

### Protección de rutas backend (4 dependencies)
1. `get_current_user()` — Valida token, devuelve user dict (~200 endpoints)
2. `require_admin()` — Solo `ADMIN_ROLES` (~80 endpoints)
3. `require_field_or_admin()` — `ADMIN_ROLES | FIELD_SUPERVISORS` (~15 endpoints)
4. `require_master()` — Solo `"master"` (~10 endpoints, muy restrictivo)
5. `get_current_user_pdf()` — Variante flexible (acepta query param `share_token` para PDFs públicos firmados)

⚠️ **Patrón de ownership implícita** (ver `CLAUDE.md` lecciones 2026-04-17): Algunos endpoints `/api/<recurso>/{worker_id}` solo dependen de `get_current_user` sin validar ownership. CLAUDE.md confirma fix en commit `e569190` para `/payroll/*`, `/reimbursements`, `/unified-receipts/{id}/link`.

### Protección de rutas frontend (5 guards en `App.js`)
| Guard | Roles permitidos | Redirect si no |
|---|---|---|
| `MasterRoute` | `["master"]` | `/dashboard` |
| `AdminRoute` | `["admin", "administrador", "master"]` | `/dashboard` |
| `FieldRoute` | `["admin", "administrador", "master", "almacenero", "maestro", "jefe_operaciones"]` | `/mis-tareas` |
| `WorkerRoute` | Cualquier autenticado | `/login` |
| `PrivateRoute` | Cualquier autenticado | `/login` |
| `ModuleRoute` | Verifica `roleModules[mk] === false` (RBAC dinámico) | `/dashboard` |

**RootRedirect:** worker/tecnico → `/mis-tareas`, admin/master → `/dashboard`, otros → `/dashboard`.

**RBAC dinámico:** `GestionModulos.jsx` permite al master habilitar/deshabilitar 24 módulos por rol (collection `role_modules`). `AuthContext` carga estos módulos en `checkAuth()` y `AdminLayout` filtra el sidebar con `buildNav()`.

**"Ver como" (ViewAsContext):** Solo Master puede simular vistas de otros 5 roles. Re-fetch de `roleModules` al cambiar. Banner amarillo persistente en UI mientras está activo.

---

## 6. ESTILO VISUAL ACTUAL

### Paleta exacta (de `design_guidelines.json` + `tailwind.config.js`)

**Colores corporativos FRD:**
| Nombre | Hex | Uso |
|---|---|---|
| Navy | `#1a2744` | Sidebar, textos principales, CTAs primarios |
| Sky Blue | `#4db8e8` | Acento, focus rings, botones secundarios |
| Red-Orange | `#e85d26` | Destructivo, descuentos, alertas críticas |
| Yellow-Orange | `#f5a623` | Warnings, pendientes, master, tag |
| Green | `#10b981` | Completado, positivo |

**UI mapping:**
- Background: `#f8f9fc` (slate-50 custom)
- Surface: `#ffffff`
- Border: `#e2e8f0` (slate-200)
- Input bg: `#f1f5f9` (slate-100)
- Text main: `#0f172a` (slate-900)
- Text muted: `#64748b` (slate-600)

**Variables shadcn (HSL en `index.css`):** Estándar `--background`, `--primary`, `--destructive`, `--ring`, `--chart-1..5`, etc. Modo dark configurado pero no activamente usado en UI.

### Tipografías cargadas
**`index.css` línea 1 — Google Fonts:**
- **Chivo** (400, 600, 700, 900) — Títulos, números grandes, CTAs (estilo "Old Money Tech" / "Swiss Brutalist")
- **IBM Plex Sans** (400, 500, 600) — Cuerpo, formularios, datos tabulares
- Fallback: `-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`

**Tamaños canónicos:**
- h1: `text-4xl md:text-5xl font-black tracking-tighter text-[#1a2744]`
- h2: `text-2xl md:text-3xl font-bold tracking-tight`
- overline: `text-xs font-bold uppercase tracking-[0.2em]`

### Sistema de iconos
- **Primario:** `@phosphor-icons/react` ^2.1.10 (peso `regular` por defecto, `fill` para activos)
- **Secundario:** `lucide-react` ^0.507.0 (usado internamente por shadcn)

⚠️ **Discrepancia detectada:** `components.json` declara `iconLibrary: "lucide"` pero el código de páginas usa Phosphor. Generación de nuevos componentes shadcn agregará Lucide imports — convenir una regla o configurar shadcn con Phosphor.

### Componentes UI reutilizables
- **45 componentes shadcn** estilo `new-york` en `components/ui/` (named exports)
- **13 componentes custom** en `components/` (mix default/named)
- **No hay design system propio documentado** más allá de `design_guidelines.json`

### Patrón de layouts
- **`AdminLayout.jsx`** (343 líneas) — Sidebar fijo + main content + checkout flotante + check-in modal gate + ViewAsBanner. Mobile-first con drawer.
- **`WorkerPortal.jsx`** — Mobile-first con bottom nav (no usa AdminLayout, layout propio embebido en la página de 2,328 líneas).

---

## 7. CONFIGURACIÓN Y AMBIENTES

### Variables de entorno

**Frontend** (`frontend/.env`):
- `REACT_APP_BACKEND_URL` — URL del backend (única variable detectada)

**Backend** (`backend/.env`, no commiteado):
- `MONGO_URL` — Conexión MongoDB
- `DB_NAME` — Nombre BD
- `BACKEND_URL` — URL backend (default `http://localhost:8000`)
- `FRONTEND_URL` — URL frontend (para callbacks OAuth, default `http://localhost:3000`)
- `CORS_ORIGINS` — Origins CORS (comma-separated)
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`

⚠️ **Faltan variables esperadas según docs:** `JWT_SECRET`, `EMERGENT_LLM_KEY` (legacy), `ANTHROPIC_API_KEY` — verificar si se cargan por otro nombre.

### Configuración local vs producción
- **Local:** `.env` en cada carpeta (frontend / backend) con credenciales del usuario
- **Producción:** Variables seteadas en Railway dashboard, deploy automático en push a `main`
- **No hay ambiente staging** — push directo a producción

### CORS middleware (verificación crítica)
```python
# server.py línea 60: app = FastAPI(...)
# server.py línea 72-78: app.add_middleware(CORSMiddleware, ...)
# server.py línea 12,355: app.include_router(api_router)
```
✅ **ORDEN CORRECTO:** CORS middleware se registra **ANTES** del `include_router`. No hay riesgo de requests pre-flight bloqueados.

**Config CORS:**
- Origins: default `["https://clever-rejoicing-production.up.railway.app", "http://localhost:3000"]`, configurable via `CORS_ORIGINS`
- Methods: `["*"]`
- Headers: `["*"]`
- Allow credentials: `True`

### Falta documentación de ambiente
- ❌ No existe `frontend/.env.example`
- ❌ No existe `backend/.env.example`
- ❌ No existe instructivo de setup local en READMEs

---

## 8. INCONSISTENCIAS Y DEUDA TÉCNICA

### Patrones rotos / código duplicado

| # | Inconsistencia | Severidad | Archivos / Evidencia |
|---|---|---|---|
| 1 | **`fetch` inline en las 26 páginas** — cero servicio API centralizado | 🔴 Crítico | Toda `pages/*.jsx` |
| 2 | **`react-hook-form` y `zod` instalados pero no usados** — validación 100% manual | 🔴 Crítico | Toda `pages/*.jsx` |
| 3 | **`axios` instalado pero no usado** — todo es `fetch` nativo | 🟡 Medio | `package.json` vs uso real |
| 4 | **Constante `MONTHS` duplicada en 14 páginas** | 🟡 Medio | Tasks, Payroll, Advances, Reports, Dashboard, Contable, Asistencia, Ordenes, Gastos, Comprobantes, CajaChica, Presupuestos... |
| 5 | **Constante `STATUS_CFG` duplicada en 6+ páginas** con leves variaciones | 🟡 Medio | Ordenes, Requests, Almacen, CajaChica, Gastos, Contable |
| 6 | **Helper `token()` y `API` duplicados en 26 páginas** | 🟡 Medio | Toda `pages/*.jsx` |
| 7 | **`ErrorBoundary` solo en 3 páginas de 26** — falta en `WorkerPortal.jsx` (2,328 líneas) | 🟠 Alto | Solo Ordenes, GestionModulos, Requests |
| 8 | **`console.log` dejado en producción** | 🟡 Medio | `Asistencia.jsx:161` con `console.log("[edit-attendance] body:", ...)` |
| 9 | **Roles hardcodeados inconsistentemente** entre `["admin", "administrador", "master"]` y `["master", "administrador"]` | 🟠 Alto | Dashboard.jsx:55, Ordenes.jsx:98 |
| 10 | **Mix `body: dict` vs `BaseModel` en endpoints backend** (~20 casos con dict) | 🟡 Medio | server.py varios endpoints |
| 11 | **Backend monolítico** — `server.py` creció a **12,355 líneas** (CLAUDE.md decía 8,258, +50% sin refactor) | 🟠 Alto | server.py |
| 12 | **Cero índices MongoDB explícitos** — 698 operaciones inline en 47 collections | 🔴 Crítico | server.py |
| 13 | **`use-toast.js` custom + `Toaster` de sonner** — dual setup confuso | 🟡 Medio | hooks/use-toast.js vs App.js |
| 14 | **Patrón ownership implícita** parcialmente fixed — algunos endpoints aún sin validación de owner | 🟠 Alto | server.py (CLAUDE.md fix parcial commit e569190) |
| 15 | **3 collections de receipts coexisten** (`receipts`, `unified_receipts`, `scanned_receipts`) — migración incompleta | 🟠 Alto | `migrate_unified_receipts.py` presente |
| 16 | **`components.json` declara icon library `lucide` pero el código usa Phosphor** | 🟡 Medio | components.json vs uso |
| 17 | **`PETTY_CASH_MAX_EGRESS = 200.0` hardcoded** sin parametrización | 🟢 Bajo | server.py:6256 |
| 18 | **`LIMA_TZ` hardcoded** — sistema asume operación solo en Perú | 🟢 Bajo | server.py |
| 19 | **`fetchData` con `useCallback` solo en algunas páginas** — inconsistencia de re-renders | 🟡 Medio | Dashboard, Ordenes vs Tasks, Workers |
| 20 | **`@emergentbase/visual-edits` posiblemente deprecated** post-Cloudinary | 🟡 Medio | craco.config.js condicional |

### TODOs / FIXMEs encontrados
- **Cero TODOs/FIXMEs explícitos** en código frontend (limpio en este aspecto)
- Backend: 1 import comentado `#from emergentintegrations.llm.chat import ...` en server.py:15 (legacy)

### Archivos huérfanos / sin referencia
- **`./plugins/health-check/`** — referenciado condicionalmente en `craco.config.js` pero archivos no localizados
- **`@emergentbase/visual-edits`** — devDependency con carga condicional, probablemente stale
- **`backend/test_env.py`** — helper para tests, verificar uso real
- **`backend/migrate_unified_receipts.py`** — script de migración, ¿ya ejecutado en producción?

### Discrepancia con CLAUDE.md
- **CLAUDE.md dice `server.py` tiene ~8,258 líneas; auditoría detectó ~12,355 líneas** → CLAUDE.md desactualizado en este punto (+4,000 líneas desde última actualización del doc).

---

## 9. DOCUMENTACIÓN EXISTENTE

| Archivo | Estado | Notas |
|---|---|---|
| `README.md` (raíz) | ❌ **VACÍO** | Solo "# Here are your Instructions" — placeholder |
| `frontend/README.md` | ❌ **OBSOLETO** | Default de Create React App, sin customización FRD |
| `DEVELOPER_DOCS.md` | ⚠️ **PARCIALMENTE DESACTUALIZADO** | Menciona React 18 (actual 19), schema BD truncada en línea 200, marzo 2026 |
| `.claude/CLAUDE.md` | ✅ **VIGENTE Y RICO** | Es la fuente de verdad real del proyecto. Stack, arquitectura, reglas de negocio, lecciones aprendidas, roadmap, último estado de sesión. Único punto a actualizar: tamaño de `server.py` |
| `design_guidelines.json` | ✅ **VIGENTE** | Paleta, tipografía, layouts, componentes. Fuente única de verdad visual |
| `memory/PRD.md` | ✅ **VIGENTE** | Última actualización 2026-04-08. Cambios arq + changelog tareas 1-2 |
| `.claude/commands/analizar.md` | ✅ Activo | Slash command "Analizar antes de tocar código" |
| `.claude/commands/auditar.md` | ✅ Activo | Slash command "Auditoría de integridad" |
| `.claude/commands/testear.md` | ✅ Activo | Slash command "Revisión pre-entrega" |
| `.claude/commands/produccion-audit.md` | ✅ Activo | Slash command "Auditoría runtime producción" |
| `auth_testing.md` | ⚠️ Parcialmente desactualizado | Menciona cookies, actualidad usa Bearer headers |
| `image_testing.md` | ✅ Vigente | Reglas de validación de imágenes |
| `test_result.md` | ✅ Vigente | Protocolo entre main_agent y testing_agent |

**Resumen documentación:**
- **Fuente de verdad de facto:** `.claude/CLAUDE.md` (rico, actualizado, con lecciones)
- **Documentación visual:** `design_guidelines.json` (completa)
- **Documentación de producto:** `memory/PRD.md` (vigente)
- **READMEs públicos:** ❌ inexistentes en la práctica
- **No hay `.env.example`** ni `ARCHITECTURE.md` ni `CONTRIBUTING.md`

---

## 10. RESUMEN EJECUTIVO

### Salud general del proyecto: **7.0 / 10**

**Justificación breve:**
Sistema en producción estable con 26 módulos completos, cobertura funcional rica (planilla, asistencia con GPS, OTs, gastos con flujo N1-N4, escaneo IA de comprobantes, RBAC dinámico). Stack moderno (React 19, FastAPI 0.110, Pydantic v2). El producto funciona y sirve a una empresa real.

Pierde puntos por: backend monolítico de **12K líneas** sin separación, **cero índices MongoDB explícitos** sobre 47 collections, **fetch inline** repetido en 26 páginas sin servicio centralizado, **react-hook-form + zod instalados pero ignorados** (100% validación manual), READMEs públicos vacíos, dual setup confuso de toasts, y migración de receipts incompleta (3 collections coexisten).

### Top 3 fortalezas
1. **Cobertura funcional rica y madura** — 26 módulos, 285 endpoints, 88 modelos Pydantic, todos en producción y usados. RBAC dinámico configurable por master, "Ver como" para debugging, escaneo IA real con Claude API, planilla con prorrateo automático, asistencia GPS, generación PDF para 15 documentos.
2. **Convenciones internas consistentes** dentro de cada capa: nombres en kebab-case para `data-testid`, prefijos de IDs por dominio, default exports para páginas, named para shadcn, Chivo+IBM Plex como dual font, paleta de 5 colores corporativos respetada en todo el código.
3. **Documentación operacional sólida** en `.claude/CLAUDE.md` y `memory/PRD.md` — incluye lecciones aprendidas, protocolos de auto-verificación, bucle de mejora autónoma, roadmap con 6 ítems priorizados. CORS bien configurado (orden middleware/router correcto).

### Top 3 oportunidades de mejora
1. **Crear capa de servicios API centralizada en frontend** (`src/services/api.js`): elimina duplicación en 26 páginas, centraliza Bearer auth, retry, manejo de error 401 → logout automático. Reduce ~100 líneas por página.
2. **Adoptar `react-hook-form + zod`** (ya instalados, costo 0 deps): schemas reutilizables, validación uniforme, mensajes de error consistentes. Empezar por modales nuevos y migrar gradualmente.
3. **Modularizar `server.py`** (12,355 líneas → 15-20 routers por dominio en `backend/routers/`): mantiene compatibilidad con `include_router`, mejora navegación, reduce conflictos en merges. Empezar por dominios estables (workers, clients, locations).

### Top 3 riesgos detectados
1. 🔴 **Cero índices MongoDB sobre 698 operaciones** en 47 collections. Con crecimiento de datos (especialmente `attendance`, `tasks`, `expenses`, `unified_receipts`), las queries se degradarán linealmente. Riesgo de timeouts en `Dashboard.jsx` y reportes mensuales en próximos meses.
2. 🟠 **Auth ownership implícita parcialmente fixed** — el commit `e569190` arregló `/payroll/*`, `/reimbursements`, `/unified-receipts/{id}/link`, pero el patrón sigue siendo riesgoso. Cualquier endpoint nuevo con `{worker_id}` que solo dependa de `get_current_user` es vulnerable a leakage de datos entre técnicos.
3. 🟡 **Migración de receipts incompleta** — coexisten `receipts`, `unified_receipts`, `scanned_receipts` con script `migrate_unified_receipts.py` presente pero estado desconocido. Riesgo de inconsistencia entre frontend/backend si distintos endpoints leen de distintas collections.

### Recomendación clave: ¿qué deberíamos hacer ANTES de crear nuevos módulos?

**TRES tareas en orden estricto antes del próximo módulo nuevo:**

1. **Crear índices MongoDB para las 10 collections más consultadas** (attendance, tasks, expenses, unified_receipts, work_orders, advances, discounts, requests, petty_cash_movements, daily_reports). 1-2 horas de trabajo, evita degradación inevitable. Crear script `backend/setup_indexes.py` idempotente.

2. **Crear `src/services/api.js` con wrapper fetch + interceptor 401** (~80 líneas). NO migrar las 26 páginas — solo dejar la herramienta lista. Adoptarla en módulos NUEVOS desde día 1. Esto evita seguir multiplicando deuda técnica.

3. **Auditar y cerrar la migración de receipts** — definir cuál es la collection canónica (`unified_receipts` parece ser la dirección), ejecutar `migrate_unified_receipts.py` si no se ejecutó, deprecar las otras dos en código y agendar un sweep para eliminarlas. Actualizar `CLAUDE.md` con la decisión.

**Tarea complementaria (no bloqueante):** Actualizar `.claude/CLAUDE.md` con el tamaño real de `server.py` (12,355 líneas) y agregar "índices MongoDB" + "ownership implícita" a la sección de lecciones aprendidas como riesgos vivos.

---

## ANEXO — Notas de método

- **4 subagentes en paralelo:** Backend (server.py por secciones + tests + requirements), Frontend Páginas (26 archivos), Frontend Core (App + contexts + components), Configs+Docs.
- **Tiempo total real:** ~10 minutos (vs 12-18 estimados).
- **Archivos no leídos contenido completo:** `server.py` (12,355 líneas) — leído por secciones + grep de patrones; `pdf_utils.py` (1,981) — head + grep de funciones; las 5 páginas >1500 líneas — head + grep.
- **Carpetas excluidas confirmadas:** `node_modules`, `.git`, `__pycache__`, `dist`, `build`, `venv`.
- **Modificaciones realizadas:** **Cero archivos de código tocados.** Único archivo escrito: este reporte.

---

**Reporte generado por auditoría inicial — 2026-04-26**
