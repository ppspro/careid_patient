import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Standardized Primary CTA Button for CareID Patient App.
///
/// Implements approved Figma node 17:55 specifications:
/// - Shape: [StadiumBorder] (radius 9999).
/// - Default Height: 56.0 dp.
/// - Width: Full width (`double.infinity`) by default, with optional custom width.
/// - Background: [AppColors.primary] (`#0A84FF`).
/// - Text: `Plus Jakarta Sans`, 16sp, FontWeight.w600, White.
/// - Shadow: Subtle blue glow `BoxShadow(color: Color(0x4D5B14B8), blurRadius: 12, offset: Offset(0, 4))` when enabled.
/// - Four Explicit Interactive States:
///   1. Default: Enabled, background `#0A84FF`, clickable.
///   2. Pressed: Active tap down effect, background `#0066CC`, splash effect.
///   3. Disabled (`onPressed == null`): background `#CBD5E1`, text white, shadow none, non-interactive.
///   4. Loading (`isLoading == true`): centered white CircularProgressIndicator (24x24, stroke 2.5), non-interactive.
/// - Optional leading and trailing icon support.
/// - 100% backward-compatible with all existing parameters (`label`, `text`, `icon`, `isLoading`, `onPressed`).
class PrimaryButton extends StatefulWidget {
  /// Button display text. Can be supplied via [text] or [label] for backwards compatibility.
  final String label;

  /// Callback when the button is tapped. When null, the button is disabled.
  final VoidCallback? onPressed;

  /// Indicates if an asynchronous operation is in progress.
  /// When true, replaces label with a centered white progress indicator and prevents user taps.
  final bool isLoading;

  /// Whether the button expands to fill available width. Defaults to true.
  final bool isFullWidth;

  /// Explicit custom width override. If specified, takes precedence over [isFullWidth].
  final double? width;

  /// Explicit custom height override. Defaults to 56.0 dp (Figma node 17:55 standard).
  final double height;

  /// Legacy/trailing icon parameter for backwards compatibility.
  final IconData? icon;

  /// Optional leading icon displayed before the label text.
  final IconData? leadingIcon;

  /// Optional trailing icon displayed after the label text.
  final IconData? trailingIcon;

  /// Optional custom leading widget displayed before the label text.
  final Widget? leading;

  /// Optional custom trailing widget displayed after the label text.
  final Widget? trailing;

  /// Optional custom gradient override. When provided, replaces solid background.
  final Gradient? gradient;

  /// Whether this button should use the signature CareID purple gradient (#A44CFF -> #5B14B8).
  final bool isGradient;

  /// Custom background color override. Defaults to [AppColors.primary] (`#0A84FF`) when isGradient is false.
  final Color? backgroundColor;

  /// Custom text color override. Defaults to [Colors.white].
  final Color? textColor;

  /// Custom disabled background color override. Defaults to `#CBD5E1`.
  final Color? disabledBackgroundColor;

  /// Custom disabled text color override. Defaults to [Colors.white].
  final Color? disabledTextColor;

  /// Custom pressed background color override. Defaults to `#0066CC`.
  final Color? pressedBackgroundColor;

  /// Custom ink splash color override. Defaults to `#330066CC`.
  final Color? splashColor;

  /// Custom text style override. Defaults to Plus Jakarta Sans w600 16sp.
  final TextStyle? textStyle;

  /// Custom font size override. Defaults to 16.0.
  final double? fontSize;

  /// Custom font weight override. Defaults to [FontWeight.w600].
  final FontWeight? fontWeight;

  /// Optional custom border radius in dp. When null, defaults to [StadiumBorder] (radius 9999).
  final double? borderRadius;

  /// Elevation control. When set to 0, disables the blue glow shadow.
  final double? elevation;

  /// Inner padding. Defaults to `EdgeInsets.symmetric(horizontal: 24.0)`.
  final EdgeInsetsGeometry? padding;

  /// Explicit enabled flag. Defaults to true. If false, acts as disabled.
  final bool enabled;

  const PrimaryButton({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 56.0,
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.leading,
    this.trailing,
    this.gradient,
    this.isGradient = true,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.pressedBackgroundColor,
    this.splashColor,
    this.textStyle,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.enabled = true,
  }) : label = label ?? text ?? '';

  /// Factory for signature CareID purple gradient CTA button
  const PrimaryButton.gradient({
    Key? key,
    String? label,
    String? text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    double? width,
    double height = 56.0,
    IconData? icon,
    IconData? leadingIcon,
    IconData? trailingIcon,
    Widget? leading,
    Widget? trailing,
    Gradient? gradient,
    Color? textColor,
    Color? disabledBackgroundColor,
    Color? disabledTextColor,
    Color? pressedBackgroundColor,
    Color? splashColor,
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    bool enabled = true,
  }) : this(
          key: key,
          label: label,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          width: width,
          height: height,
          icon: icon,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
          leading: leading,
          trailing: trailing,
          isGradient: true,
          gradient: gradient ?? AppColors.purpleGradient,
          textColor: textColor,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledTextColor: disabledTextColor,
          pressedBackgroundColor: pressedBackgroundColor,
          splashColor: splashColor,
          textStyle: textStyle,
          fontSize: fontSize,
          fontWeight: fontWeight,
          borderRadius: borderRadius,
          elevation: elevation,
          padding: padding,
          enabled: enabled,
        );

  /// Alias getter for [label] to ensure compatibility with callers accessing `button.text`.
  String get text => label;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEffectivelyEnabled =
        widget.enabled && widget.onPressed != null && !widget.isLoading;

    // 1. Interactive state color resolution
    final bool useGradient = (widget.isGradient || widget.gradient != null) &&
        (isEffectivelyEnabled || widget.isLoading);
    final Gradient? effectiveGradient = useGradient
        ? (widget.gradient ?? AppColors.purpleGradient)
        : null;

    final Color? effectiveBackgroundColor;
    if (!isEffectivelyEnabled && !widget.isLoading) {
      // State 3: Disabled
      effectiveBackgroundColor =
          widget.disabledBackgroundColor ?? const Color(0xFFCBD5E1);
    } else if (useGradient) {
      effectiveBackgroundColor = null; // Gradient will handle fill
    } else if (_isPressed && isEffectivelyEnabled) {
      // State 2: Pressed
      effectiveBackgroundColor =
          widget.pressedBackgroundColor ?? const Color(0xFF4A0E99);
    } else {
      // State 1: Default / State 4: Loading
      effectiveBackgroundColor = widget.backgroundColor ?? AppColors.primary;
    }

    // 2. Text and icon color resolution
    final Color effectiveTextColor = !isEffectivelyEnabled && !widget.isLoading
        ? (widget.disabledTextColor ?? Colors.white)
        : (widget.textColor ?? Colors.white);

    // 3. Shadow resolution (subtle blue glow for solid blue, soft purple shadow for purple gradient)
    final List<BoxShadow>? effectiveShadow;
    if (isEffectivelyEnabled &&
        (widget.elevation == null || widget.elevation! > 0)) {
      if (useGradient) {
        effectiveShadow = const [
          BoxShadow(
            color: Color(0x4D5B14B8),
            blurRadius: 12.0,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ];
      } else {
        effectiveShadow = const [
          BoxShadow(
            color: Color(0x330A84FF),
            blurRadius: 16.0,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ];
      }
    } else {
      effectiveShadow = null;
    }

    // 4. Shape resolution: StadiumBorder() by default (radius 9999)
    final ShapeBorder effectiveShape = widget.borderRadius != null
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius!),
          )
        : const StadiumBorder();

    // 5. Width and height resolution
    final double? effectiveWidth =
        widget.width ?? (widget.isFullWidth ? double.infinity : null);
    final double effectiveHeight = widget.height;

    // 6. Typography resolution: Plus Jakarta Sans 16sp w600 white
    final TextStyle effectiveTextStyle = widget.textStyle ??
        TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: widget.fontSize ?? 16.0,
          fontWeight: widget.fontWeight ?? FontWeight.w600,
          color: effectiveTextColor,
          letterSpacing: 0.2,
        );

    // 7. Icon resolution (leading and trailing)
    final IconData? effectiveTrailingIcon = widget.trailingIcon ?? widget.icon;

    final Widget? leadingWidget = widget.leading ??
        (widget.leadingIcon != null
            ? Icon(widget.leadingIcon, color: effectiveTextColor, size: 20)
            : null);

    final Widget? trailingWidget = widget.trailing ??
        (effectiveTrailingIcon != null
            ? Icon(effectiveTrailingIcon, color: effectiveTextColor, size: 20)
            : null);

    // 8. Content: Spinner for loading, Row of icons and text otherwise
    final Widget content;
    if (widget.isLoading) {
      // State 4: Loading spinner
      content = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: effectiveTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget,
          ],
        ],
      );
    }

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        gradient: effectiveGradient,
        shape: effectiveShape,
        shadows: effectiveShadow,
      ),
      child: Material(
        color: Colors.transparent,
        shape: effectiveShape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: effectiveShape,
          splashColor: widget.splashColor ??
              (useGradient
                  ? const Color(0x33A44CFF)
                  : const Color(0x335B14B8)),
          highlightColor: Colors.white.withValues(alpha: 0.15),
          onHighlightChanged: isEffectivelyEnabled
              ? (isHighlighted) {
                  setState(() => _isPressed = isHighlighted);
                }
              : null,
          onTap: isEffectivelyEnabled ? widget.onPressed : null,
          child: Padding(
            padding:
                widget.padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
