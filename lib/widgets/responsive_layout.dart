import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    }

    if (screenWidth >= ResponsiveBreakpoints.mobile) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}