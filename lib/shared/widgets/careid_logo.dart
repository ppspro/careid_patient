import 'package:flutter/material.dart';

/// Supported visual variants of the authoritative CareID brand mark
enum CareIdLogoVariant {
  /// Horizontal lockup (Emblem + Wordmark side-by-side).
  /// Authoritative for Top App Bars (Figma 79x18 or 80x18).
  horizontal,

  /// Standalone CareID-only ID monogram logo (Figma exact 25x17 or 26x18).
  /// Authoritative for compact headers, record detail titles, cards, and badges.
  onlyId,

  /// Legacy emblem / ID monogram alias.
  emblem,

  /// Full stacked logo (Emblem on top, Wordmark centered below).
  /// Authoritative for Hero and Welcome onboarding surfaces (Figma 200x113 or 107x64).
  stacked,

  /// Standalone gradient wordmark without emblem.
  wordmark,
}

/// CareID Official Brand Logo Widget
/// Renders the authoritative CareID brand mark from the approved Figma design specification
/// (Node 20:19804 / 20:19759 / 20:25189 - 20:25206).
class CareIdLogo extends StatelessWidget {
  final CareIdLogoVariant variant;
  final double? size;
  final double? width;
  final double? height;
  final bool showWordmark;
  final bool isHorizontal;

  /// Default constructor with backwards compatibility
  const CareIdLogo({
    super.key,
    this.variant = CareIdLogoVariant.horizontal,
    this.size,
    this.width,
    this.height,
    this.showWordmark = true,
    this.isHorizontal = true,
  });

  /// Factory for top app bars and headers with full horizontal wordmark (Figma exact 79-80px x 18px)
  const CareIdLogo.horizontal({
    super.key,
    this.height = 18.0,
    this.width,
  })  : variant = CareIdLogoVariant.horizontal,
        size = null,
        showWordmark = true,
        isHorizontal = true;

  /// Factory for CareID-only ID monogram logo (Figma exact 25px x 17px, assets/images/careid_only_id.png)
  const CareIdLogo.onlyId({
    super.key,
    this.height = 17.0,
    this.width = 25.0,
  })  : variant = CareIdLogoVariant.onlyId,
        size = null,
        showWordmark = false,
        isHorizontal = false;

  /// Factory for compact headers and discipline hubs (Figma exact 25-27px x 17-18px)
  const CareIdLogo.emblem({
    super.key,
    this.height = 17.0,
    this.width = 25.0,
  })  : variant = CareIdLogoVariant.onlyId,
        size = null,
        showWordmark = false,
        isHorizontal = false;

  /// Factory for hero welcome and splash screens (Figma exact 200x113 or 107x64)
  const CareIdLogo.stacked({
    super.key,
    this.width = 200.0,
    this.height,
  })  : variant = CareIdLogoVariant.stacked,
        size = null,
        showWordmark = true,
        isHorizontal = false;

  /// Factory for wordmark-only instances
  const CareIdLogo.wordmark({
    super.key,
    this.width,
    this.height = 20.0,
  })  : variant = CareIdLogoVariant.wordmark,
        size = null,
        showWordmark = true,
        isHorizontal = true;

  @override
  Widget build(BuildContext context) {
    // 1. Determine active variant
    CareIdLogoVariant effectiveVariant = variant;
    if (!showWordmark) {
      effectiveVariant = CareIdLogoVariant.onlyId;
    } else if (isHorizontal && (height == null || height! <= 36.0) && variant == CareIdLogoVariant.horizontal) {
      effectiveVariant = CareIdLogoVariant.horizontal;
    }

    switch (effectiveVariant) {
      case CareIdLogoVariant.onlyId:
      case CareIdLogoVariant.emblem:
        // CareID-only ID asset native aspect ratio: 344 / 237 = 1.451 (Figma 25x17)
        final double effH = height ?? (size != null && size! <= 36.0 ? size! : 17.0);
        final double effW = width ?? (effH * (344.0 / 237.0));
        return Image.asset(
          'assets/images/careid_only_id.png',
          width: effW,
          height: effH,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );

      case CareIdLogoVariant.horizontal:
        // Asset ratio: 928 / 200 = 4.64. At height 18, width is ~83.5px.
        final double effH = height ?? (size != null && size! <= 36.0 ? size! : 18.0);
        final double effW = width ?? (effH * (928.0 / 200.0));
        return Image.asset(
          'assets/images/careid_logo_horizontal.png',
          width: effW,
          height: effH,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );

      case CareIdLogoVariant.stacked:
        // Asset ratio: 1248 / 747 = 1.67.
        final double effW = width ?? (size != null ? size! * 1.67 : (height != null ? height! * 1.67 : 200.0));
        final double effH = height ?? (effW / 1.67);
        return Image.asset(
          'assets/images/careid_logo.png',
          width: effW,
          height: effH,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );

      case CareIdLogoVariant.wordmark:
        // Asset ratio: 1183 / 366 = 3.23.
        final double effH = height ?? (size != null ? size! : 20.0);
        final double effW = width ?? (effH * (1183.0 / 366.0));
        return Image.asset(
          'assets/images/careid_wordmark.png',
          width: effW,
          height: effH,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );
    }
  }
}
