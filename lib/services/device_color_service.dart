import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceColorSchemes {
  const DeviceColorSchemes({required this.light, required this.dark});

  final ColorScheme light;
  final ColorScheme dark;
}

class DeviceColorService {
  static const _channel = MethodChannel('cards_wallet/appearance');

  static Future<DeviceColorSchemes?> load() async {
    try {
      final palette = await _channel.invokeMapMethod<String, dynamic>(
        'getSystemPalette',
      );
      if (palette == null) return null;
      return DeviceColorSchemes(
        light: _scheme(palette, Brightness.light),
        dark: _scheme(palette, Brightness.dark),
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static ColorScheme _scheme(
    Map<String, dynamic> palette,
    Brightness brightness,
  ) {
    final dark = brightness == Brightness.dark;
    final roles = (palette[dark ? 'dark' : 'light'] as Map?) ?? const {};
    Color tone(String name, double value) {
      final tones = Map<String, dynamic>.from(palette[name] as Map);
      final keys = tones.keys.map(int.parse).toList()..sort();
      final low = keys.lastWhere((key) => key <= value);
      final high = keys.firstWhere((key) => key >= value);
      final lower = Color(tones['$low'] as int);
      if (low == high) return lower;
      return Color.lerp(
        lower,
        Color(tones['$high'] as int),
        (value - low) / (high - low),
      )!;
    }

    Color role(String name, String family, double value) =>
        roles[name] is int ? Color(roles[name] as int) : tone(family, value);
    final base = ColorScheme.fromSeed(
      seedColor: tone('accent1', 40),
      brightness: brightness,
    );
    return base.copyWith(
      primary: role('primary', 'accent1', dark ? 80 : 40),
      onPrimary: role('on_primary', 'accent1', dark ? 20 : 100),
      primaryContainer: role('primary_container', 'accent1', dark ? 30 : 90),
      onPrimaryContainer: role(
        'on_primary_container',
        'accent1',
        dark ? 90 : 10,
      ),
      secondary: role('secondary', 'accent2', dark ? 80 : 40),
      onSecondary: role('on_secondary', 'accent2', dark ? 20 : 100),
      secondaryContainer: role(
        'secondary_container',
        'accent2',
        dark ? 30 : 90,
      ),
      onSecondaryContainer: role(
        'on_secondary_container',
        'accent2',
        dark ? 90 : 10,
      ),
      tertiary: role('tertiary', 'accent3', dark ? 80 : 40),
      onTertiary: role('on_tertiary', 'accent3', dark ? 20 : 100),
      tertiaryContainer: role('tertiary_container', 'accent3', dark ? 30 : 90),
      onTertiaryContainer: role(
        'on_tertiary_container',
        'accent3',
        dark ? 90 : 10,
      ),
      primaryFixed: tone('accent1', 90),
      primaryFixedDim: tone('accent1', 80),
      onPrimaryFixed: tone('accent1', 10),
      onPrimaryFixedVariant: tone('accent1', 30),
      secondaryFixed: tone('accent2', 90),
      secondaryFixedDim: tone('accent2', 80),
      onSecondaryFixed: tone('accent2', 10),
      onSecondaryFixedVariant: tone('accent2', 30),
      tertiaryFixed: tone('accent3', 90),
      tertiaryFixedDim: tone('accent3', 80),
      onTertiaryFixed: tone('accent3', 10),
      onTertiaryFixedVariant: tone('accent3', 30),
      surface: role('surface', 'neutral1', dark ? 6 : 98),
      onSurface: role('on_surface', 'neutral1', dark ? 90 : 10),
      onSurfaceVariant: role('on_surface_variant', 'neutral2', dark ? 80 : 30),
      surfaceDim: role('surface_dim', 'neutral1', dark ? 6 : 87),
      surfaceBright: role('surface_bright', 'neutral1', dark ? 24 : 98),
      surfaceContainerLowest: role(
        'surface_container_lowest',
        'neutral1',
        dark ? 4 : 100,
      ),
      surfaceContainerLow: role(
        'surface_container_low',
        'neutral1',
        dark ? 10 : 96,
      ),
      surfaceContainer: role('surface_container', 'neutral1', dark ? 12 : 94),
      surfaceContainerHigh: role(
        'surface_container_high',
        'neutral1',
        dark ? 17 : 92,
      ),
      surfaceContainerHighest: role(
        'surface_container_highest',
        'neutral1',
        dark ? 22 : 90,
      ),
      outline: role('outline', 'neutral2', dark ? 60 : 50),
      outlineVariant: role('outline_variant', 'neutral2', dark ? 30 : 80),
      inverseSurface: role('inverse_surface', 'neutral1', dark ? 90 : 20),
      onInverseSurface: role('inverse_on_surface', 'neutral1', dark ? 20 : 95),
      inversePrimary: role('inverse_primary', 'accent1', dark ? 40 : 80),
      surfaceTint: role('primary', 'accent1', dark ? 80 : 40),
      error: roles['error'] is int ? Color(roles['error'] as int) : base.error,
      onError: roles['on_error'] is int
          ? Color(roles['on_error'] as int)
          : base.onError,
      errorContainer: roles['error_container'] is int
          ? Color(roles['error_container'] as int)
          : base.errorContainer,
      onErrorContainer: roles['on_error_container'] is int
          ? Color(roles['on_error_container'] as int)
          : base.onErrorContainer,
    );
  }
}
