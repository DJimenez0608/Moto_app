import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';

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

  String _getMotorcycleImagePath(int index) {
    switch (index % 3) {
      case 0:
        return 'assets/images/yamaha.jpg';
      case 1:
        return 'assets/images/pulsar.png';
      default:
        return 'assets/images/notImageFound.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final motorcycleProvider = context.watch<MotorcycleProvider>();
    final allMotorcycles = motorcycleProvider.motorcycles;
    final motorcycles = motorcycleProvider.searchMotorcyclesByMake(
      _searchQuery,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar motos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.5,
                      ),
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
    if (allMotorcycles.isEmpty) {
      return Center(
        child: Text(
          'Aún no has registrado motocicletas.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (filteredMotorcycles.isEmpty) {
      return Center(
        child: Text(
          'No encontramos motos con esa marca.',
          style: Theme.of(context).textTheme.bodyLarge,
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
        final imagePath = _getMotorcycleImagePath(index);

        return Slidable(
          key: ValueKey(motorcycle.id),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.198,
            children: [
              SlidableAction(
                onPressed: (_) {},
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
                        color: AppColors.surfaceAlt,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppConstants.borderRadius),
                        ),
                        border: Border.all(
                          color: AppColors.accentCoral.withValues(alpha: 0.3),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCoral.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 7,
                            spreadRadius: 1.1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppConstants.borderRadius),
                        ),
                        child: Image.asset(imagePath, fit: BoxFit.cover),
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
