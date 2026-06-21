import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets_app.dart';

class BgImageWidget extends StatelessWidget {
  const BgImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 0,
      start: 0,
      end: 0,
      child: SizedBox(
        height: 300.h,
        child: Image.asset(
          AssetsApp.loginBg,
          width: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
