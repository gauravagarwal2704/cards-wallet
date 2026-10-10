import 'package:cards_wallet/theme/app_theme.dart';
import 'package:cards_wallet/models/theme_config.dart';
import 'package:cards_wallet/widgets/swipeable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'outlined swipe actions fit narrow cards in light and dark themes',
    (tester) async {
      for (final mode in [AppBrightnessMode.light, AppBrightnessMode.dark]) {
        for (final width in [260.0, 400.0]) {
          final calls = <String>[];
          final theme = AppTheme.build(
            brightnessMode: mode,
            seedColor: Colors.purple,
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: width,
                    height: 200,
                    child: SwipeableCard(
                      key: ValueKey('$mode-$width'),
                      cardWidth: width,
                      cardHeight: 200,
                      onShare: () => calls.add('Share'),
                      onDelete: () => calls.add('Delete'),
                      onEdit: () => calls.add('Edit'),
                      child: const SizedBox.expand(
                        child: ColoredBox(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          for (final label in ['Share', 'Delete', 'Edit']) {
            await tester.drag(
              find.byType(SwipeableCard),
              Offset(-width * 0.6, 0),
            );
            await tester.pumpAndSettle();
            final buttons = tester
                .widgetList<OutlinedButton>(find.byType(OutlinedButton))
                .toList();
            expect(buttons, hasLength(3));
            for (final button in buttons) {
              expect(
                button.style!.backgroundColor!.resolve({}),
                Colors.transparent,
              );
              expect(button.style!.side!.resolve({})!.style, BorderStyle.solid);
              expect(
                tester.getSize(find.byWidget(button)).width,
                greaterThanOrEqualTo(48),
              );
            }
            final colors = buttons
                .map((button) => button.style!.foregroundColor!.resolve({}))
                .toList();
            expect(colors[0], theme.colorScheme.primary);
            expect(colors[1], theme.colorScheme.error);
            expect(colors[2], isNot(colors[1]));
            expect(colors[2], isNot(colors[0]));
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            expect(calls.last, label);
            expect(find.byType(OutlinedButton), findsNothing);
            expect(tester.takeException(), isNull);
          }
          expect(calls, ['Share', 'Delete', 'Edit']);
        }
      }
    },
  );
}
