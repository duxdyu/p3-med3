unit untMed;
interface
uses
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs, StdCtrls, ExtCtrls, XPMan, ComCtrls;

type
TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    StaBar: TStatusBar;
    Timer1: TTimer;
    Button1: TButton;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);





private
{ Private declarations }
public
destructor Destroy; override;
{ Public declarations }
end;

var
  Form1: TForm1;
  GB:bool;
  GH:HWND;
  GH2:HWND;
  GName:string;

function SetHook(lpHwnd:HWND):bool;stdcall;external 'MED3.dll' name 'SetHook';
procedure StopHook;stdcall;external 'MED3.dll' name 'StopHook';


implementation

//------------------------------------------------------------------------------
{$R *.dfm}

destructor TForm1.Destroy;
begin
  StopHook;
  inherited Destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
form1.Close;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
if  Edit1.Text='' then
    begin
      showmessage('游戏名不能为空！');
      exit;
     end;


GName:=edit1.text;
GH:=FindWindow(nil,pchar(GName));
if GH>0 then
   begin
     GB:=SetHook(GH);
     if GB then
        begin
           Application.Title:='钩子安装成功！';
           stabar.Panels[0].Text :='钩子安装成功！F2呼出窗口';
           Timer1.Enabled :=false;
           Timer2.Enabled :=true;
            // The shipped old launcher hides Form1, not Application.Minimize.
            // Keep the owning process and Timer2 alive without a taskbar button.
            Hide;
            ShowWindow(Application.Handle, SW_HIDE);

        end
        else
         stabar.Panels[0].Text :='钩子安装失败';
    end
   else
     stabar.Panels[0].Text :='没找游戏，检查游戏名是否正确';

end;



procedure TForm1.Timer2Timer(Sender: TObject);

begin
GH2:=FindWindow(nil,pchar(GName));
if GH2=0 then form1.Close;

end;


end.

