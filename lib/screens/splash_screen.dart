import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_constants.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 1. Initial Scale/Pop sequence
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60, // Hold state
      ),
    ]).animate(_controller);

    // 2. Shimmer sweep pattern for text
    _shimmerAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.0, end: -1.0),
        weight: 30, // Delay until pop finishes
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -1.0,
          end: 2.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 70, // Sweep light across
      ),
    ]).animate(_controller);

    _controller.forward();

    // Navigate to next screen after delay
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Popping Custom SVG Logo
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha:
                                0.15 * (_scaleAnimation.value).clamp(0.0, 1.0),
                          ),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'sources/logo.svg',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Active Shimmer Custom Text effect
                ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        isDark
                            ? Colors.white30
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                        isDark ? Colors.white : AppColors.primary,
                        isDark
                            ? Colors.white30
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment(_shimmerAnimation.value - 1.0, 0),
                      end: Alignment(_shimmerAnimation.value + 1.0, 0),
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'CITIZEN',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
