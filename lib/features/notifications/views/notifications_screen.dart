import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/data_state_view.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: l.notifications,
              showDivider: false,
              horizontalPadding: 20,
            ),
            Expanded(
              child: DataStateView(
                title: l.noNotifications,
                subtitle: '',
                actionText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
