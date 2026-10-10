enum CardOverlay {
  networkLogo('Network logo'),
  bankLogo('Bank logo'),
  contactless('Contactless symbol'),
  category('Card type'),
  nickname('Nickname'),
  cardNumber('Card number'),
  cardholderName('Cardholder name'),
  expiryDate('Expiry date');

  const CardOverlay(this.label);
  final String label;
}

class CardOverlayVisibility {
  const CardOverlayVisibility({this.hidden = const {}});

  final Set<CardOverlay> hidden;

  bool shows(CardOverlay overlay) => !hidden.contains(overlay);

  CardOverlayVisibility withVisible(CardOverlay overlay, bool visible) {
    final updated = {...hidden};
    visible ? updated.remove(overlay) : updated.add(overlay);
    return CardOverlayVisibility(hidden: Set.unmodifiable(updated));
  }

  List<String> toJson() => hidden.map((overlay) => overlay.name).toList();

  factory CardOverlayVisibility.fromJson(dynamic json) {
    if (json is! List) return const CardOverlayVisibility();
    return CardOverlayVisibility(
      hidden: Set.unmodifiable(
        CardOverlay.values.where((overlay) => json.contains(overlay.name)),
      ),
    );
  }
}
