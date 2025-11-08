import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.pureWhite,
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

