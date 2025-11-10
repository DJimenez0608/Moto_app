import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuraciones')),
      body: const Center(child: Text('Ajusta la aplicación a tu medida.')),
    );
  }
}
