unit Untmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
   StdCtrls, Grids, ComCtrls, ImgList,Untpublic, ExtCtrls, ValEdit,Math,
  DBGrids, Tabs,Buttons,Dialogs, TabNotBk, jpeg, CheckLst,strUtils,
  Menus , ToolWin, MedWindowCompat,
  Untjg, UntShowShip,UntEditMap,UntShipyard,Untdzh,UntRk,UntSc,UntSWS,UntBuild,
  Unthd,UntDk,UntJT,UntJS,Untplays,Untmylx,Untabout,UntWc,Untph,UntWuqi,
  Untimt,Untother;

type
  TFrmMain = class(TMedHostForm)
    page: TPageControl;
    PageZL: TTabSheet;
    pagejg: TTabSheet;
    pageDzh: TTabSheet;
    TabMylx: TTabSheet;
    Panel21: TPanel;
    EditMap: TTabSheet;
    Dk: TTabSheet;
    PageMadeShip: TTabSheet;
    Panel20: TPanel;
    Panel7: TPanel;
    PageSWS: TTabSheet;
    TabJT: TTabSheet;
    Panel10: TPanel;
    Panel9: TPanel;
    Panel11: TPanel;
    Image1: TImage;
    Panel8: TPanel;
    Panel12: TPanel;
    Panel14: TPanel;
    PagePh: TTabSheet;
    Panel17: TPanel;
    PageImt: TTabSheet;
    Panel18: TPanel;
    Panel22: TPanel;
    TabSheet6: TTabSheet;
    Button1: TButton;
    LE2: TLabeledEdit;
    LE1: TLabeledEdit;
    BitBtn3: TBitBtn;
    ListBox2: TListBox;
    PageMid: TPageControl;
    TabRK: TTabSheet;
    Panel0: TPanel;
    TabSpcb: TTabSheet;
    TabWq: TTabSheet;
    Tabjs: TTabSheet;
    TabShip: TTabSheet;
    TabWc: TTabSheet;
    TabMyz: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel13: TPanel;
    Panel15: TPanel;
    Panel23: TPanel;
    BitBtn1: TBitBtn;
    TabPice: TTabSheet;
    Panel16: TPanel;
    TabLayout: TTabSheet;
    Panlay: TPanel;
    Tabbj: TTabSheet;
    Panel19: TPanel;


    procedure FormCreate(Sender: TObject);
    procedure PageMidChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure pageChange(Sender: TObject);
    procedure SpeedButton16Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);



  private
//    procedure WndProc(var Message: TMessage); override;
//    procedure CreateParams(var Params:TCreateParams);override;
     
    { Private declarations }

  public
    { Public declarations }

  end;
 Function Restart:boolean;



var
  FrmMain: TFrmMain;

  hMapObject: THandle = 0;
implementation

uses MedDiagnostics, MedHookLifetime;

const
  // Read/write game memory and query its PID for native production-table checks.
  // Delphi 13 PROCESS_ALL_ACCESS includes rights unavailable on Windows XP.
  MedProcessAccess = PROCESS_QUERY_INFORMATION or PROCESS_VM_READ or
    PROCESS_VM_WRITE or PROCESS_VM_OPERATION;

function OpenMedProcess(GamePID: DWORD): THandle;
var Error: DWORD;
begin
  Result := OpenProcess(MedProcessAccess, False, GamePID);
  Error := GetLastError;
  TraceMed('OpenProcess pid='+UIntToStr(GamePID)+' access='+IntToHex(MedProcessAccess,8)+
    ' handle='+IntToHex(NativeUInt(Result),8)+' error='+UIntToStr(Error));
end;

{$R *.dfm}

//procedure TFrmMain.WndProc(var Message: TMessage);
//begin
//  inherited WndProc(Message);
//  if Message.Msg=TILC_Message then
//    Close;
//end;

//procedure  TFrmMain.CreateParams(var Params:TCreateParams);
//begin
//    FrmMain.BorderStyle :=bsNone;
//    inherited   CreateParams(Params);
//    Params.Style :=WS_THICKFRAME or WS_POPUP  OR WS_BORDER;
//end;

//-----------------------FormCreate--------------------------------------
procedure TFrmMain.FormCreate(Sender: TObject);
var
i:word;
windowstyle:longint;
GameWindow: HWND;
GamePID: DWORD;
begin
GameWindow := MedParentWindow;
GamePID := 0;
GetWindowThreadProcessId(GameWindow, @GamePID);
if GamePID = 0 then
begin
  ShowMessage('没有找到游戏');
  Exit;
end;
if GHandle = 0 then GHandle := OpenMedProcess(GamePID);
Arestart:=0;
windowstyle:=getwindowlong(handle,GWL_Style);
setwindowlong(handle,GWL_Style,windowstyle and not WS_Border);

For i:= Low(SpBmp) To High(SpBmp) do
  begin
  SpBmp[i]:=TBitmap.Create; //实例化子图片
     SpBmp[i].Height:=20;
     SpBmp[i].Width:=20;
     BitBlt (SpBmp[i].Canvas.Handle , 0, 0, 20, 20, image1.Canvas.Handle , i*20, 0, SRCCOPY);
end;
//for i:=0 to page.PageCount-1 do
//page.Pages[i].TabVisible :=false;
end;


procedure TFrmMain.FormShow(Sender: TObject);
var
GPid,T:Dword;
GH:Hwnd;
Amoney,Atime:integer;
begin
GH:=MedParentWindow;
T:=GetWindowThreadProcessId(GH,GPid);//FindProcess('p3.exe'); //------检测游戏启动
if GPid=0 then
   begin
      showmessage ('没有找到游戏');
      FrmMain.close;
      exit;
   end
   else
   begin
      if GHandle=0 then
         GHandle:=OpenMedProcess(GPid);// 返回游戏句柄
   end;

if not Restart then
begin
  FrmMain.Close;
  Poped := True; // Terminal 004C67C0 marks the failed opening before returning.
  Exit;
end;
Game_init;
Amoney:=Get_Money;
panel22.Caption :='$'+inttostr(Amoney);
ReadProcessMemory(GHandle, Pointer($71cdbc), Pointer(@Atime),4,tmpNum);

Panel23.Caption :=Time_to_string(Atime);
FrmMain.pageChange(Sender);
end;

//-------------------------------------------------
procedure TFrmMain.FormActivate(Sender: TObject);
begin
if not MedModernOwnsWindows then
begin
  SynchronizeToGame;
  Exit;
end;
FrmMain.top:=-3;
FrmMain.left:=-3;
FrmMain.width:=screen.Width +6;
FrmMain.height:=screen.Height+6;
end;


//-------------------------------------------------
procedure TFrmMain.PageMidChange(Sender: TObject);
begin
case PageMid.TabIndex of
  0: begin
  FrmRk.Show;
  FrmRk.Button1Click(Sender);
  end;
  1:begin
  FrmSc.Show;
  FrmSc.TabControl1Change(Sender);
  end;
  2:begin
  FrmWuqi.Show;
  FrmWuqi.Button1Click(Sender);
  end;
  3:begin
   FrmJs.Show;
  FrmJS.Button1Click(Sender);
  end;
  4:begin
  FrmShowShip.Show;
  show_ship;
  end;
  5:begin
  Frmwc.Show;
  FrmWc.RadioGroup1Click(Sender);
  end;
  6:begin
  FrmPlays.Show;
  FrmPlays.Button1Click(Sender);
   end;
  7:begin
  FrmJT.Show;
  FrmJT.Button1Click(Sender);
  end;

end;
end;

//----------------------------重启进程----------------------------------
Function Restart:boolean;
begin
Result:=true;
ReadProcessMemory(GHandle, Pointer($71CE20), Pointer(@PlaysJz),4,Numtmp);//贸易者基址
ReadProcessMemory(GHandle, Pointer($71CE10), Pointer(@CityJz),4,tmpNum); //城市基址
ReadProcessMemory(GHandle, Pointer($6DFB8C), Pointer(@ShipJZ),4,tmpNum); //船只基址
ReadProcessMemory(GHandle, Pointer($6DFB90), Pointer(@ShipJdjz),4,tmpNum); //舰队基址
ReadProcessMemory(GHandle, Pointer($71CE1C), Pointer(@SWSjz),4,tmpNum);//事务所基址
ReadProcessMemory(GHandle, Pointer($6E2F2C), Pointer(@Home),1,tmpNum);//家乡城市编号
ReadProcessMemory(GHandle, Pointer($71CDB8), Pointer(@CityCunt),1,tmpNum); //城市总数
ReadProcessMemory(GHandle, Pointer($71CDB2), Pointer(@Player),1,tmpNum);  //玩家编号
ReadProcessMemory(GHandle, Pointer($71CE26), Pointer(@Swscunt),2,tmpNum);//事务所数量
// Final MED 00479348 rejects any missing required game table, not only all-zero state.
if (PlaysJz=0) or (CityJz=0) or (ShipJZ=0) or (SWSjz=0) or (CityCunt=0) or (Player=0) then
     Result:=false;
end;

//----------------------------------------------------
procedure TFrmMain.pageChange(Sender: TObject);
begin
case page.TabIndex of
//------------0
0:
begin
if not Assigned(FrmRk) then
begin
FrmRk:= TFrmRk.Create(self);
FrmRk.Parent := Panel0;
FrmRk.Show;
end;

if not Assigned(FrmSc) then
begin
FrmSc:= TFrmSc.Create(self);
FrmSc.Parent := Panel1;
FrmSc.Show;
end;

if not Assigned(FrmWuqi) then
begin
FrmWuqi:= TFrmWuqi.Create(self);
FrmWuqi.Parent := Panel2;
FrmWuqi.Show;
end;

if not Assigned(FrmJs) then
begin
FrmJs:= TFrmJs.Create(self);
FrmJs.Parent := Panel3;
FrmJs.Show;
end;

if not Assigned(FrmShowShip) then
begin
FrmShowShip:= TFrmShowShip.Create(self);
FrmShowShip.Parent := Panel4;
FrmShowShip.Show;
end;

if not Assigned(FrmJT) then
begin
FrmJT:= TFrmJT.Create(self);
FrmJT.Parent := Panel13;
FrmJT.Show;
end;

if not Assigned(FrmPlays) then
begin
FrmPlays:= TFrmPlays.Create(self);
FrmPlays.Parent := Panel6;
FrmPlays.Show;
end;
if not Assigned(Frmwc) then
begin
Frmwc:= TFrmwc.Create(self);
Frmwc.Parent := Panel5;
Frmwc.Show;
end;
if not Assigned(FrmShowShip) then
begin
FrmShowShip:= TFrmShowShip.Create(self);
FrmShowShip.Parent := Panel4;
FrmShowShip.Show;
end;
FrmMain.PageMidChange(Sender);
end;

//----------------------1
1:
begin
if not Assigned(FrmSWS) then
begin
FrmSWS:= TFrmSWS.Create(self);
FrmSWS.Parent := Panel8;
FrmSWS.Show;
end;
FrmSWS.Button8Click(Sender);
end;
//----------------------2
2:
begin
if not Assigned(FrmShipyard) then
begin
FrmShipyard:= TFrmShipyard.Create(self);
FrmShipyard.Parent := Panel12;
FrmShipyard.Show;
end;
FrmShipYard_init;
end;
//----------------------3
3:
begin
if not Assigned(FrmJg) then
begin
FrmJg:= TFrmJg.Create(self);
FrmJg.Parent := Panel14;
FrmJg.Show;
end;
FrmJg.Button1Click(Sender);
FrmJg.BitBtn1Click(Sender);
end;

//----------------------4
4:
begin
if not Assigned(FrmDzh) then
begin
FrmDzh:= TFrmDzh.Create(self);
FrmDzh.Parent := Panel7;
FrmDzh.Show;
end;
DzhRefresh;
end;
//---------------------5
5:
begin
if not Assigned(FrmEditMap) then
begin
FrmEditMap:= TFrmEditMap.Create(self);
FrmEditMap.Parent := Panel20;
FrmEditMap.Show;
end;
// Terminal 004A7980 uses the active game city each time this page is entered.
ReadProcessMemory(GHandle, Pointer($6E2F2C), @Ecity, 1, tmpNum);
if CityCunt = 0 then Exit;
if (Ecity >= CityCunt) or (Ecity >= Length(CityName)) then Ecity := 0;
EDitMap_init;
Change_city;
end;
//---------------------6
6:
begin
if not Assigned(FrmDk) then
begin
FrmDk:= TFrmDk.Create(self);
FrmDk.Parent := Panel9;
FrmDk.Show;
end;
FrmDk.Button2Click(Sender);

end;
//---------------------7
7:
begin
if not Assigned(FrmMylx) then
begin
FrmMylx:= TFrmMylx.Create(self);
FrmMylx.Parent := Panel21;
FrmMylx.Show;
end;
MYLxMap_init;
Get_JDL;

end;

8:
begin
if not Assigned(FrmHd) then
begin
FrmHd:= TFrmHd.Create(self);
FrmHd.Parent := Panel11;
FrmHd.Show;
end;
FrmHd.Button1Click(Sender);
end;

9:
begin
if not Assigned(FrmPH) then
begin
FrmPH:= TFrmPH.Create(self);
FrmPH.Parent := Panel17;
FrmPH.Show;
end;
PH_init;
FrmPH.RadioGroupClick(Sender);
FrmPH.Button1Click(Sender);
end;

10:
begin
if not Assigned(Frmimt) then
begin
Frmimt:= TFrmimt.Create(self);
Frmimt.Parent := Panel18;
Frmimt.Show;
end;
FrmImt.BitBtn1Click(Sender);
end;


// Terminal page dispatcher has only visible indices 0..10.
// Price/layout/comparison resources remain hidden and are not initialized here.
end;
end;






procedure TFrmMain.SpeedButton16Click(Sender: TObject);
begin
close;
Poped:=False;
end;



procedure TFrmMain.BitBtn1Click(Sender: TObject);
begin
close;
Poped:=False;
end;

end.
