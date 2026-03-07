/// RustDesk Design Tokens
/// 
/// Centralized design system constants for consistent UI across the app.
/// Based on a 4px base spacing unit and aligned typography scale.

import 'package:flutter/material.dart';

/// Spacing scale based on 4px unit
/// 
/// Usage: `Spacing.m` for 16px margin, `Spacing.l` for 24px padding
class Spacing {
  Spacing._();
  
  /// 4px - Extra small gaps
  static const double xs = 4.0;
  
  /// 8px - Small gaps, icon padding
  static const double s = 8.0;
  
  /// 12px - Medium-small gaps
  static const double ms = 12.0;
  
  /// 16px - Standard content spacing
  static const double m = 16.0;
  
  /// 20px - Common component margins
  static const double ml = 20.0;
  
  /// 24px - Large spacing, section gaps
  static const double l = 24.0;
  
  /// 32px - Extra large spacing
  static const double xl = 32.0;

  // ─────────────────────────────────────────────────────────────────
  // Component-specific spacing (matching existing values for compatibility)
  // ─────────────────────────────────────────────────────────────────
  
  /// Card left margin in settings
  static const double cardMargin = 15.0;
  
  /// Horizontal content margin
  static const double contentHMargin = 15.0;
  
  /// Sub-content horizontal margin (with indent)
  static const double contentHSubMargin = 48.0; // 15 + 33
  
  /// Checkbox left margin
  static const double checkboxLeftMargin = 10.0;
  
  /// Radio button left margin  
  static const double radioLeftMargin = 10.0;
  
  /// ListView bottom margin
  static const double listBottomMargin = 15.0;
  
  /// ID board container height
  static const double idBoardHeight = 57.0;
  
  /// Password board container height
  static const double passwordBoardHeight = 52.0;
}

/// Typography scale aligned with MyTheme
/// 
/// Usage: `Typography.titleLarge` for heading, `Typography.body` for content
class TypographyScale {
  TypographyScale._();
  
  /// 19px - Page titles, section headers
  static const double titleLarge = 19.0;
  
  /// 20px - Settings page title (legacy, prefer titleLarge)
  static const double title = 20.0;
  
  /// 16px - Label text, emphasized content
  static const double labelLarge = 16.0;
  
  /// 15px - Settings content text
  static const double content = 15.0;
  
  /// 14px - Body text, descriptions
  static const double body = 14.0;
  
  /// 12px - Small text, captions
  static const double caption = 12.0;
  
  /// 22px - ID display text
  static const double idDisplay = 22.0;
  
  /// 15px - Password display text
  static const double passwordDisplay = 15.0;
}

/// Brand gradient colors for themed components
/// 
/// Usage: `BrandGradients.installCard` for install/update cards
class BrandGradients {
  BrandGradients._();
  
  /// Pink gradient start color
  static const Color installCardStart = Color(0xFFE242BC);
  
  /// Coral gradient end color
  static const Color installCardEnd = Color(0xFFF4727C);
  
  /// Pre-built gradient for install/update cards
  static const LinearGradient installCard = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [installCardStart, installCardEnd],
  );
}

/// Common border radii used throughout the app
class Radii {
  Radii._();
  
  /// 5px - Small elements like tiles
  static const double small = 5.0;
  
  /// 8px - Buttons, inputs
  static const double medium = 8.0;
  
  /// 12px - Cards, frames
  static const double large = 12.0;
  
  /// 13px - Connection input container
  static const double container = 13.0;
  
  /// 16px - Peer cards
  static const double card = 16.0;
  
  /// 18px - Dialogs, modals
  static const double dialog = 18.0;
}
