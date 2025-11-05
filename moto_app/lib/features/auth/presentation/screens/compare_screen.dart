import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.pureBlack, AppColors.bluishGray],
            stops: [0.0, 0.7],
          ),
        ),
        child: Center(
          child: Text(
            'Comparar motos',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

