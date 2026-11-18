unit Untmylx;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Untpublic, Dialogs, StdCtrls, Grids, ExtCtrls, Math, Buttons, ComCtrls, IniFiles;

type
  TFrmMylx = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel10: TPanel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Imgzy: TImage;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    GroupBox2: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    BitBtn21: TBitBtn;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    StrGid: TStringGrid;
    StrGidL: TStringGrid;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BitBtn21Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Image3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StrGidSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StrGidMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FBoard: TBitmap;
    FHoverRow, FHoverCol, FDownRow, FDownCol: Integer;
    FHoverStop, FCurrentStop, FRouteCount: Integer;
    FRouteCity: array[0..19,0..1] of Byte;
    FPercent: array[0..19] of Integer;
    FBaseCount: array[0..19,0..19] of Integer;
    procedure InitializeAtlas;
    procedure Atlas(Canvas: TCanvas; X,Y,W,H,SX,SY: Integer);
    procedure DrawStop(Index: Integer; Pressed: Boolean);
    procedure DisplayRoute(Index: Integer);
    procedure GetRoute(Index: Integer);
    procedure ApplyPercent(Good, First: Integer);
    procedure DrawButtons;
  public
    destructor Destroy; override;
  end;

procedure Get_JDL;
procedure MYLxMap_init;
function Read_ShipTime(Index: Word): string;

var
  FrmMylx: TFrmMylx;
  BCZT: array[0..200] of Boolean;
  JDL: array[0..200] of Word;
  pyL: array[0..200,0..1] of Word;
  MYlxDZ, CzDZ: Cardinal;
  AllCount: array[0..19,0..19] of Integer;
  Spid: array[0..19,0..19] of Byte;
  JieYu: array[0..19] of Integer;

implementation

uses MedConfigPath;

{$R *.dfm}

const
  MaxTrade = 1000000000;
  ColumnX: array[0..6] of Integer = (20,120,170,198,243,286,314);
  ColumnWidth: array[0..5] of Integer = (96,48,23,35,35,23);
  SelectedMark = #$221A;

function ReadValue(Address: Cardinal; Size: Integer): Integer;
begin
  Result := 0;
  ReadProcessMemory(GHandle, Pointer(Address), @Result, Size, tmpNum);
end;

function Settings: TIniFile;
begin
  Result := TIniFile.Create(MedConfigFileName);
end;

function Read_ShipTime(Index: Word): string;
var Ini: TIniFile;
begin
  Ini := Settings;
  try Result := Ini.ReadString('ShipTime', IntToStr(Index), '7');
  finally Ini.Free;
  end;
end;

procedure Get_JDL;
var
  Fleets: array[0..200] of Cardinal;
  Cities: array[0..20] of Byte;
  FleetBase, CaptainBase, Ship, Fleet, Captain, Route: Cardinal;
  FleetID, ShipID, Node, LastNode, NextNode, ShipNode: Word;
  Count, I, J, Repairs, LastCity, Steps, Row, Age, NowTime, Born: Integer;
  Capacity, Loaded: Integer;
  Ini: TIniFile;
  S, T: string;
begin
  { 004BC2AC: fleet selection and persistent lock/time/captain/load columns. }
  FillChar(JDL, SizeOf(JDL), 0);
  FillChar(pyL, SizeOf(pyL), 0);
  FillChar(BCZT, SizeOf(BCZT), 0);
  FrmMylx.StrGid.RowCount := 1;
  FrmMylx.Image3.Canvas.Brush.Color := RGB(216,205,192);
  FrmMylx.Image3.Canvas.FillRect(Rect(0,0,142,560));
  CzDZ := ReadValue($6DFB8C,4);
  CaptainBase := ReadValue($6DFB88,4);
  FleetBase := ReadValue($6DFB90,4);
  MYlxDZ := ReadValue($6DD070,4);
  FleetID := ReadValue($6DFC74,2);
  NowTime := ReadValue($71CDBC,4);
  Count := 0;
  Steps := 0;
  while (FleetID <> $FFFF) and (Steps < $FFFF) do
  begin
    Fleet := FleetBase + Cardinal(FleetID) * 60;
    FleetID := ReadValue(Fleet+8,2);
    if (ReadValue(Fleet,1) = Player-1) and (Count < Length(Fleets)) then
    begin
      Fleets[Count] := Fleet;
      Inc(Count);
    end;
    Inc(Steps);
  end;
  Row := 1;
  for I := 0 to Count-1 do
  begin
    ShipID := ReadValue(Fleets[I]+16,2);
    Node := ReadValue(CzDZ + Cardinal(ShipID)*$180 + $132,2);
    if Node = $FFFF then Continue;
    LastNode := Node;
    Repairs := 0;
    J := 0;
    LastCity := 0;
    Steps := 0;
    repeat
      Route := MYlxDZ + Cardinal(Node)*$DC;
      if ReadValue(Route+3,1) = 4 then Inc(Repairs);
      if Repairs > 0 then
      begin
        if J > High(Cities) then Break;
        Cities[J] := ReadValue(Route+2,1);
        LastCity := J;
        Inc(J);
        LastNode := Node;
      end;
      NextNode := ReadValue(Route,2);
      Node := NextNode;
      Inc(Steps);
    until (Repairs > 1) or (LastNode = Node) or (Node = $FFFF) or (Steps = $FFFF);
    if (Repairs < 1) or (LastCity < 4) or (LastCity > 20) then Continue;
    if (Cities[0] = Cities[1]) and (Cities[1] <> Cities[2]) and
       (Cities[2] = Cities[3]) and (Row <= High(JDL)) then
    begin
      JDL[Row] := ShipID;
      pyL[Row,0] := LastNode;
      pyL[Row,1] := LastCity;
      Inc(Row);
    end;
  end;
  pyL[0,1] := Row-1;
  FrmMylx.StrGid.RowCount := Row;
  Ini := Settings;
  try
    for Row := 1 to pyL[0,1] do
    begin
      Ship := CzDZ + Cardinal(JDL[Row])*$180;
      FrmMylx.StrGid.Cells[1,Row] := Get_String(Ship+$160);
      Captain := CaptainBase + Cardinal(ReadValue(Ship+$42,2))*16;
      Born := ReadValue(Captain+4,4);
      Age := NowTime-Born;
      if Age > $474A00 then
      begin
        Born := NowTime-$390800;
        WriteProcessMemory(GHandle,Pointer(Captain+4),@Born,4,tmpNum);
        Age := NowTime-Born;
      end;
      FrmMylx.StrGid.Cells[5,Row] := IntToStr(Age div $16D00);
      FrmMylx.StrGid.Cells[6,Row] := IntToStr(ReadValue(Captain+10,1) div 50)+'/'+
        IntToStr(ReadValue(Captain+9,1) div 50)+'/'+IntToStr(ReadValue(Captain+11,1) div 50);
      Fleet := FleetBase + Cardinal(ReadValue(Ship+8,2))*60;
      ShipNode := ReadValue(Fleet+10,2);
      Loaded := 0;
      Steps := 0;
      while (ShipNode <> $FFFF) and (Steps < $FFFF) do
      begin
        Ship := CzDZ + Cardinal(ShipNode)*$180;
        Inc(Loaded, ReadValue(Ship+$118,4)+ReadValue(Ship+$11C,4));
        ShipNode := ReadValue(Ship+6,2);
        Inc(Steps);
      end;
      Capacity := ReadValue(Fleet+4,4);
      BCZT[Row] := (Capacity > 0) and (Round(Loaded*100/Capacity) >= 94);
      S := IntToStr(Ceil(Loaded/200));
      T := IntToStr(Ceil(Capacity/200));
      FrmMylx.StrGid.Cells[3,Row] := S+StringOfChar(' ',Max(0,6-Length(S)))+'/'+
        StringOfChar(' ',Max(0,6-Length(T)))+T;
      FrmMylx.StrGid.Cells[4,Row] := Ini.ReadString('ShipTime',IntToStr(JDL[Row]),'7');
      if Ini.ReadString('SLock',IntToStr(JDL[Row]),'N') = 'Y' then
        FrmMylx.StrGid.Cells[0,Row] := SelectedMark
      else FrmMylx.StrGid.Cells[0,Row] := '';
    end;
  finally Ini.Free;
  end;
end;

procedure KaoAn(CityCode, Index, Kao, ATime: Byte);
var
  Net: array[0..19] of Integer;
  I,J,K,Last,Good,Column: Integer;
  Base: Cardinal;
  Swap: Byte;
begin
  { 004BCC98 consumes the Int64 matrix from 00478810, columns 12/13. }
  FinalCityBalance(CityCode,ATime);
  if FrmMylx.CheckBox2.Checked then Column := 12 else Column := 13;
  for I := 0 to 19 do
    Net[I] := Floor(FinalBalance[I,Column]/Get_BZLX(I))*Get_BZLX(I);
  if FrmMylx.CheckBox3.Checked then
  begin
    Base := Cardinal(CityDZ[CityCode]);
    if (ReadValue(Base+$768,2) <> 0) and (ReadValue(Base+$766,2) <> $FFFF) then
      Dec(Net[19],8000*ATime);
  end;
  for I := 0 to 19 do
  begin
    Inc(JieYu[I],Net[I]);
    if JieYu[I] < 0 then
    begin
      Dec(AllCount[1,I],JieYu[I]);
      JieYu[I] := 0;
    end;
  end;
  Last := Index+Kao-1;
  if Kao = 2 then
    for I := 0 to 19 do
      if Net[I] <= 0 then
      begin AllCount[Index,I] := MaxTrade; AllCount[Index+1,I] := Net[I]; end
      else
      begin AllCount[Index,I] := 0; AllCount[Index+1,I] := MaxTrade; end
  else if Kao = 3 then
  begin
    for I := 0 to 9 do
    begin
      AllCount[Index,I] := -MaxTrade;
      if Net[I] > 0 then
      begin AllCount[Index+1,I] := 0; AllCount[Index+2,I] := MaxTrade; end
      else
      begin AllCount[Index+1,I] := MaxTrade; AllCount[Index+2,I] := Net[I]; end;
    end;
    for I := 10 to 19 do
      if Net[I] > 0 then
      begin
        AllCount[Index,I] := 0;
        AllCount[Index+1,I] := 0;
        AllCount[Index+2,I] := MaxTrade;
      end
      else
      begin
        AllCount[Index,I] := MaxTrade;
        AllCount[Index+1,I] := Net[I];
        AllCount[Index+2,I] := 0;
      end;
    for I := 0 to 9 do
    begin
      Swap := Spid[Index+1,I];
      Spid[Index+1,I] := Spid[Index+1,I+10];
      Spid[Index+1,I+10] := Swap;
    end;
  end;
  I := 0;
  J := 19;
  while I < J do
  begin
    Good := Spid[Last,I];
    if AllCount[Last,Good] = MaxTrade then
    begin
      for K := I to J-1 do Spid[Last,K] := Spid[Last,K+1];
      Spid[Last,J] := Good;
      Dec(J);
    end else Inc(I);
  end;
end;

procedure TFrmMylx.GetRoute(Index: Integer);
var I,J,Atime,Stop: Integer; Node: Word; Address: Cardinal;
begin
  if (Index < 1) or (Index > pyL[0,1]) then Exit;
  FillChar(AllCount,SizeOf(AllCount),0);
  FillChar(JieYu,SizeOf(JieYu),0);
  FillChar(FRouteCity,SizeOf(FRouteCity),$FF);
  for I := 0 to 19 do
  begin
    AllCount[0,I] := -MaxTrade;
    for J := 0 to 19 do Spid[I,J] := J;
  end;
  Atime := Get_Num(StrGid.Cells[4,Index]);
  if Atime < 1 then
  begin Atime := 10; StrGid.Cells[4,Index] := '10'; end;
  FRouteCount := Min(20,pyL[Index,1]);
  Node := pyL[Index,0];
  Image3.Canvas.Brush.Color := RGB(216,205,192);
  Image3.Canvas.FillRect(Rect(0,0,142,560));
  Image3.Canvas.Brush.Style := bsClear;
  for I := 0 to FRouteCount-1 do
  begin
    Address := MYlxDZ+Cardinal(Node)*$DC;
    FRouteCity[I,0] := ReadValue(Address+2,1);
    FRouteCity[I,1] := ReadValue(Address+3,1);
    Node := ReadValue(Address,2);
    if not Timer1.Enabled then
    begin
      Image3.Canvas.Font.Color := clBlack;
      Image3.Canvas.TextOut(2,I*27+16,IntToStr(I+1));
      DrawStop(I,False);
    end;
  end;
  Stop := 2;
  while Stop < FRouteCount-1 do
  begin
    if (FRouteCount-Stop >= 3) and
      (FRouteCity[Stop,0] = FRouteCity[Stop+1,0]) and
      (FRouteCity[Stop+1,0] = FRouteCity[Stop+2,0]) then
    begin
      KaoAn(FRouteCity[Stop,0],Stop,3,Byte(Atime));
      Inc(Stop,3);
    end
    else if (FRouteCount-Stop >= 2) and (FRouteCity[Stop,0] = FRouteCity[Stop+1,0]) then
    begin
      KaoAn(FRouteCity[Stop,0],Stop,2,Byte(Atime));
      Inc(Stop,2);
    end else Inc(Stop);
  end;
  Move(AllCount, FBaseCount, SizeOf(FBaseCount));
  for I := 0 to 19 do ApplyPercent(I,0);
end;

procedure TFrmMylx.ApplyPercent(Good, First: Integer);
var I, Product: Integer;
begin
  for I := First to FRouteCount-1 do
    if (FBaseCount[I,Good] < MaxTrade) and (FBaseCount[I,Good] > -MaxTrade) then
    begin
      Product := FBaseCount[I,Good] * FPercent[Good];
      AllCount[I,Good] := Round(Product/100);
    end;
end;

procedure TFrmMylx.Atlas(Canvas: TCanvas; X,Y,W,H,SX,SY: Integer);
begin
  BitBlt(Canvas.Handle,X,Y,W,H,Imgzy.Canvas.Handle,SX,SY,SRCCOPY);
end;

procedure TFrmMylx.DrawStop(Index: Integer; Pressed: Boolean);
var S: string; Y: Integer;
begin
  if (Index < 0) or (Index >= FRouteCount) or (FRouteCity[Index,0] >= CityCunt) then Exit;
  Y := Index*27+10;
  Atlas(Image3.Canvas,20,Y,96,27,0,360+Ord(Pressed)*27);
  if Pressed then Image3.Canvas.Font.Color := clBlue else Image3.Canvas.Font.Color := clGreen;
  S := CityName[FRouteCity[Index,0]];
  Image3.Canvas.TextOut(20+(96-Image3.Canvas.TextWidth(S)) div 2,Y+6+Ord(Pressed),S);
end;

procedure TFrmMylx.DrawButtons;
var I,Y: Integer;
begin
  for I := 0 to 19 do
  begin
    Y := 60+I*22;
    Atlas(FBoard.Canvas,170,Y,20,18,98,252+Ord((FDownCol=2) and (FDownRow=I))*36);
    Atlas(FBoard.Canvas,286,Y,20,18,98,270+Ord((FDownCol=5) and (FDownRow=I))*36);
  end;
  Atlas(FBoard.Canvas,120,515,48,18,98,Ord(FDownCol=6)*18);
  Atlas(FBoard.Canvas,190,515,48,18,98,180+Ord(FDownCol=7)*18);
  Atlas(FBoard.Canvas,250,515,48,18,98,180+Ord(FDownCol=8)*18);
  FBoard.Canvas.TextOut(210,517+Ord(FDownCol=7),'0');
  FBoard.Canvas.TextOut(263,517+Ord(FDownCol=8),'100');
end;

procedure TFrmMylx.DisplayRoute(Index: Integer);
var I,Good,Amount,Y,Direction,UnitIndex: Integer; S: string;
begin
  if (Index < 0) or (Index >= FRouteCount) then Exit;
  for I := 0 to 19 do
  begin
    Good := Spid[Index,I];
    Amount := AllCount[Index,Good];
    Direction := 0;
    if Amount > 0 then Direction := 3;
    if Amount < 0 then Direction := 6;
    S := '';
    if Amount <> 0 then S := IntToStr(Floor(Abs(Amount)/Get_BZLX(Good)));
    if Abs(Amount) = MaxTrade then S := '最大';
    Y := 60+I*22;
    Atlas(FBoard.Canvas,20,Y,96,18,0,Good*18);
    Atlas(FBoard.Canvas,120,Y,48,18,98,Direction*18);
    Atlas(FBoard.Canvas,198,Y,35,18,98,162);
    Atlas(FBoard.Canvas,243,Y,35,18,98,162);
    FBoard.Canvas.TextOut(205+(20-FBoard.Canvas.TextWidth(S)) div 2,Y+2,S);
    S := IntToStr(FPercent[Good]);
    FBoard.Canvas.TextOut(248+(20-FBoard.Canvas.TextWidth(S)) div 2,Y+2,S);
    UnitIndex := Ord(Get_BZLX(Good)=2000);
    Atlas(FBoard.Canvas,314,Y,23,18,98,216+UnitIndex*18);
  end;
  DrawButtons;
  Image2.Canvas.Draw(0,0,FBoard);
  Image2.Refresh;
end;

procedure TFrmMylx.InitializeAtlas;
var I,Y: Integer;
begin
  if Assigned(FBoard) then Exit;
  FBoard := TBitmap.Create;
  FBoard.Width := Image1.Width;
  FBoard.Height := Image1.Height;
  BitBlt(FBoard.Canvas.Handle,0,0,FBoard.Width,FBoard.Height,Image1.Canvas.Handle,0,0,SRCCOPY);
  FBoard.Canvas.Brush.Style := bsClear;
  FBoard.Canvas.Font.Style := [fsBold];
  for I := 0 to 19 do
  begin
    Y := 60+I*22;
    Atlas(FBoard.Canvas,20,Y,96,18,0,I*18);
    Atlas(FBoard.Canvas,120,Y,48,18,98,0);
    Atlas(FBoard.Canvas,198,Y,35,18,98,162);
    Atlas(FBoard.Canvas,243,Y,35,18,98,162);
  end;
  DrawButtons;
  Image2.Canvas.Draw(0,0,FBoard);
end;

procedure MYLxMap_init;
begin
  FrmMylx.InitializeAtlas;
end;

procedure TFrmMylx.FormCreate(Sender: TObject);
var I: Integer; Ini: TIniFile;
begin
  FHoverRow := 255; FHoverCol := 255; FDownRow := 255; FDownCol := 255;
  FHoverStop := 255; FCurrentStop := 255;
  StrGid.Cells[0,0] := '';
  StrGid.Cells[1,0] := '舰队名称';
  StrGid.Cells[3,0] := '当前 /舰队 容量';
  StrGid.Cells[4,0] := '时间';
  StrGid.Cells[5,0] := '年龄';
  StrGid.Cells[6,0] := '能力';
  StrGid.ColWidths[0] := 19;
  StrGid.ColWidths[1] := 80;
  StrGid.ColWidths[2] := 30;
  StrGid.ColWidths[3] := 100;
  StrGid.ColWidths[4] := 40;
  Shape1.Left := 16;
  Shape1.Width := 395;
  Shape2.Left := 16;
  Shape2.Width := 395;
  Shape3.Left := 16;
  Shape4.Left := 411;
  Image3.Canvas.Font.Style := [fsBold];
  Ini := Settings;
  try
    for I := 0 to 19 do FPercent[I] := Ini.ReadInteger('tj',IntToStr(I),100);
  finally Ini.Free;
  end;
  InitializeAtlas;
end;

destructor TFrmMylx.Destroy;
begin
  FBoard.Free;
  inherited Destroy;
end;

procedure TFrmMylx.Button2Click(Sender: TObject);
var I,J,K,Zero: Integer; Node: Word; Address: Cardinal;
begin
  Zero := 0;
  for I := 1 to pyL[0,1] do
    if StrGid.Cells[0,I] = SelectedMark then
    begin
      GetRoute(I);
      Node := pyL[I,0];
      for J := 0 to pyL[I,1]-1 do
      begin
        Address := MYlxDZ+Cardinal(Node)*$DC;
        for K := 0 to 19 do
        begin
          WriteProcessMemory(GHandle,Pointer(Address+Cardinal(K)*4+$7C),@AllCount[J,K],4,tmpNum);
          WriteProcessMemory(GHandle,Pointer(Address+Cardinal(K)+4),@Spid[J,K],1,tmpNum);
          WriteProcessMemory(GHandle,Pointer(Address+Cardinal(K)*4+$1C),@Zero,4,tmpNum);
        end;
        Node := ReadValue(Address,2);
      end;
    end;
end;

procedure TFrmMylx.CheckBox1Click(Sender: TObject);
begin
  Timer1.Enabled := CheckBox1.Checked;
end;

procedure TFrmMylx.Timer1Timer(Sender: TObject);
begin
  { 00479348 tests the current game globals before the automatic write. }
  PlaysJz := ReadValue($71CE20,4);
  CityJz := ReadValue($71CE10,4);
  ShipJZ := ReadValue($6DFB8C,4);
  SWSjz := ReadValue($71CE1C,4);
  CityCunt := ReadValue($71CDB8,1);
  Player := ReadValue($71CDB2,1);
  Swscunt := ReadValue($71CE26,2);
  if (PlaysJz=0) or (CityJz=0) or (ShipJZ=0) or (SWSjz=0) or
     (CityCunt=0) or (Player=0) then
  begin
    Timer1.Enabled := False;
    CheckBox1.Checked := False;
  end
  else Button2Click(Sender);
end;

procedure TFrmMylx.StrGidSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
var Time: Integer; Ini: TIniFile;
begin
  if (ARow <= 0) or (ACol <> 4) or (ARow > High(JDL)) then Exit;
  Time := Get_Num(Value);
  if Time = 0 then Time := 7;
  Ini := Settings;
  try Ini.WriteString('ShipTime',IntToStr(JDL[ARow]),IntToStr(Time));
  finally Ini.Free;
  end;
end;

procedure TFrmMylx.StrGidMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
var I: Integer; Ini: TIniFile;
begin
  if StrGid.RowCount = 1 then Exit;
  if (StrGid.Row > 0) and (StrGid.Col = 4) then
    StrGid.Options := StrGid.Options+[goEditing]
  else StrGid.Options := StrGid.Options-[goEditing];
  if StrGid.Col = 0 then
  begin
    if StrGid.Cells[0,StrGid.Row] = SelectedMark then StrGid.Cells[0,StrGid.Row] := ''
    else StrGid.Cells[0,StrGid.Row] := SelectedMark;
    if StrGid.Row = 0 then
      for I := 1 to StrGid.RowCount-1 do StrGid.Cells[0,I] := StrGid.Cells[0,0];
    Ini := Settings;
    try
      for I := 1 to StrGid.RowCount-1 do
        if StrGid.Cells[0,I] = SelectedMark then Ini.WriteString('sLock',IntToStr(JDL[I]),'Y')
        else Ini.WriteString('sLock',IntToStr(JDL[I]),'N');
    finally Ini.Free;
    end;
  end;
  if (StrGid.Row > 0) and (StrGid.Col = 1) then
  begin
    Panel7.Enabled := True;
    Timer1.Enabled := CheckBox1.Checked;
    GetRoute(StrGid.Row);
    FCurrentStop := 1;
    FHoverStop := 1;
    DisplayRoute(1);
  end;
end;

procedure TFrmMylx.StrGidDrawCell(Sender: TObject; ACol,ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var Box: TRect; Flags: UINT; Icon: Integer;
begin
  if ACol = 0 then
  begin
    Box.Left := 0;
    Box.Top := (Rect.Top+Rect.Bottom-20) div 2;
    Box.Right := 19;
    Box.Bottom := Box.Top+20;
    Flags := DFCS_BUTTONCHECK;
    Icon := 38;
    if StrGid.Cells[0,ARow] = SelectedMark then
    begin
      Flags := Flags or DFCS_CHECKED;
      Icon := 39;
    end;
    if Assigned(SpBmp[Icon]) then StrGid.Canvas.Draw(0,Box.Top,SpBmp[Icon])
    else DrawFrameControl(StrGid.Canvas.Handle,Box,DFC_BUTTON,Flags);
  end;
  if (ARow <= High(BCZT)) and BCZT[ARow] and (ACol = 2) then
    Atlas(StrGid.Canvas,Rect.Left+5,Rect.Top,20,20,98,324);
end;

procedure TFrmMylx.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
var I: Integer; Visible: Boolean;
begin
  FHoverRow := 255; FHoverCol := 255;
  if (Y > 60) and (Y < 497) then
  begin
    FHoverRow := (Y-60) div 22;
    for I := 0 to 5 do
      if (X > ColumnX[I]) and (X < ColumnX[I]+ColumnWidth[I]) then FHoverCol := I;
    Shape1.Top := FHoverRow*22+58;
    Shape2.Top := Shape1.Top+22;
    Shape3.Top := Shape1.Top;
    Shape4.Top := Shape1.Top;
  end;
  Visible := (X >= 10) and (X <= 420) and (Y >= 60) and (Y <= 497);
  Shape1.Visible := Visible; Shape2.Visible := Visible;
  Shape3.Visible := Visible; Shape4.Visible := Visible;
  if (Y > 514) and (Y < 533) then
    if (X >= 120) and (X <= 168) then FHoverCol := 6
    else if (X >= 190) and (X <= 238) then FHoverCol := 7
    else if (X >= 250) and (X <= 298) then FHoverCol := 8;
  Button4.Caption := IntToStr(FHoverRow);
  Button3.Caption := IntToStr(FHoverCol);
end;

procedure TFrmMylx.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
var I,J,Good: Integer; Ini: TIniFile;
begin
  if (FCurrentStop < 0) or (FCurrentStop >= FRouteCount) then Exit;
  FDownRow := FHoverRow;
  FDownCol := FHoverCol;
  Ini := Settings;
  try
    if ((FDownCol = 2) or (FDownCol = 5)) and (FDownRow < 20) then
    begin
      Good := Spid[FCurrentStop,FDownRow];
      if FDownCol = 2 then Dec(FPercent[Good],10) else Inc(FPercent[Good],10);
      { Final persists before the 0..300 clamp. }
      Ini.WriteInteger('tj',IntToStr(Good),FPercent[Good]);
      if (FDownCol = 2) and (FPercent[Good] < 0) then FPercent[Good] := 0;
      if (FDownCol = 5) and (FPercent[Good] > 300) then FPercent[Good] := 300;
      ApplyPercent(Good,1);
    end;
    if FDownCol = 7 then
      for I := 0 to 19 do
      begin
        FPercent[I] := 0;
        for J := 1 to FRouteCount-1 do AllCount[J,I] := 0;
      end;
    if FDownCol = 8 then
      for I := 0 to 19 do
      begin
        FPercent[I] := 100;
        Ini.WriteInteger('tj',IntToStr(I),100);
        for J := 1 to FRouteCount-1 do AllCount[J,I] := FBaseCount[J,I];
      end;
  finally Ini.Free;
  end;
  DisplayRoute(FCurrentStop);
end;

procedure TFrmMylx.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
begin
  FDownRow := 255; FDownCol := 255;
  if (FCurrentStop >= 0) and (FCurrentStop < FRouteCount) then DisplayRoute(FCurrentStop);
end;

procedure TFrmMylx.Image3MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
begin
  FHoverStop := (Y-10) div 27;
  if (Y < 10) or (Y > 550) or (X < 20) or (X > 116) or
    (FHoverStop >= FRouteCount) then FHoverStop := 255;
  Button4.Caption := IntToStr(FHoverStop);
end;

procedure TFrmMylx.Image3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
begin
  if FHoverStop = 255 then Exit;
  FCurrentStop := FHoverStop;
  DrawStop(FCurrentStop,True);
  DisplayRoute(FCurrentStop);
end;

procedure TFrmMylx.Image3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X,Y: Integer);
begin
  if FCurrentStop = 255 then Exit;
  DrawStop(FCurrentStop,False);
  FCurrentStop := FHoverStop;
end;

procedure TFrmMylx.BitBtn21Click(Sender: TObject);
const
  Headers: array[0..5] of string = ('序号','舰队编号','主人','地址','未知','主船编号');
var FleetBase,Address: Cardinal; Node: Word; Row: Integer;
begin
  for Row := 0 to 5 do StrGidL.Cells[Row,0] := Headers[Row];
  FleetBase := ReadValue($6DFB90,4);
  Node := ReadValue($6DFC74,2);
  Row := 1;
  while (Node <> $FFFF) and (Row <= 200) do
  begin
    Address := FleetBase+Cardinal(Node)*60;
    Node := ReadValue(Address+8,2);
    StrGidL.RowCount := Row+1;
    StrGidL.Cells[0,Row] := IntToStr(Row-1);
    StrGidL.Cells[1,Row] := IntToStr(Node);
    StrGidL.Cells[2,Row] := IntToStr(ReadValue(Address,1));
    StrGidL.Cells[3,Row] := IntToHex(Address,8);
    StrGidL.Cells[4,Row] := IntToStr(ReadValue(Address+12,2));
    StrGidL.Cells[5,Row] := IntToStr(ReadValue(Address+16,2));
    Inc(Row);
  end;
end;

end.
