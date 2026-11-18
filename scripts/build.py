"""Portable Delphi CE IDE build. Single attempt, owned private desktop only."""
from pathlib import Path
import os,sys,runpy,argparse,subprocess,json,shutil
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('target',choices=['app','tests','all'],nargs='?',default='all');ap.add_argument('--bds',default=os.environ.get('BDS'));ap.add_argument('--allow-existing-ide',action='store_true')
a=ap.parse_args()
if not a.bds:ap.error('Set BDS or use --bds')
os.environ['BDS']=a.bds
if a.allow_existing_ide:os.environ['ALLOW_EXISTING_IDE']='1'
if not (ROOT/'src/sdk-overlay/Winapi.UIAutomation.pas').exists():raise SystemExit('Prepare SDK overlay manually or run scripts/prepare_dependencies.py first.')
driver=runpy.run_path(str(ROOT/'scripts/build_ide.py'))
for group in (['MED','Tests'] if a.target=='all' else ['MED'] if a.target=='app' else ['Tests']):
    code=driver['run'](group,timeout=240)
    if code:raise SystemExit(code)
    if group=='MED':continue
    tests=['tests/MedProductionTests.exe','tests/MedMemoryTextTests.exe','tests/ProcessAccessTests.exe']
    results=[]
    for rel in tests:
        exe=ROOT/'build'/rel
        if not exe.exists():
            alternatives=list((ROOT/'build').rglob(exe.name))
            if len(alternatives)!=1:raise RuntimeError('Test output missing/ambiguous: '+rel)
            exe=alternatives[0]
        args=[str(exe)]
        if exe.name=='XMLHelperTests.exe':args.append(str(ROOT/'build/xml-roundtrip.xml'))
        r=subprocess.run(args,capture_output=True,timeout=45)
        results.append(dict(test=exe.name,exit=r.returncode,stdout=r.stdout.decode('mbcs',errors='replace'),stderr=r.stderr.decode('mbcs',errors='replace')))
        print(results[-1]['stdout'])
        if r.returncode:raise RuntimeError('Test failed: '+exe.name)
    (ROOT/'build/logs'/f'{group}-tests.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),'utf-8')
