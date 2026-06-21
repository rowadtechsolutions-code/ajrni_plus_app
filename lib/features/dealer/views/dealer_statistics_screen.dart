import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cars/models/car_model.dart';
import '../helpers/dealer_text.dart';
import '../services/dealer_car_service.dart';
import '../services/dealer_request_service.dart';

class DealerStatisticsScreen extends StatefulWidget {
  const DealerStatisticsScreen({super.key});

  @override
  State<DealerStatisticsScreen> createState() => _DealerStatisticsScreenState();
}

class _DealerStatisticsScreenState extends State<DealerStatisticsScreen> {
  late Future<(int, int, int, int)> _future;

  @override
  void initState() {
    super.initState();
    final id = context.read<AuthProvider>().session?.id ?? '';
    _future = _load(id);
  }

  Future<(int, int, int, int)> _load(String id) async {
    final values = await Future.wait([
      DealerCarService().getCars(id),
      DealerRequestService().getRequests(id),
    ]);
    final cars = values[0] as List<CarModel>;
    final requests = values[1] as List<Map<String, dynamic>>;
    final available = cars.where((car) => car.status == 'available').length;
    final pending = requests
        .where((row) => row['status']?.toString() == 'pending')
        .length;
    return (cars.length, available, requests.length, pending);
  }

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.statistics,
              style: getSemiBoldStyle(size: 20, color: AppColors.navy),
            ),
            SizedBox(height: 20.h),
            FutureBuilder<(int, int, int, int)>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    children: [OfficeSkeleton(), OfficeSkeleton()],
                  );
                }
                final value = snapshot.data ?? (0, 0, 0, 0);
                final cards = [
                  (t.totalCars, value.$1, AppIcons.car),
                  (t.availableCars, value.$2, Icons.trending_up_rounded),
                  (t.totalRequests, value.$3, AppIcons.calendar),
                  (t.pendingRequests, value.$4, Icons.schedule_rounded),
                ];
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (_, index) {
                    final card = cards[index];
                    return Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(13.r),
                        border: Border.all(color: AppColors.border01),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            card.$3,
                            color: AppColors.primaryNormal,
                            size: 24.sp,
                          ),
                          Text(
                            card.$2.toString(),
                            style: getSemiBoldStyle(
                              size: 26,
                              color: AppColors.navy,
                            ),
                          ),
                          Text(
                            card.$1,
                            style: getRegularStyle(
                              size: 11,
                              color: AppColors.font01,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              height: 180.h,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(color: AppColors.border01),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.latestRequests,
                    style: getSemiBoldStyle(size: 16, color: AppColors.black10),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      t.noRequests,
                      style: getRegularStyle(size: 13, color: AppColors.font01),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
