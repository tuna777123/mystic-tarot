from pathlib import Path
import runpy

ROOT = Path(__file__).resolve().parents[1]

runpy.run_path(
    str(ROOT / 'tool/v122_revenue_final_v5.py'),
    run_name='__main__',
)

widget_test = ROOT / 'test/store_ready_premium_conversion_test.dart'
source = widget_test.read_text(encoding='utf-8')
old = """    expect(yearly, findsOneWidget);
    expect(stickyAction, findsOneWidget);
    final actionRect = tester.getRect(stickyAction);
    expect(actionRect.top, greaterThanOrEqualTo(0));
    expect(actionRect.bottom, lessThanOrEqualTo(900));
    expect(
      find.text(
        r'The store charges $39.99 for one year. It renews yearly unless cancelled before the next renewal.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      monthly,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(monthly, findsOneWidget);
"""
new = """    expect(stickyAction, findsOneWidget);
    final actionRect = tester.getRect(stickyAction);
    expect(actionRect.top, greaterThanOrEqualTo(0));
    expect(actionRect.bottom, lessThanOrEqualTo(900));
    expect(
      find.text(
        r'The store charges $39.99 for one year. It renews yearly unless cancelled before the next renewal.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      yearly,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(yearly, findsOneWidget);
    await tester.scrollUntilVisible(
      monthly,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(monthly, findsOneWidget);
"""
if old not in source:
    raise SystemExit('Expected lazy-list test block not found')
source = source.replace(old, new, 1)
widget_test.write_text(source, encoding='utf-8')

contract = ROOT / 'test/v122_revenue_final_contract_test.dart'
source = contract.read_text(encoding='utf-8')
source = source.replace(
    "expect(File('tool/v122_revenue_final_v5.py').existsSync(), isFalse);",
    """expect(File('tool/v122_revenue_final_v5.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v6.py').existsSync(), isFalse);""",
    1,
)
contract.write_text(source, encoding='utf-8')

Path(__file__).unlink()
