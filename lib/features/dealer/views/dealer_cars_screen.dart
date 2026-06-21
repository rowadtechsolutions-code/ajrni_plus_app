import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cars/models/car_model.dart';
import '../helpers/dealer_text.dart';
import '../services/dealer_car_service.dart';
import 'dealer_car_form_screen.dart';

class DealerCarsScreen extends StatefulWidget {
  final VoidCallback onChanged;

  const DealerCarsScreen({super.key, required this.onChanged});

  @override
  State<DealerCarsScreen> createState() => _DealerCarsScreenState();
}

class _DealerCarsScreenState extends State<DealerCarsScreen> {
  final _service = DealerCarService();
  late Future<List<CarModel>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final officeId = context.read<AuthProvider>().session?.id ?? '';
    _future = officeId.isEmpty
        ? Future.value(const [])
        : _service.getCars(officeId);
  }

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    final office = context.watch<AuthProvider>().session?.office;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.dashboard,
                        style: getSemiBoldStyle(
                          size: 20,
                          color: AppColors.navy,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        office?.officeName ?? '',
                        style: getRegularStyle(
                          size: 12,
                          color: AppColors.font01,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: office?.isActive == true
                        ? AppColors.success.withValues(alpha: .12)
                        : AppColors.warning.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    office?.isActive == true ? t.active : t.pendingApproval,
                    style: getMediumStyle(
                      size: 10,
                      color: office?.isActive == true
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.myCars,
                    style: getSemiBoldStyle(size: 17, color: AppColors.black10),
                  ),
                ),
                SizedBox(
                  width: 138.w,
                  child: MyButton(
                    textButton: t.addCar,
                    icon: AppIcons.add,
                    heightButton: 44,
                    textSize: 12,
                    borderRadius: 9,
                    onTap: () => _openForm(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: FutureBuilder<List<CarModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: 3,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (_, __) => const CardSkeleton(),
                  );
                }
                if (snapshot.hasError) {
                  return DataStateView(
                    title: t.failed,
                    subtitle: snapshot.error.toString(),
                    actionText: t.myCars,
                    onRetry: _reload,
                  );
                }
                final cars = snapshot.data ?? const <CarModel>[];
                if (cars.isEmpty) {
                  return DataStateView(
                    title: t.noCars,
                    subtitle: '',
                    actionText: t.addCar,
                    onRetry: _openForm,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                    itemCount: cars.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (_, index) =>
                        _DealerCarCard(car: cars[index], onAction: _reload),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm([CarModel? car]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DealerCarFormScreen(car: car)),
    );
    if (changed == true) _reload();
  }

  void _reload() {
    setState(_load);
    widget.onChanged();
  }
}

class _DealerCarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onAction;

  const _DealerCarCard({required this.car, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    return Container(
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border01),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9.r),
            child: SizedBox(
              width: 88.w,
              height: 76.h,
              child: car.image.startsWith('http')
                  ? Image.network(
                      car.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        AssetsApp.hyundaiAvante,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(AssetsApp.hyundaiAvante, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getSemiBoldStyle(size: 14, color: AppColors.black10),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${car.brand} ${car.model} ${car.year ?? ''}',
                  style: getRegularStyle(size: 11, color: AppColors.font01),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      '${car.dailyPrice ?? '-'} ${car.currency}',
                      style: getSemiBoldStyle(
                        size: 13,
                        color: AppColors.primaryNormal,
                      ),
                    ),
                    const Spacer(),
                    _status(t),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(AppIcons.moreVert, size: 22.sp, color: AppColors.font01),
            onSelected: (value) =>
                value == 'edit' ? _edit(context) : _delete(context),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(t.edit)),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  t.delete,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _status(DealerText t) {
    final label = switch (car.status) {
      'rented' => t.rented,
      'maintenance' => t.maintenance,
      _ => t.available,
    };
    final available = car.status == 'available';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: available
            ? AppColors.success.withValues(alpha: .12)
            : AppColors.warning.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: getMediumStyle(
          size: 9,
          color: available ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DealerCarFormScreen(car: car)),
    );
    if (changed == true) onAction();
  }

  Future<void> _delete(BuildContext context) async {
    final t = DealerText.of(context);
    final confirmed = await showConfirmationDialog(
      context: context,
      title: t.deleteTitle,
      message: t.deleteMessage,
      confirmText: t.delete,
      cancelText: t.ar ? 'إلغاء' : 'Cancel',
      destructive: true,
    );
    if (!confirmed) return;
    await DealerCarService().delete(car);
    onAction();
  }
}
