import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../helpers/dealer_text.dart';
import '../services/dealer_request_service.dart';

class DealerRequestsScreen extends StatefulWidget {
  const DealerRequestsScreen({super.key});

  @override
  State<DealerRequestsScreen> createState() => _DealerRequestsScreenState();
}

class _DealerRequestsScreenState extends State<DealerRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final id = context.read<AuthProvider>().session?.id ?? '';
    _future = DealerRequestService().getRequests(id);
  }

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
            child: Text(
              t.requests,
              style: getSemiBoldStyle(size: 20, color: AppColors.navy),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: 4,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, __) => const OfficeSkeleton(),
                  );
                }
                final requests = snapshot.data ?? const [];
                if (requests.isEmpty) {
                  return DataStateView(
                    title: t.requestsComingSoon,
                    subtitle: t.requestsAvailableOnWeb,
                    actionText: t.requests,
                    onRetry: () => setState(_load),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(_load),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, index) =>
                        _RequestCard(row: requests[index], text: t),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> row;
  final DealerText text;

  const _RequestCard({required this.row, required this.text});

  @override
  Widget build(BuildContext context) {
    final request = row['request'] is Map
        ? Map<String, dynamic>.from(row['request'])
        : row;
    final name =
        request['full_name']?.toString() ??
        request['customer_name']?.toString() ??
        (text.ar ? 'عميل' : 'Customer');
    final status = row['status']?.toString() ?? 'pending';
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border01),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              AppIcons.person,
              color: AppColors.primaryNormal,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: getSemiBoldStyle(size: 14, color: AppColors.black10),
                ),
                SizedBox(height: 3.h),
                Text(
                  request['phone_number']?.toString() ?? '',
                  style: getRegularStyle(size: 11, color: AppColors.font01),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              status,
              style: getMediumStyle(size: 10, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
