import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/providers/history_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _progressAnim;
  late Animation<double> _zoomThrough;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Trigger history provider initialization (SharedPreferences load) during splash
    ref.read(historyProvider);

    // Setup single AnimationController (duration: 2200ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 1. Fade & Scale In (0.0 to 0.6 timeline)
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _scaleIn = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Progress Bar fills from 0% to 100% during 0.0 to 0.6 timeline
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // 2. Cinematic Eye Zoom-Through (0.6 to 1.0 timeline)
    _zoomThrough = Tween<double>(begin: 1.0, end: 25.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInExpo),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
      ),
    );

    // Transition when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go('/');
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B10), // Pitch-black background
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isZooming = _controller.value > 0.6;

          final double currentScale = isZooming
              ? _zoomThrough.value
              : _scaleIn.value;
          final double currentOpacity = isZooming
              ? _fadeOut.value
              : _fadeIn.value;
          final double progressValue = _progressAnim.value.clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Ambient Cyan Center Glow Spotlight
              Center(
                child: Container(
                  width: 380 * (isZooming ? (currentScale * 0.2) : 1.0),
                  height: 380 * (isZooming ? (currentScale * 0.2) : 1.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withValues(
                      alpha: (0.15 * currentOpacity).clamp(0.0, 1.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(
                          alpha: (0.35 * currentOpacity).clamp(0.0, 1.0),
                        ),
                        blurRadius: 140,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),

              // Layout Structure: Centered Column containing enlarged Logo and Progress Loader Bar
              Center(
                child: Opacity(
                  opacity: currentOpacity.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Enlarged Splash Logo (210 logical pixels, fit: BoxFit.contain)
                      Transform.scale(
                        scale: currentScale,
                        alignment: Alignment.center,
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(
                                  alpha: (0.45 * currentOpacity).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                ),
                                blurRadius: 40,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/trusight_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF0F172A),
                                    ),
                                    child: const Icon(
                                      Icons.visibility_outlined,
                                      color: Color(0xFF00E5FF),
                                      size: 90,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 2. Sleek Progress Loader Bar (180px x 4px, background 0xFF1E293B, cyan/violet gradient)
                      if (!isZooming)
                        Container(
                          width: 180,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 50),
                              width: 180 * progressValue,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00E5FF),
                                    Color(0xFFA855F7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
