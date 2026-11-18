unit UntWc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Untpublic, StdCtrls, Grids, ExtCtrls, MedProduction;

type
  TFrmWc = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    StrGid: TStringGrid;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StrGidDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmWc: TFrmWc;
  Astring :array [0..4] of string;
implementation

{$R *.dfm}

Function WC_SPid(B:byte):byte;
begin
Case B of
0:Result:=9;1:Result:=2;2:Result:=3;3:Result:=12;4:Result:=5;5:Result:=0;6:Result:=1;
7:Result:=11;8:Result:=8;9:Result:=4;10:Result:=16;11:Result:=14;12:Result:=7;13:Result:=18;
14:Result:=19;15:Result:=15;16:Result:=17;17:Result:=10;
else
  Result:=255;
end;
end;


Function SPid_WCid(B:byte):byte;
begin
Case B of
0:Result:=5;//稻谷
1:Result:=6;//肉
2:Result:=1;//鱼
3:Result:=2;//啤酒
4:Result:=9;//盐
5:Result:=4;//蜂蜜

7:Result:=12;//葡萄酒
8:Result:=8;//布
9:Result:=0;//兽皮
10:Result:=17;//鲸油
11:Result:=7;//木材
12:Result:=3;//铁制品
13:Result:=6;//皮革
14:Result:=11;//羊毛
15:Result:=15;//沥青
16:Result:=10;//生铁
17:Result:=16;//麻
18:Result:=13;//陶器
19:Result:=14;//砖
else
  Result:=255;
end;
end;


procedure TFrmWc.Button1Click(Sender: TObject);
var
  i,j,Column: Integer;
  Kind: Byte;
  Amount: Word;
  Values: TProductionValues;
  DZ: Cardinal;
begin
  StrGid.RowCount:=CityCunt+1;
  for i:=0 to CityCunt-1 do
  begin
    if not TryReadProduction(GHandle,CityDZ[i],Values) then Continue;
    for j:=0 to 19 do
      StrGid.Cells[j+1,i+1]:=Astring[Values[j]];
    for j:=21 to 23 do StrGid.Cells[j,i+1]:='';
    ReadProcessMemory(GHandle,Pointer(CityDZ[i]+$9b4),@DZ,4,tmpNum);
    while DZ<>0 do
    begin
      ReadProcessMemory(GHandle,Pointer(DZ+$10),@Kind,1,tmpNum);
      case Kind of
        4: Column:=23;
        13: Column:=21;
        16: Column:=22;
      else Column:=-1;
      end;
      ReadProcessMemory(GHandle,Pointer(DZ+4),@Amount,2,tmpNum);
      if Column>=0 then StrGid.Cells[Column,i+1]:=IntToStr(Amount*7 div 200);
      ReadProcessMemory(GHandle,Pointer(DZ),@DZ,4,tmpNum);
    end;
  end;
end;




//---------------------------------------------------------------------
procedure TFrmWc.FormCreate(Sender: TObject);
begin
StrGid.ColWidths[0]:=100;
Astring[0]:='';
Astring[1]:='';
Astring[2]:='';
Astring[3]:='☆';
Astring[4]:='★★';
end;

procedure TFrmWc.RadioGroup1Click(Sender: TObject);
begin
Button1Click(Sender);
end;

procedure TFrmWc.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  with StrGid do
  begin
    if ARow=0 then
    begin
      if (ACol>=1) and (ACol<=20) then
        Canvas.Draw(Rect.Left+10,Rect.Top+2,SpBmp[ColumnGoods[ACol-1]])
      else if (ACol>=21) and (ACol<=23) then
        Canvas.Draw(Rect.Left+10,Rect.Top+2,SpBmp[ACol-1]);
    end
    else if ACol=0 then
    begin
      Canvas.Draw(Rect.Left,Rect.Top,SpBmp[23+CityMarker[ARow-1]]);
      Canvas.TextOut(Rect.Left+25,Rect.Top+5,CityName[ARow-1]);
    end
    else if (ACol>=1) and (ACol<=20) then
    begin
      if gdSelected in State then Canvas.Brush.Color:=clHighlight;
      Canvas.FillRect(Rect);
      if Cells[ACol,ARow]<>'' then
        Canvas.TextOut(Rect.Left+5,Rect.Top+5,Cells[ACol,ARow]);
    end
    else if (ACol>=21) and (ACol<=23) and (Cells[ACol,ARow]<>'') then
    begin
      Canvas.Brush.Color:=$C0DCC0;
      Canvas.FillRect(Rect);
      Canvas.TextOut(Rect.Left+2,Rect.Top+2,Cells[ACol,ARow]);
    end;
  end;
end;

procedure TFrmWc.StrGidDblClick(Sender: TObject);
var
  ARow,ACol,I: Integer;
  Values: TProductionValues;
begin
  ARow:=StrGid.Row;
  ACol:=StrGid.Col;
  if (ARow<1) or (ARow>CityCunt) or (ACol<1) or (ACol>20) then Exit;
  if not TryEditProduction(GHandle,CityDZ[ARow-1],ACol-1,Values) then Exit;
  for I:=0 to 19 do StrGid.Cells[I+1,ARow]:=Astring[Values[I]];
end;

end.
