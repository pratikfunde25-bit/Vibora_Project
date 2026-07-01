import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

// ─────────────────────────────────────────────────────────
//  PRIMARY GRADIENT BUTTON
// ─────────────────────────────────────────────────────────
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 56, // Slightly taller for premium feel
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18), // Modern rounded corners
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ] : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(18),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: Colors.black),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  OUTLINED BUTTON
// ─────────────────────────────────────────────────────────
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? prefixWidget;
  final double height;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.prefixWidget,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixWidget != null) ...[prefixWidget!, const SizedBox(width: 10)],
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  APP TEXT FIELD
// ─────────────────────────────────────────────────────────
class AppTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20, color: Colors.white.withOpacity(0.7))
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 20,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffix,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GLASS CARD
// ─────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ??
              (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  APP AVATAR
// ─────────────────────────────────────────────────────────
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 44,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((e) => e[0].toUpperCase()).join();

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(initials),
              )
            : _buildFallback(initials),
      ),
    );
  }

  Widget _buildFallback(String initials) {
    return Container(
      color: backgroundColor ?? AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SHIMMER LOADER
// ─────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E3A) : const Color(0xFFE8E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.6),
        );
  }
}

// ─────────────────────────────────────────────────────────
//  CATEGORY CHIP
// ─────────────────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
//  GRADIENT BADGE
// ─────────────────────────────────────────────────────────
class GradientBadge extends StatelessWidget {
  final String label;
  final LinearGradient gradient;

  const GradientBadge({
    super.key,
    required this.label,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────
class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

// ─────────────────────────────────────────────────────────
//  SUCCESS OVERLAY
// ─────────────────────────────────────────────────────────
class SuccessOverlay extends StatelessWidget {
  final String message;

  const SuccessOverlay({
    super.key,
    required this.message,
  });

  static void show(BuildContext context, String message) {
    final overlay = OverlayEntry(
      builder: (context) => SuccessOverlay(message: message),
    );
    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 2), () => overlay.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4))
                .animate()
                .fadeIn(duration: 300.ms),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
          ),
        ],
      ),
    );
  }
}
