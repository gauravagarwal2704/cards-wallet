import 'package:cards_wallet/data/banks.dart';
import 'package:cards_wallet/data/card_designs.dart';
import 'package:cards_wallet/models/card_data.dart';
import 'package:cards_wallet/models/card_overlay_visibility.dart';
import 'package:cards_wallet/widgets/bank_logo.dart';
import 'package:cards_wallet/widgets/card_background_picker.dart';
import 'package:cards_wallet/widgets/card_background_surface.dart';
import 'package:cards_wallet/widgets/card_network_logo.dart';
import 'package:cards_wallet/widgets/card_tiles_grid.dart';
import 'package:cards_wallet/widgets/infinite_card_deck.dart';
import 'package:cards_wallet/widgets/wallet_card.dart';
import 'package:cards_wallet/widgets/wallet_card_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _face(CardOverlayVisibility visibility) => AspectRatio(
  aspectRatio: 1.586,
  child: WalletCardFace(
    bank: Banks.getById('hdfc'),
    network: CardNetwork.visa,
    categoryName: 'Credit',
    nickname: 'Everyday',
    cardNumber: '4111 1111 1111 1111',
    cardholderName: 'Test User',
    expiryDate: '12/30',
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    overlayVisibility: visibility,
  ),
);

Finder _painted(Finder finder) {
  final elements = finder.evaluate().where((element) {
    var visible = true;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is Visibility &&
          !(ancestor.widget as Visibility).visible) {
        visible = false;
        return false;
      }
      return true;
    });
    return visible;
  }).toSet();
  return find.byElementPredicate(elements.contains);
}

void main() {
  test('overlay preferences round-trip and apply only to custom images', () {
    final preferences = const CardOverlayVisibility()
        .withVisible(CardOverlay.bankLogo, false)
        .withVisible(CardOverlay.networkLogo, false);
    final card = CardData(
      encryptedCardNumber: 'encrypted',
      encryptedExpiryDate: 'encrypted',
      lastFourDigits: '1111',
      cardType: 'Visa',
      customBackgroundImagePath: '/image.jpg',
      overlayVisibility: preferences,
    );
    final restored = CardData.fromJson(card.toJson())
        .copyWith(cardNickname: 'New');
    expect(
      restored.effectiveOverlayVisibility.shows(CardOverlay.bankLogo),
      isFalse,
    );
    expect(
      restored.effectiveOverlayVisibility.shows(CardOverlay.networkLogo),
      isFalse,
    );
    expect(
      restored.effectiveOverlayVisibility.shows(CardOverlay.cardNumber),
      isTrue,
    );
    expect(
      restored
          .copyWith(clearCustomBackgroundImage: true)
          .effectiveOverlayVisibility
          .shows(CardOverlay.bankLogo),
      isTrue,
    );
    final legacy = card.toJson()..remove('hiddenCardOverlays');
    expect(CardData.fromJson(legacy).overlayVisibility.hidden, isEmpty);
    expect(CardOverlayVisibility.fromJson(['unknown', 'networkLogo']).hidden, {
      CardOverlay.networkLogo,
    });
  });

  testWidgets(
    'custom-image controls immediately hide and restore individual overlays',
    (tester) async {
      var visibility = const CardOverlayVisibility();
      var mode = CardBackgroundMode.customImage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    _face(visibility),
                    CardBackgroundPicker(
                      mode: mode,
                      selectedStyle: CardDesignStyle.gradient,
                      selectedDesign: null,
                      gradientStart: Colors.blue,
                      gradientEnd: Colors.black,
                      gradientAngle: 135,
                      customImagePath: '/missing/image.jpg',
                      backgroundImageBlur: 0,
                      onModeChanged: (next) => setState(() => mode = next),
                      onStyleChanged: (_) {},
                      onDesignChanged: (_) {},
                      onGradientChanged: (_, _) {},
                      onGradientAngleChanged: (_) {},
                      onCustomImageChanged: (_) {},
                      onBackgroundImageBlurChanged: (_) {},
                      overlayVisibility: visibility,
                      onOverlayVisibilityChanged: (next) =>
                          setState(() => visibility = next),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final assertions = <CardOverlay, Finder>{
        CardOverlay.networkLogo: find.byType(CardNetworkLogo),
        CardOverlay.bankLogo: find.byType(BankLogo),
        CardOverlay.contactless: find.byIcon(Icons.contactless),
        CardOverlay.category: find.text('CREDIT CARD'),
        CardOverlay.nickname: find.text('Everyday'),
        CardOverlay.cardNumber: find.text('4111 1111 1111 1111'),
        CardOverlay.cardholderName: find.text('TEST USER'),
        CardOverlay.expiryDate: find.text('12/30'),
      };
      for (final entry in assertions.entries) {
        final chip = find.byKey(ValueKey('card-overlay-${entry.key.name}'));
        expect(_painted(entry.value), findsOneWidget);
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(_painted(entry.value), findsNothing);
        final deselected = tester.widget<FilterChip>(chip);
        expect(deselected.selected, isFalse);
        expect(deselected.backgroundColor, Colors.transparent);
        expect(deselected.side!.style, BorderStyle.solid);
        if (entry.key != CardOverlay.cardNumber) {
          expect(_painted(find.text('4111 1111 1111 1111')), findsOneWidget);
        }
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(_painted(entry.value), findsOneWidget);
        final selected = tester.widget<FilterChip>(chip);
        expect(
          selected.selectedColor,
          Theme.of(tester.element(chip)).colorScheme.primary,
        );
      }
      await tester.ensureVisible(find.text('Gradient'));
      await tester.tap(find.text('Gradient'));
      await tester.pumpAndSettle();
      expect(find.text('Show on card'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'hiding overlays preserves every other slot across sizes and networks',
    (tester) async {
      final semantics = tester.ensureSemantics();
      for (final width in [300.0, 420.0]) {
        for (final network in [
          CardNetwork.visa,
          CardNetwork.mastercard,
          CardNetwork.rupay,
        ]) {
          var visibility = const CardOverlayVisibility();
          late void Function(CardOverlayVisibility) update;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: width,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        update = (next) => setState(() => visibility = next);
                        return AspectRatio(
                          aspectRatio: 1.586,
                          child: WalletCardFace(
                            bank: Banks.getById('hdfc'),
                            network: network,
                            categoryName: 'Credit',
                            nickname: 'Everyday',
                            cardNumber: '4111 1111 1111 1111',
                            cardholderName: 'Test User',
                            expiryDate: '12/30',
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            overlayVisibility: visibility,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final items = <CardOverlay, Finder>{
            CardOverlay.bankLogo: find.byType(BankLogo),
            CardOverlay.networkLogo: find.byType(CardNetworkLogo),
            CardOverlay.contactless: find.byIcon(Icons.contactless),
            CardOverlay.category: find.text('CREDIT CARD'),
            CardOverlay.nickname: find.text('Everyday'),
            CardOverlay.cardNumber: find.text('4111 1111 1111 1111'),
            CardOverlay.cardholderName: find.text('TEST USER'),
            CardOverlay.expiryDate: find.text('12/30'),
          };
          final baseline = {
            for (final entry in items.entries)
              entry.key: tester.getRect(entry.value),
          };
          for (final hidden in CardOverlay.values) {
            update(const CardOverlayVisibility().withVisible(hidden, false));
            await tester.pumpAndSettle();
            expect(_painted(items[hidden]!), findsNothing);
            for (final entry in items.entries.where(
              (entry) => entry.key != hidden,
            )) {
              expect(
                tester.getRect(entry.value),
                baseline[entry.key],
                reason:
                    '${entry.key.name} moved when ${hidden.name} was hidden at width $width',
              );
            }
            if (hidden == CardOverlay.nickname) {
              expect(
                tester.semantics
                    .simulatedAccessibilityTraversal()
                    .map((node) => node.label)
                    .join('\n'),
                isNot(contains('Everyday')),
              );
            }
          }
          expect(tester.takeException(), isNull);
        }
      }
      semantics.dispose();
    },
  );

  testWidgets('wallet tile and carousel honor hidden custom-image overlays', (
    tester,
  ) async {
    final card = CardData(
      encryptedCardNumber: 'encrypted',
      encryptedExpiryDate: 'encrypted',
      lastFourDigits: '1111',
      cardType: 'Visa',
      id: 'custom-card',
      bankId: 'hdfc',
      cardNickname: 'Everyday',
      customBackgroundImagePath: '/missing/image.jpg',
      overlayVisibility: CardOverlayVisibility(
        hidden: CardOverlay.values.toSet(),
      ),
    );
    for (final view in [
      CardTilesGrid(cards: [card]),
      InfiniteCardDeck(cards: [card]),
      WalletCard(
        cardData: card,
        bank: Banks.getById('hdfc'),
        cardholderName: 'Test User',
      ),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: SizedBox(width: 400, height: 520, child: view)),
          ),
        ),
      );
      await tester.pump();
      final surfaces = find.byType(CardBackgroundSurface);
      expect(surfaces, findsWidgets);
      for (final overlay in [
        find.byType(CardNetworkLogo),
        find.byType(BankLogo),
        find.text('Everyday'),
        find.text('•••• 1111'),
        find.text(card.maskedCardNumber),
        find.byIcon(Icons.contactless),
      ]) {
        expect(
          _painted(find.descendant(of: surfaces, matching: overlay)),
          findsNothing,
        );
      }
      expect(tester.takeException(), isNull);
    }
  });
}
