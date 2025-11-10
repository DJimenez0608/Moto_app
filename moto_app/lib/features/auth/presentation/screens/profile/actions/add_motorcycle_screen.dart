import 'package:flutter/material.dart';

class AddMotorcycleScreen extends StatelessWidget {
  const AddMotorcycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar moto')),
      body: const Center(
        child: Text('Próximamente podrás agregar tu motocicleta.'),
      ),
    );
  }
}
