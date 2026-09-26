#!/usr/bin/env bash
# Direct metadata/link/syntax checks plus the real example. No unit-test runner.
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PYTHONDONTWRITEBYTECODE=1 python3 - "$SCRIPT_DIR" <<'PY'
from pathlib import Path
import json
import os
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit
sys.dont_write_bytecode = True
scripts = Path(sys.argv[1])
sys.path.insert(0, str(scripts))
from research_validation import UniqueLoader
import yaml
repo = scripts.parent.parent
errors = []
for skill in repo.glob('*/SKILL.md'):
    text = skill.read_text(encoding='utf-8')
    match = re.match(r'\A---\s*\n(.*?)\n---\s*\n', text, re.S)
    if not match:
        errors.append(f'{skill}: missing YAML frontmatter')
        continue
    try:
        metadata = yaml.load(match.group(1), Loader=UniqueLoader)
        for field in ('name', 'description'):
            if not isinstance(metadata.get(field), str) or not metadata[field].strip():
                errors.append(f'{skill}: nonempty {field} required')
        description = metadata.get('description', '')
        if not isinstance(description, str) or len(description) > 1024 or 'use when' not in description.lower():
            errors.append(f'{skill}: description needs Use when triggers and at most 1024 characters')
        if len(text.splitlines()) > 100:
            errors.append(f'{skill}: core skill exceeds 100 lines')
    except (yaml.YAMLError, ValueError, AttributeError) as exc:
        errors.append(f'{skill}: invalid frontmatter: {exc}')
for path in repo.rglob('*.md'):
    text = path.read_text(encoding='utf-8')
    for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', text):
        target = target.strip().strip('<>')
        if urlsplit(target).scheme or target.startswith('#'):
            continue
        clean = unquote(target.split('#', 1)[0])
        if clean and not (path.parent / clean).resolve().exists():
            errors.append(f'{path}: broken local link {target}')
for path in scripts.glob('*.py'):
    try:
        compile(path.read_text(encoding='utf-8'), str(path), 'exec')
    except SyntaxError as exc:
        errors.append(f'{path}: {exc}')
for path in scripts.glob('*.sh'):
    checked = subprocess.run(['bash', '-n', str(path)], text=True, capture_output=True)
    if checked.returncode:
        errors.append(f'{path}: {checked.stderr.strip()}')
if errors:
    print('\n'.join('ERROR: ' + error for error in errors))
    raise SystemExit(1)
print('PASS: skill metadata, local Markdown links, and Python/shell syntax')
example = scripts.parent / 'examples/documentation-handoff.md'
checked = subprocess.run(['bash', str(scripts / 'verify-deep-research-output.sh'), str(example), str(example)],
                         text=True, capture_output=True, env={**os.environ, 'PYTHONDONTWRITEBYTECODE': '1'})
print(checked.stdout, end='')
if checked.stderr:
    print(checked.stderr, file=sys.stderr, end='')
raise SystemExit(checked.returncode)
PY
