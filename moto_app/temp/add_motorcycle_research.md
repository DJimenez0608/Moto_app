## Add Motorcycle Dialog Research Notes

- Dialog pattern: existing `AddMotorcycleScreen` uses `showDialog` for delete confirmation with rounded corners and `AppConstants.borderRadius`.
- Theming cues: use `AppColors.pureWhite`, `AppColors.surfaceAlt`, accents with `AppColors.primaryBlue` and `AppColors.accentCoral`.
- No shared date helpers or `showDatePicker` usage found; new UI will need inline DatePicker invocations (visual placeholders only for now).
- Validation utilities limited to per-screen implementations (e.g., password check in `SignUpScreen`); no shared validator module.
- Maintain minimalist styling: generous spacing (`16.0`), outlined inputs with rounded borders, subtle shadows.

