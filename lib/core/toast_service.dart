// lib/core/toast_service.dart
import 'package:flutter/material.dart';

class ToastService {
  static void show(BuildContext context, String message, {bool isError = false}) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _BottomFadeToast(
        message: message,
        isError: isError,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

class _BottomFadeToast extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _BottomFadeToast({
    required this.message, 
    required this.isError, 
    required this.onDismiss
  });

  @override
  State<_BottomFadeToast> createState() => _BottomFadeToastState();
}

class _BottomFadeToastState extends State<_BottomFadeToast> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    // Show instantly, then start fade after 2 seconds
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        await _fadeController.forward();
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40), // Spacing from bottom
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity, // Takes maximum width
                margin: const EdgeInsets.symmetric(horizontal: 24), // Side padding
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.isError ? const Color(0xFFE53935) : const Color(0xFF2D3243),
                  borderRadius: BorderRadius.circular(16), // Slightly more squared for a modern bar look
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded( // Ensures text wraps correctly in the full-width bar
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}