# Maintenance History Research Notes

- Created: 2025-11-08

## R1 – Home Screen Maintenance Section

- Static UI: `_buildMaintenanceCard` in `features/auth/presentation/screens/home_screen.dart` renders repeated placeholder cards (hardcoded description/date/cost).
- Current section anchored under title `"Historial de mantenimientos"` within `_buildBody`.
- No integration with providers; uses repeated calls `_buildMaintenanceCard(context)` rather than data-driven list.
- Empty-state currently absent; needs new layout with full-width card (padding 30, height 100, centered text).

## R2 – Provider & HTTP Service Patterns

- `domain/providers/motorcycle_provider.dart` maintains local `List<Motorcycle>` with `set`, `clear`, and async `getMotorcycles` calling `MotorcycleHttpService`.
- `MotorcycleHttpService.getMotorcycles` returns `List<Map<String, dynamic>>` mapped from backend JSON `{ userMotorcyclesRows: [...] }`.
- Pattern: service handles HTTP/JSON transformation, provider converts to model instances and updates state with `notifyListeners`.
- `MaintenanceProvider` currently empty; needs to mirror structure (list storage, fetch method, optional loading/error flags).

## R3 – Backend Endpoint & Schema

- `server.js` already declares placeholder `app.get("/motorcycle/:id/maintenance", ...)` but no implementation.
- Database `maintenance` table columns: `id`, `motorcycle_id`, `date` (DATE), `description` (TEXT), `cost` (DECIMAL 10,2).
- Expected flow: validate motorcycle exists (optional), query `SELECT * FROM maintenance WHERE motorcycle_id = $1 ORDER BY date DESC;`.
- Response should mirror motorcycle endpoint style, e.g., `{ maintenanceRows: [...] }` or direct array; consistency suggests wrapper object.
- Need to handle empty result by returning empty array and 200 OK.

## R4 – Empty-State Card Guidelines

- Flutter empty states typically wrap `Card` with `SizedBox` to constrain height/width; use `Padding` to respect horizontal spacing (30 px requested).
- Center text using `Center` widget or `Align` with alignment `Alignment.center`.
- Maintain neutral palette consistent with app theme; leverage `Theme.of(context).textTheme` for typography.
- Ensure empty state appears within scrollable column (e.g., `ListView.builder` replaced with conditional `SizedBox`).

## R5 – Profile Screen Requirements (2025-11-09)

- User data: `UserProvider` expone `user` con campos `fullName`, `email`, `phoneNumber`, etc. Para métricas se complementa con `MotorcycleProvider.motorcycles.length`.
- Layout solicitado: `SingleChildScrollView` con `padding const EdgeInsets.all(12)`, `SizedBox(height: 500)` y `Stack` que superpone imagen `assets/images/SL_092920_35860_04.jpg`, contenedor 100x100 con ícono `Icons.person`, y `Text` con el nombre completo.
- Tarjeta de estadísticas: `Card` de ancho completo y altura 100 con `Row` de tres `Column`, separadas por `VerticalDivider`. Valores: motos registradas (dinámico), carreras y ganadas (ambos 0 por ahora).
- Acciones: cinco filas estilo tile con icono (Add, Money, Compare, Edit, Settings), título y flecha (`Icons.chevron_right`) siguiendo paleta neutra (`AppColors.surfaceSoft`, `AppColors.neutralText`) y borde redondeado según `AppConstants.borderRadius`.
- Scroll: mantener espaciados consistentes (`SizedBox(height: 16/20)`) y tipografía del tema (`Theme.of(context).textTheme.titleMedium/bodyMedium`).


