import 'package:flutter/material.dart';

class PremiumButton extends StatelessWidget {
  final String label;
  final String? loadingLabel;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final bool isFullWidth;
  final bool isOutlined;
  final double? width;
  final double height;
  final double borderRadius;

  const PremiumButton({
    super.key,
    required this.label,
    this.loadingLabel,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.isFullWidth = true,
    this.isOutlined = false,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.primaryColor;
    
    // Scale button when pressed (if enabled)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: isOutlined ? _buildOutlinedButton(context, primaryColor) : _buildFilledButton(context, primaryColor),
    );
  }

  Widget _buildFilledButton(BuildContext context, Color primaryColor) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: isLoading ? 0 : 4,
        shadowColor: primaryColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return primaryColor.withOpacity(0.6);
          }
          return primaryColor;
        }),
      ),
      child: _buildContent(Colors.white),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, Color primaryColor) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: primaryColor.withOpacity(0.3), width: 2);
          }
          return BorderSide(color: primaryColor, width: 2);
        }),
      ),
      child: _buildContent(primaryColor),
    );
  }

  Widget _buildContent(Color textColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
                if (loadingLabel != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    loadingLabel!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: textColor,
                    ),
                  ),
                ],
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: textColor,
                  ),
                ),
              ],
            ),
    );
  }
}
