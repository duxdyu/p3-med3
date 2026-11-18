unit MedHookLifetime;

interface

uses Winapi.Windows;

var
  MedParentWindow: HWND = 0;

function InstallMedHook(ParentWindow: HWND; Callback: TFNHookProc): BOOL;
function PrepareMedHost: Boolean;
procedure StopMedHook;

implementation

uses System.SysUtils;

function GetModuleHandleExW(Flags: DWORD; Name: PWideChar;
  var Module: HMODULE): BOOL; stdcall; external 'kernel32.dll' name 'GetModuleHandleExW';

type
  PHookInfo = ^THookInfo;
  THookInfo = record
    ParentWindow: HWND;
  end;

var
  OwnerHook: HHOOK = 0;
  OwnerMap: THandle = 0;
  OwnerView: PHookInfo = nil;
  HostPinned: Boolean = False;

function MappingName(PID: DWORD): string;
begin
  Result := 'Local\P3MED.Hook.v2.' + UIntToStr(PID);
end;

procedure StopMedHook;
begin
  if OwnerHook <> 0 then
  begin
    UnhookWindowsHookEx(OwnerHook);
    OwnerHook := 0;
  end;
  if OwnerView <> nil then
  begin
    UnmapViewOfFile(OwnerView);
    OwnerView := nil;
  end;
  if OwnerMap <> 0 then
  begin
    CloseHandle(OwnerMap);
    OwnerMap := 0;
  end;
end;

function InstallMedHook(ParentWindow: HWND; Callback: TFNHookProc): BOOL;
var
  PID, ThreadID, Error: DWORD;
begin
  Result := False;
  if (OwnerHook <> 0) or not IsWindow(ParentWindow) then Exit;
  PID := 0;
  ThreadID := GetWindowThreadProcessId(ParentWindow, @PID);
  if (ThreadID = 0) or (PID = 0) or (PID = GetCurrentProcessId) then Exit;
  OwnerMap := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE,
    0, SizeOf(THookInfo), PChar(MappingName(PID)));
  Error := GetLastError;
  if (OwnerMap = 0) or (Error = ERROR_ALREADY_EXISTS) then
  begin
    StopMedHook;
    Exit;
  end;
  OwnerView := MapViewOfFile(OwnerMap, FILE_MAP_WRITE, 0, 0, SizeOf(THookInfo));
  if OwnerView = nil then
  begin
    StopMedHook;
    Exit;
  end;
  OwnerView^.ParentWindow := ParentWindow;
  OwnerHook := SetWindowsHookEx(WH_KEYBOARD, Callback, HInstance, ThreadID);
  Result := OwnerHook <> 0;
  if not Result then StopMedHook;
end;

function PrepareMedHost: Boolean;
const
  PinFromAddress = $00000001 or $00000004;
var
  Map: THandle;
  View: PHookInfo;
  ParentWindow: HWND;
  PID: DWORD;
  Module: HMODULE;
begin
  Result := False;
  if HostPinned then
  begin
    Result := IsWindow(MedParentWindow);
    Exit;
  end;
  // The injected copy never retains the owner's mapping or hook handle.
  Map := OpenFileMapping(FILE_MAP_READ, False, PChar(MappingName(GetCurrentProcessId)));
  if Map = 0 then Exit;
  try
    View := MapViewOfFile(Map, FILE_MAP_READ, 0, 0, SizeOf(THookInfo));
    if View = nil then Exit;
    try
      ParentWindow := View^.ParentWindow;
    finally
      UnmapViewOfFile(View);
    end;
  finally
    CloseHandle(Map);
  end;
  PID := 0;
  if GetWindowThreadProcessId(ParentWindow, @PID) <> GetCurrentThreadId then Exit;
  if PID <> GetCurrentProcessId then Exit;
  // A VCL form (including its hidden HWND/thunks) outlives an external hook.
  // Pin only here, in the host and before creating any MED window. The loader
  // remains unloadable/closable; the OS releases this pin at host process exit.
  if not GetModuleHandleExW(PinFromAddress, PWideChar(@PrepareMedHost), Module) then Exit;
  MedParentWindow := ParentWindow;
  HostPinned := True;
  Result := True;
end;

initialization
finalization
  StopMedHook;
end.
