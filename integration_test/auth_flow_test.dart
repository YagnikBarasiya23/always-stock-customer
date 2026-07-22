import 'package:always_stock/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Auth journey. Run against a FRESH install (no stored language/token):
///   xcrun simctl uninstall booted app.yagnik.alwaysStock
/// Requires the configured backend (UrlConstants.baseUrl) with the demo
/// account seeded.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth journey: splash → login/register/forgot → home', (
    tester,
  ) async {
    app.main();

    // --- Splash renders, then routes straight to the login screen ---
    // Language selection is inline on the login screen now; there is no
    // standalone language picker between splash and login.
    await pumpUntilFound(
      tester,
      find.text('Always Stock'),
      reason: 'splash wordmark',
    );
    await pumpUntilFound(
      tester,
      find.widgetWithText(FilledButton, 'Log in'),
      timeout: const Duration(seconds: 30),
      reason: 'login screen after splash',
    );

    // --- Login validation: empty submit ---
    await tapFilledButton(tester, 'Log in');
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    // --- Login validation: bad email format ---
    await enterField(tester, 'Email', 'notanemail');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter a valid email'), findsOneWidget);

    // --- Login validation: short password ---
    await enterField(tester, 'Password', '123');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    // --- Login: wrong credentials surface the API error, no navigation ---
    await enterField(tester, 'Email', 'demo@alwaysstock.app');
    await enterField(tester, 'Password', 'WrongPass1');
    await tapFilledButton(tester, 'Log in');
    await pumpUntilFound(
      tester,
      find.textContaining('Invalid email or password'),
      reason: 'invalid-credentials toast',
    );
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
    await waitForToastsToClear(tester);

    // --- Forgot password: request state validation ---
    await tapOn(tester, find.text('Forgot password?'));
    await pumpUntilFound(tester, find.text('Forgot your password?'));
    await tapFilledButton(tester, 'Send reset link');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter your email'), findsOneWidget);

    await enterField(tester, 'Email', 'bad@');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter a valid email'), findsOneWidget);

    // --- Forgot password: valid email → confirmation state ---
    await enterField(tester, 'Email', 'demo@alwaysstock.app');
    await tapFilledButton(tester, 'Send reset link');
    await pumpUntilFound(
      tester,
      find.text('Check your email'),
      timeout: const Duration(seconds: 10),
    );
    expect(
      find.textContaining('demo@alwaysstock.app', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('Resend in'), findsOneWidget);

    // --- Confirmation → back to request state → back to login ---
    await tapOn(tester, find.text('Wrong email? Try again'));
    await pumpUntilFound(tester, find.text('Forgot your password?'));
    await tapOn(tester, find.byIcon(Icons.arrow_back));
    await pumpUntilFound(tester, find.widgetWithText(FilledButton, 'Log in'));

    // --- Register: step 1 validation ---
    await tapOn(tester, find.text('Create an account'));
    await pumpUntilFound(tester, find.text('Step 1 of 2 — just the basics.'));
    await tapFilledButton(tester, 'Continue');
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter a password'), findsOneWidget);

    await enterField(tester, 'Full name', 'QA Tester');
    await enterField(tester, 'Email', 'demo@alwaysstock.app');
    await enterField(tester, 'Password', '123');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    await enterField(tester, 'Password', 'Test@1234');

    // --- Register: step 2, phone validation ---
    await tapFilledButton(tester, 'Continue');
    await pumpUntilFound(tester, find.text('Tell us about your shop'));
    await enterField(tester, 'Business name (optional)', 'QA Test Shop');
    await enterField(tester, 'Phone (optional)', '12345');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter a valid phone number'), findsOneWidget);
    await enterField(tester, 'Phone (optional)', '+91 98765 43210');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter a valid phone number'), findsNothing);

    // --- Register: back to step 1 keeps entered data ---
    await tapOn(tester, find.byIcon(Icons.arrow_back));
    await pumpUntilFound(tester, find.text('Step 1 of 2 — just the basics.'));
    expect(find.text('QA Tester'), findsOneWidget);

    // --- Register: duplicate email surfaces API error ---
    await tapFilledButton(tester, 'Continue');
    await pumpUntilFound(tester, find.text('Tell us about your shop'));
    expect(find.text('QA Test Shop'), findsOneWidget);
    await tapFilledButton(tester, 'Create account');
    await pumpUntilFound(
      tester,
      find.textContaining('already exists'),
      reason: 'duplicate-email toast',
    );
    await waitForToastsToClear(tester);

    // --- Register: unique email succeeds → home ---
    await tapOn(tester, find.byIcon(Icons.arrow_back));
    await pumpUntilFound(tester, find.text('Step 1 of 2 — just the basics.'));
    final uniqueEmail =
        'qa.tester.${DateTime.now().millisecondsSinceEpoch}@alwaysstock.app';
    await enterField(tester, 'Email', uniqueEmail);
    await tapFilledButton(tester, 'Continue');
    await pumpUntilFound(tester, find.text('Tell us about your shop'));
    await tapFilledButton(tester, 'Create account');
    await pumpUntilFound(
      tester,
      find.text('Needs attention'),
      timeout: const Duration(seconds: 30),
      reason: 'home dashboard after signup',
    );
    expect(find.text('QA TEST SHOP'), findsOneWidget);
    await waitForToastsToClear(tester);

    // --- Logout from settings returns to login ---
    await tapOn(tester, find.text('QT'));
    await pumpUntilFound(tester, find.text('Settings'));
    await tapOn(tester, find.text('Log out'));
    await pumpUntilFound(
      tester,
      find.widgetWithText(FilledButton, 'Log in'),
      reason: 'login screen after logout',
    );

    // --- Login with demo account succeeds → home with real data ---
    await enterField(tester, 'Email', 'demo@alwaysstock.app');
    await enterField(tester, 'Password', 'Demo@1234');
    await tapFilledButton(tester, 'Log in');
    await pumpUntilFound(
      tester,
      find.text('Needs attention'),
      timeout: const Duration(seconds: 30),
      reason: 'home dashboard after demo login',
    );
    // Fixed: /auth/login now returns the business object, so the header
    // shows the real business name right after login.
    await pumpUntilFound(tester, find.text('DEMO KIRANA STORE'));
  });
}
