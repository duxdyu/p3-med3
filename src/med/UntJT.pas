unit UntJT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls,Untpublic,math;

type
  TFrmJT = class(TForm)
    Panel1: TPanel;
    StrGid: TStringGrid;
    Panel2: TPanel;
    Panel3: TPanel;
    Button2: TButton;
    Button1: TButton;
    Panel4: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StrGidClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);



  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  FrmJT: TFrmJT;


implementation

{$R *.dfm}

procedure TFrmJT.FormCreate(Sender: TObject);
begin
StrGid.Cells[0,0]:='城市';
StrGid.Cells[2,0]:='教堂等级';
StrGid.Cells[3,0]:='教堂需求';
StrGid.Cells[4,0]:='扩建资金';
StrGid.Cells[5,0]:='扩建材料';
StrGid.ColWidths [5]:=100;
StrGid.Cells[6,0]:='捐款资金';
StrGid.Cells[7,0]:='行会加入';
StrGid.ColWidths[0]:=100;
end;
//-------------------------------------------------------
procedure TFrmJT.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  with StrGid do
  begin
    if (ACol=0) and (ARow>0) then
    begin
      Canvas.Draw(Rect.Left,Rect.Top,SpBmp[23+CityMarker[ARow-1]]);
      Canvas.TextOut(Rect.Left+25,Rect.Top+5,CityName[ARow-1]);
    end
    else if ACol=1 then
    begin
      if Cells[1,ARow]='yes' then
        Canvas.Draw(ColWidths[0]+2,(Rect.Bottom+Rect.Top-20) div 2,SpBmp[39])
      else
        Canvas.Draw(ColWidths[0]+2,(Rect.Bottom+Rect.Top-20) div 2,SpBmp[38]);
    end;
  end;
end;
//------------------------------------------------------
procedure TFrmJT.StrGidClick(Sender: TObject);
var
i:word;
begin

  if StrGid.Cells[1,StrGid.row]='yes' then
   StrGid.Cells[1,StrGid.row]:='no'
 else
   StrGid.Cells[1,StrGid.row]:='yes';
  if StrGid.row=0 then
     for i:=1 to StrGid.RowCount-1 do
         StrGid.Cells[1,i]:=StrGid.Cells[1,0];
end;

//---------------------------------------------------------
procedure TFrmJT.Button1Click(Sender: TObject);
var

i,j,xq,jk,zj,dz,temp:integer;

GHM:cardinal;
T:single;
Ab:array[0..3]of byte;
GHC:array [0..39] of byte;
begin
fillchar(GHC,sizeof(GHC),255);
StrGid.RowCount:=CityCunt+1;


temp:=PlaysJz+(player-1)*$650+$468;
ReadProcessMemory(GHandle, Pointer(temp), Pointer(@GHM),4,tmpNum);
for i:=31 downto 0 do
    begin
    T:=power(2,i);
    if GHM>=T then
       begin
         GHM:=round(GHM-T);
         GHC[i]:=1;
       end
    else
    continue;
    end;

for i:=0 to 7 do  GHC[i+32]:=GHC[i];

for i:=0 to CityCunt-1 do
begin
    DZ:=CityDZ[i]+$794;
    ReadProcessMemory(GHandle, Pointer(DZ), Pointer(@jk),4,Numtmp);
    ReadProcessMemory(GHandle, Pointer(DZ+4), Pointer(@zj),4,Numtmp);
    ReadProcessMemory(GHandle, Pointer(DZ+8), Pointer(@xq),4,Numtmp);
    for j:=0 to 3 do
    ReadProcessMemory(GHandle, Pointer(DZ+12+j), Pointer(@Ab[j]),1,Numtmp);

    StrGid.Cells[2,i+1]:=inttostr(Ab[3]);
    if (xq>=100) and (Ab[3]<3) then
      StrGid.Cells[3,i+1]:='√'
      else
      StrGid.Cells[3,i+1]:='';
     StrGid.Cells[4,i+1]:=inttostr(zj);

     if zj>0 then
     StrGid.Cells[5,i+1]:='木'+inttostr(Ab[0])+'  铁'+inttostr(Ab[1])+'   砖'+inttostr(Ab[2])
     else
     StrGid.Cells[5,i+1]:='';

     StrGid.Cells[6,i+1]:=IntToStr(jk);
     if GHC[i]=1 then
      StrGid.Cells[7,i+1]:='√'
      else
      StrGid.Cells[7,i+1]:='';

     // StrGid.Cells[7,i+1]:= inttohex(DZ+12,8); //
end;

end;
//------------------------------------------------------------------
procedure TFrmJT.Button2Click(Sender: TObject);
var
xq:word;
zj,dz,dz1,M,PlayMoney,Aplayer:Cardinal;
i,jb:byte;
begin
 Aplayer:=player;
  ReadProcessMemory(GHandle, Pointer($71CE20), Pointer(@dz1),4,Numtmp);
  dz1:=dz1+(Aplayer-1)*$650;
  ReadProcessMemory(GHandle, Pointer(dz1), Pointer(@PlayMoney),4,Numtmp);
for i:=1 to CityCunt do
 begin
    DZ:=CityDZ[i-1]+$794;
    ReadProcessMemory(GHandle, Pointer(DZ+4), Pointer(@zj),4,Numtmp);
    ReadProcessMemory(GHandle, Pointer(DZ+8), Pointer(@xq),2,Numtmp);
    ReadProcessMemory(GHandle, Pointer(DZ+15), Pointer(@jb),1,Numtmp);
     M:=(jb+1) *20000;
    if ((xq>100) and (StrGid.Cells[1,i]='yes') and
       (PlayMoney>= M)) and (jb<3) then
        begin
          zj:=M -zj;
          PlayMoney:=PlayMoney-zj;
          writeprocessmemory(GHandle,Pointer(dz1),Pointer(@PlayMoney),4,tmpNum);
          writeprocessmemory(GHandle,Pointer(DZ+4),Pointer(@M),4,tmpNum);
         end;
end;
Button1Click(Sender);
end;




end.
