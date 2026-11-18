library MED3;
{$SETPEOSVERSION 5.1}
{$SETPESUBSYSVERSION 5.1}

uses
  Winapi.UIAutomation in '..\sdk-overlay\Winapi.UIAutomation.pas',
  SysUtils,
  Classes,Forms,
  Windows,
  MedHookLifetime,
  MedWindowCompat,
  Messages,
  Dialogs,
  MedDiagnostics,
  Untpublic,
  Untmain in 'Untmain.pas';

{$R *.res}
function HookProc(iCode:Integer;wParam: WPARAM;lParam: LPARAM):LRESULT; stdcall;

begin
  result:=0;
// WH_KEYBOARD HC_NOREMOVE is a preview from PeekMessage, not another press.
// Delphi 13's modal loop emits both preview and action for a single F2.
if iCode <> HC_ACTION then
begin
  Result := CallNextHookEx(0, iCode, wParam, lParam);
  Exit;
end;
try
if ((lParam and $C0000000)=0) and(wParam=VK_F2) then
   begin
      // F1 and ordinary game keys must not create MED windows or UI state.
      if not PrepareMedHost then
      begin
        Result := CallNextHookEx(0, iCode, wParam, lParam);
        Exit;
      end;
      if FrmMain = nil then
      begin
        if MedModernOwnsWindows then
          FrmMain := TFrmMain.CreateParented(MedParentWindow)
        else
          FrmMain := TFrmMain.Create(nil);
      end;
      TraceMed('F2 enter code='+IntToStr(iCode)+' poped='+BoolToStr(Poped,True));
      // Final 004C70C0 gates F2 on the loaded game tables.
      if Restart then
      begin
         if not Poped then
         begin
           ShowCursor(true);  //Show cursor sc:=
           Poped:=true;  //set flag
            TraceMed('ShowModal begin');
            try
              FrmMain.ShowModal;
            finally
              Poped := False;
            end;
            TraceMed('ShowModal returned');
         end
      else
       begin
         TraceMed('Close begin');
         FrmMain.Close ;
         TraceMed('Close returned');
        Poped:=false;  //set flag
         end;
      end;
      result:=CallNextHookEx(0,iCode,wParam,lParam);;
     TraceMed('F2 exit');
  end
   else Result := CallNextHookEx(0, iCode, wParam, lParam);
except
  on E: Exception do
  begin
    TraceMed('EXCEPTION '+E.ClassName+': '+E.Message+' addr='+IntToHex(NativeUInt(ExceptAddr),8)+
      ' module='+IntToHex(NativeUInt(HInstance),8)+' rva='+IntToHex(NativeUInt(ExceptAddr)-NativeUInt(HInstance),8));
    raise;
  end;
end;
end;


//---------------------------------------------------------------------
function SetHook(Ahwnd:Hwnd):bool;stdcall;export;  //Call the func to set the keyboard hook
begin
    Result := InstallMedHook(Ahwnd, @HookProc);
end;

procedure StopHook; stdcall; export;
begin
  StopMedHook;
end;


Exports
  SetHook, StopHook;


begin

end.



