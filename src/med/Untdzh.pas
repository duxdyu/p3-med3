unit Untdzh;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, StdCtrls, Menus, ImgList, Untpublic;


type
  TFrmDzh = class(TForm)
    Panel1: TPanel;
    Image2: TImage;
    Panel2: TPanel;
    StrGidDzh: TStringGrid;
    Button1: TButton;
    Image1: TImage;
    Panel3: TPanel;
    Button2: TButton;
    StrGid: TStringGrid;
    Button3: TButton;
    Pop: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    ImageList1: TImageList;
    strgids: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure StrGidDzhDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure StrGidDzhMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StrGidDzhDblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmDzh: TFrmDzh;

procedure DzhRefresh;

implementation
const
  { MED3.dll $004C9434, referenced through $004CA650. }
  DzhGoodsUnit: array[0..19] of Integer =
    (2000, 2000, 2000, 200, 200, 200, 200, 200, 200, 200,
     200, 2000, 200, 200, 2000, 200, 2000, 2000, 200, 2000);
var
dzhtemp:array [0..14,0..4] of byte;
DZhZB:array[0..49] of ZuoBiao;
MyZB:array[0..14] of ZuoBiao;
SelectedRow, SelectedCol: Integer;
SelectedGoods: Byte;

{$R *.dfm}

procedure Get_DzhZB;
var
i,x,y:word;
begin
for i:=0 to 49 do
  begin
  ReadProcessMemory(GHandle, Pointer($692a78+i*4), Pointer(@x),2,tmpNum);
  ReadProcessMemory(GHandle, Pointer($692a78+i*4+2), Pointer(@y),2,tmpNum);
  DzhZb[i].x:=x;
  DzhZb[i].y:=y;
  end;
end;


procedure TFrmDzh.FormCreate(Sender: TObject);
var
  i: Integer;
begin
with StrGidDzh do
   begin
    cells[0,0]:='序号';cells[1,0]:='城市';cells[2,0]:='发现者';cells[3,0]:='发现时间';cells[4,0]:='城市类型';
    cells[5,0]:='供应';cells[6,0]:='供应';cells[7,0]:='需求';cells[8,0]:='需求';
     ColWidths[2]:=120;
   end;//end with
image1.Top :=image2.Top;
image1.Left  :=image2.Left ;
image1.Height  :=image2.Height ;
image1.Width  :=image2.Width ;
ImageList1.Width := 20;
ImageList1.Height := 20;
for i := 0 to 18 do
  ImageList1.Add(SpBmp[i], nil);
N1.ImageIndex := 0;
N2.ImageIndex := 1;
N3.ImageIndex := 2;
N4.ImageIndex := 3;
N5.ImageIndex := 4;
N6.ImageIndex := 5;
N7.ImageIndex := 6;
N8.ImageIndex := 7;
N9.ImageIndex := 8;
N10.ImageIndex := 9;
N11.ImageIndex := 10;
N12.ImageIndex := 11;
N13.ImageIndex := 12;
N14.ImageIndex := 13;
N15.ImageIndex := 14;
N16.ImageIndex := 15;
N17.ImageIndex := 16;
N18.ImageIndex := 17;
N19.ImageIndex := 18;
end;

procedure TFrmDzh.StrGidDzhDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

var
temp: byte;
begin
StrGiddzh.Canvas.Brush.Style:=bsSolid;
if gdFixed in State then StrGiddzh.Canvas.Brush.Color:=StrGiddzh.FixedColor
else if gdSelected in State then StrGiddzh.Canvas.Brush.Color:=clHighlight
else StrGiddzh.Canvas.Brush.Color:=StrGiddzh.Color;
StrGiddzh.Canvas.FillRect(Rect);
StrGiddzh.Canvas.TextOut(Rect.Left + 2, Rect.Top + 3, StrGiddzh.Cells[ACol, ARow]);
if (ACol >= 5) and (ACol <= 8) and (ARow > 0) and (ARow <= 15) then
  begin
    temp := dzhtemp[ARow-1, ACol-5];
    if temp < 20 then
      StrGiddzh.Canvas.Draw(Rect.Left+1, Rect.Top+2, SpBmp[temp]);
  end;
end;



{ Final MED3.dll $004B171C: main-window refresh, separate from Button1Click. }
procedure DzhRefresh;
var
 i,j:word;
  bytetemp:array [0..6] of byte;
  zb:ZuoBiao;
  longtemp:longword;
  timetemp:longword;
  tempstring:string;

begin
Get_DzhZB;
with FrmDzh do
begin
image1.Picture :=image2.Picture;
For i := 0 To 14 do
  begin
    FrmDzh.StrGidDzh.Cells[0,i+1]:=inttostr(i);
     FillChar(bytetemp,SizeOf(bytetemp),$FF);
     FillChar(dzhtemp[i],SizeOf(dzhtemp[i]),$FF);
     for j:=1 to 8 do StrGidDzh.Cells[j,i+1]:='';
     if not ReadProcessMemory(GHandle, Pointer($71D8B8+i*36),
       @bytetemp[0],SizeOf(bytetemp),tmpNum) or (tmpNum<>SizeOf(bytetemp)) then Continue;
     Move(bytetemp[0],dzhtemp[i,0],SizeOf(dzhtemp[i]));
     if bytetemp[4]>High(DzhZB) then Continue;
    If bytetemp[4] < 30 Then
       begin
       tempstring:= DzhcityName[bytetemp[4]];
       end
     Else
       begin
       tempstring :=DzhcityName[30];
       end;
      FrmDzh.StrGidDzh.cells[1,i+1]:= tempstring;
      MYzb[i].x :=DzhZB[bytetemp[4]].x;
      MYzb[i].y :=DzhZB[bytetemp[4]].y;
      if bytetemp[4]<30 then
        begin
         ZB.x:=round(DzhZB[bytetemp[4]].x*3.5-488);
         ZB.y:=round(DzhZB[bytetemp[4]].y*3.5-62);
        end
        else
          begin
         ZB.x:=round(DzhZB[bytetemp[4]].x*2-10);
         ZB.y:=round(DzhZB[bytetemp[4]].y*2-10);
        end ;

     image1.Canvas.brush.Style:=bsClear;
     image1.Canvas.Font.Color:=clWhite;
     image1.Canvas.TextOut (ZB.x-FrmDzh.image1.Canvas.TextWidth(tempstring)div 2+6 ,ZB.y+12,tempstring);
     If bytetemp[6] = 255 Then
     begin
       StrGidDzh.cells[2,i+1]:= '';
       image1.Canvas.pen.color:=clblue;
       image1.Canvas.Brush.Color :=clblue;
     end
     else
     begin
      image1.Canvas.pen.color:=clred;
      image1.Canvas.Brush.Color :=clred;
       if bytetemp[6]<=High(PopName) then
         StrGidDzh.cells[2,i+1]:= PopName[bytetemp[6]];
     end;
     image1.Canvas.Ellipse (ZB.x,ZB.y,ZB.x+11,ZB.y+11);

      timetemp:=$FFFFFFFF;
      ReadProcessMemory(GHandle, Pointer($71D8B8+i*36 +8), Pointer(@timetemp),4,tmpNum);//  游戏内部开始时间
     If timetemp = $FFFFFFFF Then
        StrGidDzh.cells[3,i+1]:=''
        else
        StrGidDzh.cells[3,i+1]:= Time_To_String(timetemp);
         if bytetemp[5]<=High(DzhCityLx) then
           StrGidDzh.cells[4,i+1]:=DzhCityLx[bytetemp[5]];

     For j := 0 To 3 do
     begin
      // $FF is an absent commodity (e.g. native villages have no supply).
      // It must never index the 20-element conversion table.
      if bytetemp[j]>High(DzhGoodsUnit) then Continue;
      if not ReadProcessMemory(GHandle, Pointer($71D8B8+i*36 +j*4+12),
        @longtemp,4,tmpNum) or (tmpNum<>4) then Continue;
      longtemp := longtemp div LongWord(DzhGoodsUnit[bytetemp[j]]);
      FrmDzh.StrGidDzh.cells[j+5,i+1]:='       '+inttostr(Int64(longtemp));
     end;

end;
end;
end;

procedure TFrmDzh.Button2Click(Sender: TObject);
var
temp:integer;
ZR,sZT:Byte;
i,k,SNext,TNext:Word;
jdL:array[0..100,0..1] of word;

begin
fillchar(JdL,sizeof(JdL),0);
ReadProcessMemory(GHandle, Pointer($6DFC74), Pointer(@SNext),2,Numtmp);//舰队指针
k:=0;
//----------------读出所有舰队-------------------------------
while SNext<>$FFFF  do
  begin
    temp:=ShipJdjz+SNext*60;
    TNext:=SNext;
    ReadProcessMemory(GHandle, Pointer(temp), Pointer(@ZR),1,Numtmp);
    ReadProcessMemory(GHandle, Pointer(temp+8), Pointer(@SNext),2,Numtmp);
    ReadProcessMemory(GHandle, Pointer(temp+18), Pointer(@sZT),1,Numtmp);
    if (Zr<>Player-1) or (sZT<>0)  then continue;
    jdL[k,0]:=TNext;//舰队编号
    ReadProcessMemory(GHandle, Pointer(temp+10), Pointer(@TNext),2,Numtmp);
    jdL[k,1]:=TNext;//主船编号
    k:=k+1;
  end;
if k=0 then exit;
for i:=0 to k-1 do
   begin
    strgid.Cells [0,i+1]:=inttostr(i);
    strgid.Cells [1,i+1]:=inttohex(ShipJdjz+jdL[i,0]*60,8);
    strgid.Cells [2,i+1]:=inttostr(jdL[i,0]);
    strgid.Cells [3,i+1]:=inttostr(jdL[i,1]);
    temp:=ShipJZ+jdL[i,1]*$180;
    StrGid.Cells [4,i+1]:=Get_String(temp+$160);//名字
 end;


end;

procedure TFrmDzh.Button3Click(Sender: TObject);
var
Lx:array[0..63] of byte;
i:byte;
begin
for i:=0 to 63 do
    Lx[i]:=i;
end;

procedure TFrmDzh.StrGidDzhMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SelectedRow := StrGidDzh.Row;
  SelectedCol := StrGidDzh.Col;
     if (SelectedRow <> 0) and (SelectedRow <= 12) and
      (SelectedCol >= 5) and (SelectedCol <= 8) and (Button = mbRight) then
    Pop.Popup(X, Y);
end;

procedure TFrmDzh.StrGidDzhDblClick(Sender: TObject);
var
  Address: Integer;
  CityType: Byte;
begin
  SelectedRow := StrGidDzh.Row;
  if (SelectedRow >= 1) and (SelectedRow <= 12) and
     (StrGidDzh.Col = 4) then
  begin
    Address := $71D8B8 + (SelectedRow-1)*36 + 5;
    ReadProcessMemory(GHandle, Pointer(Address), @CityType, 1, tmpNum);
    if CityType = 0 then CityType := 1 else CityType := 0;
    WriteProcessMemory(GHandle, Pointer(Address), @CityType, 1, tmpNum);
    StrGidDzh.Cells[4, SelectedRow] := DzhCityLx[CityType];
  end;
end;

{ Final $004B20D4 modifies one goods ID; it is not the old refresh handler. }
procedure TFrmDzh.Button1Click(Sender: TObject);
var
  i, CellX, CellY, Slot, Address, Quantity: Integer;
begin
  if (SelectedRow<1) or (SelectedRow>12) or (SelectedCol<5) or
    (SelectedCol>8) or (SelectedGoods>High(DzhGoodsUnit)) then Exit;
  CellX := 0;
  CellY := 0;
  for i := 0 to SelectedCol-1 do
    CellX := CellX + StrGidDzh.ColWidths[i] + 1;
  for i := 0 to SelectedRow-1 do
    CellY := CellY + StrGidDzh.RowHeights[i] + 1;
  Slot := SelectedCol-5;
  Address := $71D8B8 + (SelectedRow-1)*36;
  if not ReadProcessMemory(GHandle, Pointer(Address+12+Slot*4), @Quantity, 4, tmpNum)
    or (tmpNum<>4) then Exit;
  if not WriteProcessMemory(GHandle, Pointer(Address+Slot), @SelectedGoods, 1, tmpNum)
    or (tmpNum<>1) then Exit;
  Quantity := Quantity div DzhGoodsUnit[SelectedGoods];
  StrGidDzh.Cells[SelectedCol, SelectedRow] := '       '+IntToStr(Quantity);
  StrGidDzh.Canvas.Draw(CellX+1, CellY+2, SpBmp[SelectedGoods]);
  dzhtemp[SelectedRow-1, Slot] := SelectedGoods;
end;

procedure TFrmDzh.N1Click(Sender: TObject);
begin
  SelectedGoods := 0;
  Button1Click(Sender);
end;

procedure TFrmDzh.N2Click(Sender: TObject);
begin
  SelectedGoods := 1;
  Button1Click(Sender);
end;

procedure TFrmDzh.N3Click(Sender: TObject);
begin
  SelectedGoods := 2;
  Button1Click(Sender);
end;

procedure TFrmDzh.N4Click(Sender: TObject);
begin
  SelectedGoods := 2; { Final $004B22F0, including its duplicate ID. }
  Button1Click(Sender);
end;

procedure TFrmDzh.N5Click(Sender: TObject);
begin
  SelectedGoods := 4;
  Button1Click(Sender);
end;

procedure TFrmDzh.N6Click(Sender: TObject);
begin
  SelectedGoods := 5;
  Button1Click(Sender);
end;

procedure TFrmDzh.N7Click(Sender: TObject);
begin
  SelectedGoods := 4; { Final $004B235C, including its duplicate ID. }
  Button1Click(Sender);
end;

procedure TFrmDzh.N8Click(Sender: TObject);
begin
  SelectedGoods := 7;
  Button1Click(Sender);
end;

procedure TFrmDzh.N9Click(Sender: TObject);
begin
  SelectedGoods := 8;
  Button1Click(Sender);
end;

procedure TFrmDzh.N10Click(Sender: TObject);
begin
  SelectedGoods := 9;
  Button1Click(Sender);
end;

procedure TFrmDzh.N11Click(Sender: TObject);
begin
  SelectedGoods := 10;
  Button1Click(Sender);
end;

procedure TFrmDzh.N12Click(Sender: TObject);
begin
  SelectedGoods := 11;
  Button1Click(Sender);
end;

procedure TFrmDzh.N13Click(Sender: TObject);
begin
  SelectedGoods := 12;
  Button1Click(Sender);
end;

procedure TFrmDzh.N14Click(Sender: TObject);
begin
  SelectedGoods := 13;
  Button1Click(Sender);
end;

procedure TFrmDzh.N15Click(Sender: TObject);
begin
  SelectedGoods := 14;
  Button1Click(Sender);
end;

procedure TFrmDzh.N16Click(Sender: TObject);
begin
  SelectedGoods := 15;
  Button1Click(Sender);
end;

procedure TFrmDzh.N17Click(Sender: TObject);
begin
  SelectedGoods := 16;
  Button1Click(Sender);
end;

procedure TFrmDzh.N18Click(Sender: TObject);
begin
  SelectedGoods := 17;
  Button1Click(Sender);
end;

procedure TFrmDzh.N19Click(Sender: TObject);
begin
  SelectedGoods := 18;
  Button1Click(Sender);
end;

end.
