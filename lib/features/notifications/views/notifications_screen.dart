import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../models/notification_model.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().refreshNotifications();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<NotificationsProvider>().refreshNotifications();
  }

  void _handleTap(NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationsProvider>().markAsRead(notification);
    }
    debugPrint('=========== NOTIFICATION TAPPED ===========');
    debugPrint('type: ${notification.type}');
    debugPrint('referenceId: ${notification.referenceId}');
    debugPrint('data: ${notification.data}');
    debugPrint('==========================================');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: l.notifications),
            if (provider.unreadCount > 0)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                child: TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    l.markAllAsRead,
                    style: getRegularStyle(size: 13, color: AppColors.primaryNormal),
                  ),
                ),
              ),
            Expanded(child: _buildBody(provider, l)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NotificationsProvider provider, AppLocalizations l) {
    if (provider.loading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarIconsOutline.dangerTriangle, size: 48.sp, color: AppColors.error),
              SizedBox(height: 12.h),
              Text(
                l.unexpectedError,
                style: getMediumStyle(size: 14, color: AppColors.font02),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNormal,
                  foregroundColor: AppColors.white,
                ),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(SolarIconsOutline.bell, size: 56.sp, color: AppColors.hint),
              SizedBox(height: 16.h),
              Text(
                l.noNotifications,
                style: getMediumStyle(size: 14, color: AppColors.font02),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: provider.notifications.length,
        separatorBuilder: (_, __) => SizedBox(height: 6.h),
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _handleTap(notification),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: unread ? AppColors.surfaceBlue : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: unread ? AppColors.primaryNormal.withValues(alpha: .15) : AppColors.border01,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconForType(notification.type),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: getMediumStyle(
                            size: 14,
                            color: unread ? AppColors.navy : AppColors.font02,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryNormal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: getRegularStyle(size: 12, color: AppColors.font01),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: getRegularStyle(size: 10, color: AppColors.hint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconForType(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'request_created':
        icon = SolarIconsOutline.documentText;
        color = AppColors.primaryNormal;
      case 'request_accepted':
        icon = SolarIconsOutline.checkCircle;
        color = AppColors.success;
      case 'request_rejected':
      case 'car_rejected':
        icon = SolarIconsOutline.closeCircle;
        color = AppColors.error;
      case 'request_cancelled':
        icon = SolarIconsOutline.closeCircle;
        color = AppColors.warning;
      case 'request_completed':
        icon = SolarIconsOutline.shieldCheck;
        color = AppColors.success;
      case 'new_customer_request':
        icon = SolarIconsOutline.user;
        color = AppColors.secondaryNormal;
      case 'car_approved':
        icon = SolarIconsOutline.checkCircle;
        color = AppColors.success;
      case 'office_approved':
        icon = SolarIconsOutline.buildings;
        color = AppColors.success;
      case 'promotion':
        icon = SolarIconsOutline.star;
        color = AppColors.secondaryNormal;
      default:
        icon = SolarIconsOutline.bell;
        color = AppColors.hint;
    }

    return Container(
      width: 36.r,
      height: 36.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18.sp),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
