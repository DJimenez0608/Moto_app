## Moto Expenses UI Research

- Base scaffold should mirror profile action screens such as `add_motorcycle_screen.dart`, using `Scaffold` + `SafeArea` + `Padding` with `SingleChildScrollView`.
- Illuminated borders previously implemented with `BoxDecoration` combining `Border.all` and semi-transparent `boxShadow` to produce glow (see `AddMotorcycleScreen` cards).
- `fl_chart` pie examples: PieChart sections support `PieChartSectionData` with `radius`, `title`, `badgeWidget`, and interaction via `PieChart`'s `PieTouchData` callback to detect touched sections. Use `PieTouchData(touchCallback: (event, response) { ... })`.
- Tooltip behaviour: leverage `PieTouchData` with `touchTooltipData: PieTouchTooltipData(...)` or display `badgeWidget`/overlayed text based on current touched index.
- For dropdown years, reference Flutter `DropdownButton<int>` with `value` and `items`.
- Colors: maintain neutral surfaces and accent reds from `AppColors` (`primaryBlue`, `accentCoral`, `accentCoralLight`).

