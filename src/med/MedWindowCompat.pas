unit MedWindowCompat;

interface

uses Winapi.Windows, Vcl.Forms, Vcl.Controls;

type
  // Window policy only. The descendant keeps its original DFM and business.
  TMedHostForm = class(TForm)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure DoShow; override;
  public
    procedure SynchronizeToGame;
  end;

function MedModernOwnsWindows: Boolean;
function MedNativeGameBounds(Game: HWND; out Bounds: TRect): Boolean;
function MedIntersectMonitorBounds(const ClientBounds, MonitorBounds: TRect;
  out Bounds: TRect): Boolean;
function MedOriginMonitorBounds(const ClientBounds, MonitorBounds: TRect;
  out Bounds: TRect): Boolean;

implementation

uses Winapi.Messages, Winapi.MultiMon, System.Types, MedHookLifetime;

type
  TGetRect = function(Wnd: HWND; var Rect: TRect): BOOL; stdcall;
  TToScreen = function(Wnd: HWND; var Point: TPoint): BOOL; stdcall;
  TPosition = function(Wnd, After: HWND; X,Y,CX,CY: Integer; Flags: UINT): BOOL; stdcall;
  TGetLong = function(Wnd: HWND; Index: Integer): NativeInt; stdcall;
  TEnable = function(Wnd: HWND; Enable: BOOL): BOOL; stdcall;
  TClip = function(Rect: PRect): BOOL; stdcall;
  TModeRunning = function: Integer; cdecl;
  TMonitorFromWindow = function(Wnd: HWND; Flags: DWORD): HMONITOR; stdcall;
  TMonitorFromPoint = function(Point: TPoint; Flags: DWORD): HMONITOR; stdcall;
  TGetMonitorInfo = function(Monitor: HMONITOR; Info: PMonitorInfoW): BOOL; stdcall;
var
  RealClient, RealOuter: TGetRect;
  RealScreen: TToScreen;
  RealPosition: TPosition;
  RealGetLong: TGetLong;
  RealEnable: TEnable;
  RealClip: TClip;
  RealMonitorFromWindow: TMonitorFromWindow;
  RealMonitorFromPoint: TMonitorFromPoint;
  RealMonitorInfo: TGetMonitorInfo;
  GameWindow, MedWindow: HWND;
  FollowHook: HHOOK;
  Busy: Boolean;

function MedModernOwnsWindows: Boolean;
var Host: HMODULE; Running: TModeRunning;
begin
  // Modern's medCreated deliberately skips running Mode2. Only Mode0/1 own
  // MED geometry. Query the public runtime contract, never a saved INI mode.
  Host := GetModuleHandle('P3Modern.dll');
  Result := Host <> 0;
  if Host = 0 then Exit;
  @Running := GetProcAddress(Host, 'P3ModeRunning');
  if Assigned(Running) then Result := Running <> 2;
  // Older/unknown hosts without the export retain their existing ownership.
end;

procedure ResolveUser32;
var Module: HMODULE;
begin
  if Assigned(RealClient) then Exit;
  Module := GetModuleHandle('user32.dll');
  @RealClient := GetProcAddress(Module, 'GetClientRect');
  @RealOuter := GetProcAddress(Module, 'GetWindowRect');
  @RealScreen := GetProcAddress(Module, 'ClientToScreen');
  @RealPosition := GetProcAddress(Module, 'SetWindowPos');
  @RealGetLong := GetProcAddress(Module, 'GetWindowLongW');
  @RealEnable := GetProcAddress(Module, 'EnableWindow');
  @RealClip := GetProcAddress(Module, 'ClipCursor');
  @RealMonitorFromWindow := GetProcAddress(Module, 'MonitorFromWindow');
  @RealMonitorFromPoint := GetProcAddress(Module, 'MonitorFromPoint');
  @RealMonitorInfo := GetProcAddress(Module, 'GetMonitorInfoW');
end;

function OwnGameThread(Game: HWND): Boolean;
var PID, ThreadID: DWORD;
begin
  PID := 0;
  ThreadID := GetWindowThreadProcessId(Game, @PID);
  Result := (Game <> 0) and (PID = GetCurrentProcessId) and
    (ThreadID = GetCurrentThreadId);
end;

function MedIntersectMonitorBounds(const ClientBounds, MonitorBounds: TRect;
  out Bounds: TRect): Boolean;
begin
  Bounds := Rect(0, 0, 0, 0);
  Result := False;
  if (ClientBounds.Right <= ClientBounds.Left) or
     (ClientBounds.Bottom <= ClientBounds.Top) or
     (MonitorBounds.Right <= MonitorBounds.Left) or
     (MonitorBounds.Bottom <= MonitorBounds.Top) then Exit;
  Result := IntersectRect(Bounds, ClientBounds, MonitorBounds);
end;

function ClientAnchor(const ClientBounds: TRect): TPoint;
begin
  Result := Point(ClientBounds.Left, ClientBounds.Top);
  if ClientBounds.Right > ClientBounds.Left + 1 then Inc(Result.X);
  if ClientBounds.Bottom > ClientBounds.Top + 1 then Inc(Result.Y);
end;

function MedOriginMonitorBounds(const ClientBounds, MonitorBounds: TRect;
  out Bounds: TRect): Boolean;
begin
  Bounds := Rect(0, 0, 0, 0);
  Result := False;
  if (ClientBounds.Right <= ClientBounds.Left) or
     (ClientBounds.Bottom <= ClientBounds.Top) then Exit;
  // An overlapping/nearest monitor alone does not prove where the game starts.
  if not PtInRect(MonitorBounds, ClientAnchor(ClientBounds)) then Exit;
  Result := MedIntersectMonitorBounds(ClientBounds, MonitorBounds, Bounds);
end;

function MedNativeGameBounds(Game: HWND; out Bounds: TRect): Boolean;
var Client, ScreenClient: TRect; Origin, Anchor: TPoint;
    Monitor: HMONITOR; Info: TMonitorInfoW;
  function TryMonitor(Candidate: HMONITOR): Boolean;
  begin
    Result := False;
    if (Candidate = 0) or not Assigned(RealMonitorInfo) then Exit;
    FillChar(Info, SizeOf(Info), 0);
    Info.cbSize := SizeOf(Info);
    if RealMonitorInfo(Candidate, @Info) then
      Result := MedOriginMonitorBounds(ScreenClient, Info.rcMonitor, Bounds);
  end;
begin
  Result := False;
  Bounds := Rect(0, 0, 0, 0);
  if not OwnGameThread(Game) or IsIconic(Game) then Exit;
  ResolveUser32;
  Origin := Point(0, 0);
  if not RealClient(Game, Client) or not RealScreen(Game, Origin) then Exit;
  if (Client.Left <> 0) or (Client.Top <> 0) or
     (Client.Right <= 0) or (Client.Bottom <= 0) then Exit;
  // Do not turn a minimized/invalid Win32 sentinel into an on-screen UI claim.
  if (Origin.X <= -32000) or (Origin.Y <= -32000) or
     (Origin.X >= 32767) or (Origin.Y >= 32767) then Exit;
  if (Int64(Origin.X) + Client.Right > High(Integer)) or
     (Int64(Origin.Y) + Client.Bottom > High(Integer)) then Exit;
  ScreenClient := Rect(Origin.X, Origin.Y, Origin.X + Client.Right, Origin.Y + Client.Bottom);
  if (RealGetLong(Game, GWL_STYLE) and WS_CAPTION) = WS_CAPTION then
  begin
    // A normal decorated window may legitimately span multiple monitors.
    Bounds := ScreenClient;
    Result := True;
    Exit;
  end;
  // Native/Mode2 can retain an oversized HWND after a DirectDraw mode change.
  // Maximum HWND overlap can select the secondary after the primary shrinks.
  // Select the physical monitor containing the client origin's interior pixel.
  // Read fresh rcMonitor (not rcWork); never move the game or desktop layout.
  Anchor := ClientAnchor(ScreenClient);
  Monitor := 0;
  if Assigned(RealMonitorFromPoint) then
    Monitor := RealMonitorFromPoint(Anchor, MONITOR_DEFAULTTONULL);
  Result := TryMonitor(Monitor);
  if Result then Exit;
  // API/race fallback is accepted only with the same origin containment proof.
  if Assigned(RealMonitorFromWindow) then
    Result := TryMonitor(RealMonitorFromWindow(Game, MONITOR_DEFAULTTONULL));
end;

function CaptionedGame: Boolean;
begin
  Result := (RealGetLong(GameWindow, GWL_STYLE) and WS_CAPTION) = WS_CAPTION;
end;

procedure SynchronizeBounds;
var Bounds, Current: TRect;
begin
  if MedModernOwnsWindows or not IsWindow(MedWindow) then Exit;
  if not MedNativeGameBounds(GameWindow, Bounds) or not RealOuter(MedWindow, Current) then Exit;
  if not EqualRect(Bounds, Current) then
    RealPosition(MedWindow, 0, Bounds.Left, Bounds.Top, Bounds.Width, Bounds.Height,
      SWP_NOACTIVATE or SWP_NOZORDER);
end;

procedure DetachNativeWindow(Window: HWND);
begin
  if (Window <> 0) and (Window <> MedWindow) then Exit;
  if FollowHook <> 0 then
  begin
    UnhookWindowsHookEx(FollowHook);
    FollowHook := 0;
  end;
  GameWindow := 0;
  MedWindow := 0;
end;

procedure ReleaseNativeMouse;
var Foreground: HWND;
begin
  // No global mouse/focus changes for a hidden window or another application.
  if not IsWindowVisible(MedWindow) then Exit;
  Foreground := GetForegroundWindow;
  if (Foreground = GameWindow) or (Foreground = MedWindow) then RealClip(nil);
end;

function FollowGame(Code: Integer; WParam: WPARAM; LParam: LPARAM): LRESULT; stdcall;
var Event: PCWPRetStruct;
begin
  if (Code >= 0) and not Busy and (MedWindow <> 0) then
  begin
    if MedModernOwnsWindows then DetachNativeWindow(MedWindow)
    else
    begin
      Event := PCWPRetStruct(LParam);
      Busy := True;
      try
        if (Event.message = WM_NCDESTROY) and
           ((Event.hwnd = GameWindow) or (Event.hwnd = MedWindow)) then
          DetachNativeWindow(MedWindow)
        else if IsWindow(MedWindow) then
        begin
          if (Event.hwnd = GameWindow) and
             (Event.message in [WM_WINDOWPOSCHANGED, WM_SIZE, WM_MOVE, WM_DISPLAYCHANGE]) then
            SynchronizeBounds;
          if (Event.hwnd = MedWindow) and (Event.message = WM_DISPLAYCHANGE) then
            SynchronizeBounds;
          if IsWindowVisible(MedWindow) then
          begin
            // PI's native decorated-window fallback keeps the host enabled.
            // Native exclusive retains the normal VCL modal ownership policy.
            if CaptionedGame and (Event.hwnd = GameWindow) and
               (Event.message = WM_ENABLE) and (Event.wParam = 0) then
              RealEnable(GameWindow, True);
            if ((Event.hwnd = GameWindow) or (Event.hwnd = MedWindow)) and
               ((Event.message = WM_ACTIVATE) or (Event.message = WM_NCACTIVATE) or
                (Event.message = WM_SHOWWINDOW) or (Event.message = WM_ENTERSIZEMOVE) or
                (Event.message = WM_EXITSIZEMOVE)) then ReleaseNativeMouse;
          end;
        end;
      finally
        Busy := False;
      end;
    end;
  end;
  Result := CallNextHookEx(0, Code, WParam, LParam);
end;

procedure AttachNativeWindow(Window: HWND);
begin
  if MedModernOwnsWindows or not OwnGameThread(MedParentWindow) or
     not IsWindow(Window) then Exit;
  ResolveUser32;
  if (MedWindow <> 0) and (MedWindow <> Window) then DetachNativeWindow(MedWindow);
  GameWindow := MedParentWindow;
  MedWindow := Window;
  if FollowHook = 0 then
    FollowHook := SetWindowsHookEx(WH_CALLWNDPROCRET, @FollowGame, HInstance, GetCurrentThreadId);
  // No SetWindowLong(GWL_WNDPROC): VCL owns its window procedure throughout.
  SynchronizeBounds;
end;

procedure TMedHostForm.CreateParams(var Params: TCreateParams);
var Bounds: TRect;
begin
  inherited;
  if MedModernOwnsWindows or not OwnGameThread(MedParentWindow) then Exit;
  ResolveUser32;
  // Match PI: a true game-owned popup, never WS_CHILD | WS_POPUP.
  Params.Style := (Params.Style and not (WS_CHILD or WS_CAPTION or WS_THICKFRAME or
    WS_BORDER or WS_DLGFRAME)) or WS_POPUP;
  Params.ExStyle := Params.ExStyle and not (WS_EX_APPWINDOW or WS_EX_DLGMODALFRAME or
    WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE or WS_EX_TOPMOST);
  if (RealGetLong(MedParentWindow, GWL_STYLE) and WS_CAPTION) <> WS_CAPTION then
    Params.ExStyle := Params.ExStyle or WS_EX_TOPMOST;
  Params.WndParent := MedParentWindow;
  if MedNativeGameBounds(MedParentWindow, Bounds) then
  begin
    Params.X := Bounds.Left; Params.Y := Bounds.Top;
    Params.Width := Bounds.Width; Params.Height := Bounds.Height;
  end;
end;

procedure TMedHostForm.CreateWnd;
begin
  if not MedModernOwnsWindows then Position := poDesigned;
  inherited;
  AttachNativeWindow(Handle);
end;

procedure TMedHostForm.DestroyWnd;
begin
  if HandleAllocated then DetachNativeWindow(Handle);
  inherited;
end;

procedure TMedHostForm.DoShow;
begin
  if not MedModernOwnsWindows then
  begin
    Position := poDesigned;
    WindowState := wsNormal;
    AttachNativeWindow(Handle);
    if (MedWindow = Handle) and CaptionedGame then RealEnable(GameWindow, True);
    ReleaseNativeMouse;
  end;
  inherited;
end;

procedure TMedHostForm.SynchronizeToGame;
begin
  if not MedModernOwnsWindows and HandleAllocated then AttachNativeWindow(Handle);
end;

initialization
finalization
  DetachNativeWindow(0);
end.
