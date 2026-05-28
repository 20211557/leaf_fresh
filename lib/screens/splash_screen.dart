import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import 'home/home_screen.dart';
import 'setup/setup_flow_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final service = SettingsService();
    final loadFuture = service.load();
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    final settings = await loadFuture;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => settings == null
            ? const SetupFlowScreen()
            : const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _RingDecoration(controller: _controller),
                  Container(
                    width: 156,
                    height: 156,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.agriculture_rounded,
                        size: 92,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),
            const Text(
              '농스트라다무스',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'N G S T R A D A M U S',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryMuted,
                letterSpacing: 4,
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: null,
                  minHeight: 3,
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.4),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'VERSION 1.0.0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _RingDecoration extends StatelessWidget {
  const _RingDecoration({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(controller.value);
        return SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _ring(diameter: 320 * t, opacity: (1 - t).clamp(0.1, 0.4)),
              _ring(diameter: 240 * t, opacity: (1 - t).clamp(0.15, 0.5)),
            ],
          ),
        );
      },
    );
  }

  Widget _ring({required double diameter, required double opacity}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: opacity),
          width: 1,
        ),
      ),
    );
  }
}
