import 'package:flutter/material.dart';

/// Hides an overlay while retaining its layout slot. Hidden content is excluded
/// from painting, hit testing, focus, and accessibility.
class CardOverlaySlot extends StatelessWidget {
  const CardOverlaySlot({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => Visibility(
    visible: visible,
    maintainState: true,
    maintainAnimation: true,
    maintainSize: true,
    child: child,
  );
}
