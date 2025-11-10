# Research Notes

- `_buildMotorcycleCard` en `home_screen.dart` (79-137) actualmente muestra un `Icon` dentro de un `Container` fijo; requiere reemplazo por imagen con `Hero`.
- `Motorcycle` ofrece campos: `make`, `model`, `year`, `power`, `torque`, `type`, `displacement`, `fuelCapacity`, `weight`, `userId`.
- `MotorcycleProvider` expone lista `motorcycles` y notificará cambios; puede usarse para recuperar la moto por `id`.
- Assets disponibles: `assets/images/yamaha.jpg`, `assets/images/pulsar.png`, `assets/images/notImageFound.jpg`; todas deben presentarse con `BoxFit.contain`.
- Rediseño solicitado para `MotorcycleDetailScreen`: `Column` desplazable con `padding` 8, `Card` conteniendo filas título/valor separadas por `Divider`, valores resaltados en un contenedor rojo claro.

