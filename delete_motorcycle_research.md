## Delete Motorcycle Flow Notes

- `MotorcycleHttpService.getMotorcycles` already hits `/users/:id/motorcycles`; deletion endpoint should live at `/motorcycles/:id` to remove a single bike.
- Provider currently only sets and fetches. Need a dedicated `deleteMotorcycle` that calls service then refreshes list using `UserProvider` context.
- Backend schema: tables referencing `motorcycles` include `maintenance`, `observations`, `technomechanical`, `soat`, `travels` (via user). Cascading deletions should target dependent tables (`maintenance`, `observations`, `technomechanical`, `soat`, `travels` if linked) before removing motorcycle.
- Slidable delete currently uses `onPressed: (_) {}`; dialog can use `showDialog<void>` returning boolean and map to provider.delete.

