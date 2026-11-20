"""Copy the two successfully built MED binaries into the runtime directory."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[1]
BINARIES = ('MED3.dll', 'P3MED.exe')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def package(root=ROOT):
    receipt = json.loads((root / 'build/logs/MED-build-result.json').read_text('utf-8'))
    if not receipt.get('success'):
        raise RuntimeError('MED build did not succeed')
    outputs = {Path(row['path']).resolve(): row['sha256'] for row in receipt['outputs']}
    inputs = {}
    for name in BINARIES:
        source = root / 'build/compiled/p3-med3' / name
        expected = outputs.get(source.resolve())
        if not expected or not source.is_file() or sha(source) != expected:
            raise RuntimeError('Build output missing or changed: ' + name)
        inputs[name] = (source, expected)
    output = root / 'build/p3-med3'
    if output.exists():
        extras = {p.relative_to(output).as_posix()
                  for p in output.rglob('*') if p.is_file()} - inputs.keys()
        if extras:
            raise RuntimeError('Unexpected files in package output: ' + ', '.join(sorted(extras)))
    output.mkdir(parents=True, exist_ok=True)
    for name, (source, expected) in inputs.items():
        shutil.copy2(source, output / name)
    files = {p.relative_to(output).as_posix(): sha(p)
             for p in output.rglob('*') if p.is_file()}
    if files != {name: expected for name, (_, expected) in inputs.items()}:
        raise RuntimeError('Final package verification failed')
    (root / 'build/logs/package-result.json').write_text(json.dumps(
        dict(output=str(output), files=files, success=True),
        ensure_ascii=False, indent=2) + '\n', 'utf-8')
    print(f'Package verified: {len(files)} files -> {output}')
    return output


if __name__ == '__main__':
    package()
