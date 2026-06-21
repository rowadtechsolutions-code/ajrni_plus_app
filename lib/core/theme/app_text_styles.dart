import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

TextStyle _getTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  Color? color,
}) {
  return TextStyle(
    fontFamily: 'ibmPlexSansArabic',
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    color: color ?? AppColors.font01,
  );
}

// ================= REGULAR =================

TextStyle getRegularStyle({required double size, Color? color}) =>
    _getTextStyle(fontSize: size, fontWeight: FontWeight.w400, color: color);

// ================= MEDIUM =================

TextStyle getMediumStyle({required double size, Color? color}) =>
    _getTextStyle(fontSize: size, fontWeight: FontWeight.w500, color: color);

// ================= SEMI BOLD =================

TextStyle getSemiBoldStyle({required double size, Color? color}) =>
    _getTextStyle(fontSize: size, fontWeight: FontWeight.w600, color: color);

// ================= BOLD =================

TextStyle getBoldStyle({required double size, Color? color}) =>
    _getTextStyle(fontSize: size, fontWeight: FontWeight.w700, color: color);
