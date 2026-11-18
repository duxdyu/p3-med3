unit UntEditMap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Untpublic, StdCtrls, Grids, ExtCtrls, Menus,StrUtils,math,
  ImgList, ComCtrls, Buttons, MedMapViewport;

type
  TFrmEditMap = class(TForm)
    Panel4: TPanel;
    Panel10: TPanel;
    PopMap: TPopupMenu;
    Nno: TMenuItem;
    N2x3: TMenuItem;
    N5x4: TMenuItem;
    Nsj: TMenuItem;
    Panel8: TPanel;
    Panel3: TPanel;
    Panel1: TMedMapViewport;
    ImageMap: TImage;
    Shape1: TShape;
    Label4: TLabel;
    ImageGc: TImage;
    ImgCopy: TImage;
    N5x41: TMenuItem;
    StaBar: TStatusBar;
    N3x2: TMenuItem;
    BitBtn1: TBitBtn;
    NRoad: TMenuItem;
    Popimg: TImageList;
    NGh: TMenuItem;
    NFzzl: TMenuItem;
    NMove: TMenuItem;
    BitBtn2: TBitBtn;
    Button1: TButton;
    NMade: TMenuItem;
    ComBox: TComboBox;
    CkB1: TCheckBox;
    NGCGH: TMenuItem;
    NFZGH: TMenuItem;
    NUnLock: TMenuItem;
    NJZ: TMenuItem;
    Nno2: TMenuItem;
    Button2: TButton;
    Button3: TButton;
    Panel2: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel9: TPanel;
    CB1: TCheckBox;
    CB2: TCheckBox;
    CB3: TCheckBox;
    CB4: TCheckBox;
    CChoose: TCheckBox;
    checkMMp: TCheckBox;
    CheckBox1: TCheckBox;
    StrGid: TStringGrid;
    Image1: TImage;
    S1: TShape;
    S2: TShape;
    S3: TShape;
    S4: TShape;
    Nxg: TMenuItem;
    NZL0: TMenuItem;
    NZL1: TMenuItem;
    NZL2: TMenuItem;

    procedure FormCreate(Sender: TObject);

    procedure ImageMapMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMapMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageMapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgCopyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImgCopyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgCopyMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NnoClick(Sender: TObject);
    procedure N2x3Click(Sender: TObject);
    procedure N5x4Click(Sender: TObject);
    procedure N5x41Click(Sender: TObject);
    procedure NroadClick(Sender: TObject);
    procedure NsjClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure N3x2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NZLClick(Sender: TObject);
    procedure NMoveClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure NMadeClick(Sender: TObject);
    procedure NGhClick(Sender: TObject);
    procedure ComBoxChange(Sender: TObject);
    procedure NGCGHClick(Sender: TObject);
    procedure NUnLockClick(Sender: TObject);
    procedure NJZClick(Sender: TObject);
    procedure Nno2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure NFZGHClick(Sender: TObject);
    procedure NZL0Click(Sender: TObject);
    procedure NZL1Click(Sender: TObject);
    procedure NZL2Click(Sender: TObject);
    procedure checkMMpClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);

  private
    { Private declarations }
    procedure TransferHousesLegacy(Sender: TObject);
  public
    { Public declarations }
  end;
  procedure Change_city;
  procedure EDitMap_init;
  procedure Write_Dipi(sX,sY,W,H,dipi:byte);

var
  FrmEditMap: TFrmEditMap;
  Cx,Cy,Coldx,Coldy,CnewX,CnewY,oldx,oldy,newX,newY,picx,picy:integer;
  
implementation


{$R *.dfm}
var
//Dixing:byte;//地形代码
shapcX,shapcY,shapx,shapy,shapW,shapH,mfX,mfY,mfW,mfH:byte;//图形选择范围
//MapBmpBack:TBitmap;//创建地图背景
//HdMap:TBitmap;//创建地图背景
Picbmp:array[0..69] of TBitmap;// '创建30个位图

DipiDZ:array [0..255,0..255] of Cardinal;//地皮地址
DipiJDDZ:array [0..255,0..255] of Cardinal;  //基点地址
DipiCode:array [0..255,0..255] of word; //地皮代码
DipiJDCode:array [0..255,0..255] of byte; //地皮代码
DipiZR:array [0..255,0..255] of byte;//  地皮主人
DipiFX:array [0..255,0..255] of byte; //地皮方向
ZLFX:array [0..999] of byte;//终版 005EA780: 1000 个规划记录
ZLZX:array [0..999] of byte;
ZLzy:array [0..999] of byte;
Builds:array[0..10] of word;
MapStats:array[0..22,0..2] of Integer;

ZLSL:Integer;
ZLBool:boolean;
Cleanshap:boolean;



CL:array[0..3] of integer;
BuLCL:array [0..2,0 .. 3] of integer=
((100000,40000,4000,8000),
 (80000,20000,2000,8000),
  (50000,4000,400,5000));
MLx:array[0..2,0..1] of byte=
((21,200),(24,100),(27,50));

procedure ShowSelection(Visible: Boolean); forward;
procedure DrawMapOverlays; forward;
procedure ReadMapStats; forward;
procedure DisplayMapStats; forward;

//**************地皮图形*******************地皮图形********************
Function Get_DipiPicCode(Code,Jcode:byte):byte;
begin
if Jcode>0 then
  begin
  case Jcode of
 3,31..39,45..56:result:= 11; //-----------------城市建筑
 4:result:= 24; //-----------------4          狩猎小屋
 5:result:= 25; //-----------------5          捕鱼场
 6:result:= 26; //-----------------6          啤酒厂
 7:result:= 27; //-----------------7          铁制品厂
 8:result:= 28; //-----------------8          养蜂所
 9:result:= 29; //-----------------9          稻谷农场
 10:result:= 30; //-----------------0 a        养牛场
 11:result:= 31; //-----------------0 b        伐木场
 12:result:= 32; //-----------------0 c        纺织厂
 13:result:= 33; //-----------------0D         制盐厂
 14:result:= 34; //-----------------0E         生铁厂
 15:result:= 35; //-----------------0F         养羊场
 16:result:= 36; //-----------------10         葡萄园
 17:result:= 37; //-----------------11         陶瓷厂
 18:result:= 38; //-----------------12         砖厂
 19:result:= 39; //-----------------13         沥青厂
 20:result:= 40; //-----------------14         麻田
 40:result:= 41; //----------------- 水井
 21..23:result:=44; //---------------商人房
 24..26:result:=43; //---------------石砌房
 27..29:result:=42; //---------------半木房
  30,41..44:result:=7; //---------------

 else
  result:= 0;
 end;
  end
 else
 begin
 Case Code of
 176..191:
  result:= 1; //----------------------5X4绿地
 161,165,169,173:
   result:= 2; //--------------------绿地3X2
 14,162,163,166,167,170,171,174,175:
   result:= 5; //--------------------绿地2X3
160,164,168,172:result:= 3;//-------未点亮绿地
32..47:result:= 4; // -----------------城外未点亮绿地
 139:result:= 6; //-----------------建筑8B
48.. 63:result:= 8; //---------------城外5X4 3X2 2X3
 11,30:result:= 9; //-------------------水上山体空地
 4,132,146: result:= 10; //------------------城内外水井用地
 134:result:=45;
 135:result:=46;
 136:result:=47;
 137:result:=48;
10,15,7,8:result:= 11; //-----基点位  147, 154,,152,156   19..29,
128,129:result:= 12;//---------------改善道路
2,3,130,131,158:result:= 13;//----------未改善道路
12:result:= 14;//-------------------海洋
6:result:= 16;//-------------------边框
5:result:= 17;//-----------------已建城墙5
17,145:result:= 18;//-----------------城墙壁11（外）91（内）
16:result:= 20;//-------------------三级城墙外空地
 13,31:result:= 21;//-------------------海岸山地
9:result:= 22;//-------------------预留城墙位
159:result:= 23;//-------------------围栏
 else
  result:= 0;
 end;//end case
end;//end if
end;
//--------------------------------------------------------------------------
Function  Move_Enbles(sX,sY,W,H:byte):boolean;
var
i, j:byte;
begin
result:=false;
For i := 0 To W - 1 do
   For j := 0 To H - 1 do
     begin
         case DipiJdCode[sx+i, sy+j] of
             0,4,6..30,40..44:
              result:=true;

          else
             begin
                result:=false;
                exit;
             end;
          end;//end case

         case DipiCode[sx+i, sy+j] of
              146,139,160..191:
              result:=true;
         else
             begin
                result:=false;exit;
             end;
          end;//end case
   end; //end for j
end;





Function  Move_EnbleE(sX,sY,W,H,eX,eY:byte):boolean;
var
i, j:byte;
begin
result:=false;
if (W=0) or (H=0) or (Integer(eX)+W>256) or (Integer(eY)+H>256) then Exit;
For i := 0 To W - 1 do
  begin
   For j := 0 To H - 1 do
     begin
       case DipiCode[ex+i, ey+j] of
              32..63:
                if (DipiCode[sx+i,sy+j] in [11,32..63]) or
                   ((DipiCode[sx+i,sy+j]=139) and
                    (DipiJDCode[sx+i,sy+j] in [0,4,6..20])) then
                  Result:=True
                else begin Result:=False; Exit; end;
             132:
                 if DipiCode[sx+i, sy+j]=146 then
                       result:=true
                      else
                         begin
                            result:=false;exit;
                         end;
             139:
                 if (ex+i>=sx) and( ex+i<sx+w) and (ey+j>=sy) and (ey+j<sy+h) then
                   result:=true
                        else
                        begin
                              result:=false;exit;
                       end;
             160..191: result:=true;
          else
              begin
               result:=false;exit;
              end;
        end;//end case
  end;//end j
end;//end i

end;
//---------------------------------------------------------

Function  MoveJd_Enble(X,Y:byte):boolean;
begin
result:=false;
 case DipiJdCode[x,y] of
  4,6..30,40..44:
  if (shapw=1) and (shaph=1) then result:=true;
 end;
end;

//--------------右键菜单显示管理--------------------------
procedure LegacyPop_MenuEnable;
var
i,j:integer;
Nenable:boolean;
label N1,N2,N3,N4,N5,N6;
begin

//--- 水井用地----------
Nenable:=true;
for i:=0 to shapw-1 do
    for j:=0 to shaph-1 do
        case DipiCode[shapx+i, shapy+j] of
             130,131,160..191:
               Nenable:=true;
            else
             begin
                Nenable:=false;
                goto N1;
             end;
        end;

N1:
FrmEditMap.Nsj.Visible :=Nenable;
FrmEditMap.Nsj.Enabled :=Nenable;

//--- 5*4绿地修改----------
Nenable:=true;
for i:=0 to shapw-1 do
    for j:=0 to shaph-1 do
         if  (DipiCode[shapx+i, shapy+j]<32) or  (DipiCode[shapx+i, shapy+j]>63) then
             begin
               Nenable:=false;
               goto N2;
             end;

N2:
FrmEditMap.N5x41.Visible :=Nenable;
FrmEditMap.N5x41.Enabled :=Nenable;

//--- 房子规划判断----------
Nenable:=true;
if swsDZ[Ecity]=0 then
   begin
    Nenable:=false;
    goto N3;
    end;
if (shapw<2) or (shaph<2)  then
    begin
      Nenable:=false;
      goto N3;
      end;
if shapw*shaph<6 then
       begin
      Nenable:=false;
      goto N3;
      end;


for i:=0 to shapw-1 do
    for j:=0 to shaph-1 do
         if  (DipiCode[shapx+i, shapy+j]<160) or  (DipiCode[shapx+i, shapy+j]>191) then

             begin
               Nenable:=false;
               goto N3;
             end;
N3:

FrmEditMap.NMade.Enabled :=Nenable;
FrmEditMap.NMade.Visible :=Nenable;
FrmEditMap.NGh.Visible :=Nenable;
FrmEditMap.NGh.Enabled :=Nenable;
FrmEditMap.Nroad.Visible :=Nenable;
FrmEditMap.Nroad.Enabled :=Nenable;

//--- 房子整理判断----------
Nenable:=false;
for i:=0 to shapw-1 do
    for j:=0 to shaph-1 do
     if (DiPijdcode[shapx+i, shapy+j]>20) and (DiPijdcode[shapx+i, shapy+j]<30)
        then
        begin
        Nenable:=true;
        goto N4;
        end;
N4:
FrmEditMap.NFzzl.Visible  :=Nenable and ZLbool;
FrmEditMap.NFzzl.Enabled :=FrmEditMap.NFzzl.Visible;

//--------------移动判断------------------
for i:=0 to shapw-1 do
    for j:=0 to shaph-1 do
     begin
         case DipiJdCode[shapx+i, shapy+j] of
             0,4,6..30,40..44:
              Nenable:=true;
          else
             begin
                Nenable:=false;
                goto N5;
             end;
          end;//end case

         case DipiCode[shapx+i, shapy+j] of
              146,139,160..191:
              Nenable:=true;
         else
             begin
                Nenable:=false;
                goto N5;
             end;
          end;//end case
   end; //end for j

N5:

FrmEditMap.NMove.Visible  :=Nenable;
FrmEditMap.NMove.Enabled :=Nenable;

//------------------------------

for i:=0 to shapw-1 do
    for j:=0 to shaph-1 do
         if DipiJdCode[shapx+i, shapy+j] >0 then
              begin
                Nenable:=false;
                goto N6;
               end
          else
           Nenable:=true;

N6:
FrmEditMap.Nno.Visible  :=Nenable;
FrmEditMap.Nno.Enabled :=Nenable;
FrmEditMap.N2x3.Visible  :=Nenable;
FrmEditMap.N2x3.Enabled :=Nenable;
FrmEditMap.N3x2.Visible  :=Nenable;
FrmEditMap.N3x2.Enabled :=Nenable;
FrmEditMap.N5x4.Visible  :=Nenable;
FrmEditMap.N5x4.Enabled :=Nenable;



end;






{ Final 004A5F60: menu visibility depends on every tile in the selection. }
procedure Pop_MenuEnable;
var
  X,Y,C,J: Integer;
  Inside,Outside,Houses,Factories,Movable,Locked: Boolean;
  Counts: array[0..2] of Integer;
begin
  Inside:=(shapw>0) and (shaph>0);
  Outside:=Inside;
  Movable:=Inside;
  Houses:=(shapw>1) and (shaph>1) and (shapw*shaph>5);
  Factories:=(shapw>4) and (shaph>3);
  Locked:=False;
  FillChar(Counts,SizeOf(Counts),0);
  for X:=shapx to shapx+shapw-1 do
    for Y:=shapy to shapy+shaph-1 do
    begin
      C:=DipiCode[X,Y];
      J:=DipiJDCode[X,Y];
      if J in [21..29] then Inc(Counts[(J-21) div 3]);
      Inside:=Inside and (J=0) and
        (C in [0,13,31,128..132,134,136,137,139,158..191]);
      Outside:=Outside and (J=0) and (C in [4,11,32..63,141]);
      Movable:=Movable and (J in [0,4,6..30,40..44]) and
        (C in [11,139,146,158..191]);
      Houses:=Houses and (C in [160..191]);
      Factories:=Factories and (C in [32..63,160..191]);
      Locked:=Locked or (C in [134..137]);
    end;
  with FrmEditMap do
  begin
    Nno.Visible:=Inside; N2x3.Visible:=Inside; N3x2.Visible:=Inside;
    N5x4.Visible:=Inside; NRoad.Visible:=Inside; Nsj.Visible:=Inside;
    NJZ.Visible:=Inside; N5x41.Visible:=Outside; Nno2.Visible:=Outside;
    Nxg.Visible:=Inside or Outside;
    NFZGH.Visible:=Houses; NMade.Visible:=Houses;
    NGCGH.Visible:=Factories; NUnLock.Visible:=Locked;
    NGH.Visible:=Houses or Factories or Locked;
    NGH.Enabled:=True;
    NZL0.Caption:='整理商人房 ('+IntToStr(Counts[0])+')';
    NZL1.Caption:='整理石砌房 ('+IntToStr(Counts[1])+')';
    NZL2.Caption:='整理木制房 ('+IntToStr(Counts[2])+')';
    NZL0.Visible:=(Counts[0]>0) and ZLbool;
    NZL1.Visible:=(Counts[1]>0) and ZLbool;
    NZL2.Visible:=(Counts[2]>0) and ZLbool;
    NFzzl.Visible:=NZL0.Visible or NZL1.Visible or NZL2.Visible;
    NFzzl.Enabled:=True;
    NMove.Visible:=Movable; NMove.Enabled:=Movable;
  end;
end;

//******************初始化地图******************初始化地图
procedure EDitMap_init;
var
i:integer;
begin
FrmEditMap.ComBox.Items.BeginUpdate;
try
  FrmEditMap.ComBox.Items.Clear;
  for i:=0 to CityCunt-1 do FrmEditMap.ComBox.Items.Add(CityName[i]);
finally
  FrmEditMap.ComBox.Items.EndUpdate;
end;
FrmEditMap.ComBox.ItemIndex:=Ecity;
For i:=0 To 50 do begin    // Final 004AC9CC: 51 tiles.
    Picbmp[i].Free;
    Picbmp[i]:=TBitmap.Create;
    Picbmp[i].Height:=20;
    Picbmp[i].Width:=20;
    BitBlt (Picbmp[i].Canvas.Handle,0,0,20,20, FrmEditMap.imageGc.Canvas.Handle ,i*20, 0, SRCCOPY);//
end;  //end for

end;

//****************************************************************************
procedure Read_DpCode(ACity:byte);
var
i,j,BuL:word;
WC,lei,hang:Byte;
myzsl,myzcity,X,Y,ZR,LX,FX,C,D,H:byte;
CityDipi,temp,myzdz,Citydpdz:Longword;
BuildL:array[0..3000] of word;

begin
X:=0;Y:=0;
fillchar(DipiCode,sizeof(DipiCode),0);
fillchar(Dipidz,sizeof(Dipidz),0);
fillchar(Dipijddz,sizeof(Dipijddz),0);
fillchar(DipiJdCode,sizeof(DipiJdCode),0);
fillchar(BuildL,sizeof(BuildL),$ffff);
fillchar(ZLFX,sizeof(ZLFX),0);
fillchar(ZLZX,sizeof(ZLZX),0);
fillchar(ZLZY,sizeof(ZLZY),0);
fillchar(Builds,sizeof(Builds),0);
ZLSL:=0;

//***************************************地皮读取******************************
temp:=CityJz + $9F8 * ACity + $80C;
ReadProcessMemory(GHandle, Pointer(temp), Pointer(@CityDipi),4,tmpNum);   //----城市地皮地址

For j := 0 To 127 do begin    //------------读出地皮代码
  For i := 0 To 225 do begin
   hang:=i Mod 2;             // '--------奇偶
   lei:=i div 2;              // '-------列
   Case hang of
        0: begin
          X :=112-lei+j;
          Y :=lei + j;
          end;
          1:begin
            X := 112-lei+j;
            Y := lei+j+1
            end;
     End;//end case
    temp:=CityDipi + i + j * 226;
    ReadProcessMemory(GHandle, Pointer(temp), Pointer(@DipiCode[x, y]),1,tmpNum); //读出地皮代码

    case DipiCode[x, y] of
      14:Builds[0]:=Builds[0]+1;//渔夫之家空地
      32..63:Builds[1]:=Builds[1]+1;//城外绿地
      160..191:Builds[2]:=Builds[2]+1;//城内绿地
     end;


    DipiDZ[x,y]:=temp;
 end;//end i
end;//end j

//***************************************基点读取******************************
i:=0;
Citydpdz := CityJz +  $9F8 * ACity + $75c;

ReadProcessMemory (Ghandle, Pointer(Citydpdz), Pointer(@CityDipi),4,tmpNum);
ReadProcessMemory (Ghandle, Pointer(Citydpdz+4), Pointer(@BuL),2,tmpNum);
//************************城墙建筑******************************
ReadProcessMemory (Ghandle, Pointer(Citydpdz+12), Pointer(@BuL),2,tmpNum);
while BuL<>$FFFF do
       begin
       BuildL[i]:=BuL;
       i:=i+1;
       temp := CityDipi + BuL* 8;
       ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL),2,tmpNum);
       end;
//************************城镇的建筑******************************
ReadProcessMemory (Ghandle, Pointer(Citydpdz+8), Pointer(@BuL),2,tmpNum);
while BuL<>$FFFF do
       begin
       BuildL[i]:=BuL;
       i:=i+1;
       temp := CityDipi + BuL* 8;
       ReadProcessMemory (Ghandle, Pointer(temp+3), Pointer(@Lx),1,tmpNum);
       ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL),2,tmpNum);

end;

//************************正在建的建筑******************************
ReadProcessMemory (Ghandle, Pointer(Citydpdz+6), Pointer(@BuL),2,tmpNum);

while BuL<>$FFFF do
       begin
       BuildL[i]:=BuL;
       i:=i+1;
       temp := CityDipi + BuL* 8;
       ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL),2,tmpNum);
       end;

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
             ReadProcessMemory (Ghandle, Pointer(CityDipi + BuL* 8+4), Pointer(@BuL),2,tmpNum);
         end;//end while
 //***************************读房子链****************************************
        ReadProcessMemory(GHandle, Pointer(temp+12), Pointer(@BuL),2,tmpNum);
        while BuL<>$FFFF do
           begin
             BuildL[i]:=BuL;
             i:=i+1;

             ReadProcessMemory (Ghandle, Pointer(CityDipi + BuL* 8+4), Pointer(@BuL),2,tmpNum);
         end;//end while
    end;//end if
end;//end for

if i=0 then exit;

for j:=0 to i-1 do
begin
temp:=CityDipi + BuildL[j]* 8;
ReadProcessMemory (Ghandle, Pointer(temp),Pointer(@C), 1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+1), Pointer(@D),1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+2), Pointer(@ZR),1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+3), Pointer(@LX),1,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+7), Pointer(@FX),1,tmpNum);
H:= D Mod 2; //--------奇偶
D := D div 2; //-------列
Case H of
     0:begin
       X := 112 - D + C;
       Y := D + C;
       end;
     1:begin
       X := 112 - D + C;
       Y := D + C + 1;
       end;
end;
case Lx of
4..20:
    Builds[5]:=Builds[5]+1;//统计工厂数量
21..23:Builds[6]:=Builds[6]+1;//商人房屋数量
24..26:Builds[7]:=Builds[7]+1;//石砌房屋数量
27..29:Builds[8]:=Builds[8]+1;//木制房屋数量
end;

DipijdCode[X,Y]:=LX;
DipijdDZ[X,Y]:= temp;
DipiZR[X,Y]:= ZR;
DipiFX[X,Y]:= FX;

end; //end for
ReadProcessMemory(GHandle, Pointer(CityDZ[Acity]+$899), Pointer(@wc),1,tmpNum);
if wc=0 then
   BuL:=round((Builds[2]+Builds[1]-100)*0.83) div 20 +Builds[5]
   else
   BuL:=round((Builds[2]+Builds[1]-100)*0.83) div 20 + Builds[0]+Builds[5];
FrmEditMap.StaBar.Panels[4].Text:='  ';
FrmEditMap.stabar.Panels[2].Text :='工厂:['+inttostr(Builds[5])+'/'+inttostr(BuL)+']';
FrmEditMap.stabar.Panels[3].Text := '木房:'+inttostr(Builds[8])+
                                    '     石砌:'+inttostr(Builds[7])+
                                    '     商房:'+inttostr(Builds[6]);
end;

//-----------------------------------------------------------------
procedure clean_Shap(Acolor:Cardinal);
begin
ShowSelection(Acolor=clRed);
cleanshap:=False;
end;

//***********显示地皮***********显示地皮***********显示地皮
procedure Map_Display(x:byte;y:byte;w:byte;h:byte);
var
i,j,cx,cy,c:byte;
begin
for i:=x to w-1 do begin
   for j:=y to h-1 do begin
     cx:=i-j;
     cy:=i-112+j;

    c:=Get_DipiPicCode(DipiCode[cx, cy],DipijdCode[cx, cy]);
     BitBlt (FrmEditMap.ImageMap.Canvas.Handle ,cx*20 ,cy*20, 20, 20,PicBmp[c].Canvas.Handle , 0, 0, SRCCOPY);
     cy:=i-111+j;
     c:=Get_DipiPicCode(DipiCode[cx, cy],DipijdCode[cx, cy]);
     BitBlt (FrmEditMap.ImageMap.Canvas.Handle ,cx*20 ,cy*20, 20, 20,PicBmp[c].Canvas.Handle , 0, 0, SRCCOPY);
     end;
  end;
DrawMapOverlays;
FrmEditMap.ImageMap.Refresh ;
end;

procedure Map_Display2(sx,sy,w,h:byte);
var
i,j,c:byte;
begin
for i:=0 to w-1 do begin
   for j:=0 to h-1 do begin
     c:=Get_DipiPicCode(DipiCode[sx+i, sy+j],DipijdCode[sx+i, sy+j]);
     BitBlt (FrmEditMap.ImageMap.Canvas.Handle ,(sx+i)*20 ,(sy+j)*20, 20, 20,PicBmp[c].Canvas.Handle , 0, 0, SRCCOPY);
     end;
  end;
  DrawMapOverlays;
  FrmEditMap.ImageMap.Refresh ;
end;

//-----------------------------------------------------------------------
procedure TFrmEditMap.FormCreate(Sender: TObject);
begin
Label4.Left :=-200;
ImageMap.Width :=240*20;
ImageMap.Height :=241*20;
imageMap.Left :=-(imageMap.Width -panel1.Width) div 2;
imageMap.Top :=-(imageMap.Height  -panel1.Height ) div 2;
Panel4.Height:=60;
ImageMap.Canvas.Brush.Style:=bsClear;
ImageMap.Canvas.Pen.Color:=clFuchsia;
end;
//------------------------------------------------------------------------------

procedure Change_city;
begin
Read_DpCode(Ecity);
Map_Display(112,0,240,113);
shapx:=0;shapy:=0;shapw:=0;shaph:=0;
ZLbool:=false;
Cleanshap:=false;
FrmEditMap.ImageMap.Canvas.Brush.Style:=bsclear;
ShowSelection(False);
FrmEditMap.Panel7.Visible:=FrmEditMap.checkMMp.Checked;
FrmEditMap.ImageMap.Enabled :=true;
FrmEditMap.NGh.Enabled :=false;
FrmEditMap.NFzzl.Enabled :=false;
FrmEditMap.Nmove.Enabled :=false;
FrmEditMap.Bitbtn1.Enabled :=true;
FrmEditMap.ComBox.ItemIndex:=Ecity;
FrmEditMap.Button1.Enabled :=swsDZ[Ecity]<>0;
FrmEditMap.Button2.Enabled :=True;
if FrmEditMap.CheckBox1.Checked then DisplayMapStats;

end;


//---------------------修改地皮-----------------------------------------
procedure Write_Dipi(sX,sY,W,H,dipi:byte);
var
i, j:Integer;
begin
if (W=0) or (H=0) or (Integer(sX)+W>256) or (Integer(sY)+H>256) then Exit;
For i := 0To w - 1 do
  begin
   For j := 0 To h - 1 do
     begin
     if Dipidz[sx+i,sy+j]=0 then Continue;
     writeprocessmemory(GHandle,Pointer(Dipidz[sx+i,sy+j]),Pointer(@dipi),1,tmpNum);
     DipiCode[sx+i, sy+j]:=dipi;
     end;//end j
end;//end i
end;

procedure Move_Dipi(sX,sY,W,H,Ex,Ey:byte);
var
i, j,Ax,Ay:byte;
dpCode:array of array of byte;
JdCode:array of array of byte;
JdFX:array of array of byte;
JdDZ:array of array of cardinal;
begin
if (W=0) or (H=0) then Exit;
setlength(dpCode,W,H);
setlength(jdCode,W,H);
setlength(jdFX,W,H);
setlength(jdDZ,W,H);

For i := 0 To w - 1 do
   For j := 0 To h - 1 do
      begin
      dpCode[i,j]:=DipiCode[sx+i,sy+j];
      jdCode[i,j]:=DipijdCode[sx+i,sy+j];
      jdFX[i,j]:=DipiFX[sx+i,sy+j];
      jdDZ[i,j]:=DipijdDZ[sx+i,sy+j];
      end;

For i := 0 To w - 1 do
   For j := 0 To h - 1 do
     begin
      if dpCode[i,j]=11 then
          DipiCode[sx+i,sy+j]:=$20
      else if dpCode[i,j]=146 then
         DipiCode[sx+i,sy+j]:=132
        else
         DipiCode[sx+i,sy+j]:=$A0;
          writeprocessmemory(GHandle,Pointer(DipiDZ[sx+i,sy+j]),Pointer(@DipiCode[sx+i,sy+j]),1,tmpNum);
      DipiJDCode[sx+i,sy+j]:=0;
      DipiJDDZ[sx+i,sy+j]:=0;
      DipiFX[sx+i,sy+j]:=0;
     end;

For i := 0 To w - 1 do
  begin
   For j := 0 To h - 1 do
     begin
      if DipiCode[ex+i,ey+j] in [32..63] then dpCode[i,j]:=$0B
      else if (DipiCode[ex+i,ey+j] in [160..191]) and (dpCode[i,j]=$0B) then
        dpCode[i,j]:=$8B;
      DipiCode[ex+i,ey+j]:=dpCode[i,j];
     writeprocessmemory(GHandle,Pointer(DipiDZ[ex+i,ey+j]),Pointer(@dpCode[i,j]),1,tmpNum);
     if jdCode[i,j]>0 then
       begin
          DipiJdCode[ex+i, ey+j]:=jdCode[i,j];
           DipiJdDz[ex+i, ey+j]:=JdDZ[i, j];
           DipiFX[ex+i,ey+j]:=jdFX[i,j];
          Ax:=(ex+i+ey+j-112)div 2;
          Ay:=ey+j+112-ex-i;
         writeprocessmemory(GHandle, Pointer(DipijdDZ[ex+i, ey+j]),Pointer(@Ax),1,tmpNum);
         writeprocessmemory(GHandle, Pointer(DipijdDZ[ex+i, ey+j]+1),Pointer(@Ay),1,tmpNum);

       end //end if
     end;//end j
end;//end i
Map_Display(112,0,240,113);
end;


//---------------------------剪裁移动区图像 ----------------------
procedure Move_Copy(Ax,Ay,Aw,Ah:byte);
var
i,j,c1,c2,p:byte;
begin

clean_Shap(clFuchsia);

//FrmEditMap.imgcopy.Picture.Graphic.
with FrmEditMap.imgcopy do
    begin
    Left:=shapX*20+FrmEditMap.imageMap.Left;
    Top:=shapY*20+FrmEditMap.imageMap.Top;
    Height:=shapH*20+1 ;
    Width:=shapW*20+1;
    Picture.Graphic:=nil;
   for i:=0 to Aw-1 do begin
     for j:=0 to Ah-1 do begin
        c1:=DipiCode[Ax+i, Ay+j];
        c2:=DipijdCode[Ax+i, Ay+j];
        p:=Get_DipiPicCode(c1,c2);
        BitBlt (Canvas.Handle ,i*20 ,j*20, 20, 20,PicBmp[p].Canvas.Handle , 0, 0, SRCCOPY);
       end;
    end;//end for
    Canvas.Brush.Style :=bsClear;
    Canvas.Pen.Color :=clred;
    Canvas.Pen.Width :=2;
    Canvas.Rectangle(1 ,1,width,Height);
    visible:=true;
end;

end;
//-------------------------------------------------------------
procedure Pop_Menu(C:byte);
begin
ZLbool:=False;
ZLSL:=0;
Write_Dipi(shapx,shapy,shapw,shaph,C);
Map_Display(112,0,240,113);
clean_Shap(clwhite);
end;

//-----------------------------------------鼠标放开--------------------------
procedure TFrmEditMap.ImageMapMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
Point: TPoint;
begin
ClipCursor(nil);
newX:=x;newY:=y;
case Button of
   mbLeft:      //-------------------左键放开
     begin
      clean_Shap(Clred);
      Cleanshap:=true;
      shape1.Visible :=false;

       Pop_MenuEnable;
            if (shapw>0) and (shaph>0) then
             begin
               GetCursorPos(Point);
               popMap.Popup(point.x+60,point.y+20);
             end;
     end; //end

   mbRight:    //-------------------右键放开
   begin
     
    end;
end;//end case
Abutton:=0;
end;

//-----------------------------------------鼠标移动------------------------
procedure TFrmEditMap.ImageMapMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
px,py,pw,ph:byte;
NextLeft,NextTop:Integer;
begin
px:=x div 20;py:=Y div 20;
case AButton of
  0:       //----------------信息显示
   begin
   pw:=DipiJdCode[px,py];
   ph:=DipiCode[px,py];
   if pw>0 then
        stabar.Panels[0].Text :='X:'+inttostr(px)+'  Y:'+inttostr(py)
        +'  C:'+ BuildName[pw]+'[$'+inttohex(pw,2)+']'+'($'+inttohex(DipiFX[px,py],2)+')'
   else
        stabar.Panels[0].Text :='X:'+inttostr(px)+'  Y:'+inttostr(py)
        +'  C:'+ BHtoLX(ph)+'[$'+inttohex(ph,2)+']'+'($'+inttohex(DipiFX[px,py],2)+')';
     if DipiJdDZ[px,py]>0 then
         stabar.Panels[1].Text :='地址：'+inttohex(DipiJdDZ[px,py],8)
        else
         stabar.Panels[1].Text :='地址：'+inttohex(DipiDZ[px,py],8);
  end;
   //-------------------------按下左键移动------------------------
  1:begin

  shape1.Visible:=true;
  label4.Visible :=true;
  shape1.Width :=x- oldX ;
  shape1.Height := Y - oldY;
  Label4.Top := shape1.Top + (shape1.Height - label4.Height) div 2-20;
  Label4.Left := shape1.Left + (shape1.Width - Label4.Width) div 2;
  if x>oldx then
       begin
       shapw:=ceil(x/20);shapx:=floor(oldx/20);
       end;
  if x<=oldx then
       begin
        shapw:=ceil(oldx/20);shapx:=floor(x/20);
       end;
        shapw:=shapw-shapx;
  if y>oldy then
       begin
          shapH:=ceil(y/20);shapY:=floor(oldy/20);
       end;
  if y<=oldy then
       begin
         shapH:=ceil(oldy/20);shapY:=floor(y/20);
       end;
        shapH:=shapH-shapy;
        label4.Caption :=inttostr(shapW)+' X '+inttostr(shapH);
    end;
  //-------------------------按下右键移动------------------------
  2: begin
         newx:=oldx-x;
         newy:=oldy-y;
         with imagemap do
            begin
             { Clamp before updating the control: one move, no intermediate
               X-only/Y-only or out-of-bounds repaint. Preserve drag limits. }
             NextLeft:=Left-newx;
             NextTop:=Top-newy;
             if NextLeft>-1 then NextLeft:=-1;
             if NextLeft+Width<Panel1.Width then
               NextLeft:=-(Width-Panel1.Width);
             if NextTop>-1 then NextTop:=-1;
             if NextTop+Height<Panel1.Height then
               NextTop:=-(Height-Panel1.Height);
             if (NextLeft<>Left) or (NextTop<>Top) then
               SetBounds(NextLeft,NextTop,Width,Height);
            end;//end with
    end; //end 2
 end; //end case
end;


//-----------------------------------------鼠标按下--------------------------
procedure TFrmEditMap.ImageMapMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
MouseRect:Trect;

begin
MouseRect.Left :=0;
MouseRect.Top :=0;
MouseRect.Right :=panel1.Width-8 ;//panel1.Width+8 ;
MouseRect.Bottom :=panel1.Height-8 ;//panel1.Height +33;
MapWindowPoints(panel1.handle, 0, MouseRect, 2); // 座标换算
ClipCursor(@MouseRect); // 限制鼠标移动区域
Abutton:=0;
case Button of
  mbLeft:  //--------------------鼠标左键
     begin
     Abutton:=1;
     if Cleanshap then  clean_Shap(clwhite);
     if Imgcopy.Visible then Imgcopy.Visible:=false;
     //if Cleanshap then clean_Shap(clwhite);
     shape1.Left := X+imagemap.Left ;
     shape1.Top := Y+imagemap.Top;
     shapx:=x div 20;shapy:=y div 20;
     shapw:=1;shapH:=1;

  end;
//------------------------------鼠标右键
  mbRight:
             Abutton:=2;
end; //end case
 oldx:=x;oldy:=y;
end;
//-------------------------------------------------------------------------
procedure TFrmEditMap.ImgCopyMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
case CAButton of
1:begin

  Cnewx:=Coldx-x;
  Cnewy:=Coldy-y;
  ImgCopy.Left := ImgCopy.Left-Cnewx;
  ImgCopy.Top :=ImgCopy.Top -Cnewy;
  shapcX:=(ImgCopy.Left -imageMap.Left) div 20;
  shapcY:=(ImgCopy.Top -ImageMap.Top) div 20;
  stabar.Panels[0].Text :='X:'+inttostr(shapcx)+'  Y:'+inttostr(shapcy)
                          +'  W:'+inttostr(shapw)+'  H:'+inttostr(shaph)
  end;
  end;
end;

//------------------------------移动图形处理--------------------------------
procedure TFrmEditMap.ImgCopyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 case Button of
  mbLeft:
     begin
     CAButton:=1;
     Coldx:=x;Coldy:=y;
     end;
  end;
end;

//------------------------------------------------------------------------
procedure TFrmEditMap.ImgCopyMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
case button of
    mbLeft:
    if  CAButton =1 then
        begin     //左键放开
        shapcX:=round((ImgCopy.Left -imageMap.Left)/ 20);
        shapcY:=round((ImgCopy.Top -ImageMap.Top) / 20);
        ImgCopy.Left:=shapcX*20+imageMap.Left;
        ImgCopy.top:=shapcY*20+ImageMap.Top;
          CAButton:=2;
        end;//end if

    mbRight:
    begin
        if  Move_EnbleE(shapX,shapY,shapW,shapH,shapcX,shapcY)  then
            begin
              Move_Dipi(shapx,shapy,shapw,shaph,shapcx,shapcy);
              StaBar.Panels[2].Text :='移动成功';
              clean_Shap(clwhite);
            end
           else
              StaBar.Panels[2].Text :='地皮冲突' ;
              cleanshap:=true;
              ImgCopy.Visible :=false;
    end;
end;//end button of
end;

//------------------------------右键弹出菜单------------------------------------
procedure TFrmEditMap.NnoClick(Sender: TObject);
begin
Pop_Menu($A0);
end;

procedure TFrmEditMap.N2x3Click(Sender: TObject);
begin
Pop_Menu($AE);
end;

procedure TFrmEditMap.N5x4Click(Sender: TObject);
begin
Pop_Menu($BC);
end;

procedure TFrmEditMap.N5x41Click(Sender: TObject);
begin
Pop_Menu($30);
end;

procedure TFrmEditMap.NroadClick(Sender: TObject);
begin
Pop_Menu($82);
end;

procedure TFrmEditMap.NsjClick(Sender: TObject);
begin
Pop_Menu($84);
end;


//*****************************************************************************

procedure TFrmEditMap.Button2Click(Sender: TObject);
var
i,j,City,DZ,temp:integer;
Dcode,Ccode:byte;
begin
{ Final 004AB264: selected classes, current city or every city. }
for City:=0 to CityCunt-1 do
begin
if CChoose.Checked and (City<>Ecity) then Continue;
DZ:=CityJz + $9F8 * City + $80C;
ReadProcessMemory(GHandle, Pointer(DZ), Pointer(@DZ),4,tmpNum);

For j := 0 To 127 do     //------------读出地皮代码
  For i := 0 To 225 do
      begin
         temp:=DZ + i + j * 226;
         ReadProcessMemory(GHandle, Pointer(temp), Pointer(@Dcode),1,tmpNum); //读出地皮代码
         Ccode:=Dcode;
         case Dcode of
           161..191:if CB2.Checked then Ccode:=$A0;
           48..63:if CB3.Checked then Ccode:=$2F;
           $82:if CB4.Checked then Ccode:=$A0;
           $84:if CB1.Checked then Ccode:=$A0;
         end;
         if Ccode<>Dcode then
           WriteProcessMemory(GHandle,Pointer(temp),@Ccode,1,tmpNum);
       end;
end;
Read_DpCode(Ecity);
Map_Display(112,0,240,113);
StaBar.Panels[3].Text:='已关闭所选地皮';
end;

procedure TFrmEditMap.N3x2Click(Sender: TObject);
begin
Pop_Menu($AD);
end;



procedure TFrmEditMap.FormShow(Sender: TObject);
begin
{ Final 004A94A8 is a return-only event; city selection is initialized by caller. }
end;





procedure  FZ_GH(GH:boolean);
var
i,j,k:integer;
Wsl,Hsl,TW,TH:byte;
Marker:byte;

Ax:array[0..7] of byte;
Ay:array[0..7] of byte;
Aw:array[0..7] of byte;
Ah:array[0..7] of byte;
TFx:array[0..7] of byte;
begin
if not GH then ZLSL:=0;
mfX:=shapx;mfY:=shapy;mfW:=shapW;mfH:=shapH;
TFX[0]:=224;TFX[1]:=32;TFX[2]:=224;TFX[3]:=32;
TFX[4]:=32;TFX[5]:=224;TFX[6]:=32;TFX[7]:=224;

if (mfW<2) or (mfH<2)  then exit;
if mfw*mfh<6 then  exit;
if mfw*mfh div 6>Length(ZLZX)-ZLSL then
begin
  FrmEditMap.StaBar.Panels[5].Text:='规划数量超过上限';
  Exit;
end;

case mfh mod 3 of
    0:begin
      Ah[3]:=0;Ah[4]:=0;
      end;
    1:begin
      Ah[3]:=2;Ah[4]:=2;
      end;
    2:begin
      Ah[3]:=0;Ah[4]:=2;
      end;
end;

Ah[0]:=(mfw mod 2)*(mfh mod 2)*3;
AW[0]:=(mfw mod 2)*(mfh mod 2)*2;
AW[1]:=(Mfw mod 2) *3;
Ah[1]:=mfH-(Mfh mod 2) *3;
Ax[2]:=0;
AY[2]:=0;
Ay[1]:=0;
Ax[3]:=0;
Ax[4]:=0;

Ax[0]:=mfw-AW[0];
Ay[0]:=mfH-Ah[0];
Ax[1]:=mfW-AW[1];
AW[2]:=mfW-AW[1];
Ah[2]:=mfh-Ah[3]-Ah[4];

AY[3]:=Ah[2];
AY[4]:=AY[3]+Ah[3];
AW[3]:=((mfW-AW[1])div 3)*3;
AW[4]:=((mfW-AW[1])div 3)*3;

if (Ah[3]=2) and (Ah[4]=2) and (Ah[0]=3) then
   AW[5]:=((mfw-Aw[4]-Aw[0]) div 2)*2
   else
   Aw[5]:=0;
Ax[5]:=AW[4];
Ay[5]:=Ay[0];
Ah[5]:=Ah[0];

if (Ah[3]=0) and (Ah[4]=2) and (Ah[0]=3) then
   AW[6]:=((mfw-Aw[3]-Aw[0]) div 3)*3
   else
   AW[6]:=0;

Ax[6]:=AW[4];
Ay[6]:=Ay[4];
Ah[6]:=Ah[4];

if (Ah[3]=2) and (Ah[4]=2) and (Ah[0]=0) then
   AW[7]:=((mfw-Aw[3]-Aw[1]) div 2)*2
   else
   AW[7]:=0;

Ax[7]:=AW[4];
Ay[7]:=Ah[2];
Ah[7]:=((mfh-Ah[2]) div 3)*3;


for k:=0 to 7 do    //8种拼合方式
   begin
     if (Aw[k]=0) or (Ah[k]=0) then continue;

      case TFx[k] of
         32:begin              //横
            Wsl:=AW[k] div 3;
            Hsl:=Ah[k] div 2;
            TW:=3; TH:=2;
            end;
         224:begin               //竖
             Wsl:=AW[k] div 2;
             Hsl:=Ah[k] div 3;
             TW:=2;TH:=3;
             end;
         else
              begin
             Wsl:=0;Hsl:=0;
             TW:=0;TH:=0;
             end;
      end;//end case

    if GH then
    for i:=0 to Aw[k]-1 do
   for j:=0  to Ah[k]-1 do
          begin
          DiPicode[shapx+Ax[k]+i,shapy+Ay[k]+j]:=$8B;
           Write_Dipi(shapx+Ax[k]+i,shapy+Ay[k]+j,1,1,$8B);
          end;

   for i:=0 to Wsl-1 do
     for j:=0 to Hsl-1 do
         begin
           if ZLSL>=Length(ZLZX) then Exit;
            ZLZX[ZLSL]:=shapx+Ax[k]+i*TW;
           ZLZY[ZLSL]:=shapy+Ay[k]+(j+1)*TH-1;
           ZLFX[ZLSL]:=TFx[k];
          if GH then
          begin
            if TFx[k]=$20 then
            begin
              if FrmEditMap.CkB1.Checked then Marker:=$88 else Marker:=$AD;
            end
            else
            begin
              if FrmEditMap.CkB1.Checked then Marker:=$89 else Marker:=$AE;
            end;
            Write_Dipi(ZLZX[ZLSL],ZLZY[ZLSL],1,1,Marker);
          end;
         ZLSL:=ZLSL+1;
         end;
end;  //end for k
ShowSelection(False);
if GH then ZLbool:=true;
end;

procedure TFrmEditMap.NZLClick(Sender: TObject);
var
i,j,k,L,Tw,TH,zsl:byte;
temps,tempx,tempy,Ax,Ay:byte;
Zx: array [0..255] of byte;
Zy: array [0..255] of byte;
begin

zsl:=0;TW:=0;TH:=0;
for i:=0 to shapw-1 do
   for j:=0 to shaph-1 do
      begin
         Zx[zsl]:=shapx+i;
         Zy[zsl]:=shapy+j;
         if (DipijdCode[Zx[zsl],Zy[zsl]]>20) and (DipijdCode[Zx[zsl],Zy[zsl]]<30) then
         begin
        case  DipiFX[Zx[zsl],Zy[zsl]] of
         224:begin           //竖
              TW:=2; TH:=3;
              end;
         32:begin            //横
              TW:=3;TH:=2;
             end;
         else
           exit;
        end;//end case

        zsl:=zsl+1;
        if zsl> ZLSL then break;
        if (TW<=0) or (TH<=0) then exit;
        for k:=0 to TW-1 do
            for L:=0 to TH-1 do
                begin
                  tempx:=shapx+i+k;
                  tempy:=shapy+j-TH+1+L;
                  DipiCode[tempx,tempy]:=$A0;
                  writeprocessmemory(GHandle,Pointer(Dipidz[tempx,tempy]),
                             Pointer(@DipiCode[tempx,tempy]),1,tmpNum);

                end;
        end;//end if
end;//end for

if ZLSL>zsl then
   temps:=zsl
    else
   temps:=ZLSL;

if temps=0 then exit;
       //-----------------------------

for i:=0 to temps-1 do
  begin
    case ZLFX[i] of
      32:begin         //横
         TW:=3;TH:=2;
         end;
      224:begin        //竖
           TW:=2; TH:=3;
          end;
      else
           exit;
     end;//end case

      if (TW<=0) or (TH<=0) then exit;
      for k:=0 to TW-1 do
          for L:=0 to TH-1 do
                 begin
                tempx:=ZLZX[I]+k;
                tempy:=ZLZY[I]-TH+1+L;
                DipiCode[tempx,tempy]:=$8B;
                writeprocessmemory(GHandle,Pointer(Dipidz[tempx,tempy]),
                             Pointer(@DipiCode[tempx,tempy]),1,tmpNum);
                end;

     DipiFX[ZLZX[I],ZLZY[I]]:=ZLFX[I];
     DipiFX[Zx[i],Zy[i]]:=0;
     DipijdCode[ZLZX[I],ZLZY[I]]:=DipijdCode[Zx[i],Zy[i]];
     DipijdCode[Zx[i],Zy[i]]:=0;
     DipiJdDz[ZLZX[I],ZLZY[I]]:=DipiJdDz[Zx[i],Zy[i]];
     DipiJdDZ[Zx[i],Zy[i]]:=0;
     Ax:=(ZLZX[I]+ZLZY[I]-112)div 2;
     Ay:=ZLZY[I]+112-ZLZX[I];

     writeprocessmemory(GHandle, Pointer(DipijdDZ[ZLZX[I], ZLZY[I]]),Pointer(@Ax),1,tmpNum);
     writeprocessmemory(GHandle, Pointer(DipijdDZ[ZLZX[I], ZLZY[I]]+1),Pointer(@Ay),1,tmpNum);
     writeprocessmemory(GHandle, Pointer(DipijdDZ[ZLZX[I], ZLZY[I]]+7),Pointer(@DipiFX[ZLZX[I],ZLZY[I]]),1,tmpNum);
  end;

Map_Display(112,0,240,113);
shapx:=0;shapy:=0;shapw:=0;shaph:=0;
Nmove.Enabled :=false;
ZLSL:=0;
fillchar(ZLFX,sizeof(ZLFX),0);
fillchar(ZLZX,sizeof(ZLZX),0);
fillchar(ZLZY,sizeof(ZLZY),0);
NFzzl.Enabled :=false;

end;


procedure TFrmEditMap.NMoveClick(Sender: TObject);
begin
Move_Copy(shapx,shapy,shapw,shaph);
end;
//---------------------------------------------------------------
procedure TFrmEditMap.BitBtn2Click(Sender: TObject);
begin
  { Final 004AC8B8: next city, wrapping at CityCunt. }
  if CityCunt=0 then Exit;
  if ComBox.ItemIndex>=CityCunt-1 then ComBox.ItemIndex:=0
  else ComBox.ItemIndex:=ComBox.ItemIndex+1;
  ComBoxChange(Sender);
end;

procedure TFrmEditMap.BitBtn1Click(Sender: TObject);
begin
  { Final 004AC82C: previous city, wrapping at zero. }
  if CityCunt=0 then Exit;
  if ComBox.ItemIndex<=0 then ComBox.ItemIndex:=CityCunt-1
  else ComBox.ItemIndex:=ComBox.ItemIndex-1;
  ComBoxChange(Sender);
end;

procedure TFrmEditMap.ComBoxChange(Sender: TObject);
begin
  { Final 004AC948. Ignore the editable combo's unselected state. }
  if (ComBox.ItemIndex<0) or (ComBox.ItemIndex>=CityCunt) then Exit;
  Ecity:=ComBox.ItemIndex;
  Change_city;
end;


//-----------------------------------------------------------------------------


procedure TFrmEditMap.TransferHousesLegacy(Sender: TObject);
var
  Lx:byte;
  i,j,s,BL,BL1,EW:word;
  HL:array[0..300] of word;
  HL1:array[0..300] of word;
  jddz,temp,temp1:integer;
  P:byte;
begin
fillchar(HL,sizeof(HL),0);
fillchar(HL1,sizeof(HL1),0);
EW:=$FFFF;
P:=player-1;
temp1:= CityJz +  $9F8 * ECity + $75c;
ReadProcessMemory (Ghandle, Pointer(temp1), Pointer(@jdDZ),4,tmpNum);

if SWSDZ[ECity]>0 then
begin
  ReadProcessMemory(GHandle, Pointer(SWSDZ[ECity]+$2D0), Pointer(@BL),2,tmpNum);
  BL1:=BL;
  while BL<>$FFFF do
     begin
       BL1:=BL;
       temp:=jdDZ + BL* 8;
       ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BL),2,tmpNum);
      end;
end
else
exit;

i:=0;
j:=0;
//************************城镇的建筑******************************
ReadProcessMemory (Ghandle, Pointer(temp1+8), Pointer(@BL),2,tmpNum);
while BL<>$FFFF do
       begin
       temp :=jdDZ + BL* 8;

       ReadProcessMemory (Ghandle, Pointer(temp+3), Pointer(@Lx),1,tmpNum);
       if (Lx>20) and (Lx<30) then
           begin
            HL[i]:=BL;
            i:=i+1;
            end
           else
            begin
            HL1[j]:=BL;
            j:=j+1;
            end;
         ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BL),2,tmpNum);
     end;

StaBar.Panels[3].Text :='没有可转变的房子';
if i=0 then exit;
if j=0 then exit;

ReadProcessMemory (Ghandle, Pointer(temp1+8), Pointer(@BL),2,tmpNum);
if BL=HL[0] then
    writeprocessmemory(GHandle,Pointer(temp1+8),Pointer(@HL1[0]),2,tmpNum); //总指针

for s:=0 to j-2 do
  begin
  temp :=jdDZ + HL1[s]* 8;
  writeprocessmemory(GHandle,Pointer(temp+4),Pointer(@HL1[s+1]),2,tmpNum);//重建城镇其它建筑链
  end;

  temp :=jdDZ + HL1[j-1]* 8;
  writeprocessmemory(GHandle,Pointer(temp+4),Pointer(@EW),2,tmpNum);//写入线束标志

if BL1=$FFFF then
    writeprocessmemory(GHandle,Pointer(SWSDZ[ECity]+$2D0),Pointer(@HL[0]),2,tmpNum)//如果玩家没有建筑，则打开链头
    else
    begin
    temp :=jdDZ + BL1* 8;
    writeprocessmemory(GHandle,Pointer(temp+4),Pointer(@HL[0]),2,tmpNum);
    end;
if i>1 then
for s:=0 to i-2 do
  begin
  temp :=jdDZ + HL[s]* 8;
  writeprocessmemory(GHandle,Pointer(temp+2),Pointer(@P),1,tmpNum);
  writeprocessmemory(GHandle,Pointer(temp+4),Pointer(@HL[s+1]),2,tmpNum);
  end;

  temp :=jdDZ + HL[i-1]* 8;
  writeprocessmemory(GHandle,Pointer(temp+2),Pointer(@P),1,tmpNum);
  writeprocessmemory(GHandle,Pointer(temp+4),Pointer(@EW),2,tmpNum);

StaBar.Panels[3].Text :='成功转变'+inttostr(i)+'所房子';
end;


//---------------------统计材料是否充足-----------------------------------------
Function Get_AllowMade(Lx:byte):boolean;
var
i:word;
DZ,CLtemp:integer;

begin
if Lx>2 then begin Result:=False; Exit; end;
result:=true;
fillchar(CL,sizeof(CL),0);
if SWSDz[ECity]<>0 then
   begin
    DZ:=SWSDz[ECity]+4;
    ReadProcessMemory(GHandle, Pointer(DZ+19*4),Pointer(@CLtemp),4,tmpNum);
    CL[0]:=CL[0]+CLtemp;
    ReadProcessMemory(GHandle, Pointer(DZ+11*4),Pointer(@CLtemp),4,tmpNum);
    CL[1]:=CL[1]+CLtemp;
    ReadProcessMemory(GHandle, Pointer(DZ+12*4),Pointer(@CLtemp),4,tmpNum);
    CL[2]:=CL[2]+CLtemp;
    end;

for i:=1 to  CLshipList[0] do
  begin
    DZ:= ShipJZ + CLshipList[i] * $180+84;
    ReadProcessMemory(GHandle, Pointer(DZ+19*4),Pointer(@CLtemp),4,tmpNum);
    CL[0]:=CL[0]+CLtemp;
    ReadProcessMemory(GHandle, Pointer(DZ+11*4),Pointer(@CLtemp),4,tmpNum);
    CL[1]:=CL[1]+CLtemp;
    ReadProcessMemory(GHandle, Pointer(DZ+12*4),Pointer(@CLtemp),4,tmpNum);
    CL[2]:=CL[2]+CLtemp;
  end;
  CL[3]:=Get_Money;

if (CL[0]<BuLCL[Lx,0]) or (CL[1]<BuLCL[Lx,1])
    or (CL[2]<BuLCL[Lx,2]) or (CL[3]<BuLCL[Lx,3]) then
      result:=false;
end;


//-----------------------------------扣除材料---------------------------
procedure TakeOff_CL(Lx:byte);
var
MCL:array[0..3] of integer;
CLtemp,DZ,AMoney:integer;
i,j,Wy:word;

begin
for i:=0 to 3 do
  MCL[i]:=BuLCL[LX,i];

wy:=0;
for i:=1 to  CLshipList[0] do
  begin
    DZ:= ShipJZ + CLshipList[i] * $180;

    for j:=0 to 2 do
        begin
        case j of
           0:wy:=19;1:wy:=11;2:wy:=12;
         end;
        ReadProcessMemory(GHandle, Pointer(DZ+wy*4+84),Pointer(@CLtemp),4,tmpNum);
        if MCL[j]=0 then continue;

        if CLtemp<=MCL[j] then
           begin
             MCL[j]:=MCL[j]-CLtemp;
             CLtemp:=0;
           end
          else
            begin
               CLtemp:=CLtemp-MCL[j];
               MCL[j]:=0;
            end;
         writeprocessmemory(GHandle,Pointer(DZ+wy*4+84),Pointer(@Cltemp),4,tmpNum);
      end;//end for j
 end;//end for  i


DZ:= SWSDz[ECity]+4;
if SWSDz[ECity]<>0 then
for j:=0 to 2 do
  begin
   case j of
     0:wy:=19;1:wy:=11;2:wy:=12;
   end;
   ReadProcessMemory(GHandle, Pointer(DZ+wy*4),Pointer(@CLtemp),4,tmpNum);
   if MCL[j]=0 then continue;
   if CLtemp<=MCL[j] then
      begin
      MCL[j]:=MCL[j]-CLtemp;
      CLtemp:=0;
       end
      else
       begin
         CLtemp:=CLtemp-MCL[j];
         MCL[j]:=0;
       end;
   writeprocessmemory(GHandle,Pointer(DZ+wy*4),Pointer(@Cltemp),4,tmpNum);
  end;//end for j

AMoney:=Get_Money;
Write_Money(AMoney-MCL[3]);

end;

//---------------------------------------------------------------
Function Get_MadeLx:byte;
var
i:integer;
Rk:array [0..2]of integer;

begin
for i:=0 to 2 do
  ReadProcessMemory(GHandle, Pointer(CityDZ[Ecity]+728+i*4), Pointer(@Rk[i]),4,tmpNum);
Rk[0]:=(Rk[0]*100) div (Builds[6]*80);
Rk[1]:=(Rk[1]*100) div (Builds[7]*140);
Rk[2]:=(Rk[2]*100) div (Builds[8]*280);
if Rk[0]>=Rk[1] then
     begin
     result:=0;
     if Rk[0]<Rk[2] then result:=2;
     end
   else
     begin
       result:=1;
       if Rk[1]<Rk[2] then result:=2;
     end;

end;




//--------------------------批量建房----------------------------------
procedure TFrmEditMap.NMadeClick(Sender: TObject);
var
temp,Citydpdz,CityDipi:integer;
TW,TH,P,T,M:Byte;
N:Integer;
Ax,Ay,E,i,j,k,L,BuL,BuL0,Max:Word;
Lx:array [0..2] of byte;
Rk:array[0..3] of integer;
TRk:array[0..2] of integer;
SL:array[0..2,0..2] of byte;
S:array[0..2] of word;
LxL:array[0..999] of byte;
begin
CkB1.Checked:=False;
P:=Player-1;
E:=$FFFF;

TH:=0;
Tw:=0;
LX[0]:=0;
LX[1]:=1;
LX[2]:=2;
S[0]:=80;
S[1]:=140;
S[2]:=280;
FZ_GH(false);
if ZLsl=0 then exit;
fillchar(LXL,sizeof(LXL),255);

Get_CityTk_ship(Ecity);
ReadMapStats;

for i:=0 to 2 do
  ReadProcessMemory(GHandle, Pointer(CityDZ[Ecity]+728+i*4), Pointer(@TRk[i]),4,tmpNum);
for i:=0 to 2 do
     Rk[i]:=MapStats[i+20,2];


for i:=0 to 1 do
if Rk[i+1]>Rk[i] then
   begin
    temp:=Rk[i];
    Rk[i]:=Rk[i+1];
    Rk[i+1]:=temp;
    T:=LX[i];
    LX[i]:=LX[i+1];
    LX[i+1]:=T;
   end;
if Rk[1]>Rk[0] then
   begin
    temp:=Rk[0];
    Rk[0]:=Rk[1];
    Rk[1]:=temp;
    T:=LX[0];
    LX[0]:=LX[1];
    LX[1]:=T;
   end;

Rk[0]:=ceil((Rk[0]-Rk[2])*TRk[LX[0]]/S[LX[0]]/100);
Rk[1]:=ceil((Rk[1]-Rk[2])*TRk[LX[1]]/S[LX[1]]/100);
Rk[2]:=0;

//到此比例拉平

k:=0;
for j:=0 to 2 do
  begin
  if Rk[j]=0 then continue;
  for i:=0 to Rk[j]-1 do
    begin
     if k>=ZLSL then Break;
     LXL[k]:=LX[j];
     k:=k+1;
    end;
  end;

//--------余下按比例分配--------
for i:=0 to 2 do
  begin
    Rk[i]:=ceil(TRk[i]/S[i]);
    if Rk[i]<0 then Rk[i]:=0;
  end;

Rk[3]:=Rk[0]+Rk[1]+Rk[2];
if Rk[3]=0 then exit;
temp:=ZLsL-k;
if temp>0 then
begin
  Rk[0]:=round(Rk[0]/Rk[3]*temp);
  Rk[1]:=round(Rk[2]/Rk[3]*temp);
  Rk[2]:=temp-Rk[0]-Rk[1];
   if Rk[2]<0 then Rk[2]:=0;
end
else
  begin
  Rk[0]:=0;
  Rk[1]:=0;
  Rk[2]:=0;
  end;

for j:=2 downto 0 do
  begin
  if Rk[j]=0 then continue;
  for i:=0 to Rk[j]-1 do
    begin
     if k>=ZLSL then Break;
     LXL[k]:=j;
     k:=k+1;
    end;
  end;



temp:= CityJz +  $9F8 * ECity + $75c;
ReadProcessMemory (Ghandle, Pointer(temp), Pointer(@CityDipi),4,tmpNum);
ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL0),2,tmpNum);//总指针
ReadProcessMemory (Ghandle, Pointer(temp+26), Pointer(@MAX),2,tmpNum);//最大指针
if BuL0=MAX then
   begin
    StaBar.Panels[4].Text :='序列上限';
   exit;
   end;

      if (LXL[0]>2) or (Get_AllowMade(LXL[0])=false) then
   begin
   StaBar.Panels[4].Text:='材料或金钱不足';
   exit;
   end;

Citydpdz:=temp+6;
ReadProcessMemory (Ghandle, Pointer(Citydpdz), Pointer(@BuL),2,tmpNum);
if BuL=$FFFF then
    temp:=Citydpdz
    else
     while BuL<>$FFFF do
        begin
          temp:= CityDipi + BuL* 8+4;
          ReadProcessMemory (Ghandle, Pointer(temp), Pointer(@BuL),2,tmpNum);
        end;

//修改接头的建造指针
writeprocessmemory(GHandle,Pointer(temp),Pointer(@BuL0),2,tmpNum);

N:=0;
T:=$8B;


for i:=0 to ZLsl-1 do
begin
   M:=LxL[i];
      if Get_AllowMade(M)=false then
   begin
   StaBar.Panels[4].Text:='材料或金钱不足';
   break;
   end;

  
  //读取下一个指针
  temp:= CityDipi + BuL0* 8;
  Ax:=(ZLZX[I]+ZLZY[I]-112)div 2;
  Ay:=ZLZY[I]+112-ZLZX[I];
  writeprocessmemory(GHandle,Pointer(temp),Pointer(@Ax),1,tmpNum); //x
  writeprocessmemory(GHandle,Pointer(temp+1),Pointer(@Ay),1,tmpNum);//y
  writeprocessmemory(GHandle,Pointer(temp+2),Pointer(@P),1,tmpNum);//主人
  writeprocessmemory(GHandle,Pointer(temp+3),Pointer(@MLX[M,0]),1,tmpNum);//类型
  writeprocessmemory(GHandle,Pointer(temp+6),Pointer(@MLX[M,1]),1,tmpNum);//建造时间
  writeprocessmemory(GHandle,Pointer(temp+7),Pointer(@ZLFX[I]),1,tmpNum);//方向

  case ZLFX[i] of
      224:begin           //竖
              TW:=2; TH:=3;
              end;
         32:begin            //横
              TW:=3;TH:=2;
             end;
        end;//end case

    for k:=0 to TW-1 do
       for L:=0 to TH-1 do
       begin
         Ax:=ZLZX[I]+k;
         Ay:=ZLZY[I]-TH+1+L;
         writeprocessmemory(GHandle,Pointer(Dipidz[Ax,Ay]),Pointer(@T),1,tmpNum);
       end;
  TakeOff_CL(M);
  ReadProcessMemory (Ghandle, Pointer(temp+4), Pointer(@BuL0),2,tmpNum);//下一个链
  writeprocessmemory(GHandle,Pointer(Citydpdz-2),Pointer(@BuL0),2,tmpNum); //写入总指针
  N:=N+1;
  if BuL0=MAX then break;

end;
 writeprocessmemory(GHandle,Pointer(temp+4),Pointer(@E),2,tmpNum);//结束链

ZLbool:=false;
ZLSL:=0;
NFzzl.Enabled :=false;
Change_city;
StaBar.Panels[4].Text :='建造了'+inttostr(N)+'座房子';
end;


procedure TFrmEditMap.NGhClick(Sender: TObject);
begin
NFZGHClick(Sender);
end;

procedure ShowSelection(Visible: Boolean);
var X,Y,W,H:Integer;
begin
  with FrmEditMap do
  begin
    Label4.Visible:=False;
    X:=shapx*20+ImageMap.Left-1;
    Y:=shapy*20+ImageMap.Top-1;
    W:=shapw*20; H:=shaph*20;
    S1.SetBounds(X,Y,1,H); S2.SetBounds(X,Y,W,1);
    S3.SetBounds(X+W,Y,1,H); S4.SetBounds(X,Y+H,W,1);
    S1.Visible:=Visible; S2.Visible:=Visible;
    S3.Visible:=Visible; S4.Visible:=Visible;
  end;
end;

procedure DrawMapOverlays;
const Widths:array[0..3] of Integer=(100,60,40,60);
      Heights:array[0..3] of Integer=(80,40,60,80);
var X,Y,C,J,K:Integer;
begin
  { Final 004A6DE0 / table 004CA034: outlines and cropped 240x240 minimap. }
  with FrmEditMap.ImageMap.Canvas do
  begin
    Brush.Style:=bsClear; Pen.Color:=clFuchsia;
    for X:=0 to 239 do
      for Y:=0 to 240 do
      begin
        C:=DipiCode[X,Y]; J:=DipiJDCode[X,Y]; K:=-1;
        case C of
          $86,$87:K:=0;
          $88:K:=1;
          $89:K:=2;
        end;
        case J of
          4,6..20:K:=0;
          21..30:if DipiFX[X,Y]=$20 then K:=1 else K:=2;
          41,44:K:=3;
        end;
        if K>=0 then
          Rectangle(X*20-1,(Y+1)*20-Heights[K]-1,X*20+Widths[K],(Y+1)*20);
      end;
  end;
  with FrmEditMap do
  begin
    StretchBlt(Image1.Canvas.Handle,0,0,240,240,ImageMap.Canvas.Handle,
      500,500,ImageMap.Width-1000,ImageMap.Height-1000,SRCCOPY);
    Image1.Refresh;
    StaBar.Panels[5].Text:='规划: '+IntToStr(ZLSL);
  end;
end;

procedure TFrmEditMap.NFZGHClick(Sender: TObject);
begin
  { Final 004AB4A8 -> 004AB8F8: commit house lots, not a preview. }
  FZ_GH(True);
  Map_Display2(shapx,shapy,shapw,shaph);
  StaBar.Panels[5].Text:='规划: '+IntToStr(ZLSL);
end;

procedure TFrmEditMap.NGCGHClick(Sender: TObject);
var X,Y,W,H,C:Integer;
begin
  { Final 004ABEC8: row-major 5x4 lots, anchor at bottom left. }
  if (shapw<5) or (shaph<4) then Exit;
  W:=(shapw div 5)*5; H:=(shaph div 4)*4;
  ShowSelection(False);
  for Y:=shapy to shapy+H-1 do
    for X:=shapx to shapx+W-1 do
    begin
      C:=DipiCode[X,Y];
      if C in [32..63] then Write_Dipi(X,Y,1,1,$0B)
      else if C in [160..191] then Write_Dipi(X,Y,1,1,$8B);
    end;
  for X:=0 to W div 5-1 do
    for Y:=0 to H div 4-1 do
    begin
      C:=DipiCode[shapx+X*5,shapy+Y*4+3];
      if C=$8B then
      begin
        if CkB1.Checked then C:=$86 else C:=$B8;
      end
      else if C=$0B then
      begin
        if CkB1.Checked then C:=$87 else C:=$38;
      end;
      Write_Dipi(shapx+X*5,shapy+Y*4+3,1,1,C);
    end;
  Map_Display2(shapx,shapy,shapw,shaph);
end;

procedure TFrmEditMap.NUnLockClick(Sender: TObject);
var X,Y,C:Integer;
begin
  { Final 004ACC54: unlock the four reserved anchor codes. }
  ZLSL:=0;
  for X:=shapx to shapx+shapw-1 do
    for Y:=shapy to shapy+shaph-1 do
    begin
      C:=DipiCode[X,Y];
      if not (C in [$86..$89]) then Continue;
      case C of
        $86:C:=$BC;
        $87:C:=$3B;
        $88,$89:
          begin
            if ZLSL>=Length(ZLZX) then Exit;
            ZLZX[ZLSL]:=X; ZLZY[ZLSL]:=Y;
            if C=$88 then
            begin ZLFX[ZLSL]:=$20; C:=$A9; end
            else
            begin ZLFX[ZLSL]:=$E0; C:=$AA; end;
            Inc(ZLSL);
          end;
      end;
      Write_Dipi(X,Y,1,1,C);
    end;
  ZLbool:=ZLSL>0;
  Map_Display(112,0,240,113);
end;

procedure TFrmEditMap.NJZClick(Sender: TObject);
begin
  Pop_Menu($8B);
end;

procedure TFrmEditMap.Nno2Click(Sender: TObject);
begin
  Pop_Menu($20);
end;

procedure ArrangeHouses(Kind:Integer);
var
  X,Y,I,J,N,W,H:Integer;
  AX,AY:Byte;
  SX,SY,Code:array[0..999] of Byte;
  Address:array[0..999] of Cardinal;
begin
  { Final 004A94B8: select one class; consume only the used planning entries. }
  N:=0;
  for X:=shapx to shapx+shapw-1 do
    for Y:=shapy to shapy+shaph-1 do
      if (DipiJDCode[X,Y] in [21..29]) and
         ((DipiJDCode[X,Y]-21) div 3=Kind) and (N<ZLSL) then
      begin
        SX[N]:=X; SY[N]:=Y; Code[N]:=DipiJDCode[X,Y];
        Address[N]:=DipiJDDZ[X,Y]; Inc(N);
      end;
  if N=0 then Exit;
  for I:=0 to N-1 do
    if not (DipiFX[SX[I],SY[I]] in [$20,$E0]) or
       not (ZLFX[I] in [$20,$E0]) then Exit;
  ShowSelection(False);
  for I:=0 to N-1 do
  begin
    if DipiFX[SX[I],SY[I]]=$20 then begin W:=3; H:=2; end
    else begin W:=2; H:=3; end;
    Write_Dipi(SX[I],SY[I]-H+1,W,H,$A0);
    DipiJDCode[SX[I],SY[I]]:=0;
    DipiJDDZ[SX[I],SY[I]]:=0;
    DipiFX[SX[I],SY[I]]:=0;
  end;
  for I:=0 to N-1 do
  begin
    if ZLFX[I]=$20 then begin W:=3; H:=2; end
    else begin W:=2; H:=3; end;
    X:=ZLZX[I]; Y:=ZLZY[I];
    Write_Dipi(X,Y-H+1,W,H,$8B);
    DipiJDCode[X,Y]:=Code[I]; DipiJDDZ[X,Y]:=Address[I];
    DipiFX[X,Y]:=ZLFX[I];
    AX:=(X+Y-112) div 2; AY:=Y+112-X;
    WriteProcessMemory(GHandle,Pointer(Address[I]),@AX,1,tmpNum);
    WriteProcessMemory(GHandle,Pointer(Address[I]+1),@AY,1,tmpNum);
    WriteProcessMemory(GHandle,Pointer(Address[I]+7),@ZLFX[I],1,tmpNum);
  end;
  for J:=0 to ZLSL-N-1 do
  begin
    ZLZX[J]:=ZLZX[J+N]; ZLZY[J]:=ZLZY[J+N]; ZLFX[J]:=ZLFX[J+N];
  end;
  Dec(ZLSL,N); ZLbool:=ZLSL>0;
  shapx:=0; shapy:=0; shapw:=0; shaph:=0;
  Map_Display(112,0,240,113);
  FrmEditMap.StaBar.Panels[5].Text:='剩余规划: '+IntToStr(ZLSL);
end;

procedure TFrmEditMap.NZL0Click(Sender: TObject);
begin
  ArrangeHouses(0);
end;

procedure TFrmEditMap.NZL1Click(Sender: TObject);
begin
  ArrangeHouses(1);
end;

procedure TFrmEditMap.NZL2Click(Sender: TObject);
begin
  ArrangeHouses(2);
end;

type
  TMapBuilding = packed record
    C,D,Owner,Kind:Byte;
    Next:Word;
    BuildTime,Direction:Byte;
  end;
  TMapBuildingList = array of Word;

function ReadBuildingChain(Base:Cardinal; Head:Word;
  var List:TMapBuildingList):Boolean;
var Next:Word; N:Integer;
begin
  Result:=False;
  while Head<>$FFFF do
  begin
    N:=Length(List);
    if N>=3000 then Exit;
    SetLength(List,N+1); List[N]:=Head;
    if not ReadProcessMemory(GHandle,Pointer(Base+Head*8+4),@Next,2,tmpNum) then Exit;
    Head:=Next;
  end;
  Result:=True;
end;

function RemoveBuildings(Base,CityList:Cardinal; const List:TMapBuildingList;
  Competitors:Boolean):Integer;
var
  I,X,Y,DX,DY,W,H:Integer;
  B:TMapBuilding;
  Empty,OldFree,Next:Word;
  Zero,C:Byte;
begin
  { Final 004A9D88 / 004AC1A4: recycle records onto the city's free chain. }
  Result:=0;
  if Length(List)=0 then Exit;
  Empty:=$FFFF; Zero:=0;
  ReadProcessMemory(GHandle,Pointer(CityList+4),@OldFree,2,tmpNum);
  WriteProcessMemory(GHandle,Pointer(CityList+4),@List[0],2,tmpNum);
  for I:=0 to High(List) do
  begin
    ReadProcessMemory(GHandle,Pointer(Base+List[I]*8),@B,SizeOf(B),tmpNum);
    X:=112-(B.D div 2)+B.C; Y:=(B.D div 2)+B.C+(B.D mod 2);
    W:=0; H:=0;
    case B.Kind of
      4,6..20:begin W:=5; H:=4; end;
      5:begin W:=3; H:=2; end;
      21..29:
        if B.Direction=$20 then begin W:=3; H:=2; end
        else if B.Direction=$E0 then begin W:=2; H:=3; end;
    end;
    for DX:=0 to W-1 do
      for DY:=0 to H-1 do
      begin
        C:=$A0;
        if Competitors then
        begin
          if B.Kind=5 then
          begin
            if (DX=0) and (DY=0) then C:=$0E else C:=$1E;
          end
          else if DipiCode[X+DX,Y-DY]=$0B then C:=$20;
        end;
        Write_Dipi(X+DX,Y-DY,1,1,C);
      end;
    if I<High(List) then Next:=List[I+1] else Next:=OldFree;
    WriteProcessMemory(GHandle,Pointer(Base+List[I]*8+4),@Next,2,tmpNum);
    WriteProcessMemory(GHandle,Pointer(Base+List[I]*8),@Empty,2,tmpNum);
    WriteProcessMemory(GHandle,Pointer(Base+List[I]*8+2),@Empty,2,tmpNum);
    if Competitors then
      WriteProcessMemory(GHandle,Pointer(Base+List[I]*8+6),@Zero,1,tmpNum);
    WriteProcessMemory(GHandle,Pointer(Base+List[I]*8+7),@Zero,1,tmpNum);
    Inc(Result);
  end;
end;

procedure ReadMapStats;
const Capacity:array[0..2] of Integer=(8,14,28);
var
  CityList,Base,TraderBase,Trader,ProductionBase,RecordAddress:Cardinal;
  Count,City,CityKind,Kind:Byte;
  Head,Next,Employed,CapacityWorkers:Word;
  I,J,Index,Population,Steps:Integer;
  List:TMapBuildingList;

  procedure CountChain(AHead:Word; Pending:Boolean);
  var N,K,Column:Integer; L:TMapBuildingList; B:TMapBuilding;
  begin
    if not ReadBuildingChain(Base,AHead,L) then Exit;
    if Pending then Column:=1 else Column:=0;
    for N:=0 to High(L) do
    begin
      if not ReadProcessMemory(GHandle,Pointer(Base+L[N]*8),@B,SizeOf(B),tmpNum) then Continue;
      K:=-1;
      if B.Kind in [4..20] then
      begin
        K:=B.Kind-4;
        if (CityKind=4) and (K=1) then K:=17;
      end
      else if B.Kind in [21..29] then K:=20+(B.Kind-21) div 3;
      if K>=0 then Inc(MapStats[K,Column]);
    end;
  end;

begin
  { Final 00478150, verified against supplemental x86 assembly. }
  FillChar(MapStats,SizeOf(MapStats),0);
  CityList:=CityDZ[Ecity]+$75C;
  if not ReadProcessMemory(GHandle,Pointer(CityList),@Base,4,tmpNum) then Exit;
  CityKind:=0;
  ReadProcessMemory(GHandle,Pointer(CityDZ[Ecity]+$2CD),@CityKind,1,tmpNum);
  ReadProcessMemory(GHandle,Pointer(CityList+6),@Head,2,tmpNum);
  CountChain(Head,True);
  ReadProcessMemory(GHandle,Pointer(CityList+8),@Head,2,tmpNum);
  CountChain(Head,False);
  Count:=0;
  ReadProcessMemory(GHandle,Pointer($71CE26),@Count,1,tmpNum);
  ReadProcessMemory(GHandle,Pointer($71CE1C),@TraderBase,4,tmpNum);
  for I:=0 to Integer(Count)-1 do
  begin
    Trader:=TraderBase+Cardinal(I)*$44C+$2C4;
    ReadProcessMemory(GHandle,Pointer(Trader+2),@City,1,tmpNum);
    if City<>Ecity then Continue;
    ReadProcessMemory(GHandle,Pointer(Trader+12),@Head,2,tmpNum);
    CountChain(Head,False);
    ReadProcessMemory(GHandle,Pointer(Trader+10),@Head,2,tmpNum);
    CountChain(Head,False);
  end;
  if SwsDZ[Ecity]<>0 then
  begin
    ReadProcessMemory(GHandle,Pointer($71CE18),@ProductionBase,4,tmpNum);
    ReadProcessMemory(GHandle,Pointer(SwsDZ[Ecity]+$2CC),@Head,2,tmpNum);
    Steps:=0;
    while (Head<>$FFFF) and (Steps<3000) do
    begin
      RecordAddress:=ProductionBase+Cardinal(Head)*20;
      ReadProcessMemory(GHandle,Pointer(RecordAddress+4),@Employed,2,tmpNum);
      ReadProcessMemory(GHandle,Pointer(RecordAddress+12),@CapacityWorkers,2,tmpNum);
      ReadProcessMemory(GHandle,Pointer(RecordAddress+6),@Kind,1,tmpNum);
      ReadProcessMemory(GHandle,Pointer(RecordAddress+8),@Next,2,tmpNum);
      Index:=Kind-4;
      if (CityKind=4) and (Index=1) then Index:=17;
      if (Index>=0) and (Index<18) then
        if CapacityWorkers=0 then MapStats[Index,2]:=0
        else MapStats[Index,2]:=Round(Employed*100/CapacityWorkers);
      Head:=Next; Inc(Steps);
    end;
  end;
  for I:=0 to 22 do Inc(MapStats[I,0],MapStats[I,1]);
  for J:=0 to 2 do
  begin
    Population:=0;
    ReadProcessMemory(GHandle,Pointer(CityDZ[Ecity]+$2D8+J*4),@Population,4,tmpNum);
    if MapStats[20+J,0]=0 then MapStats[20+J,2]:=100
    else MapStats[20+J,2]:=Population*10 div (MapStats[20+J,0]*Capacity[J]);
  end;
end;

procedure DisplayMapStats;
const Goods:array[0..17] of Byte=(9,2,3,12,5,0,1,11,8,4,16,14,7,18,19,15,17,10);
var I,Col:Integer;
begin
  { Final 004ACEF8: count[under construction] and utilization. }
  ReadMapStats;
  for Col:=0 to 22 do
  begin
    FrmEditMap.StrGid.Cells[Col,1]:='';
    FrmEditMap.StrGid.Cells[Col,2]:='';
  end;
  for I:=0 to 22 do
  begin
    if I<18 then Col:=sp_index(Goods[I])
    else if I>=20 then Col:=I else Continue;
    if (MapStats[I,0]<>0) or (I>=20) then
    begin
      FrmEditMap.StrGid.Cells[Col,1]:=IntToStr(MapStats[I,0]);
      if MapStats[I,1]<>0 then
        FrmEditMap.StrGid.Cells[Col,1]:=FrmEditMap.StrGid.Cells[Col,1]+
          '['+IntToStr(MapStats[I,1])+']';
    end;
    if (MapStats[I,2]<>0) or (I>=20) then
      FrmEditMap.StrGid.Cells[Col,2]:=IntToStr(MapStats[I,2])+'%';
  end;
end;

procedure TFrmEditMap.CheckBox1Click(Sender:TObject);
begin
  { Final 004AD37C. }
  Panel10.Visible:=CheckBox1.Checked;
  if Panel10.Visible then
  begin
    Panel4.Height:=125;
    DisplayMapStats;
  end
  else Panel4.Height:=60;
end;

procedure TFrmEditMap.StrGidDrawCell(Sender:TObject; ACol,ARow:Integer;
  Rect:TRect; State:TGridDrawState);
begin
  { Final 004ACE10: commodity bitmap headers followed by house symbols. }
  if ARow<>0 then Exit;
  if ACol<20 then
  begin
    if Assigned(SpBmp[index_sp(ACol)]) then
      StrGid.Canvas.Draw(Rect.Left+10,Rect.Top,SpBmp[index_sp(ACol)]);
  end
  else if ACol<=22 then
    if Assigned(Picbmp[44-(ACol-20)]) then
      StrGid.Canvas.Draw(Rect.Left+10,Rect.Top,Picbmp[44-(ACol-20)]);
end;

procedure TFrmEditMap.Button1Click(Sender:TObject);
var
  Base,CityList:Cardinal;
  Head,Next:Word;
  I,N:Integer;
  B:TMapBuilding;
  All,Houses,Keep:TMapBuildingList;
begin
  { Final 004A9D88 replaces the old ownership-transfer operation. }
  CityList:=CityJz+Cardinal(Ecity)*$9F8+$75C;
  if not ReadProcessMemory(GHandle,Pointer(CityList),@Base,4,tmpNum) then Exit;
  ReadProcessMemory(GHandle,Pointer(CityList+8),@Head,2,tmpNum);
  if not ReadBuildingChain(Base,Head,All) then Exit;
  for I:=0 to High(All) do
  begin
    ReadProcessMemory(GHandle,Pointer(Base+All[I]*8),@B,SizeOf(B),tmpNum);
    if B.Kind in [21..29] then
    begin N:=Length(Houses); SetLength(Houses,N+1); Houses[N]:=All[I]; end
    else
    begin N:=Length(Keep); SetLength(Keep,N+1); Keep[N]:=All[I]; end;
  end;
  StaBar.Panels[3].Text:='没有可删除的房屋';
  if (Length(Houses)=0) or (Length(Keep)=0) then Exit;
  WriteProcessMemory(GHandle,Pointer(CityList+8),@Keep[0],2,tmpNum);
  for I:=0 to High(Keep) do
  begin
    if I<High(Keep) then Next:=Keep[I+1] else Next:=$FFFF;
    WriteProcessMemory(GHandle,Pointer(Base+Keep[I]*8+4),@Next,2,tmpNum);
  end;
  N:=RemoveBuildings(Base,CityList,Houses,False);
  Read_DpCode(Ecity); Map_Display(112,0,240,113);
  StaBar.Panels[3].Text:='删除了'+IntToStr(N)+'所房屋';
end;

procedure TFrmEditMap.Button3Click(Sender:TObject);
var
  Base,CityList,TraderBase,Trader:Cardinal;
  Count,Owner,City:Byte;
  I,N:Integer;
  Head,Empty:Word;
  List:TMapBuildingList;
begin
  { Final 004AC1A4: remove other traders' factories and houses in this city. }
  CityList:=CityJz+Cardinal(Ecity)*$9F8+$75C;
  if not ReadProcessMemory(GHandle,Pointer(CityList),@Base,4,tmpNum) then Exit;
  if not ReadProcessMemory(GHandle,Pointer($71CE26),@Count,1,tmpNum) then Exit;
  if not ReadProcessMemory(GHandle,Pointer($71CE1C),@TraderBase,4,tmpNum) then Exit;
  Empty:=$FFFF; N:=0;
  for I:=0 to Integer(Count)-1 do
  begin
    Trader:=TraderBase+Cardinal(I)*$44C+$2C4;
    ReadProcessMemory(GHandle,Pointer(Trader),@Owner,1,tmpNum);
    ReadProcessMemory(GHandle,Pointer(Trader+2),@City,1,tmpNum);
    if (Owner=Player-1) or (City<>Ecity) then Continue;
    SetLength(List,0);
    ReadProcessMemory(GHandle,Pointer(Trader+10),@Head,2,tmpNum);
    if not ReadBuildingChain(Base,Head,List) then Exit;
    ReadProcessMemory(GHandle,Pointer(Trader+12),@Head,2,tmpNum);
    if not ReadBuildingChain(Base,Head,List) then Exit;
    if Length(List)=0 then Continue;
    WriteProcessMemory(GHandle,Pointer(Trader+10),@Empty,2,tmpNum);
    WriteProcessMemory(GHandle,Pointer(Trader+12),@Empty,2,tmpNum);
    Inc(N,RemoveBuildings(Base,CityList,List,True));
  end;
  Read_DpCode(Ecity); Map_Display(112,0,240,113);
  StaBar.Panels[3].Text:='删除了'+IntToStr(N)+'个对手建筑';
end;

procedure TFrmEditMap.checkMMpClick(Sender:TObject);
begin
  { Final 004AC980. }
  Panel7.Visible:=checkMMp.Checked;
end;

end.
