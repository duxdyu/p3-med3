program MED3;
{$SETPEOSVERSION 5.1}
{$SETPESUBSYSVERSION 5.1}

uses
  Winapi.UIAutomation in '..\sdk-overlay\Winapi.UIAutomation.pas',
  Forms,
  Windows,
  Dialogs,
  untMed in 'untMed.pas';

{$R *.res}
{$R 'MEDAppIcon.res'}

VAR
Mutex:THandle;

begin
  Mutex:=CreateMutex(NIL,True,'SingleApp');
  if GetLastError<>ERROR_ALREADY_EXISTS then//如果不存在另一实例
   begin
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
   end
   else
   begin
   showmessage('已有一个实例在运行');
   ReleaseMutex(Mutex);
   end;

end.
