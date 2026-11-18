unit UntRk;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids,Untpublic, ExtCtrls, StdCtrls, ImgList, ComCtrls,math;

type
  TFrmRk = class(TForm)
    Panel4: TPanel;
    StrGid: TStringGrid;
    Image1: TImage;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Button1Click(Sender: TObject);
    procedure StrGidDblClick(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmRk: TFrmRk;
  CapL:array [0..39] of word;
  SZ:array [0..39] of byte;
implementation

{$R *.dfm}

procedure TFrmRk.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

var
Value: Integer;
begin
With StrGid Do
    Begin
      If (ARow=0) or (ARow=RowCount-1) Then exit;
      if (ARow mod 2 = 0) and (ACol<>0) then
           Canvas.Brush.Color   :=   RGB(255,255,255)
       else
          Canvas.Brush.Color   :=   RGB(220,220,220);
      Canvas.FillRect(Rect);
      if ACol=0 then
      begin
        Canvas.Draw(Rect.Left+2,Rect.Top+1,SpBmp[23+CityMarker[ARow-1]]);
        Canvas.TextOut(Rect.Left+25,Rect.Top+5,CityName[ARow-1]);
        Exit;
      end;
      if (ACol>=7) and (ACol<=10) and
         TryStrToInt(Cells[ACol,ARow],Value) and (Value<0) then
      begin
        Canvas.Brush.Color := $0045FF;
        Canvas.FillRect(Rect);
      end;
      Canvas.TextOut(Rect.Left+2,Rect.Top+2,Cells[ACol,ARow]);

         

 end;

end;


procedure TFrmRk.FormCreate(Sender: TObject);
begin
with strgid do
  begin
  cells[0,0]:='城市名称';cells[1,0]:='地址';cells[2,0]:='总人数';
  cells[3,0]:='富豪'; cells[4,0]:='富人';cells[5,0]:='穷人';
  cells[6,0]:='乞丐';cells[7,0]:='富豪M';cells[8,0]:='富人M';
   cells[9,0]:='穷人M'; cells[10,0]:='乞丐M';cells[11,0]:='市长';
  ColWidths [0] :=100;
  end;


end;


//---------------------市长竞选-------------------------
procedure Get_SZ;
var
PTime,QrDZ,DZtemp:integer;
DPoint,DPoint2,BZ:word;
City:byte;
begin
ReadProcessMemory(GHandle, Pointer($6DD480), Pointer(@QrDZ),4,tmpNum);// 确认地址
ReadProcessMemory(GHandle, Pointer($6DD480+8), Pointer(@DPoint),2,tmpNum); //指针

repeat
DPoint2:=DPoint;
 Dztemp:=QrDZ+DPoint*24;
 ReadProcessMemory(GHandle, Pointer(DZtemp+4), Pointer(@DPoint),2,tmpNum); //下一指针
 ReadProcessMemory(GHandle, Pointer(DZtemp+6), Pointer(@BZ),2,tmpNum);
 if BZ<>2 then continue;
 ReadProcessMemory(GHandle, Pointer(DZtemp+14), Pointer(@City),2,tmpNum);
 ReadProcessMemory(GHandle, Pointer(DZtemp), Pointer(@PTime),4,tmpNum);//时间
 FrmRk.StrGid.Cells[14,City+1]:=Time_To_String(PTime);
 FrmRk.StrGid.Cells[15,City+1]:=inttostr(DPoint2);
 FrmRk.StrGid.Cells[16,City+1]:=inttohex(DZtemp,8);
until  DPoint=$FFFF;
end;




procedure TFrmRk.Button1Click(Sender: TObject);
var
  i,j,L:word;
  DZ,temp,temp2:integer;
  Rk:array[0..4] of integer;
  Rk2:array[0..4] of integer;
  T:array[0..3] of byte;
  myd:Smallint;
  A,b:byte;
begin
b:=0;
fillchar(SZ,sizeof(sz),255);
strgid.Rowcount:=CityCunt+2;
ReadProcessMemory(GHandle, Pointer($71DAF8), Pointer(@DZ),4,tmpNum);
for i:=0 to 4 do Rk[i]:=0;
StrGid.cells[0,StrGid.Rowcount-1]:='合计';
temp2:=PlaysJz+(player-1)*$650;

for i:=0 to CityCunt-1 do   //
  begin
   StrGid.Cells[0,i+1]:='';
   StrGid.Cells[1,i+1]:=inttoHex(CityDZ[i],8);
   ReadProcessMemory(GHandle, Pointer(CityDZ[i]+724), Pointer(@temp),4,tmpNum); //总人口
   ReadProcessMemory(GHandle, Pointer(CityDZ[i]+$6F1), Pointer(@SZ[i]),1,tmpNum);
   StrGid.Cells[11,i+1]:=inttostr(SZ[i]);
   StrGid.Cells[2,i+1]:=inttostr(temp);

   Rk[0]:=Rk[0]+temp;
   for j:=0 to 3 do
     begin
       ReadProcessMemory(GHandle, Pointer(CityDZ[i]+728+j*4), Pointer(@temp),4,tmpNum);
       Rk2[j]:=temp;
       StrGid.Cells[j+3,i+1]:=inttostr(temp);
       Rk[j+1]:=Rk[j+1]+temp;
     end;


      for j:=0 to 3  do
     begin
       ReadProcessMemory(GHandle, Pointer(CityDZ[i]+724+44+j*2), Pointer(@myd),2,tmpNum); //满意度
        StrGid.Cells[j+7,i+1]:=inttostr(myd);
      end;
    end;//end; for i
  for i:=0 to 4 do StrGid.cells[i+2,StrGid.Rowcount-1]:=inttostr(Rk[i]);
end;



procedure TFrmRk.StrGidDblClick(Sender: TObject);
var
Arow,ACol,index:word;
SL:integer;
A:byte;
begin
Arow:=StrGid.Row;
Acol:=StrGid.Col;
if (ARow=0) or (ARow>CityCunt) then Exit;
if (Arow<>0) and (Acol=6) then
  begin
  SL:=strtoint(StrGid.cells[Acol,Arow])*2;
  if SL>300 then SL:=300;
  WriteProcessMemory(GHandle,Pointer(CityDZ[ARow-1]+740),@SL,4,tmpNum);
  Button1Click(Sender);
  end;

if (Arow>0) and (Acol=11) then
    begin
     ReadProcessMemory(GHandle, Pointer(CityDZ[Arow-1]+$6F1), Pointer(@A),1,tmpNum);
     if A<>Player-1 then
        A:=Player-1
        else
        A:=255;
     writeprocessmemory(GHandle, Pointer(CityDZ[Arow-1]+$6F1), Pointer(@A),1,tmpNum);
     StrGid.Cells[11,Arow]:=inttostr(A);
    end;


end;


end.
