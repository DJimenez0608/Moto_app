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


