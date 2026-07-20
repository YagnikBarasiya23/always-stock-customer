import 'package:always_stock/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Settings, profile, and notifications journey for the demo account.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings, profile, and notifications journey', (tester) async {
    app.main();
    final viaToken = await ensureLoggedInAsDemo(tester);

    // Fixed: login returns the business and token cold starts restore the
    // session via /user/me, so both paths hydrate AuthBloc — the header
    // shows the real business initials ("DK") without a re-login.
    await pumpUntilFound(tester, find.text('DK'));
    if (viaToken) {
      debugPrint('NOTE: session restored from token via /user/me');
    }

    // --- Notification center ---
    await tapOn(tester, find.byIcon(Icons.notifications_none));
    await pumpUntilFound(tester, find.text('Notifications'));
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Unread'), findsOneWidget);
    // Seed wipes notifications, so expect an empty state on either tab.
    await pumpUntilFound(tester, find.text('No notifications yet'));
    await tapOn(tester, find.text('Unread'));
    await pumpUntilFound(tester, find.text("You're all caught up"));
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('Needs attention'));
    await pumpFor(tester, const Duration(milliseconds: 600)); // settle pop

    // --- Settings screen rows ---
    await tapOn(tester, find.text('DK')); // Demo Kirana Store initials
    await pumpUntilFound(tester, find.text('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 600)); // settle push
    expect(find.text('Demo Owner'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Always Stock · v1.0.0'), findsOneWidget);

    // --- Profile is read-only ---
    await tapOn(tester, find.text('Demo Owner'));
    await pumpUntilFound(tester, find.text('Profile'));
    await pumpFor(tester, const Duration(milliseconds: 600)); // settle push
    expect(
      find.byType(TextFormField),
      findsNothing,
      reason: 'profile must not offer editing (no update endpoint)',
    );
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 600)); // settle pop

    // --- Notification preferences: 4 toggles, auto-save, persistence ---
    await tapOn(tester, find.widgetWithText(InkWell, 'Notifications'));
    await pumpUntilFound(tester, find.text('Low stock alerts'));
    expect(find.text('Out of stock alerts'), findsOneWidget);
    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.text('Weekly summary'), findsOneWidget);

    bool switchValue(String title) => tester
        .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
        .value;

    final before = switchValue('Low stock alerts');
    await tapOn(tester, find.widgetWithText(SwitchListTile, 'Low stock alerts'));
    await pumpFor(tester, const Duration(seconds: 2));
    expect(switchValue('Low stock alerts'), equals(!before));
    expect(
      find.textContaining('Could not save'),
      findsNothing,
      reason: 'toggle save should succeed against live backend',
    );

    // Reopen the screen: the saved toggle must survive (the save path now
    // syncs AuthBloc, which this screen seeds from).
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 600)); // settle pop
    await tapOn(tester, find.widgetWithText(InkWell, 'Notifications'));
    await pumpUntilFound(tester, find.text('Low stock alerts'));
    await pumpFor(tester, const Duration(milliseconds: 600)); // settle push
    final afterReopen = switchValue('Low stock alerts');
    expect(
      afterReopen,
      equals(!before),
      reason: 'saved preference must persist across screen reopen',
    );
    // Restore the original value (also re-exercises save).
    await tapOn(
      tester,
      find.widgetWithText(SwitchListTile, 'Low stock alerts'),
    );
    await pumpFor(tester, const Duration(seconds: 2));
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 600)); // settle pop

    // --- Language switcher now re-renders the UI in the chosen language ---
    await tapOn(tester, find.widgetWithText(InkWell, 'Language'));
    await pumpUntilFound(tester, find.text('हिन्दी'));
    await tapOn(tester, find.text('हिन्दी'));
    // Fixed: real translations are wired — the settings screen re-renders
    // in Hindi (title + row labels).
    await pumpUntilFound(tester, find.text('सेटिंग्स'));
    expect(find.text('भाषा'), findsOneWidget);
    // Switch back to English via the now-Hindi-labelled row.
    await tapOn(tester, find.widgetWithText(InkWell, 'भाषा'));
    await pumpUntilFound(tester, find.widgetWithText(ListTile, 'English'));
    await tapOn(tester, find.widgetWithText(ListTile, 'English'));
    await pumpUntilFound(tester, find.text('Settings'));
    await pumpFor(tester, const Duration(seconds: 1));

    // --- Logout returns to login ---
    await tapOn(tester, find.text('Log out'));
    await pumpUntilFound(
      tester,
      find.widgetWithText(FilledButton, 'Log in'),
      reason: 'login screen after logout',
    );
  });
}
