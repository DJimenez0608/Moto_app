<!-- Temporary research notes for Add Motorcycle UI -->

## Home Screen Card Reference
- `HomeScreen._buildMotorcycleCard` shows current motorcycle layout with image + detailed metadata.
- For Add Motorcycle UI we only need concatenated `make` + `model`; no image or extra fields required.

## Provider Usage
- `MotorcycleProvider.motorcycles` exposes list already populated elsewhere (Profile screen reads it via `context.watch<MotorcycleProvider>()`).
- No dedicated fetch method needed if provider already loaded; we can read list via `context.watch`.

## flutter_slidable Notes
- Use `Slidable` widget wrapping each card.
- `ActionPane(motion: const BehindMotion(), children: [SlidableAction(...)])`.
- `SlidableAction` supports `onPressed`, `backgroundColor`, `foregroundColor`, `icon`.
- Set `onPressed` to empty handler for placeholder (e.g. `_`).

