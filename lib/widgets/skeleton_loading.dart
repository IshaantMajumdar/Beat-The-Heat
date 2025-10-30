import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class SkeletonLoadingBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoadingBox({
    Key? key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: const SizedBox(),
    );
  }
}

class WeatherSkeletonLoading extends StatefulWidget {
  const WeatherSkeletonLoading({Key? key}) : super(key: key);

  @override
  State<WeatherSkeletonLoading> createState() => _WeatherSkeletonLoadingState();
}

class _WeatherSkeletonLoadingState extends State<WeatherSkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppStyles.slowAnimation,
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Card(
            child: Padding(
              padding: AppStyles.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SkeletonLoadingBox(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLoadingBox(height: 24),
                            SizedBox(height: 8),
                            SkeletonLoadingBox(width: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(3, (index) => const SkeletonLoadingBox(
                      width: 80,
                      height: 60,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}