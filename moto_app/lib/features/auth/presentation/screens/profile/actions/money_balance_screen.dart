import 'package:flutter/material.dart';

class MoneyBalanceScreen extends StatelessWidget {
  const MoneyBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
      ),
      body: const Center(
        child: Text('Consulta y administra tus gastos de mantenimiento.'),
      ),
    );
  }
}

