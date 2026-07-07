import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MyTextField extends StatefulWidget {
  final String label;
  final bool isRequired;
  final String hintText;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final bool showLabel;
  final String? Function(String?)? validator;
  final IconData? icon;
  final double labelSize;
  final double hintSize;
  final double fieldHeight;
  final double borderRadius;
  final double labelSpacing;
  final double textSize;
  final bool compact;
  final bool enabled;
  final Widget? labelSuffix;

  const MyTextField({
    super.key,
    this.label = '',
    this.isRequired = false,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.showLabel = true,
    this.maxLines = 1,
    this.validator,
    this.icon,
    this.labelSuffix,
    this.labelSize = 14,
    this.hintSize = 12,
    this.fieldHeight = 52,
    this.borderRadius = 12,
    this.labelSpacing = 12,
    this.textSize = 16,
    this.compact = false,
    this.enabled = true,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return SizedBox(
        width: 44.w,
        height: widget.fieldHeight.h,
        child: Center(child: widget.prefixIcon),
      );
    }
    if (widget.icon != null) {
      return SizedBox(
        width: 44.w,
        height: widget.compact ? widget.fieldHeight.h : 52.h,
        child: Center(
          child: Icon(widget.icon, size: 20.sp, color: AppColors.hint),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      validator: widget.validator,
      textAlignVertical: widget.compact ? TextAlignVertical.center : null,
      style: TextStyle(
        fontSize: widget.textSize.sp,
        color: AppColors.black10,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.hintSize.sp,
          color: AppColors.hint,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.white,
        prefixIcon: _buildPrefixIcon(),
        prefixIconConstraints: BoxConstraints(
          minWidth: 44.w,
          maxWidth: 44.w,
          minHeight: widget.compact ? widget.fieldHeight.h : 20.h,
        ),
        suffixIcon: widget.suffixIcon != null || widget.obscureText
            ? SizedBox(
                width: 44.w,
                height: widget.fieldHeight.h,
                child: widget.obscureText
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: 44.w,
                          height: widget.fieldHeight.h,
                        ),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.hint,
                          size: widget.compact ? 18.sp : 20.sp,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : Center(child: widget.suffixIcon),
              )
            : null,
        suffixIconConstraints: widget.suffixIcon != null || widget.obscureText
            ? BoxConstraints.tightFor(width: 44.w, height: widget.fieldHeight.h)
            : null,
        isDense: widget.compact,
        contentPadding: widget.compact
            ? EdgeInsetsDirectional.only(
                start: widget.prefixIcon == null && widget.icon == null
                    ? 12.w
                    : 0,
                end: widget.suffixIcon == null && !widget.obscureText
                    ? 12.w
                    : 0,
              )
            : EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: const BorderSide(color: AppColors.border01),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: BorderSide(color: AppColors.primaryNormal, width: 1.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          borderSide: BorderSide(color: AppColors.error, width: 1.w),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label, style: getMediumStyle(size: widget.labelSize)),
              if (widget.isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    fontSize: widget.labelSize.sp,
                    color: AppColors.error,
                  ),
                ),
              if (widget.labelSuffix != null) widget.labelSuffix!,
            ],
          ),
        SizedBox(height: widget.labelSpacing.h),
        widget.compact
            ? SizedBox(height: widget.fieldHeight.h, child: field)
            : field,
      ],
    );
  }
}
