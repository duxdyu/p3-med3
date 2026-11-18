"""Single IDE attempt. Only owned-PID dialogs; never save IDE changes."""
from pathlib import Path
import ctypes as C
from ctypes import wintypes as W
import datetime, hashlib, json, os, re, subprocess, sys, time
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parents[1]
u = C.WinDLL('user32', use_last_error=True)
CB = C.WINFUNCTYPE(W.BOOL, W.HWND, W.LPARAM)
u.EnumWindows.argtypes = [CB, W.LPARAM]
u.EnumDesktopWindows.argtypes = [W.HANDLE, CB, W.LPARAM]
u.CreateDesktopW.argtypes = [W.LPCWSTR, W.LPCWSTR, C.c_void_p, W.DWORD, W.DWORD, C.c_void_p]
u.CreateDesktopW.restype = W.HANDLE
u.CloseDesktop.argtypes = [W.HANDLE]
build_desktop = None
k = C.WinDLL('kernel32',use_last_error=True)
class STARTUPINFO(C.Structure):
    _fields_=[('cb',W.DWORD),('lpReserved',W.LPWSTR),('lpDesktop',W.LPWSTR),('lpTitle',W.LPWSTR),
              ('dwX',W.DWORD),('dwY',W.DWORD),('dwXSize',W.DWORD),('dwYSize',W.DWORD),
              ('dwXCountChars',W.DWORD),('dwYCountChars',W.DWORD),('dwFillAttribute',W.DWORD),
              ('dwFlags',W.DWORD),('wShowWindow',W.WORD),('cbReserved2',W.WORD),
              ('lpReserved2',C.c_void_p),('hStdInput',W.HANDLE),('hStdOutput',W.HANDLE),('hStdError',W.HANDLE)]
class PROCESSINFO(C.Structure):
    _fields_=[('process',W.HANDLE),('thread',W.HANDLE),('pid',W.DWORD),('tid',W.DWORD)]
k.CreateProcessW.argtypes=[W.LPCWSTR,W.LPWSTR,C.c_void_p,C.c_void_p,W.BOOL,W.DWORD,C.c_void_p,W.LPCWSTR,C.POINTER(STARTUPINFO),C.POINTER(PROCESSINFO)]
k.CloseHandle.argtypes=[W.HANDLE]
k.GetExitCodeProcess.argtypes=[W.HANDLE,C.POINTER(W.DWORD)]
k.TerminateProcess.argtypes=[W.HANDLE,W.UINT]
k.WaitForSingleObject.argtypes=[W.HANDLE,W.DWORD]
class DesktopProcess:
    def __init__(self,args,cwd,desktop):
        si=STARTUPINFO();si.cb=C.sizeof(si);si.lpDesktop=desktop
        pi=PROCESSINFO();command=C.create_unicode_buffer(subprocess.list2cmdline(args))
        if not k.CreateProcessW(None,command,None,None,False,0,None,str(cwd),C.byref(si),C.byref(pi)):
            raise C.WinError(C.get_last_error())
        k.CloseHandle(pi.thread)
        self.handle=pi.process;self.pid=pi.pid;self.returncode=None
    def poll(self):
        exit_code=W.DWORD()
        if not k.GetExitCodeProcess(self.handle,C.byref(exit_code)):raise C.WinError(C.get_last_error())
        self.returncode=None if exit_code.value==259 else exit_code.value
        return self.returncode
    def kill(self):
        if not k.TerminateProcess(self.handle,1):raise C.WinError(C.get_last_error())
    def wait(self,timeout):
        if k.WaitForSingleObject(self.handle,int(timeout*1000))!=0:raise TimeoutError('Owned IDE wait timeout')
        return self.poll()
    def close(self):k.CloseHandle(self.handle)
u.EnumChildWindows.argtypes = [W.HWND, CB, W.LPARAM]
u.GetWindowThreadProcessId.argtypes = [W.HWND, C.POINTER(W.DWORD)]
u.GetWindowTextW.argtypes = [W.HWND, W.LPWSTR, C.c_int]
u.GetClassNameW.argtypes = [W.HWND, W.LPWSTR, C.c_int]
u.GetDlgCtrlID.argtypes = [W.HWND]
u.GetDlgCtrlID.restype = C.c_int
u.IsWindowVisible.argtypes = [W.HWND]
u.PostMessageW.argtypes = [W.HWND, W.UINT, W.WPARAM, W.LPARAM]
u.IsWindowEnabled.argtypes = [W.HWND]

def info(hwnd):
    text, cls = C.create_unicode_buffer(4096), C.create_unicode_buffer(256)
    u.GetWindowTextW(hwnd, text, len(text))
    u.GetClassNameW(hwnd, cls, len(cls))
    return dict(hwnd=int(hwnd), text=text.value, cls=cls.value, id=u.GetDlgCtrlID(hwnd))

def windows(pid):
    rows = []
    @CB
    def enum(hwnd, _):
        owner = W.DWORD()
        u.GetWindowThreadProcessId(hwnd, C.byref(owner))
        if owner.value == pid and u.IsWindowVisible(hwnd):
            row = info(hwnd)
            children = []
            @CB
            def child(ch, _):
                if u.IsWindowVisible(ch): children.append(info(ch))
                return True
            u.EnumChildWindows(hwnd, child, 0)
            row['children'] = children
            rows.append(row)
        return True
    if build_desktop:
        C.set_last_error(0)
        if not u.EnumDesktopWindows(build_desktop, enum, 0) and C.get_last_error(): raise C.WinError(C.get_last_error())
    else: u.EnumWindows(enum, 0)
    return rows

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def run(group, timeout=90):
    global build_desktop
    assert group in {'MED', 'Tests'}
    busy = subprocess.check_output(['powershell', '-NoProfile', '-Command',
        "@(Get-Process bds,dcc32,MSBuild -ErrorAction SilentlyContinue).Count"], text=True).strip()
    if busy != '0' and os.environ.get('ALLOW_EXISTING_IDE') != '1': raise RuntimeError('Delphi/compiler already active; refusing to compete: '+busy)
    ns = {'m':'http://schemas.microsoft.com/developer/msbuild/2003'}
    group_file = HERE/('tests/Tests.groupproj' if group == 'Tests' else 'MED.groupproj')
    projects = [group_file.parent/x.attrib['Include'] for x in ET.parse(group_file).findall('.//m:Projects',ns)]
    expected = []
    for proj in projects:
        tree = ET.parse(proj)
        source = tree.find('.//m:MainSource',ns).text
        ext = '.dll' if re.match(r'\s*library\b',(proj.parent/source).read_text(encoding='utf-8-sig')) else '.exe'
        folder = tree.findall('.//m:DCC_ExeOutput',ns)[-1].text
        expected.append((proj.parent/folder/(Path(source).stem+ext)).resolve())
    # Refuse to accept the previous run's log as evidence of this build.
    err = group_file.with_suffix('.err')
    if err.exists():
        history = HERE/'build/logs'; history.mkdir(parents=True,exist_ok=True)
        err.rename(history/(group+'-'+str(time.time_ns())+'.err'))
    # IDE sometimes rewrites project metadata. Preserve exact pre-run bytes.
    metadata = projects+[group_file]
    original = {p:p.read_bytes() for p in metadata}
    start = time.time()
    result = dict(group=group, start=datetime.datetime.now().isoformat(), attempts=1,
                  dialogs=[], errors=[], expected=[str(p) for p in expected])
    p = None
    acted = {}
    try:
        # Main session may be exercising exclusive DirectDraw. Build on a
        # separate, never-switched desktop; no IDE HWND can take its foreground.
        desktop_name = 'MedStandaloneBuild-'+str(os.getpid())
        build_desktop = u.CreateDesktopW(desktop_name,None,None,0,0x1ff,None)
        if not build_desktop: raise C.WinError(C.get_last_error())
        desktop_path = 'WinSta0\\'+desktop_name
        result['desktop'] = desktop_path
        result['desktop_switched'] = False
        p = DesktopProcess([str(Path(os.environ['BDS'])/'bin/bds.exe'),'-b','-ns',str(group_file)],group_file.parent,desktop_path)
        result['pid'] = p.pid
        while p.poll() is None:
            if time.time()-start > timeout:
                result['timeout_windows'] = windows(p.pid)
                raise TimeoutError('Owned IDE build timed out')
            default_visible=[]
            @CB
            def audit_default(h,_):
                pid=W.DWORD();u.GetWindowThreadProcessId(h,C.byref(pid))
                if pid.value==p.pid and u.IsWindowVisible(h):default_visible.append(int(h))
                return True
            u.EnumWindows(audit_default,0)
            if default_visible: raise RuntimeError('Owned IDE leaked visible windows to default desktop: '+str(default_visible))
            result['default_desktop_visible_owned_windows'] = []
            for row in windows(p.pid):
                # Native task dialogs and Delphi custom message dialogs only.
                if row['cls'] not in {'#32770','TMessageForm','TTaskDialogForm','TProgressForm'}: continue
                buttons = [c for c in row['children'] if c['cls'].lower() in {'button','tbutton','tbitbtn'}]
                if not buttons: continue
                text = ' '.join([row['text']]+[c['text'] for c in row['children']])
                title = row['text'].casefold()
                def label(c): return c['text'].replace('&','').strip().casefold()
                no = next((c for c in buttons if label(c) in {'no','否','否(n)','no to all','全部否','全部否(n)'}),None)
                ok = next((c for c in buttons if label(c) in {'ok','确定','确定(o)'}),None)
                action = None
                if row['cls'] == 'TProgressForm' and (not ok or not u.IsWindowEnabled(ok['hwnd'])): continue
                if no and (any(s in text.casefold() for s in ['save','saving','保存']) or title in {'confirm','confirmation','确认'}):
                    button, action = no, 'NO: discard IDE save confirmation'
                elif ok and (any(s in title for s in ['build','compile','编译','构建']) or
                             any(s in text.casefold() for s in ['build failed','build succeeded','compilation failed','编译失败','编译成功'])):
                    button, action = ok, 'OK: acknowledge build result (log decides success)'
                else:
                    result['dialogs'].append(dict(**row, action='FAIL: unexpected owned modal'))
                    raise RuntimeError('Unexpected owned IDE dialog: '+text)
                key = (row['hwnd'],text)
                if key not in acted:
                    result['dialogs'].append(dict(**row,action=action))
                    acted[key] = time.time()
                    if not u.IsWindowEnabled(button['hwnd']): raise RuntimeError('Owned dialog button disabled')
                    u.PostMessageW(button['hwnd'],0xF5,0,0) # BM_CLICK
                elif time.time()-acted[key]>10:
                    raise RuntimeError('Owned dialog did not dismiss')
            time.sleep(.1)
        result['exit_code'] = p.returncode
        if p.returncode != 0: result['errors'].append('IDE exit code '+str(p.returncode))
        log = err.read_text(encoding='utf-8-sig',errors='replace') if err.exists() else ''
        failures = [line for line in log.splitlines() if re.search(r'\[(?:dcc\w*|brcc\w*) (?:Fatal )?Error\]|\b(?:Fatal:|Error [EF]\d+)|^\s*Failed\s*$',line,re.I)]
        result['errors'].extend(failures)
        if not re.search(r'^\s*Success\s*$',log,re.M): result['errors'].append('No fresh terminal Success in build log')
        result['outputs'] = []
        for f in expected:
            if not f.exists() or f.stat().st_mtime < start-2:
                result['errors'].append('Missing/stale output '+str(f))
            else: result['outputs'].append(dict(path=str(f),bytes=f.stat().st_size,sha256=sha(f)))
    except Exception as e:
        result['errors'].append(type(e).__name__+': '+str(e))
    finally:
        if p is not None and p.poll() is None:
            # Terminate only the process object launched here; no taskkill/name match.
            p.kill(); p.wait(timeout=10)
            result['owned_pid_terminated'] = True
        if p is not None: result['exit_code'] = p.returncode
        if p is not None: p.close()
        if build_desktop:
            u.CloseDesktop(build_desktop)
            build_desktop = None
        restored = []
        for path, data in original.items():
            if path.read_bytes() != data:
                path.write_bytes(data); restored.append(str(path))
        result['restored_ide_metadata'] = restored
        result['end'] = datetime.datetime.now().isoformat()
        result['success'] = not result['errors']
        logs=HERE/'build/logs'; logs.mkdir(parents=True,exist_ok=True)
        (logs/(group+'-build-result.json')).write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf-8')
        if err.exists(): err.replace(logs/(group+'.err'))
    print(json.dumps(result,indent=2,ensure_ascii=False))
    return 0 if result['success'] else 1

if __name__ == '__main__': sys.exit(run(sys.argv[1]))
