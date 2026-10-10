import 'dart:io';

import 'package:cards_wallet/models/app_release.dart';
import 'package:cards_wallet/screens/change_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('current release matches the app package and repository changelog', () {
    final release = AppRelease.history.first;
    final version = '${release.version}+${release.buildNumber}';
    final manifest = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(
        r'^version:\s*(\S+)',
        multiLine: true,
      ).firstMatch(manifest)!.group(1),
      version,
    );
    expect(File('CHANGELOG.md').readAsStringSync(), contains('## [$version]'));
  });

  testWidgets('change history remains readable on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const ChangeHistoryScreen(),
      ),
    );
    expect(find.text('Change history'), findsOneWidget);
    final release = AppRelease.history.first;
    expect(find.text('Version ${release.version}'), findsOneWidget);
    expect(
      find.text('${release.date} · Build ${release.buildNumber}'),
      findsOneWidget,
    );
    for (final change in release.changes) {
      await tester.ensureVisible(find.text(change));
      await tester.pumpAndSettle();
      expect(find.text(change).hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
