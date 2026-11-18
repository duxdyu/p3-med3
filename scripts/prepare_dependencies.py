"""Prepare ignored build dependencies; never modifies the installed SDK."""
from pathlib import Path
import argparse,os,re
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser()
ap.add_argument('--bds',default=os.environ.get('BDS'))
a=ap.parse_args()
if not a.bds:ap.error('Set BDS or pass --bds for your licensed RAD Studio installation')
sdk=Path(a.bds)/'source/rtl/win/Winapi.UIAutomation.pas'
data=sdk.read_bytes();bom=data.startswith(b'\xef\xbb\xbf');text=data.decode('utf-8-sig')
pattern=r"(external\s+['\"]UIAutomationCore\.dll['\"]\s+name\s+['\"]UiaReturnRawElementProvider['\"])(\s+delayed)?\s*;"
matches=list(re.finditer(pattern,text,re.I))
if len(matches)!=1:raise RuntimeError('SDK UIAutomation declaration differs; inspect before adapting')
text=re.sub(pattern,lambda m:m[1]+' delayed;',text,flags=re.I)
out=ROOT/'src/sdk-overlay';out.mkdir(exist_ok=True)
(out/'Winapi.UIAutomation.pas').write_bytes((b'\xef\xbb\xbf' if bom else b'')+text.encode('utf-8'))
print('Local UIAutomation overlay prepared; SDK source not part of public source ZIP.')
