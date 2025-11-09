#!/usr/bin/env python3
import os
import re
import subprocess
import sys

def collect_python_packages():
    candidates = []
    for root, dirs, files in os.walk('.'):
        for file in files:
            if file.endswith(('.qmd', '.py', '.ipynb')):
                candidates.append(os.path.join(root, file))

    packages = set()

    for file_path in candidates:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
                imports = re.findall(r'(?:^|\n)\s*import\s+([a-zA-Z0-9_]+)', content)
                packages.update(imports)
                
                from_imports = re.findall(r'(?:^|\n)\s*from\s+([a-zA-Z0-9_]+)\s+import', content)
                packages.update(from_imports)
        except Exception as e:
            print(f"Warning: Could not read {file_path}: {e}")

    if os.path.exists('requirements.txt'):
        with open('requirements.txt', 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    pkg = re.split(r'[=<>!]', line)[0].strip()
                    packages.add(pkg)

    stdlib_modules = set(sys.stdlib_module_names) if hasattr(sys, 'stdlib_module_names') else {
        'abc', 'argparse', 'array', 'ast', 'asyncio', 'base64', 'bisect', 'builtins',
        'calendar', 'collections', 'copy', 'csv', 'datetime', 'decimal', 'difflib',
        'functools', 'gc', 'glob', 'gzip', 'hashlib', 'heapq', 'html', 'http', 'io',
        'itertools', 'json', 'logging', 'math', 'multiprocessing', 'numbers', 'operator',
        'os', 'pathlib', 'pickle', 'platform', 'pprint', 'queue', 're', 'random',
        'shutil', 'signal', 'socket', 'sqlite3', 'ssl', 'statistics', 'string', 'struct',
        'subprocess', 'sys', 'tempfile', 'threading', 'time', 'timeit', 'traceback',
        'types', 'typing', 'unittest', 'urllib', 'uuid', 'warnings', 'weakref', 'xml', 'zipfile'
    }

    packages = packages - stdlib_modules
    packages.discard('jupyter')

    print(f"Found Python packages: {sorted(packages)}")

    if packages:
        for package in packages:
            try:
                pip_cmd = ['/workspace/req-venv/bin/pip', 'install', package]
                subprocess.run(pip_cmd, check=False)
            except Exception:
                print(f"{package} could not be installed! maybe add specifically to requirements?")

if __name__ == '__main__':
    collect_python_packages()
