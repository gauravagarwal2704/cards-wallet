class AppRelease {
  final String version;
  final int buildNumber;
  final String date;
  final List<String> changes;

  const AppRelease({
    required this.version,
    required this.buildNumber,
    required this.date,
    required this.changes,
  });

  static const history = [
    AppRelease(
      version: '1.8.5',
      buildNumber: 24,
      date: '10 October 2026',
      changes: [
        'Restyled Buy me a Chai to match the Coffee button more closely with smaller corners and a chai cup icon.',
      ],
    ),
    AppRelease(
      version: '1.8.4',
      buildNumber: 23,
      date: '10 October 2026',
      changes: [
        'Updated the Chai support shortcut label to Buy me a Chai while keeping both external support buttons on one line.',
      ],
    ),
    AppRelease(
      version: '1.8.3',
      buildNumber: 22,
      date: '10 October 2026',
      changes: [
        'Replaced the custom Coffee shortcut with the supplied official Buy me a coffee artwork and kept Coffee and Chai together on one line.',
      ],
    ),
    AppRelease(
      version: '1.8.2',
      buildNumber: 21,
      date: '10 October 2026',
      changes: [
        'Updated the Buy Me a Coffee shortcut to use the requested Buy me a pizza label, pizza emoji, and coral styling.',
      ],
    ),
    AppRelease(
      version: '1.8.1',
      buildNumber: 20,
      date: '10 October 2026',
      changes: [
        'Added Coffee and Chai as external support options on the supporter page alongside Google Play.',
      ],
    ),
    AppRelease(
      version: '1.8.0',
      buildNumber: 19,
      date: '10 October 2026',
      changes: [
        'Added optional Google Play Supporter Stars with quick and custom configured amounts.',
        'Tap the CardVault icon or Support in Settings to open the new supporter page.',
        'Updated the privacy policy to explain how optional Google Play payments and the local Supporter Star count are handled.',
      ],
    ),
    AppRelease(
      version: '1.7.4',
      buildNumber: 18,
      date: '10 October 2026',
      changes: [
        'Added more space between color theme tiles for a clearer three-column layout.',
      ],
    ),
    AppRelease(
      version: '1.7.3',
      buildNumber: 17,
      date: '10 October 2026',
      changes: [
        'Fixed development builds failing to launch after changing the app icon. Debug and profile builds now use a stable launcher activity.',
      ],
    ),
    AppRelease(
      version: '1.7.2',
      buildNumber: 16,
      date: '10 October 2026',
      changes: [
        'Palette style tiles show distinct Tonal Spot and Expressive examples using the same base color, including when Device colors is selected.',
        'Device colors and color theme tiles are more compact with reduced spacing.',
        'All three color circles now display fully inside each color theme tile.',
      ],
    ),
    AppRelease(
      version: '1.7.1',
      buildNumber: 15,
      date: '10 October 2026',
      changes: [
        'Palette styles now appear side by side with labeled button and surface color previews.',
        'Color themes use three columns and filled selection highlights without colored borders.',
        'The Settings appearance indicator and device palette previews now show active colors instead of the previous custom color.',
      ],
    ),
    AppRelease(
      version: '1.7.0',
      buildNumber: 14,
      date: '10 October 2026',
      changes: [
        'New installations use the softer Tonal Spot palette style by default.',
        'Device colors now use the Android wallpaper palette and refresh when returning to the app.',
        'Added Lavender, Sage, Dusty rose, Sand, Powder blue, Peach, Mist, and Olive Material color themes.',
      ],
    ),
    AppRelease(
      version: '1.6.0',
      buildNumber: 13,
      date: '10 October 2026',
      changes: [
        'Added Edit to the card swipe actions, with authentication before opening the card editor.',
        'Share, Delete, and Edit now use outlined buttons, with red for Delete and blue for Edit.',
      ],
    ),
    AppRelease(
      version: '1.5.2',
      buildNumber: 12,
      date: '10 October 2026',
      changes: [
        'Card swipe actions now use the app theme color with matching icon and label contrast.',
      ],
    ),
    AppRelease(
      version: '1.5.1',
      buildNumber: 11,
      date: '10 October 2026',
      changes: [
        'Custom-image overlay controls are filled when selected and outlined when deselected.',
        'Hiding a card logo or detail now preserves the positions of the remaining overlays in previews and wallet views.',
        'Card numbers scale to fit narrow previews without wrapping.',
      ],
    ),
    AppRelease(
      version: '1.5.0',
      buildNumber: 10,
      date: '10 October 2026',
      changes: [
        'Choose which logos, symbols, and card details appear over a custom card image, with live preview updates.',
        'Overlay visibility is saved with each card and preserved in wallet views and backups.',
      ],
    ),
    AppRelease(
      version: '1.4.0',
      buildNumber: 9,
      date: '10 October 2026',
      changes: [
        'Custom card images now fill the card without a bank-colored border or shadow.',
        'Zoom and move custom card images in a live alignment preview with the card number visible.',
        'Image alignment is saved with the card and preserved in wallet views and backups.',
      ],
    ),
    AppRelease(
      version: '1.3.0',
      buildNumber: 8,
      date: '10 October 2026',
      changes: [
        'Added change history in Settings so you can see what changed in each version.',
        'Returning to the home page within the app no longer asks you to unlock again. App lock now has a two-minute grace period when you leave the app.',
        'Camera scanning keeps your session unlocked and returns to the card editor so you can review and save the scanned card.',
      ],
    ),
  ];
}
