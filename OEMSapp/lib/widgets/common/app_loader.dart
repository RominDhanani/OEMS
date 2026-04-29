import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final bool isTransparent;

  const AppLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: isTransparent 
                    ? Colors.transparent 
                    : Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _BrandedSpinner(),
                        if (message != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            message!,
                            style: GoogleFonts.inter(
                              color: isTransparent ? theme.primaryColor : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BrandedSpinner extends StatefulWidget {
  @override
  State<_BrandedSpinner> createState() => _BrandedSpinnerState();
}

class _BrandedSpinnerState extends State<_BrandedSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      )),
      child: Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF4338CA), // Indigo 700
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Handle
            Positioned(
              top: 0,
              child: Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Body
            Positioned(
              bottom: 0,
              child: Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 3,
                    color: const Color(0xFF4338CA),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

