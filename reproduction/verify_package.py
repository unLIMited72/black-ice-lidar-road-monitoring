"""Static file-integrity, input-map and syntax verification; no numerical work."""
from pathlib import Path
import ast
import csv
import hashlib
import re
from urllib.parse import unquote

root = Path(__file__).resolve().parents[1]
def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()

expected = {}
for line in (root / 'SHA256SUMS.txt').read_text().splitlines():
    value, name = line.split('  ', 1)
    assert name not in expected and not Path(name).is_absolute() and '..' not in Path(name).parts
    expected[name] = value
actual = {p.relative_to(root).as_posix() for p in root.rglob('*') if p.is_file()}
assert actual == set(expected) | {'SHA256SUMS.txt'}, 'Unexpected or missing files'
for name, value in expected.items():
    assert digest(root / name) == value, f'Checksum mismatch: {name}'
with (root / 'RELEASE_MANIFEST.csv').open(newline='') as stream:
    manifest = list(csv.DictReader(stream))
assert {r['path'] for r in manifest} == actual - {'RELEASE_MANIFEST.csv', 'SHA256SUMS.txt'}
for row in manifest:
    assert digest(root / row['path']) == row['sha256']
    assert (root / row['path']).stat().st_size == int(row['size'])
for filename, id_field in [('FIGURE_REPRODUCTION_MAP.csv', 'figure'), ('TABLE_REPRODUCTION_MAP.csv', 'table')]:
    with (root / 'docs' / filename).open(newline='') as stream:
        for row in csv.DictReader(stream):
            optional = row['availability'] == 'OPTIONAL_USER_INPUT'
            for key in ['script', 'reference_file', 'input_data', 'source_data', 'output']:
                value = row.get(key, '')
                if not value or value.startswith(('conceptual', 'NONE:', 'authored')):
                    continue
                if key == 'script':
                    assert (root / value).is_file(), value
                elif optional:
                    # Optional input/output is documented; it must not be bundled.
                    assert not (root / value).exists(), value
                elif key != 'output' or id_field == 'table':
                    assert (root / value).is_file(), value
with (root / 'docs/INPUT_DEPENDENCIES.csv').open(newline='') as stream:
    for row in csv.DictReader(stream):
        assert (root / row['script']).is_file()
        if row['status'] == 'PRESENT':
            assert (root / row['resolved_path']).is_file(), row['resolved_path']
        else:
            assert row['status'] in {'OPTIONAL_USER_INPUT', 'GENERATED_OUTPUT', 'ZENODO OVERLAY'}
with (root / 'supplementary/electronic_tables/SCHEMA.csv').open(newline='') as stream:
    for row in csv.DictReader(stream):
        assert (root / 'supplementary/electronic_tables' / row['file']).is_file()
for path in root.rglob('*.py'):
    ast.parse(path.read_text())
for path in root.rglob('*.md'):
    for target in re.findall(r'\]\(([^)]+)\)', path.read_text()):
        if '://' in target or target.startswith(('#', 'mailto:')):
            continue
        target = unquote(target.split('#')[0])
        assert (path.parent / target).exists(), (path, target)
assert not (root / '.git').exists()
print(f'PASS: {len(expected)} file hashes, exact payload, documented optional inputs, maps, links and Python syntax.')
print('No simulations, numerical extraction or figure generation executed. Publication authority/license application remain separate.')
