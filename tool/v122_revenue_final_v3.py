from pathlib import Path
import runpy

ROOT = Path(__file__).resolve().parents[1]

runpy.run_path(
    str(ROOT / 'tool/v122_revenue_final_v2.py'),
    run_name='__main__',
)

widget_test = ROOT / 'test/store_ready_premium_conversion_test.dart'
source = widget_test.read_text(encoding='utf-8')
source = source.replace("import 'package:flutter/foundation.dart';\n", '', 1)
widget_test.write_text(source, encoding='utf-8')

contract = ROOT / 'test/v122_revenue_final_contract_test.dart'
source = contract.read_text(encoding='utf-8')
source = source.replace(
    'premium.indexOf("..._planIds.map((id) => _productTile(context, id))")',
    "premium.indexOf('..._planIds.map((id) => _productTile(context, id))')",
)
contract.write_text(source, encoding='utf-8')

Path(__file__).unlink()
