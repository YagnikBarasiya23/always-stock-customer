import 'package:always_stock/core/common_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps frames for a fixed wall-clock duration (real async keeps running).
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps until [finder] matches at least one widget, or fails after [timeout].
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for ${reason ?? finder.toString()}');
}

/// Pumps until [finder] matches nothing, or fails after [timeout].
Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isEmpty) return;
  }
  fail('Timed out waiting for ${reason ?? finder.toString()} to disappear');
}

/// The TextFormField inside the CustomTextField whose heading label is [heading].
Finder fieldWithHeading(String heading) => find.descendant(
  of: find.widgetWithText(CustomTextField, heading),
  matching: find.byType(TextFormField),
);

/// Enters [text] into the CustomTextField labelled [heading].
Future<void> enterField(WidgetTester tester, String heading, String text) async {
  final field = fieldWithHeading(heading).first;
  await tester.ensureVisible(field);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.enterText(field, text);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Taps the FilledButton whose label is [label].
Future<void> tapFilledButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label).first;
  await tester.ensureVisible(button);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.tap(button);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Whether the FilledButton labelled [label] is currently enabled.
bool filledButtonEnabled(WidgetTester tester, String label) {
  final button = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, label).first,
  );
  return button.onPressed != null;
}

/// Taps the first widget matched by [finder], scrolling it into view first.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.tap(finder.first);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Waits out any toast currently on screen so it can't block later taps.
Future<void> waitForToastsToClear(WidgetTester tester) async {
  await pumpFor(tester, const Duration(milliseconds: 4500));
}

/// Gets past splash to the home dashboard, logging in as the demo account if
/// the app starts signed out. Returns true when home was reached straight from
/// a stored token (no fresh login this session).
Future<bool> ensureLoggedInAsDemo(WidgetTester tester) async {
  final end = DateTime.now().add(const Duration(seconds: 45));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (find.text('Needs attention').evaluate().isNotEmpty) return true;
    if (find.textContaining('Continue in').evaluate().isNotEmpty) {
      await tapOn(tester, find.textContaining('Continue in'));
      continue;
    }
    if (find.widgetWithText(FilledButton, 'Log in').evaluate().isNotEmpty) {
      await enterField(tester, 'Email', 'demo@alwaysstock.app');
      await enterField(tester, 'Password', 'Demo@1234');
      await tapFilledButton(tester, 'Log in');
      await pumpUntilFound(
        tester,
        find.text('Needs attention'),
        timeout: const Duration(seconds: 30),
        reason: 'home dashboard after demo login',
      );
      return false;
    }
  }
  fail('Could not reach the home dashboard');
}
