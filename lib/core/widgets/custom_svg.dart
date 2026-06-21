import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvg extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final bool isFit;

  const CustomSvg({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.isFit = false,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      fit: isFit ? BoxFit.cover : BoxFit.contain,
    );
  }
}
