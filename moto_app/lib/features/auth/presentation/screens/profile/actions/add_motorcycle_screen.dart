import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/domain/models/soat.dart';
import 'package:moto_app/domain/models/technomechanical.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/features/auth/data/datasources/motorcycle_http_service.dart';
import 'package:moto_app/features/auth/data/services/firebase_storage_service.dart';
import 'package:moto_app/features/auth/data/utils/image_compression_service.dart';
import 'package:moto_app/features/auth/data/datasources/motorcycle_image_serpapi_service.dart';
import 'package:path_provider/path_provider.dart';

class AddMotorcycleScreen extends StatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  State<AddMotorcycleScreen> createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends State<AddMotorcycleScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final motorcycleProvider = context.watch<MotorcycleProvider>();
    final allMotorcycles = motorcycleProvider.motorcycles;
    final motorcycles = motorcycleProvider.searchMotorcyclesByMake(
      _searchQuery,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar motos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return const AddMotorcycleDialog();
            },
          );
        },
        backgroundColor: accentColor,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar moto',
                    suffixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildMotorcycleContent(
                    context: context,
                    allMotorcycles: allMotorcycles,
                    filteredMotorcycles: motorcycles,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotorcycleContent({
    required BuildContext context,
    required List<Motorcycle> filteredMotorcycles,
    required List<Motorcycle> allMotorcycles,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;

    if (allMotorcycles.isEmpty) {
      return Center(
        child: Text(
          'Aún no has registrado motocicletas.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (filteredMotorcycles.isEmpty) {
      return Center(
        child: Text(
          'No encontramos motos con esa marca.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: filteredMotorcycles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final motorcycle = filteredMotorcycles[index];
        final title = '${motorcycle.make} ${motorcycle.model}';

        return Slidable(
          key: ValueKey(motorcycle.id),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.198,
            children: [
              SlidableAction(
                onPressed:
                    (_) => _confirmDelete(
                      context: context,
                      motorcycle: motorcycle,
                    ),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete,
              ),
            ],
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.34,
                      height: 94,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppConstants.borderRadius),
                        ),
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.2),
                            blurRadius: 7,
                            spreadRadius: 1.1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppConstants.borderRadius),
                        ),
                        child:
                            motorcycle.photo != null
                                ? Image.network(
                                  motorcycle.photo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.motorcycle,
                                      size: 50,
                                      color: colorScheme.onSurfaceVariant,
                                    );
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                )
                                : Icon(
                                  Icons.motorcycle,
                                  size: 50,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddMotorcycleDialog extends StatefulWidget {
  const AddMotorcycleDialog({super.key});

  @override
  State<AddMotorcycleDialog> createState() => _AddMotorcycleDialogState();
}

class _AddMotorcycleDialogState extends State<AddMotorcycleDialog> {
  late final PageController _pageController;
  int _currentPage = 0;
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _soatCostController = TextEditingController();
  final TextEditingController _technomechanicalCostController =
      TextEditingController();
  DateTime? _soatDate;
  DateTime? _tecnomecanicaDate;
  File? _selectedImage;
  bool _cameraPermissionDenied = false;
  bool _showPermissionError = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _soatCostController.dispose();
    _technomechanicalCostController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double dialogWidth = mediaQuery.size.width * 0.85;
    final double dialogHeight = (mediaQuery.size.height * 0.65) - 40;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _DialogPageIndicator(currentPage: _currentPage, totalPages: 3),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildPhotoStep(context),
                    _buildBasicInfoStep(context),
                    _buildWellnessStep(context),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _DialogNavigationControls(
                currentPage: _currentPage,
                isLoading: _isCreating,
                onCancel: () => Navigator.of(context).pop(),
                onNext: () async {
                  if (_currentPage < 2) {
                    _goToPage(_currentPage + 1);
                  } else {
                    // Página 2: Crear motocicleta
                    await _createMotorcycle(context);
                  }
                },
                onPrevious: () {
                  if (_currentPage > 0) {
                    _goToPage(_currentPage - 1);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toma foto de tu moto',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Es con el fin de que puedas identificar la moto con facilidad, en caso de omitir ese paso se refleja un icono de motocicleta',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedImage != null) ...[
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  border: Border.all(
                    color: colorScheme.surfaceVariant.withOpacity(0.7),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.45),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: colorScheme.surfaceVariant.withOpacity(0.7),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _GlassActionTile(
                      icon: Icons.camera_alt_outlined,
                      label: 'Tomar foto',
                      onTap: _requestCameraPermission,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colorScheme.surfaceVariant.withOpacity(0.6),
                  ),
                  Expanded(
                    child: _GlassActionTile(
                      icon: Icons.photo_library_outlined,
                      label: 'Escoger de galería',
                      onTap: _pickImageFromGallery,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showPermissionError) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Acceso a cámara denegado: Para agregar una foto de la motocicleta hágalo con el botón "Escoger de galería" o diríjase a las configuraciones de la aplicación y habilite el permiso manualmente',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información básica de tu moto',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta información es esencial para completar la información de tu moto',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _LabeledTextField(
            label: 'Marca',
            controller: _makeController,
            hintText: 'Bajaj',
            border: inputBorder,
          ),
          const SizedBox(height: 16),
          _LabeledTextField(
            label: 'Modelo',
            controller: _modelController,
            hintText: 'eje: Pulsar 160 ns',
            border: inputBorder,
          ),
          const SizedBox(height: 16),
          _LabeledTextField(
            label: 'Año',
            controller: _yearController,
            hintText: 'eje: 2023',
            border: inputBorder,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Control del bienestar de tu moto',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta información es importante saberla para llevar un control del bienestar de tu moto, haciendo recordatorios del nuevo mantenimiento, renovación de SOAT, tecnomecánica, etc.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Text(
                  'Fecha compra de SOAT:',
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _DateSelectionRow(
                displayText: _formatDate(_soatDate),
                onPressed:
                    () => _selectDate(
                      currentValue: _soatDate,
                      onDateSelected: (value) => _soatDate = value,
                    ),
              ),
              const SizedBox(height: 16),
              _LabeledTextField(
                label: 'Costo (COP)',
                controller: _soatCostController,
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Text(
                  'Fecha última Tecnomecánica:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _DateSelectionRow(
                displayText: _formatDate(_tecnomecanicaDate),
                onPressed:
                    () => _selectDate(
                      currentValue: _tecnomecanicaDate,
                      onDateSelected: (value) => _tecnomecanicaDate = value,
                    ),
              ),
              const SizedBox(height: 16),
              _LabeledTextField(
                label: 'Costo (COP)',
                controller: _technomechanicalCostController,
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({
    required DateTime? currentValue,
    required void Function(DateTime date) onDateSelected,
  }) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentValue ?? now,
      firstDate: firstDate,
      lastDate: now,
    );

    if (selectedDate != null) {
      setState(() {
        onDateSelected(selectedDate);
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Elegir una fecha';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      // Primera vez que se solicita o se denegó previamente
      final result = await Permission.camera.request();

      if (result.isDenied) {
        // Se denegó nuevamente
        if (!_cameraPermissionDenied) {
          // Primera denegación: mostrar mensaje explicativo
          _cameraPermissionDenied = true;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Es importante otorgar el permiso de cámara para poder tomar una foto de la motocicleta que deseas registrar.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          // Segunda denegación: mostrar error en rojo
          setState(() {
            _showPermissionError = true;
          });
        }
      } else if (result.isPermanentlyDenied) {
        // Permiso permanentemente denegado
        setState(() {
          _showPermissionError = true;
        });
      } else if (result.isGranted) {
        // Permiso otorgado
        setState(() {
          _cameraPermissionDenied = false;
          _showPermissionError = false;
        });
        await _takePhoto();
      }
    } else if (status.isPermanentlyDenied) {
      // Ya estaba permanentemente denegado
      setState(() {
        _showPermissionError = true;
      });
    } else if (status.isGranted) {
      // Permiso ya otorgado
      await _takePhoto();
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showPermissionError = false;
      });
    }
  }

  Motorcycle _buildMotorcycleModel(int userId) {
    return Motorcycle(
      id: 0, // ID temporal, se asignará en el backend
      make:
          _makeController.text.isNotEmpty ? _makeController.text : 'Sin marca',
      model:
          _modelController.text.isNotEmpty
              ? _modelController.text
              : 'Sin modelo',
      year:
          _yearController.text.isNotEmpty
              ? int.parse(_yearController.text)
              : DateTime.now().year,
      power: 100,
      torque: 50,
      type: 'Standard',
      displacement: null,
      fuelCapacity: '10L',
      weight: 150,
      userId: userId,
    );
  }

  Soat _buildSoatModel() {
    final now = _soatDate ?? DateTime.now();
    final endDate = DateTime(now.year + 1, now.month, now.day);
    final cost =
        _soatCostController.text.isNotEmpty
            ? double.parse(_soatCostController.text)
            : 0.0;

    return Soat(
      id: 0, // ID temporal, se asignará en el backend
      motorcycleId: 0, // ID temporal, se asignará después de crear la moto
      startDate: now,
      endDate: endDate,
      cost: cost,
    );
  }

  Technomechanical _buildTechnomechanicalModel() {
    final now = _tecnomecanicaDate ?? DateTime.now();
    final endDate = DateTime(now.year + 1, now.month, now.day);
    final cost =
        _technomechanicalCostController.text.isNotEmpty
            ? double.parse(_technomechanicalCostController.text)
            : 0.0;

    return Technomechanical(
      id: 0, // ID temporal, se asignará en el backend
      motorcycleId: 0, // ID temporal, se asignará después de crear la moto
      startDate: now,
      endDate: endDate,
      cost: cost,
    );
  }

  Future<void> _createMotorcycle(BuildContext context) async {
    setState(() {
      _isCreating = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final motorcycleProvider = Provider.of<MotorcycleProvider>(
      context,
      listen: false,
    );

    if (userProvider.user == null) {
      setState(() {
        _isCreating = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo registrar la moto, inténtelo en otro momento',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Construir modelos
      final motorcycle = _buildMotorcycleModel(userProvider.user!.id);
      final soat = _buildSoatModel();
      final technomechanical = _buildTechnomechanicalModel();

      // Llamar al servicio HTTP
      final httpService = MotorcycleHttpService();
      final message = await httpService.addMotorcycle(
        userId: userProvider.user!.id,
        motorcycleData: motorcycle.toJson(),
        soatData: soat.toJson(),
        technomechanicalData: technomechanical.toJson(),
      );

      if (!mounted) return;

      // Solo si la creación fue exitosa, subir foto a Firebase Storage
      File? imageToUpload = _selectedImage;

      // Si no hay foto del usuario, obtener imagen de SerpAPI
      if (imageToUpload == null) {
        try {
          final serpapiService = MotorcycleImageSerpapiService();
          final imageUrl = await serpapiService.getMotorcycleImageUrl(
            motorcycle.make,
            motorcycle.model,
            motorcycle.year,
          );

          if (imageUrl != null) {
            // Descargar imagen desde URL
            final response = await http.get(Uri.parse(imageUrl));
            if (response.statusCode == 200) {
              final tempDir = await getTemporaryDirectory();
              final file = File(
                '${tempDir.path}/motorcycle_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
              await file.writeAsBytes(response.bodyBytes);
              imageToUpload = file;
            }
          }
        } catch (e) {
          // Si falla la obtención de imagen, continuar sin foto
          debugPrint('Error al obtener imagen de SerpAPI: $e');
        }
      }

      // Subir foto a Firebase Storage si existe
      if (imageToUpload != null) {
        try {
          final compressedImage =
              await ImageCompressionService.compressAndSaveToTemp(
                imageToUpload,
              );
          final storageService = FirebaseStorageService();
          await storageService.uploadMotorcyclePhoto(
            username: userProvider.user!.username,
            make: motorcycle.make,
            model: motorcycle.model,
            year: motorcycle.year,
            imageFile: compressedImage,
          );
        } catch (e) {
          // Si falla la subida, continuar sin mostrar error crítico
          debugPrint('Error al subir foto a Firebase Storage: $e');
        }
      }

      // Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );

      // Refrescar lista de motocicletas
      await motorcycleProvider.getMotorcycles(
        userProvider.user!.id,
        userProvider.user!.username,
      );

      // Cerrar diálogo
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _isCreating = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No se pudo registrar la moto, inténtelo en otro momento',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _DialogPageIndicator extends StatelessWidget {
  const _DialogPageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 20 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                isActive
                    ? colorScheme.primary
                    : colorScheme.surfaceVariant.withOpacity(0.6),
          ),
        );
      }),
    );
  }
}

class _DialogNavigationControls extends StatelessWidget {
  const _DialogNavigationControls({
    required this.currentPage,
    required this.isLoading,
    required this.onCancel,
    required this.onNext,
    required this.onPrevious,
  });

  final int currentPage;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: currentPage == 0 ? onCancel : onPrevious,
          child: Text(currentPage == 0 ? 'Cancelar' : 'Anterior'),
        ),
        if (currentPage == 0) ...[
          const SizedBox(width: 8),
          TextButton(onPressed: onNext, child: const Text('Omitir')),
        ],
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isLoading ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child:
              isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                  : Text(currentPage == 2 ? 'Crear' : 'Siguiente'),
        ),
      ],
    );
  }
}

class _GlassActionTile extends StatelessWidget {
  const _GlassActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.border,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final InputBorder border;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            border: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateSelectionRow extends StatelessWidget {
  const _DateSelectionRow({required this.displayText, required this.onPressed});

  final String displayText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            side: BorderSide(color: accentColor.withOpacity(0.4)),
            padding: const EdgeInsets.all(12),
          ),
          child: Icon(Icons.calendar_today_outlined, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: colorScheme.surfaceVariant.withOpacity(0.8),
              ),
              color: colorScheme.surface,
            ),
            child: Text(
              displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    displayText == 'Elegir una fecha'
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension on _AddMotorcycleScreenState {
  Future<void> _confirmDelete({
    required BuildContext context,
    required Motorcycle motorcycle,
  }) async {
    final theme = Theme.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadius * 1.5,
            ),
          ),
          title: const Text(
            '¿Está seguro de querer eliminar esta motocicleta?',
          ),
          content: const Text(
            'Al eliminar esta motocicleta se eliminará todo lo que esté relacionado a ella (mantenimientos, viajes, etc). Lo único que se mantendrá serán los gastos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final motorcycleProvider = context.read<MotorcycleProvider>();
    final userProvider = context.read<UserProvider>();

    try {
      final message = await motorcycleProvider.deleteMotorcycle(
        motorcycleId: motorcycle.id,
        userProvider: userProvider,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }
}
