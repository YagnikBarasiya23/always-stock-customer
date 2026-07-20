import 'package:always_stock/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

/// Dashboard, products, and inventory journey against freshly seeded demo
/// data (Basmati Rice starts at stock 24; run `npm run seed` + reinstall
/// before a full suite pass).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dashboard, products, and inventory journey', (tester) async {
    app.main();
    final viaToken = await ensureLoggedInAsDemo(tester);

    // --- Dashboard content ---
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text('Out of stock'), findsOneWidget);
    expect(find.text('TOTAL PRODUCTS'), findsOneWidget);
    expect(find.text('TOTAL STOCK'), findsOneWidget);
    expect(find.text('7'), findsWidgets); // total products KPI
    expect(find.textContaining('170'), findsWidgets); // "170 units" KPI
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.text('Stock removed'), findsWidgets); // seeded transactions
    // Fixed: login returns the business and cold starts restore the session
    // via /user/me, so the real business name shows on every path.
    await pumpUntilFound(tester, find.text('DEMO KIRANA STORE'));
    if (viaToken) {
      debugPrint('NOTE: business name restored on token cold start');
    }

    // --- Products list via KPI tile ---
    await tapOn(tester, find.text('TOTAL PRODUCTS'));
    await pumpUntilFound(tester, find.text('Basmati Rice 5kg'));
    expect(find.text('7 products'), findsOneWidget);
    expect(find.text('Toor Dal 1kg'), findsOneWidget);

    // --- Search by name ---
    final searchField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          w.decoration?.hintText == 'Search name, SKU or barcode',
    );
    await tester.enterText(searchField, 'Rice');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpUntilGone(
      tester,
      find.text('Toor Dal 1kg'),
      reason: 'non-matching products after search',
    );
    expect(find.text('Basmati Rice 5kg'), findsOneWidget);

    // Empty search restores the full list. The search action closes the
    // input connection, so the simulated keyboard can't re-drive this field;
    // invoke the widget's own submit callback with an empty value instead.
    tester.widget<TextField>(searchField).onSubmitted!.call('');
    await pumpUntilFound(tester, find.text('Toor Dal 1kg'));

    // --- Filter: low stock only ---
    await tapOn(tester, find.byIcon(Icons.tune));
    await pumpUntilFound(tester, find.text('Filter products'));
    await tapOn(tester, find.text('Low stock'));
    await tapFilledButton(tester, 'Apply filters');
    await pumpUntilGone(
      tester,
      find.text('Basmati Rice 5kg'),
      reason: 'in-stock products under low-stock filter',
    );
    expect(find.text('Toor Dal 1kg'), findsOneWidget);
    // Active filter chip is removable.
    await tapOn(tester, find.byIcon(Icons.close));
    await pumpUntilFound(tester, find.text('Basmati Rice 5kg'));

    // --- Filter: by category ---
    await tapOn(tester, find.byIcon(Icons.tune));
    await pumpUntilFound(tester, find.text('Filter products'));
    await tapOn(tester, find.text('Beverages'));
    await tapFilledButton(tester, 'Apply filters');
    await pumpUntilGone(
      tester,
      find.text('Basmati Rice 5kg'),
      reason: 'non-beverage products under category filter',
    );
    expect(find.text('Cola 750ml'), findsOneWidget);
    expect(find.text('Mango Juice 1L'), findsOneWidget);
    await tapOn(tester, find.byIcon(Icons.close));
    await pumpUntilFound(tester, find.text('Basmati Rice 5kg'));

    // --- Product detail ---
    await tapOn(tester, find.text('Basmati Rice 5kg'));
    await pumpUntilFound(tester, find.text('Current stock (bag)'));
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Low stock threshold'), findsOneWidget);
    expect(find.text('18%'), findsOneWidget); // margin (450-380)/380
    expect(find.text('Update stock'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    // Fixed: populated categoryId objects now parse, so the category name
    // resolves once the async category fetch lands.
    await pumpUntilFound(tester, find.text('Groceries'));
    await pumpUntilFound(tester, find.text('Initial stock')); // activity loads

    // --- Edit form: no stock field, name required ---
    await tapOn(tester, find.text('Edit'));
    await pumpUntilFound(tester, find.text('Edit product'));
    expect(find.text('Starting stock'), findsNothing);
    expect(find.text('Active'), findsOneWidget);
    await enterField(tester, 'Product name', '');
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter a product name'), findsOneWidget);
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('Current stock (bag)'));

    // --- Stock update: Add (quantity 0 blocked, then +5 → 29) ---
    await tapOn(tester, find.text('Update stock'));
    await pumpUntilFound(tester, find.widgetWithText(FilledButton, 'Add stock'));
    final quantityField = find.byWidgetPredicate(
      (w) => w is TextField && w.textAlign == TextAlign.center,
    );
    await tapOn(tester, find.byIcon(Icons.remove)); // 1 → 0
    await pumpFor(tester, const Duration(milliseconds: 300));
    expect(filledButtonEnabled(tester, 'Add stock'), isFalse,
        reason: 'Add with quantity 0 must be blocked');
    await tester.enterText(quantityField, '5');
    await pumpFor(tester, const Duration(milliseconds: 500));
    // Fixed: the quantity field now rebuilds the sheet on every keystroke,
    // so the preview and button state update live while typing.
    expect(find.text('29 bag'), findsOneWidget); // preview
    expect(filledButtonEnabled(tester, 'Add stock'), isTrue);
    await tapFilledButton(tester, 'Add stock');
    await pumpUntilFound(tester, find.textContaining('Stock updated'));
    await pumpUntilFound(tester, find.text('29'), reason: 'stock stat 29');
    await waitForToastsToClear(tester);

    // --- Stock update: Remove (999 blocked inline, then -4 → 25) ---
    await tapOn(tester, find.text('Update stock'));
    await pumpUntilFound(tester, find.text('Remove'));
    await tapOn(tester, find.text('Remove'));
    await pumpFor(tester, const Duration(milliseconds: 300));
    await tester.enterText(quantityField, '999');
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.textContaining("Can't remove more than"), findsOneWidget);
    expect(filledButtonEnabled(tester, 'Remove stock'), isFalse);
    await tester.enterText(quantityField, '4');
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(filledButtonEnabled(tester, 'Remove stock'), isTrue);
    await tapFilledButton(tester, 'Remove stock');
    await pumpUntilFound(tester, find.textContaining('Stock updated'));
    await pumpUntilFound(tester, find.text('25'), reason: 'stock stat 25');
    await waitForToastsToClear(tester);

    // --- Stock update: Adjust (reason required, negative blocked, → 30) ---
    await tapOn(tester, find.text('Update stock'));
    await pumpUntilFound(tester, find.text('Adjust'));
    await tapOn(tester, find.text('Adjust'));
    await pumpUntilFound(tester, fieldWithHeading('New stock count'));
    // Fresh sheet: the reason field starts empty, so a valid count alone
    // must not enable submit.
    await enterField(tester, 'New stock count', '30');
    expect(filledButtonEnabled(tester, 'Save adjustment'), isFalse,
        reason: 'adjust without a reason must be blocked');
    await enterField(tester, 'New stock count', '-5');
    await enterField(tester, 'Reason', 'QA recount');
    expect(filledButtonEnabled(tester, 'Save adjustment'), isFalse,
        reason: 'negative adjust must be blocked');
    await enterField(tester, 'New stock count', '30');
    expect(filledButtonEnabled(tester, 'Save adjustment'), isTrue);
    await tapFilledButton(tester, 'Save adjustment');
    await pumpUntilFound(tester, find.textContaining('Stock updated'));
    await pumpUntilFound(tester, find.text('30'), reason: 'stock stat 30');
    await waitForToastsToClear(tester);

    // --- Stock history: grouping and type filter ---
    await tapOn(tester, find.text('History'));
    // Fixed: day grouping converts timestamps to local time, so entries made
    // moments ago always land under "Today".
    await pumpUntilFound(tester, find.text('Today'));
    // Let the push transition finish so the detail screen behind is culled
    // (its rows use different labels and would false-positive the asserts).
    await pumpFor(tester, const Duration(milliseconds: 600));
    // Fixed: history now uses the same label vocabulary as the detail screen.
    expect(find.text('Stock added'), findsWidgets);
    expect(find.text('Stock removed'), findsWidgets);
    expect(find.text('Adjusted'), findsWidgets);
    await tapOn(tester, find.text('Added'));
    await pumpUntilGone(
      tester,
      find.text('Stock removed'),
      reason: 'removed entries under Added filter',
    );
    expect(find.text('Stock added'), findsWidgets);
    // The chip row is a horizontal ListView; tapping "Added" may have culled
    // the leading "All" chip out of the viewport — scroll it back into view.
    final chipRow = find
        .ancestor(of: find.text('Added'), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(find.text('All'), -100,
        scrollable: chipRow);
    await tapOn(tester, find.text('All'));
    await pumpUntilFound(tester, find.text('Stock removed'));
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('Current stock (bag)'));
    // Let the pop transition finish — during it both screens' AppBars exist
    // and a second pageBack would find two Back buttons.
    await pumpFor(tester, const Duration(milliseconds: 600));
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('7 products'));
    await pumpFor(tester, const Duration(milliseconds: 600));

    // --- Add product: required name, then created and listed ---
    final qaName = 'QA Item ${DateTime.now().millisecondsSinceEpoch % 100000}';
    await tapOn(tester, find.byIcon(Icons.add));
    await pumpUntilFound(tester, find.text('Add product'));
    await tapFilledButton(tester, 'Add product'); // submit empty
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter a product name'), findsOneWidget);
    await enterField(tester, 'Product name', qaName);
    await enterField(tester, 'Starting stock', '10');
    await enterField(tester, 'Selling price (optional)', '99');
    await tapFilledButton(tester, 'Add product');
    await pumpUntilFound(tester, find.textContaining('Product added'));
    await pumpUntilFound(tester, find.text('8 products'));
    await waitForToastsToClear(tester);
    // Target the products ListView specifically — the search field's inner
    // editable also counts as a Scrollable and would be matched first.
    final productListScrollable = find
        .ancestor(
          of: find.text('Basmati Rice 5kg'),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text(qaName),
      300,
      scrollable: productListScrollable,
    );
    expect(find.text(qaName), findsOneWidget);

    // --- Add product: duplicate name surfaces API error ---
    // The header add button sits above the list and is always visible.
    await tapOn(tester, find.byIcon(Icons.add));
    await pumpUntilFound(tester, find.text('Add product'));
    await enterField(tester, 'Product name', qaName);
    await tapFilledButton(tester, 'Add product');
    await pumpUntilFound(
      tester,
      find.textContaining('already exists'),
      reason: 'duplicate-product toast',
    );
    await waitForToastsToClear(tester);
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('8 products'));

    // --- Categories: list, add, duplicate blocked ---
    await tapOn(tester, find.byIcon(Icons.category_outlined));
    await pumpUntilFound(tester, find.text('Categories'));
    // Settle the push transition — the products screen behind also has an
    // Icons.add button that would otherwise swallow the next tap.
    await pumpFor(tester, const Duration(milliseconds: 600));
    for (final name in ['Groceries', 'Beverages', 'Snacks', 'Household']) {
      expect(find.text(name), findsWidgets, reason: 'seeded category $name');
    }
    final qaCategory =
        'QA Cat ${DateTime.now().millisecondsSinceEpoch % 100000}';
    await tapOn(tester, find.byIcon(Icons.add));
    await pumpUntilFound(tester, find.text('Add category'));
    await tapFilledButton(tester, 'Add category'); // submit empty
    await pumpFor(tester, const Duration(milliseconds: 400));
    expect(find.text('Enter a category name'), findsOneWidget);
    await enterField(tester, 'Category name', qaCategory);
    await tapFilledButton(tester, 'Add category');
    await pumpUntilFound(tester, find.text(qaCategory));
    // The save-success toast overlays the header add button for ~4s.
    await waitForToastsToClear(tester);

    await tapOn(tester, find.byIcon(Icons.add));
    await pumpUntilFound(tester, find.text('Add category'));
    await enterField(tester, 'Category name', 'Groceries');
    await tapFilledButton(tester, 'Add category');
    await pumpUntilFound(
      tester,
      find.textContaining('already exists'),
      reason: 'duplicate-category toast',
    );
    await waitForToastsToClear(tester);
    await tester.pageBack();
    await pumpUntilFound(tester, find.text('Categories'));
  });
}
