import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final adaptiveWidth = ResponsiveUtils.getAdaptiveWidth(context);
    final adaptivePadding = padding ?? ResponsiveUtils.getAdaptivePadding(context);
    
    Widget content = Padding(
      padding: adaptivePadding,
      child: child,
    );

    if (centerContent && screenWidth >= ResponsiveBreakpoints.tablet) {
      content = Center(
        child: SizedBox(
          width: maxWidth ?? adaptiveWidth,
          child: content,
        ),
      );
    }

    return content;
  }
}