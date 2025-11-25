import 'package:flutter/material.dart';
import 'package:moto_app/core/constants/app_constants.dart';

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.trailing,
    this.borderRadius,
    this.backgroundColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius =
        borderRadius ?? BorderRadius.circular(AppConstants.borderRadius);
    final tileColor = backgroundColor ?? colorScheme.surface;
    final trailingWidget = trailing ??
        Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: radius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}




