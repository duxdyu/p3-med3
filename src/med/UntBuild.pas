unit UntBuild;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids,Untpublic, StdCtrls, ExtCtrls;

type
  TFrmBuild = class(TForm)
    StrGid: TStringGrid;
    Image1: TImage;
    Button1: TButton;
    StrGrid2: TStringGrid;
    Button2: TButton;
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;
procedure Rush_FW;

var
  FrmBuild: TFrmBuild;

implementation
var
BackBmp1,BackBmp2: TBitmap;
propor:array [0..39,0..2] of word;
{$R *.dfm}


procedure Rush_FW;
var
  i ,j:byte;
  SpCtnJz,timetemp:Cardinal;
  temp1,temp2,temp3:word;
begin
temp3:=0;
  ReadProcessMemory(GHandle, Pointer($6dfb88), Pointer(@SpCtnJz),4,tmpNum);
  ReadProcessMemory(GHandle, Pointer($71cdbc), Pointer(@timetemp),4,tmpNum);
with FrmBuild.StrGid do
  begin
  rowcount:=CityCunt+1;
  for i:=0 to CityCunt-1 do
  begin
  Cells[0,i+1]:=CityName[i];
  
  for j:=0 to 2 do
    begin
      ReadProcessMemory(GHandle, Pointer(CityDZ[i]+$2d8+j*4), Pointer(@temp1),2,tmpNum);
      ReadProcessMemory(GHandle, Pointer(CityDZ[i]+$2f8+j*2), Pointer(@temp2),2,tmpNum);
      case j of
           0:temp3:=80;
           1:temp3:=140;
           2:temp3:=280;
      end; //end case
     Cells[j+1,i+1]:=inttostr(temp2 div temp3);

     if temp2>0 then
     propor[i,j]:=round(temp1*100/temp2)
     else
     propor[i,j]:=0;
   end;//end for j
   Cells[4,i+1]:=inttohex(CityDZ[i]+$2f8,8);
 end; //end for i
 end;//end with
end;


procedure TFrmBuild.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

  //temp:word;
begin
//temp:= round(65*propor[ARow-1,ACol-1]/100);
//With StrGid Do
 //  Begin
  //   If  ARow=0  Then exit;
   //  If  ACol=0  Then exit;
                  //标题栏退出
  //  If  ACol=4  Then exit;
  //   if   ARow   mod   2   =   0   then
  //        Canvas.Brush.Color   :=   RGB(255,255,255)
  //    else
  //       Canvas.Brush.Color   :=   RGB(230,230,230);
   //  If gdSelected In State Then Canvas.Brush.Color := clHighlight;  //选中的单元格背景色和字体色
   //  Canvas.FillRect(Rect);

  //   if (ACol=1) or (ACol=2) or (ACol=3)  then
  //   begin
  //   BackBmp2.Width:=temp;
  //      BitBlt (BackBmp2.Canvas.Handle , 0, 0,temp,
  //              12, image1.Canvas.Handle , 0, 0, SRCCOPY);
  //   BitBlt (Canvas.Handle , Rect.Left + 1, Rect.top + 3,62,
  //    14, BackBmp1.Canvas.Handle , 0, 0, SRCCOPY);
   //  BitBlt (Canvas.Handle , Rect.Left + 2, Rect.top + 4,60,
   //   12, BackBmp2.Canvas.Handle , 0, 0, SRCCOPY);
   //   canvas.Brush.Style:=bsclear;
   //   Canvas.TextOut(Rect.Left + 20, Rect.Top + 4, Cells[ACol, ARow]);
   //   end;
  //  end;
end;

procedure TFrmBuild.FormCreate(Sender: TObject);

begin
BackBmp1:=TBitmap.Create;
BackBmp2:=TBitmap.Create;
BackBmp1.Height:=14;
BackBmp1.Width:=62;
BackBmp2.Height:=12;
BackBmp2.Width:=60;
BitBlt (BackBmp1.Canvas.Handle , 0, 0,62,14, image1.Canvas.Handle , 60, 0, SRCCOPY);
strgid.Cells[0,0]:='城市';
strgid.Cells[1,0]:='商人房';
strgid.Cells[2,0]:='石砌房';
strgid.Cells[3,0]:='木制房';
strgid.Cells[4,0]:='城墙';
strgid.Cells[5,0]:='海岸炮';

StrGrid2.Cells[0,0]:='序号';
StrGrid2.Cells[1,0]:='链序号';
StrGrid2.Cells[2,0]:='地址';
StrGrid2.Cells[3,0]:='X';
StrGrid2.Cells[4,0]:='Y';
StrGrid2.Cells[5,0]:='ZR';
StrGrid2.Cells[6,0]:='类型';
StrGrid2.Cells[7,0]:='方向';

end;

procedure TFrmBuild.Button1Click(Sender: TObject);
var
myzsl,myz,myzcity:byte;
myzdz,temp:Cardinal;
i:word;
gczj,gcsl,fwzj,fwsl:word;
begin
ReadProcessMemory(GHandle, Pointer($71ce26), Pointer(@myzsl),1,tmpNum);
ReadProcessMemory(GHandle, Pointer($71ce1c), Pointer(@myzdz),4,tmpNum);
for i:=0 to myzsl-1 do
    begin
    temp:=myzdz+i*$44c+$2c4;
    ReadProcessMemory(GHandle, Pointer(temp), Pointer(@myz),1,tmpNum);
    ReadProcessMemory(GHandle, Pointer(temp+2), Pointer(@myzcity),1,tmpNum);
    ReadProcessMemory(GHandle, Pointer(temp+10), Pointer(@gczj),2,tmpNum);
    ReadProcessMemory(GHandle, Pointer(temp+12), Pointer(@fwzj),2,tmpNum);
    ReadProcessMemory(GHandle, Pointer(temp+14), Pointer(@gcsl),2,tmpNum);
    ReadProcessMemory(GHandle, Pointer(temp+16), Pointer(@fwsl),2,tmpNum);

       With StrGid Do
       begin
         Cells[0,i+1]:=inttostr(i);
         Cells[1,i+1]:=inttohex(temp,8);
         Cells[2,i+1]:=inttostr(myz);
         Cells[3,i+1]:=CityName[myzcity];
         Cells[4,i+1]:=inttostr(gczj);
         Cells[5,i+1]:=inttostr(fwzj);
         Cells[6,i+1]:=inttostr(gcsl);
         Cells[7,i+1]:=inttostr(fwsl);
       end;//end with
    end;//end for
end;

procedure Read_BuildL(ACity : byte);
var
BuildL:array[0..999] of word;
myzsl,myzcity,X,Y,ZR,LX,FX:byte;
myzdz,temp,temp2,CityDipi,Citydpdz:Cardinal;
i,j,BuL:word;
begin
i:=0;
Citydpdz := CityJz +  $9F8 * ACity + $75c;
ReadProcessMemory (Ghandle, Pointer(Citydpdz), Pointer(@CityDipi),4,tmpNum);
//************************正在建的建筑******************************
ReadProcessMemory (Ghandle, Pointer(Citydpdz+6), Pointer(@BuL),2,tmpNum);
while BuL<>$FFFF do
       begin
       BuildL[i]:=BuL;
       i:=i+1;
       temp := CityDipi + BuL* 8;
       ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL),2,tmpNum);
       end;
       
//************************已建的建筑******************************
ReadProcessMemory (Ghandle, Pointer(Citydpdz+8), Pointer(@BuL),2,tmpNum);
while BuL<>$FFFF do
       begin
       BuildL[i]:=BuL;
       i:=i+1;
       temp := CityDipi + BuL* 8;
       ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL),2,tmpNum);
       end;

//ReadProcessMemory (Ghandle, Pointer(Citydpdz+6), Pointer(@BuL),2,tmpNum);

//for i:=0 to 10 do
//   begin
 //    temp := CityDipi + BuL* 8;
 //    FrmBuild.StrGid.cells[1,i+1]:=inttostr(BuL);
 //    FrmBuild.StrGid.cells[2,i+1]:=inttohex(temp,8);
   //  ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL),2,tmpNum);
 //  end;


ReadProcessMemory(GHandle, Pointer($71ce26), Pointer(@myzsl),1,tmpNum);
ReadProcessMemory(GHandle, Pointer($71ce1c), Pointer(@myzdz),4,tmpNum);

for j:=0 to myzsl-1 do
begin
  temp:=myzdz+j*$44c+$2c4;
  ReadProcessMemory(GHandle, Pointer(temp+2), Pointer(@myzcity),1,tmpNum);
  if myzcity=ACity  then
     begin
 //***************************读工厂链****************************************
        ReadProcessMemory(GHandle, Pointer(temp+10), Pointer(@BuL),2,tmpNum);
        while BuL<>$FFFF do
           begin
             BuildL[i]:=BuL;
             i:=i+1;
             temp2 := CityDipi + BuL* 8;
             ReadProcessMemory (Ghandle, Pointer(temp2+4), Pointer(@BuL),2,tmpNum);
         end;//end while
 //***************************读房子链****************************************
        ReadProcessMemory(GHandle, Pointer(temp+12), Pointer(@BuL),2,tmpNum);
        while BuL<>$FFFF do
           begin
             BuildL[i]:=BuL;
             i:=i+1;
             temp2 := CityDipi + BuL* 8;
             ReadProcessMemory (Ghandle, Pointer(temp2+4), Pointer(@BuL),2,tmpNum);
         end;//end while
    end;//end if
end;//end for
for j:=0 to i-1 do
begin
temp:=CityDipi + BuildL[j]* 8;
ReadProcessMemory (Ghandle, Pointer(temp),Pointer(@X), 1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+1), Pointer(@Y),1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+2), Pointer(@ZR),1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+3), Pointer(@LX),1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+7), Pointer(@FX),1,tmpNum);
   with FrmBuild.StrGrid2 do
      begin
        Cells[0,j+1]:=inttostr(j);
        Cells[1,j+1]:=inttostr(BuildL[j]);
        Cells[2,j+1]:=inttohex(CityDipi + BuildL[j]* 8,8);
        Cells[3,j+1]:=inttostr(X);
        Cells[4,j+1]:=inttostr(Y);
        Cells[5,j+1]:=inttostr(ZR);
        Cells[6,j+1]:=inttostr(LX+300)+BHtoLX(LX+300);
        Cells[7,j+1]:=inttostr(FX);
      end;//end with
end; //end for
end;

procedure TFrmBuild.Button2Click(Sender: TObject);
begin
 Read_BuildL(15);
end;

end.
