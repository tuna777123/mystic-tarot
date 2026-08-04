from pathlib import Path
import runpy

ROOT = Path(__file__).resolve().parents[1]

runpy.run_path(
    str(ROOT / 'tool/v122_revenue_final_v4.py'),
    run_name='__main__',
)

widget_test = ROOT / 'test/store_ready_premium_conversion_test.dart'
source = widget_test.read_text(encoding='utf-8')
source = source.replace(
    """    await tester.tap(retry);
    await tester.pumpAndSettle();
""",
    """    await tester.tap(retry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
""",
    1,
)
source = source.replace(
    """  await tester.pumpAndSettle();
}
""",
    """  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
}
""",
    1,
)
widget_test.write_text(source, encoding='utf-8')

contract = ROOT / 'test/v122_revenue_final_contract_test.dart'
source = contract.read_text(encoding='utf-8')
source = source.replace(
    "expect(File('tool/v122_revenue_final_v4.py').existsSync(), isFalse);",
    """expect(File('tool/v122_revenue_final_v4.py').existsSync(), isFalse);
    expect(File('tool/v122_revenue_final_v5.py').existsSync(), isFalse);""",
    1,
)
contract.write_text(source, encoding='utf-8')

Path(__file__).unlink()
