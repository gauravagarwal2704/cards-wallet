import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Zoom relative to edge-to-edge coverage; offsets select the visible crop.
class CardImagePlacement {
  final double zoom;
  final double x;
  final double y;

  const CardImagePlacement({this.zoom = 1, this.x = 0, this.y = 0});

  Rect imageRect(Size image, Size viewport) {
    final scale =
        math.max(viewport.width / image.width, viewport.height / image.height) *
        zoom.clamp(1.0, 4.0);
    final width = image.width * scale;
    final height = image.height * scale;
    return Rect.fromLTWH(
      -(width - viewport.width) * (x.clamp(-1.0, 1.0) + 1) / 2,
      -(height - viewport.height) * (y.clamp(-1.0, 1.0) + 1) / 2,
      width,
      height,
    );
  }

  static CardImagePlacement fromRect(Rect rect, Size viewport, double zoom) {
    double offset(double start, double overflow) =>
        overflow <= 0.001 ? 0 : (-2 * start / overflow - 1).clamp(-1.0, 1.0);
    return CardImagePlacement(
      zoom: zoom.clamp(1.0, 4.0),
      x: offset(rect.left, rect.width - viewport.width),
      y: offset(rect.top, rect.height - viewport.height),
    );
  }

  Map<String, double> toJson() => {'zoom': zoom, 'x': x, 'y': y};

  factory CardImagePlacement.fromJson(dynamic json) {
    if (json is! Map) return const CardImagePlacement();
    double value(String key, double fallback, double min, double max) {
      final raw = json[key];
      if (raw is! num || !raw.isFinite) return fallback;
      return raw.toDouble().clamp(min, max);
    }

    return CardImagePlacement(
      zoom: value('zoom', 1, 1, 4),
      x: value('x', 0, -1, 1),
      y: value('y', 0, -1, 1),
    );
  }
}
