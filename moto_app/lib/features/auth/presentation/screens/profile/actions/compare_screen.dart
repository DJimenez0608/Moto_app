import 'package:flutter/material.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparar motos')),
      body: const Center(
        child: Text(
          'Compara diferentes modelos para encontrar la mejor opción.',
        ),
      ),
    );
  }
}
