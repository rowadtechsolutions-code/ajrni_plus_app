import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final value = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(value - 1, 0),
              end: Alignment(value + 1, 0),
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF8F8F8),
                Color(0xFFE8E8E8),
              ],
              stops: const [.25, .5, .75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class CardSkeleton extends StatelessWidget {
  final bool compact;

  const CardSkeleton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: compact ? 260.w : double.infinity,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: AppColors.border01),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(double.infinity, compact ? 136.h : 142.h, 9),
            SizedBox(height: 10.h),
            _box(170.w, 17.h, 5),
            SizedBox(height: 7.h),
            _box(110.w, 12.h, 4),
            SizedBox(height: 12.h),
            Row(
              children: [
                _box(85.w, 17.h, 4),
                const Spacer(),
                _box(120.w, 44.h, 9),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class OfficeSkeleton extends StatelessWidget {
  const OfficeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        height: 150.h,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: AppColors.border01),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: const BoxDecoration(
                    color: AppColors.gray,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    children: [
                      _line(double.infinity, 16),
                      SizedBox(height: 8.h),
                      _line(double.infinity, 11),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: _line(double.infinity, 42)),
                SizedBox(width: 12.w),
                Expanded(child: _line(double.infinity, 42)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(double width, double height) {
    return Container(
      width: width,
      height: height.h,
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(9.r),
      ),
    );
  }
}
