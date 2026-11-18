unit Unthd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls,CheckLst,Untpublic, Buttons, ComCtrls, Grids;


type
  TFrmHd = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    StatusBar1: TStatusBar;
    Button1: TButton;
    Panel3: TPanel;
    Panel4: TPanel;
    BitBtn2: TBitBtn;
    Button3: TButton;
    Panel2: TPanel;
    Button2: TButton;
    BitBtn1: TBitBtn;
    SGid1: TStringGrid;
    SGid2: TStringGrid;
    Button4: TButton;
    Button5: TButton;
    Panel5: TPanel;
    Panel6: TPanel;

    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure SGid1Click(Sender: TObject);
    procedure SGid2Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmHd: TFrmHd;

implementation
var
imgH,imgW,shipcount:word;
HdMap:TBitmap;
shipList:array [0..1,0 .. 2000 ] of word;
ShipName:array [0..1,0 .. 2000 ] of string;

{$R *.dfm}

//-------------------------------------------------------------------------
procedure TFrmHd.FormCreate(Sender: TObject);
begin
Image1.Canvas.pen.color:=clred;
Image1.Canvas.Brush.Color :=clred;
Image1.Canvas.brush.Style:=bsClear;
HdMap:=TBitmap.Create;
imgH:=image1.Height;
imgW:=image1.Width ;
HdMap.Width :=imgw;
HdMap.Height :=imgH;
image1.Height :=image1.Width *3 div 4;
BitBlt (HdMap.Canvas.Handle ,0 ,0,imgw, imgH,Image1.Canvas.Handle , 0, 0, SRCCOPY);
SGid1.ColWidths[0]:=25;
SGid2.ColWidths[0]:=25;
SGid1.ColWidths[2]:=75;
SGid2.ColWidths[2]:=75;
SGid1.ColWidths[3]:=30;
SGid2.ColWidths[3]:=30;
end;

//--------------------------------------------------------------------------------
procedure TFrmHd.Button1Click(Sender: TObject);
var
temp,temp2,MaxNJ,CurrentNJ:integer;
shipLX:Byte;
i,index:Word;
shipLxstr:string;
begin
//ReadProcessMemory(GHandle, Pointer($6E1858), Pointer(@temp),4,tmpNum); // 海盗活到强度
//ReadProcessMemory(GHandle, Pointer(temp+$13), Pointer(@HDqd),1,tmpNum);
//HDqd:=HDqd*2+1;
shipcount:=1;
//---------------------------------------------------------读取海盗船
for i:=0 to 4 do
  begin
  ReadProcessMemory(GHandle, Pointer($6DFB94+i*4), Pointer(@temp),4,tmpNum); // 海盗船只基址
  if temp=0 then continue;
  temp2:=temp +12;
  ReadProcessMemory(GHandle, Pointer(temp2), Pointer(@index),2,tmpNum);
  while index<>$FFFF  do
     begin
       shipList[1,shipcount]:=index;
       temp := shipJz + index * $180;
       ReadProcessMemory(GHandle, Pointer(temp+4), Pointer(@index),2,tmpNum);//上一船只
       shipcount:=shipcount+1;
     end;//end while
  end;
shipList[1,0]:=shipcount-1;
SGid1.RowCount:=shipcount;


for i:=1 to shipList[1,0] do
 begin
     temp:= ShipJz + shipList[1,i] * $180;// --------船只地址
     shipName[1,i]:=Get_String(temp + $160);//-------------船只名称
     ReadProcessMemory(GHandle, Pointer(temp+14), Pointer(@shipLX),1,tmpNum);//船只类型
     shipLxstr:=ShipLxName[shipLX]; //----------船只类型
      ReadProcessMemory(GHandle,Pointer(temp+$14),@MaxNJ,4,tmpNum);
      ReadProcessMemory(GHandle,Pointer(temp+$18),@CurrentNJ,4,tmpNum);
      SGid1.Cells[0,i]:=IntToStr(i);
      SGid1.Cells[1,i]:=shipLxstr;
      SGid1.Cells[2,i]:=shipName[1,i];
      SGid1.Cells[3,i]:=IntToStr(Round(CurrentNJ*100/MaxNJ))+'%';
 end;//end for


shipcount:=1;
For i := 0 To Player-2 do   //
  begin
    temp:=PlaysJz +i*$650+ 14;
    ReadProcessMemory(GHandle, Pointer(temp), Pointer(@index),2,tmpNum);//贸易家船只序列开始船只序号
    while index<>$FFFF  do
    begin
      shipList[0,shipcount]:=index;
      temp := ShipJZ + index * $180;
      ReadProcessMemory(GHandle, Pointer(temp+4), Pointer(@index),2,tmpNum);
      shipcount:=shipcount+1;
    end;
  end;//end for
shipList[0,0]:=shipcount-1;
SGid2.RowCount:=shipcount;

for i:=1 to shipList[0,0] do
 begin
     temp:= shipJz + shipList[0,i] * $180;// --------船只地址
     shipName[0,i]:=Get_String(temp + $160);//-------------船只名称
     ReadProcessMemory(GHandle, Pointer(temp+14), Pointer(@shipLX),1,tmpNum);//船只类型
     shipLxstr:=ShipLxName[shipLX]; //----------船只类型
      ReadProcessMemory(GHandle,Pointer(temp+$14),@MaxNJ,4,tmpNum);
      ReadProcessMemory(GHandle,Pointer(temp+$18),@CurrentNJ,4,tmpNum);
      SGid2.Cells[0,i]:=IntToStr(i);
      SGid2.Cells[1,i]:=shipLxstr;
      SGid2.Cells[2,i]:=shipName[0,i];
      SGid2.Cells[3,i]:=IntToStr(Round(CurrentNJ*100/MaxNJ))+'%';
 end;//end for
end;

//-----------------------------------Kill--------------------------------------
procedure Kill_Ship(LB:word);
var
i,Scount:word;
temp,Nj:integer;
shipZT:byte;
begin
Nj:=2; // MED3 004B6994: reduce durability, rather than repair the target.
Scount:=0;

for i:=1  to shipList[LB,0] do
begin
  temp:= shipJz + shipList[LB,i] * $180;// --------船只地址
  ReadProcessMemory(GHandle, Pointer(temp+ 308), Pointer(@shipZt),1,tmpNum); //shipX
  If (shipZt=15) or (shipZt=18) Then
    begin
     writeprocessmemory(GHandle,Pointer(temp+24),Pointer(@Nj),4,tmpNum);//-耐久修改
     Scount:=Scount+1;
    end;
end;//end for
FrmHD.statusbar1.Panels[0].Text:='共清理'+inttostr(Scount)+'条船';
end;


//-----------------------------------显示--------------------------------------
procedure Ship_show(LB,Start,Send:word);
var
i,shipX,shipY,printx,printy:word;
temp:integer;
begin
BitBlt (FrmHd.Image1.Canvas.Handle,0 ,0,HdMap.Width, HdMap.Height,HdMap.Canvas.Handle, 0, 0, SRCCOPY);

for i:=Start to Send do
begin
temp:= shipJz + shipList[LB,i] * $180;// --------船只地址
ReadProcessMemory(GHandle, Pointer(temp+ 30), Pointer(@shipX),2,tmpNum); //shipX
ReadProcessMemory(GHandle, Pointer(temp+ 34), Pointer(@shipY),2,tmpNum); //shipY
If (shipX>=10000) Or (shipY>=10000) Then
    begin
    FrmHD.statusbar1.Panels[0].Text:=shipName[LB,i]+'  [不在地图内]';
    continue;
    end
    else
    FrmHD.statusbar1.Panels[0].Text:= shipName[LB,i]+'    ['+inttostr(shipX)+','+inttostr(shipY)+']';

printx:=((shipX-95) * (imgW))div 2228;
printy:=((shipy-60) * (imgH)) div 1671;
with FrmHd.image1.Canvas do
  begin
    Brush.Color :=clred;
    Ellipse (printX,printY,printX+3,printY+3);//画圆
    case LB of
     0:Font.Color :=clwhite;
     1:Font.Color :=clyellow;
     end;
    brush.Style:=bsClear;
    TextOut (printx-25 ,printY+8,shipName[LB,i]);
end;//end with
end;//end if
end;

procedure TFrmHd.Button2Click(Sender: TObject);
begin
// Correct the final caller's 0..count-1 range: slot zero contains the count.
Ship_show(0,1,shipList[0,0]);
end;

procedure TFrmHd.Button3Click(Sender: TObject);
begin
Ship_show(1,1,shipList[1,0]);
end;

procedure TFrmHd.BitBtn1Click(Sender: TObject);
begin
Kill_Ship(0);
Button1Click(Sender);
end;

procedure TFrmHd.BitBtn2Click(Sender: TObject);
begin
Kill_Ship(1);
Button1Click(Sender);
end;

// MED3 004B6EC0: owner-byte override only; trader linked lists stay intact.
procedure TFrmHd.Button4Click(Sender: TObject);
var
  I, DZ: Integer;
  Owner: Byte;
begin
  Owner:=Player-1;
  for I:=1 to shipList[0,0] do
  begin
    DZ:=ShipJZ+shipList[0,I]*$180;
    WriteProcessMemory(GHandle,Pointer(DZ),@Owner,1,tmpNum);
  end;
  StatusBar1.Panels[0].Text:='共得到'+IntToStr(shipList[0,0])+'条船控制权';
end;

// MED3 004B6FDC: recover original owner from each trader's linked list.
procedure TFrmHd.Button5Click(Sender: TObject);
var
  I, DZ, Count: Integer;
  Index: Word;
  Owner: Byte;
begin
  Count:=0;
  for I:=0 to Player-2 do
  begin
    Owner:=I;
    DZ:=PlaysJZ+I*$650+14;
    ReadProcessMemory(GHandle,Pointer(DZ),@Index,2,tmpNum);
    while Index<>$FFFF do
    begin
      DZ:=ShipJZ+Index*$180;
      WriteProcessMemory(GHandle,Pointer(DZ),@Owner,1,tmpNum);
      ReadProcessMemory(GHandle,Pointer(DZ+4),@Index,2,tmpNum);
      Inc(Count);
    end;
  end;
  StatusBar1.Panels[0].Text:='已归还'+IntToStr(Count)+'条船控制权';
end;

procedure TFrmHd.SGid1Click(Sender: TObject);
begin
  if SGid1.Row=0 then Exit;
  Ship_show(1,SGid1.Row,SGid1.Row);
end;

procedure TFrmHd.SGid2Click(Sender: TObject);
begin
  if SGid2.Row=0 then Exit;
  Ship_show(0,SGid2.Row,SGid2.Row);
end;

end.
