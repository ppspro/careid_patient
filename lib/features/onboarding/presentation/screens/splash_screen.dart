import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/widgets/careid_logo.dart';
import 'welcome_screen.dart';

/// CareID Splash Screen
/// Faithfully reproduces Figma frame node 20:25191 ("Splash_Screen", 390x884)
/// located on canvas "Careid patient app" (node 17:55).
class SplashScreen extends StatefulWidget {
  final ApiClient? apiClient;
  final TokenStorage? tokenStorage;
  final Duration displayDuration;

  const SplashScreen({
    super.key,
    this.apiClient,
    this.tokenStorage,
    this.displayDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    _navigationTimer = Timer(widget.displayDuration, _proceedToNextScreen);
  }

  Future<void> _proceedToNextScreen() async {
    if (!mounted) return;

    final tokenStorage = widget.tokenStorage ??
        widget.apiClient?.tokenStorage ??
        AppTokenStorage();
    final token = await tokenStorage.getAccessToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Validate session against real backend contract (GET /api/v1/auth/me)
      final client = widget.apiClient ?? ApiClient(tokenStorage: tokenStorage);
      final meResult = await client.get<Map<String, dynamic>>(
        ApiEndpoints.authMe,
        requiresAuth: true,
      );

      if (!mounted) return;

      if (meResult.isSuccess) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
        return;
      } else {
        // Token is invalid/expired and refresh failed; clear credentials and route to welcome
        await tokenStorage.clear();
      }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) =>
            WelcomeScreen(apiClient: widget.apiClient),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E0B36),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _navigationTimer?.cancel();
          _proceedToNextScreen();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background photographic asset (Figma node 20:25193 image 9 / careid_splash_bg_image9.png)
            Image.asset(
              'assets/images/careid_splash_bg_image9.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1E0B36),
              ),
            ),

            // Authentic Patient Graphic overlay layer
            Image.asset(
              'assets/images/careid_splash_graphic.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

            // Subtle dark overlay gradient for high contrast
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0x881E0B36),
                  ],
                ),
              ),
            ),

            // Foreground Brand Elements & Security Seals
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 40),
                    // Centered CareID Logo
                    const Center(
                      child: CareIdLogo(
                        variant: CareIdLogoVariant.stacked,
                        width: 200,
                        height: 113,
                        isHorizontal: false,
                        showWordmark: true,
                      ),
                    ),

                    // Bottom Security Badge and Loading Indicator
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Security Vault Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0x405EEAD4),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 13,
                                  color: Color(0xFF5EEAD4),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'AES-256 · HIPAA Sovereign Vault',
                                  style: TextStyle(
                                    color: Color(0xFF5EEAD4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Activity indicator
                          const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF5EEAD4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
