import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class MyButton extends StatefulWidget {
  final Color? bGColor;
  final double heightButton;
  final String? textButton;
  final double textSize;
  final Color textColor;
  final Function()? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final Color? borderColor;
  final double borderRadius;

  const MyButton({
    super.key,
    this.bGColor,
    this.heightButton = 52,
    required this.textButton,
    this.textSize = 16,
    required this.onTap,
    this.textColor = Colors.white,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.borderColor,
    this.borderRadius = 12,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    final background = widget.isSecondary
        ? Colors.white
        : (widget.bGColor ?? AppColors.primaryNormal);
    final foreground = widget.isSecondary
        ? AppColors.primaryNormal
        : widget.textColor;
    return SizedBox(
      width: double.infinity,
      height: widget.heightButton.h,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          side: widget.borderColor != null
              ? BorderSide(color: widget.borderColor!)
              : widget.isSecondary
              ? const BorderSide(color: AppColors.primaryNormal)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          onTap: widget.isLoading ? null : widget.onTap,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20.sp, color: foreground),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        widget.textButton!,
                        style: TextStyle(
                          fontFamily: 'ibmPlexSansArabic',
                          fontWeight: FontWeight.w700,
                          fontSize: widget.textSize.sp,
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
