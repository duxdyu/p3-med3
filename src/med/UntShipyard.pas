unit UntShipyard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,Untpublic, ComCtrls, Grids, Buttons,math,StrUtils,
  Spin;

type
  TFrmShipyard = class(TForm)
    SBar: TStatusBar;
    Panel6: TPanel;
    Button2: TButton;
    ComBoxship: TComboBox;
    Button1: TButton;
    Panel16: TPanel;
    Panel3: TPanel;
    Panel1: TPanel;
    RGrpship: TRadioGroup;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label1: TLabel;
    Button4: TButton;
    Edit2: TEdit;
    Panel4: TPanel;
    Panel5: TPanel;
    Label2: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Panel10: TPanel;
    Edit3: TEdit;
    Edit4: TEdit;
    Button7: TButton;
    ComboBox1: TComboBox;
    Panel8: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    StrGidc: TStringGrid;
    Strgid: TStringGrid;
    ComboBox3: TComboBox;
    Button5: TButton;
    SpinEdit1: TSpinEdit;
    Button6: TButton;
    Button8: TButton;
    Panel2: TPanel;
    Edit1: TEdit;
    Button3: TButton;
    Panel7: TPanel;
    Button9: TButton;
    CheckBox1: TCheckBox;
    Button10: TButton;
    StrGid2: TStringGrid;
    Button11: TButton;
    Button12: TButton;
    CheckBox2: TCheckBox;
    Image1: TImage;
    Panel9: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ComBoxshipChange(Sender: TObject);
    procedure StrGidcClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure StrGidcDblClick(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);



  private
    { Private declarations }
    BattleShipCount: Integer;
    procedure RefreshBattleShips;
  public
    { Public declarations }
  end;


procedure FrmShipYard_init;


var
  FrmShipyard: TFrmShipyard;
  procedure Show_CityTK_ship;
  //procedure Read_madeshiping(city:byte);
  //procedure Read_CityTK(City:byte);
  //procedure Get_CLshipList(City:byte);

  
implementation
type
  TGameShipName = type AnsiString(936);
var
shipJb:array [0 .. 3 ] of byte;

CL:array[0..5] of integer;
ShipIndex:word;
HL:array [0 .. 3,0..23] of byte=
(($07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07),

($07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07),

($07,$07,$07,$07,$07,$07,$07,$07,$FF,$FF,$FF,$FF,
$FF,$FF,$FF,$FF,$07,$07,$07,$07,$07,$07,$07,$07),

($07,$07,$07,$07,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
$FF,$FF,$FF,$FF,$07,$07,$07,$07,$07,$07,$07,$07));

Rmadeship:array [0 .. 3,0..3,0..2 ] of integer=
    (((30000,42000,8550),(38000,53200,9100),(50000,64400,9640),(50000,70000,9640)),
    ((56000,78400,19110),(62000,86800,19500),(68000,95200,20670),(70000,98000,20670)),
    ((90000,126000,17280),(96000,134400,17220),(104000,145600,18150),(110000,154000,18150)),
    ((110000,154000,23628),(118000,165200,23700),(130000,182000,25440),(140000,196000,25440)));
RmadeCL:array [0..3,0 .. 3,0..4] of integer=
     (((14000,600,600,6000,4000),(18000,600,600,6000,4000),(22000,600,600,6000,4000),(22000,600,600,6000,4000)),
     ((24000,1000,1000,10000,6000),(28000,1000,1000,10000,6000), (32000,1000,1000,10000,6000), (32000,1000,1000,10000,6000)),
     ((36000,600,800,8000,8000),(40000,600,800,8000,8000),(44000,600,800,8000,8000),(44000,600,800,8000,8000)),
     ((60000,2000,2000,16000,10000),(69000,2000,2000,16000,10000),(78000,2000,2000,16000,10000),(78000,2000,2000,16000,10000)));

{$R *.dfm}


Function Get_Madeship_money(city,AshipLx:byte):word;
var
inDAta:word;
DZ:integer;
AEX,Amod:smallint;
const
MadeJG:array[0..3,0..3] of word=
((8550,9100,9640,9640),
(19110,19500,20670,20670),
(17280,17220,18150,18150),
(23628,23700,25440,25440));

begin
result:=MadeJG[AshipLx,shipjb[AshipLx]];
    DZ:=CityJz + $9F8 *city + $80C;
    ReadProcessMemory(GHandle, Pointer(DZ+14), Pointer(@inDAta),2,tmpNum);  //----价格浮动
    if inData<16256 then exit;

AEx:=(inDAta-16255) div 128;//乘方次数
Amod:=(inDAta-16255) mod 128;//返回余数
result:=MadeJG[AShipLx,shipJb[AShipLx]]+ceil((power(2,Aex)-1)+Amod*power(2,AEX)/128);
end;

//-----------------------------------------------------
function StringToHex(str: string): string;
var
   i : integer;
   s : string;
begin
   for i:=1 to length(str) do begin
       s := s + InttoHex(Integer(str[i]),2);
   end;
   Result:=s;
end;


//---------------------统计材料-----------------------------------------
procedure Get_CityCL(City:byte);
var
i,j,wy:word;
DZ,CLtemp:integer;

begin
//统计材料是否够
wy:=0;
fillchar(CL,sizeof(CL),0);
for i:=1 to  CLshipList[0] do
  begin
    DZ:= ShipJZ + CLshipList[i] * $180;

for j:=0 to 4 do
    begin
      case j of
        0:wy:=11;1:wy:=8;2:wy:=12;3:wy:=17;4:wy:=15;
      end;
       ReadProcessMemory(GHandle, Pointer(DZ+Wy*4+84),Pointer(@CLtemp),4,tmpNum);
       CL[j]:=CL[j]+CLtemp;
     end;
end;


if SWSDz[City]<>0 then
for j:=0 to 4 do
    begin
     case j of
       0:wy:=11;1:wy:=8;2:wy:=12;3:wy:=17;4:wy:=15;
     end;
     ReadProcessMemory(GHandle, Pointer(SWSDz[City]+wy*4+4), Pointer(@Cltemp),4,tmpNum);
     CL[j]:=CL[j]+CLtemp;
    end;
end;


//-----------------------------判断建造条件---------------------------------
Function Allow_MadeShip(city,shipLx:byte):byte;
var
i,madePoint,MaxShip:word;
AMoney,mmoney:integer;
begin
Result:=5;
Get_CityCL(City);

if shipJb[ShipLx]=255 then
   begin
    Result:=0;
    exit;
    end;

//判断最大地址是否可以建造
ReadProcessMemory(GHandle, Pointer($6DFC6A), Pointer(@madePoint),2,tmpNum); // 总造船指针
ReadProcessMemory(GHandle, Pointer($6DFC7c), Pointer(@MaxShip),2,tmpNum); // 最大造船数量
if  madepoint= $FFFF then
         begin
          Result:=1;
          exit;
          end;

//ReadProcessMemory(GHandle, Pointer(ShipJZ + madePoint * $180+6), Pointer(@madePoint),2,tmpNum);//--------------下一船只
if madepoint= MaxShip then
          begin
          Result:=2;
          exit;
          end;

//建造船只的船钱
mmoney:=Get_Madeship_money(City,shipLx);
AMoney:=Get_Money;
if  AMoney< mmoney then
    begin
       Result:=3;
       exit;
       end;

for i:=0 to 4 do
    begin
     AMoney:=RmadeCL[ShipLx,shipJb[ShipLx],i];
    if CL[i]<AMoney then
        begin
          Result:=4;
          exit;
        end;
   end;

end;

//-----------------------------------扣除材料---------------------------
procedure TakeOff_CL(city,ShipLx:byte);
var
MadeShipCL:array[0..4] of integer;
CLtemp,DZ,mmoney,AMoney:integer;
i,j,Wy:word;
begin
wy:=0;
for i:=0 to 4 do
      MadeShipCL[i]:=RmadeCL[ShipLx,shipJb[ShipLx],i];

for i:=1 to  CLshipList[0] do
  begin
    DZ:= ShipJZ + CLshipList[i] * $180;

    for j:=0 to 4 do
        begin
        case j of
           0:wy:=11;1:wy:=8;2:wy:=12;3:wy:=17;4:wy:=15;
         end;
        ReadProcessMemory(GHandle, Pointer(DZ+wy*4+84),Pointer(@CLtemp),4,tmpNum);
        if MadeShipCL[j]=0 then continue;

        if CLtemp<=MadeShipCL[j] then
           begin
             MadeShipCL[j]:=MadeShipCL[j]-CLtemp;
             CLtemp:=0;
           end
          else
            begin
               CLtemp:=CLtemp-MadeShipCL[j];
               MadeShipCL[j]:=0;

            end;
         writeprocessmemory(GHandle,Pointer(DZ+wy*4+84),Pointer(@Cltemp),4,tmpNum);
      end;//end for j
 end;//end for  i


DZ:= SWSDz[City]+4;
for j:=0 to 4 do
  begin
   case j of
     0:wy:=11;1:wy:=8;2:wy:=12;3:wy:=17;4:wy:=15;
   end;
   ReadProcessMemory(GHandle, Pointer(DZ+wy*4),Pointer(@CLtemp),4,tmpNum);
   if MadeShipCL[j]=0 then continue;
   if CLtemp<=MadeShipCL[j] then
      begin
      MadeShipCL[j]:=MadeShipCL[j]-CLtemp;
      CLtemp:=0;
       end
      else
       begin
         CLtemp:=CLtemp-MadeShipCL[j];
         MadeShipCL[j]:=0;
       end;
   writeprocessmemory(GHandle,Pointer(DZ+wy*4),Pointer(@Cltemp),4,tmpNum);
  end;//end for j

//建造船只的船钱
mmoney:=Get_Madeship_money(City,shipLx);
AMoney:=Get_Money;
Write_Money(AMoney-mmoney);
end;



//----------------造船厂级别--------------------------------
procedure Read_ShipYardJB(city:byte);
var
temp,IndustrialValue:integer;
k,i:word;
M:byte;
begin
temp:=Citydz[City] + $80C;
ReadProcessMemory(GHandle, Pointer(temp-$9E), Pointer(@k),2,tmpNum);
ReadProcessMemory(GHandle, Pointer($71CDC0+City), Pointer(@M),1,tmpNum);
ReadProcessMemory(GHandle,Pointer(temp+4),@IndustrialValue,4,tmpNum);
FrmShipyard.Panel14.Caption:='船厂工业值：'+IntToStr(IndustrialValue);
if IndustrialValue>$3BD080 then IndustrialValue:=$3BD080;
FrmShipyard.Panel17.Left:=IndustrialValue*FrmShipyard.Image1.Width div $3BD080+
  FrmShipyard.Image1.Left-5;
if k=0 then
   for i:=0 to 3 do
       begin
         shipJb[i]:=$FF;
         Frmshipyard.RGrpship.Items.Strings[i]:='不能建造';
       end
   else
       for i:=0 to 3 do
           begin
             ReadProcessMemory(GHandle, Pointer(temp+24+i), Pointer(@shipJb[i]),1,tmpNum); //--------四种船的级别
             if (M=9) or (M=31) or (M=39) then
                        shipJb[3]:=$FF;
            // if shipjb[i]<=3 then

             //Frmshipyard.RGrpship.Items.Strings[i]:=ShipLxName[i]+'  ['+inttostr(Get_Madeship_money(City,i))+']';
             Frmshipyard.RGrpship.Items.Strings[i]:=ShipLxName[i]+'  ['+inttostr(shipJb[i])+']';
             if shipJb[i]=255 then
                Frmshipyard.RGrpship.Items.Strings[i]:='不能建造';
           end;
end;


//----------------造船厂级别--------------------------------
procedure Read_ShipYardJB2(city:byte);
var
temp:integer;
k,M,i:word;
begin
temp:=Citydz[City] + $80C;
ReadProcessMemory(GHandle, Pointer(temp-$9E), Pointer(@k),2,tmpNum);
ReadProcessMemory(GHandle, Pointer($71CDC0+City), Pointer(@M),1,tmpNum);
for i:=0 to 3 do
  if k=0 then
     shipJb[i]:=$FF
     else
     begin
       ReadProcessMemory(GHandle, Pointer(temp+24+i), Pointer(@shipJb[i]),1,tmpNum); //--------四种船的级别
       if (M=9) or (M=31) or (M=39) then shipJb[3]:=$FF;
     end;
end;



//--------------返回正在建造的船只数量
Function Madeing_count(city:byte):byte;
var
temp:integer;
shipnext,k:word;
begin
temp:=Citydz[City] + $80C;
ReadProcessMemory(GHandle, Pointer(temp+16), Pointer(@shipnext),2,tmpNum);  //----------造船厂当前造船指针
k:=0;
while shipnext<>$FFFF do
  begin
    temp := ShipJZ + shipnext * $180;
    k:=k+1;
    ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@shipnext),2,tmpNum);//--------------下一船只
end;
Result:=k;
end;



//-----------------------读正在建造的船只----------------------------------
procedure Read_ShipMadeing(city:byte);
var
ZDnj,DQnj,ZDll,temp:integer;
Maoyize,shipLx:byte;
shipnext,k:word;
begin
Frmshipyard.Strgid.rowcount:=1;
temp:=Citydz[City] + $80C;
ReadProcessMemory(GHandle, Pointer(temp+16), Pointer(@shipnext),2,tmpNum);  //----------造船厂当前造船指针
k:=0;

while shipnext<>$FFFF do
begin
temp := ShipJZ + shipnext * $180;
ReadProcessMemory(GHandle, Pointer(temp), Pointer(@MaoYiZe),1,tmpNum);//-----------------船只主人
ReadProcessMemory(GHandle, Pointer(temp+14),Pointer(@shipLX), 1, tmpNum);//--------------船只类型
ReadProcessMemory(GHandle, Pointer(temp+16),Pointer(@ZDll), 4, tmpNum);//----------------船只最大容量
ReadProcessMemory(GHandle, Pointer(temp+20),Pointer(@ZDnj), 4, tmpNum);//----------------船只最大耐久
ReadProcessMemory(GHandle, Pointer(temp+24),Pointer(@DQnj), 4, tmpNum);//----------------船只当前耐久
k:=k+1;
with Frmshipyard.Strgid do
   begin
    rowcount:=k+1;
    Cells[0,k]:=inttostr(maoyize);
    Cells[1,k]:=ShipLxName[shipLX];
    Cells[2,k]:=inttostr(Zdll div 200);
    Cells[3,k]:=inttostr(ZDnj div 200);
    Cells[4,k]:=inttostr(round(DQnj/ZDnj*100))+'%';
    Cells[5,k]:=inttostr(shipnext);
   end;
ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@shipnext),2,tmpNum);//--------------下一船只
end;
end;


procedure Read_ShipMade(city:byte);
var
ZDnj,DQnj,ZDll,temp:integer;
Maoyize,shipLx:byte;
shipnext,k,SMax:word;
begin
Frmshipyard.Strgidc.rowcount:=1;
temp:=Citydz[City] + $80C;
ReadProcessMemory(GHandle, Pointer($6DFC6A), Pointer(@shipnext),2,tmpNum); // 总造船指针
ReadProcessMemory(GHandle, Pointer($6DFC7c), Pointer(@SMax),2,tmpNum); // 最大造船数量
k:=0;

while shipnext<>SMax do
begin
temp := ShipJZ + shipnext * $180;
k:=k+1;
    Frmshipyard.Strgidc.rowcount:=k+1;
    Frmshipyard.Strgidc.Cells[0,k]:=inttostr(shipnext);
    Frmshipyard.Strgidc.Cells[1,k]:=inttohex(temp,8);
ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@shipnext),2,tmpNum);//--------------下一船只
Frmshipyard.Strgidc.Cells[2,k]:=inttostr(shipnext);
end;

end;

//----------------------------显示港口停泊船只------------------------
procedure Show_CityTK_ship;
var
temp,ZDll,DqNJ,ZDnj,Amoney,Bmoney:integer;
shipLX,AshipJb:Byte;
i,k:Word;
Sjmoney:array [0 .. 3] of byte;


begin
Sjmoney[0]:=63;
Sjmoney[1]:=47;
Sjmoney[2]:=8;
Sjmoney[3]:=65;

for i:=1 to CLshipList[0]+1 do
  begin
      temp := ShipJZ + CLshipList[i] * $180;
       ReadProcessMemory(GHandle, Pointer(temp+14),Pointer(@shipLX), 1, tmpNum);//--------------船只类型
       ReadProcessMemory(GHandle, Pointer(temp+15),Pointer(@AshipJb), 1, tmpNum);//--------------船只级别
       ReadProcessMemory(GHandle, Pointer(temp+16),Pointer(@ZDll), 4, tmpNum);//----------------船只最大容量
       ReadProcessMemory(GHandle, Pointer(temp+20),Pointer(@ZDnj), 4, tmpNum);//----------------船只最大耐久
       ReadProcessMemory(GHandle, Pointer(temp+24),Pointer(@Dqnj), 4, tmpNum);//----------------船只最大耐久
       Amoney:=(ZDll+ZDnj)*20 div Sjmoney[shipLX];
       //Bmoney:=round(( ZDnj-Dqnj)*0.1597);
       with  FrmShipyard.StrGidc do
          begin
            k:=i;
            RowCount :=k;
            Cells [0,k]:= inttostr(CLshipList[i]); //'-----------------------------编号
            Cells [1,k]:=Get_String(temp + $160);//------------------------------船只名称
            Cells [2,k]:=ShipLxName[shipLX]; //--------------------------------船只类型
            Cells [3,k]:=inttostr(AshipJb);  //---------------------------------船只级别
            Cells [4,k]:=inttostr(Zdll div 200);//------------------------------船只最大容量
            Cells [5,k]:=inttostr(ZDnj div 200);//--------------------------------------船只耐久
            Cells [6,k]:=inttostr(Amoney);
           // Cells [7,k]:=inttostr(Bmoney);
            Cells [8,k]:=inttohex(temp,8);
           end;//end with
  end;
FrmShipyard.SBar.Panels[0].Text :='木材:'+inttostr(CL[0] div 2000)
                                  +'    布:'+inttostr(CL[1] div 200)
                                  +'    铁制品:'+inttostr(CL[2] div 200)
                                  +'    麻:'+inttostr(CL[3] div 2000)
                                  +'    沥青:'+inttostr(CL[4] div 200);
end;



//----------------------建造船只---------------------------------------
procedure Made_ship(City,ShipLx:byte);
var
madedate,temp:integer;
shipZT,stemp1,jb,town:Byte;
madePoint,PCitymade,madePoint1, i,j,shipPre,shipnext,shipLast,stemp2,stemp3:Word;
mmoney:word;
AMoney,stemp4:integer;
AshipName:TGameShipName;
begin
if shipJb[shipLX]=$FF then exit;
//目标进程句柄   读取数据的起始地址  存放数据的缓存区地址  要读取的字节数  实际读取数存放地址
stemp1:=$FF;
stemp2:=$FFFF;
stemp3:=$7FFF;
stemp4:=0;

MaoYiZe:=Player-1;
FrmShipyard.Sbar.Panels[0].Text :='';
FrmShipyard.Sbar.Panels[1].Text :='';
FrmShipyard.Sbar.Panels[2].Text :='';

ReadProcessMemory(GHandle, Pointer($6DFC6A), Pointer(@madePoint),2,tmpNum); // 总造船指针
ReadProcessMemory(GHandle, Pointer($71CDBC), Pointer(@madedate),4,tmpNum); //--------日期
temp:=PlaysJz +MaoYiZe*$650+ 14;
ReadProcessMemory(GHandle, Pointer(temp), Pointer(@shipPre),2,tmpNum);//-------贸易家船只序列开始船只序号
writeprocessmemory(GHandle,Pointer(temp),Pointer(@madePoint),2,tmpNum); //----更改贸易家船只序列开始船只序号
ReadProcessMemory(GHandle, Pointer(temp+11), Pointer(@town),1,tmpNum);//-------玩家家乡


shipLast:=0;
temp:=CityDZ[City] + $80C;
ReadProcessMemory(GHandle, Pointer(temp+16), Pointer(@PCitymade),2,tmpNum);//----造船厂当前造船指针
if PCitymade=$FFFF then
     writeprocessmemory(GHandle,Pointer(temp+16),Pointer(@madePoint),2,tmpNum)//如果是关闭，则打开造船厂指针
   else
    begin
      shipnext:=PCitymade;
      while shipnext<>$FFFF do
       begin
         temp := ShipJZ + shipnext * $180;
         shipLast:=shipnext;
         ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@shipnext),2,tmpNum);//下一船只
       end;
        temp := ShipJZ + shipLast* $180;
        writeprocessmemory(GHandle,Pointer(temp+6),Pointer(@madePoint),2,tmpNum);//---更改上一条船的下一造船建造序号
    end;


    temp := ShipJZ + madePoint * $180;
    ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@madePoint1),2,tmpNum); // 读取下一个总造船指针
    writeprocessmemory(GHandle,Pointer($6DFC6A),Pointer(@madePoint1),2,tmpNum);////写入下一个总造船指针


    for i:=0 to 95 do
        writeprocessmemory(GHandle,Pointer(temp+i*4),Pointer(@stemp4),4,tmpNum); //数据清0


    writeprocessmemory(GHandle,Pointer(temp),Pointer(@MaoYiZe),1,tmpNum);//-------------船只主人
    writeprocessmemory(GHandle,Pointer(temp+4),Pointer(@shipPre),2,tmpNum);//-----------写入上一只船只编号
    writeprocessmemory(GHandle,Pointer(temp+6),Pointer(@stemp2),2,tmpNum);//----------下一只船只为FFFF
    writeprocessmemory(GHandle,Pointer(temp+8),Pointer(@stemp2),2,tmpNum);
    writeprocessmemory(GHandle,Pointer(temp+14),Pointer(@shipLX),1,tmpNum);//-----------------船只类型
    jb:=0;
    writeprocessmemory(GHandle,Pointer(temp+15),Pointer(@jb),1,tmpNum);//-----------------船只级别
    writeprocessmemory(GHandle,Pointer(temp+16),Pointer(@Rmadeship[shipLX,shipJb[shipLX],0]),4,tmpNum);//---船只最大容量
    writeprocessmemory(GHandle,Pointer(temp+20),Pointer(@Rmadeship[shipLX,shipJb[shipLX],1]),4,tmpNum);//---船只最大耐久
    writeprocessmemory(GHandle,Pointer(temp+30),Pointer(@CityZB[City].x),2,tmpNum);//-----------X坐标
    writeprocessmemory(GHandle,Pointer(temp+34),Pointer(@CityZB[City].y),2,tmpNum);//-----------Y坐标
    for j:=0 to 2 do
    writeprocessmemory(GHandle,Pointer(temp+55+j),Pointer(@City),1,tmpNum);//-------------------船只停靠地
    writeprocessmemory(GHandle,Pointer(temp+58),Pointer(@stemp2),2,tmpNum);//----------FFFF
    if FrmShipYard.CheckBox1.Checked then
       writeprocessmemory(GHandle,Pointer(temp+64),Pointer(@SS[shipLX]),2,tmpNum);//-------水手数量

    writeprocessmemory(GHandle,Pointer(temp+66),Pointer(@stemp2),2,tmpNum); //----------FFFF
    writeprocessmemory(GHandle,Pointer(temp+68),Pointer(@madedate),4,tmpNum);//-----------------日期
    mmoney:=Rmadeship[shipLX,shipJb[shipLX],2];
    writeprocessmemory(GHandle,Pointer(temp+72),Pointer(@mmoney),2,tmpNum);//-------------------造船所用的钱
    writeprocessmemory(GHandle,Pointer(temp+76),Pointer(@madedate),4,tmpNum);//-----------------日期
    writeprocessmemory(GHandle,Pointer(temp+80),Pointer(@stemp2),2,tmpNum);
    writeprocessmemory(GHandle,Pointer(temp+82),Pointer(@stemp2),2,tmpNum);
    writeprocessmemory(GHandle,Pointer(temp+306),Pointer(@stemp2),2,tmpNum);//路线偏移

    shipZT:=14;
    writeprocessmemory(GHandle,Pointer(temp+308),Pointer(@shipZT),1,tmpNum);//------------------船只状态
    writeprocessmemory(GHandle,Pointer(temp+314),Pointer(@town),1,tmpNum); //-------------------家乡城市
    writeprocessmemory(GHandle,Pointer(temp+315),Pointer(@City),1,tmpNum); //-------------------建造城市
    writeprocessmemory(GHandle,Pointer(temp+345),Pointer(@stemp1),1,tmpNum);
     for i:=0 to 23 do                                                         //-------------------武器位
    writeprocessmemory(GHandle,Pointer(temp+316+i),Pointer(@HL[shiplx,i]),1,tmpNum);

    writeprocessmemory(GHandle,Pointer(temp+349),Pointer(@stemp1),1,tmpNum);
    stemp3:=stemp3-shipLX;
    writeprocessmemory(GHandle,Pointer(temp+350),Pointer(@stemp3),2,tmpNum);//-------------自动命名
    if FrmShipyard.edit2.Text <>'' then
       AshipName:=FrmShipyard.edit2.Text
       else
       AshipName:=ShipLxName[shipLX];
    for i:=1 to length(AshipName) do
    writeprocessmemory(GHandle,Pointer(temp+351+i),
           Pointer(@AshipName[i]),1,tmpNum); //-----------船只名称
   // Amoney:=Get_Money;
   // AMoney:=AMoney-Mmoney;                                                     //写入金钱
    //Write_Money(AMoney);

   // FrmShipyard.Sbar.Panels[0].Text :='下一艘船地址：'+inttohex(ShipJZ + madePoint * $180,8);
   // FrmShipyard.Sbar.Panels[1].Text :='下一艘船编号：'+inttostr(madePoint);

end;


//---------------------------切换城市-------------------------
procedure Chang_City(city:byte);

begin
Read_ShipYardJB(city);
Read_ShipMadeing(city);

Get_CityTK_ship(City);//依靠城市的船只;
Get_CityCL(City);

Show_CityTK_ship;
FrmShipyard.RefreshBattleShips;

//Read_ShipMade(city);
end;


//------------------------------
procedure FrmShipYard_init;
var
i:word;
city:byte;
begin

with FrmShipyard do
begin
combobox1.Items.Clear;
combobox3.Items.Clear;
for i:=0 to 3 do
  begin
  combobox1.Items.Add(ShipLxName[i]);
  combobox3.Items.Add(ShipLxName[i]);
  end;
combobox1.ItemIndex :=1;
combobox3.ItemIndex :=1;
ComBoxship.Items.Clear;
for i:=0 to CityCunt-1 do ComBoxship.Items.Add(IntToStr(i)+CityName[i]);
ReadProcessMemory(GHandle, Pointer($6e2f2c), Pointer(@city),1,tmpNum);
if city>40 then city:=0;
Home:=City;
ComBoxship.ItemIndex:=city;
end;//end with
Chang_City(city);
end;

//--------------------------------------------------------------
procedure TFrmShipyard.FormCreate(Sender: TObject);
begin
strgid.Cells[0,0]:='所有者';
strgid.Cells[1,0]:='船型';
strgid.Cells[2,0]:='容量';
strgid.Cells[3,0]:='耐久';
strgid.Cells[4,0]:='完成';
strgid.colwidths[0]:=50;

strgidc.Cells[0,0]:='编号';
strgidc.Cells[1,0]:='船名';
strgidc.Cells[2,0]:='类型';
strgidc.Cells[3,0]:='级别';
strgidc.Cells[4,0]:='最大容量';
strgidc.Cells[5,0]:='最大耐久';
strgidc.Cells[6,0]:='升级金额';
//strgidc.Cells[7,0]:='维修金额';
strgidc.Cells[8,0]:='地址';
strgidc.ColWidths[0]:=30;
strgidc.ColWidths[1]:=80;
strgidc.ColWidths[3]:=30;

BattleShipCount:=0;
StrGid2.Cells[0,0]:='编号';
StrGid2.Cells[1,0]:='船名';
StrGid2.Cells[2,0]:='水手';
StrGid2.Cells[3,0]:='船长';
StrGid2.Cells[4,0]:='刀';
end;
//------------------------------------下一城市------------------------------
procedure TFrmShipyard.Button1Click(Sender: TObject);
begin
if comboxship.ItemIndex < Citycunt-1 then
comboxship.ItemIndex:=comboxship.ItemIndex+1
else
comboxship.ItemIndex:=0;
Chang_City(comboxship.ItemIndex);
end;
//-----------------------------上一城市---------------------------
procedure TFrmShipyard.Button2Click(Sender: TObject);
begin
if comboxship.ItemIndex>0 then
comboxship.ItemIndex:=comboxship.ItemIndex-1
else
comboxship.ItemIndex:=Citycunt-1;
Chang_City(comboxship.ItemIndex);
end;



procedure TFrmShipyard.Button7Click(Sender: TObject);
var
i,j,k:word;
AshipLx,T:byte;
DZ:integer;

string1,string2:string;
stringT:TGameShipName;
begin
if edit4.Text ='' then
   k:=0
   else
   k:=Get_Num(edit4.Text);
T:=0;
for i:=1 to  CLshipList[0] do
  begin
   DZ := ShipJZ + CLshipList[i] * $180;
       ReadProcessMemory(GHandle, Pointer(DZ+14),Pointer(@AshipLX), 1, tmpNum);//--------------船只类型
   if  AshipLX<>combobox1.ItemIndex  then continue;
       if edit3.Text ='' then
           string1:=shipLxname[AshipLX]
           else
           string1:=edit3.Text;
       string2:=rightstr('000' +inttostr(k), 3);
       stringT:=string1+' '+string2;
       for j:=1 to 32 do
           writeprocessmemory(GHandle,Pointer(Dz+351+j), Pointer(@T),1,tmpNum);
       for j:=1 to length(stringT) do
         writeprocessmemory(GHandle,Pointer(Dz+351+j), Pointer(@stringT[j]),1,tmpNum); //-----------船只名称
       k:=k+1;
end;
Get_CityTK_ship(Home);;
end;



procedure TFrmShipyard.Button4Click(Sender: TObject);
var
i:word;
City,shipLX,SL,ERRCode:byte;
ERRStr:array[0..6] of string;
begin
ERRstr[0]:='不能建造';
ERRstr[1]:='造船指针未打开';
ERRstr[2]:='造船指针上限,请手动造一艘船';
ERRstr[3]:='金钱不足';
ERRstr[4]:='材料不足';
ERRstr[5]:=' ';
ERRstr[6]:='出错';

city:=comboxship.ItemIndex;
shipLx:=Rgrpship.ItemIndex ;
SL:=SpinEdit1.Value;
//Get_CityTK(City);//进入城市的船只;
for i:=0 to SL-1 do
    begin
       Get_CityCL(City);
       ERRCode:=Allow_MadeShip(City,ShipLx);
       Sbar.Panels[1].Text :=ERRstr[Errcode];
       if ERRCode<>5 then break;
        Made_ship(city,ShipLx);//建造船只
        TakeOff_CL(city,shipLx);//扣除材料
    end;
Sbar.Panels[2].Text :='签定了'+inttostr(i)+'艘船';

Get_CityCL(City);//计算城市金钱材料，并返回是否可以建造

Read_ShipMadeing(city);
end;


//--------------------------------船只复原---------------------------------
procedure TFrmShipyard.Button8Click(Sender: TObject);
var
j:word;
temp,AHL,zdLL:integer;
k,AshipLx,AshipJb:byte;
RL:array[0..3] of word;
begin
k:=0;
RL[0]:=30; RL[1]:=50;RL[2]:=80;RL[3]:=100;

   temp := ShipJZ + shipindex * $180;
   ReadProcessMemory(GHandle, Pointer(temp+15),Pointer(@AshipJb), 1, tmpNum);//船只级别
   if  AshipJb=0 then exit;
   ReadProcessMemory(GHandle, Pointer(temp+288),Pointer(@AHL), 4, tmpNum);
   if AHL>0 then
      begin
        Sbar.Panels[0].Text :='请移除武器';
        exit;
      end;
     ReadProcessMemory(GHandle, Pointer(temp+14),Pointer(@AshipLX), 1, tmpNum);//船只类型
  k:=0;
     writeprocessmemory(GHandle,Pointer(temp+15),Pointer(@K),1,tmpNum);
   for j:=0 to 23 do
       writeprocessmemory(GHandle,Pointer(temp+316+j),Pointer(@HL[AshipLx,j]),1,tmpNum);
       ReadProcessMemory(GHandle, Pointer(temp+16),Pointer(@ZDll), 4, tmpNum);
       ZDLL:=ZDLL+RL[AshipLx]*AshipJb*200;
       writeprocessmemory(GHandle,Pointer(temp+16),Pointer(@ZDLL),4,tmpNum);//---船只最大容量
       ZDLL:=ceil(ZDll*1.4);
       writeprocessmemory(GHandle,Pointer(temp+20),Pointer(@ZDLL),4,tmpNum);//---船只最大耐久
       writeprocessmemory(GHandle,Pointer(temp+24),Pointer(@ZDLL),4,tmpNum);//---船只头前耐久
  Sbar.Panels[0].Text :='已复原'+StrGidc.Cells[1,strgidc.Row];
  Get_CityTK_ship(comboxship.ItemIndex);
  show_CityTK_ship;
end;


//--------------------------船只改型------------------------------------
procedure TFrmShipyard.Button5Click(Sender: TObject);
var
Lx:byte;
DZ:integer;
begin
Lx:=combobox3.ItemIndex ;
DZ:= ShipJZ + shipindex * $180;
writeprocessmemory(GHandle,Pointer(DZ+14),Pointer(@Lx),1,tmpNum);
Get_CityTK_ship(comboxship.ItemIndex);
show_CityTK_ship;
end;

//-------------------------------船只升级-------------------------------
procedure TFrmShipyard.Button6Click(Sender: TObject);
var
i,k:word;
DZ,Pmoney,LL,Nj,Amoney:integer;
begin
k:=0;

for i:=1 to  CLshipList[0] do
  begin
   DZ:= ShipJZ + CLshipList[i] * $180;
   ReadProcessMemory(GHandle, Pointer(DZ+16),Pointer(@LL), 4, tmpNum);//船只最大容量
   ReadProcessMemory(GHandle, Pointer(DZ+20),Pointer(@Nj), 4, tmpNum);//船只最大耐久
   if (LL>$88B80)  then continue;
   Amoney:=strtoint(StrGidc.Cells[6,i]);
   Pmoney:=Get_Money;
     Pmoney:=Pmoney-Amoney;
        if Pmoney<0 then
        begin
          Sbar.Panels[0].Text :='金钱不足';
          exit;
        end;

     Write_Money(Pmoney);

   LL:=LL*2;Nj:=Nj*2;
   writeprocessmemory(GHandle,Pointer(DZ+16),Pointer(@LL),4,tmpNum);//---船只最大容量
   writeprocessmemory(GHandle,Pointer(DZ+20),Pointer(@NJ),4,tmpNum);//---船只最大耐久
   writeprocessmemory(GHandle,Pointer(DZ+24),Pointer(@NJ),4,tmpNum);//---船只头前耐久
   k:=k+1;
  end;
Sbar.Panels[0].Text :='已升级'+inttostr(k)+'只船';
Get_CityTK_ship(comboxship.ItemIndex);
show_CityTK_ship;
end;


procedure TFrmShipyard.ComBoxshipChange(Sender: TObject);
begin
Chang_City(comboxship.ItemIndex);
end;






procedure TFrmShipyard.StrGidcClick(Sender: TObject);
begin
if StrGidc.Row=0 then exit;
ShipIndex :=strtoint(StrGidc.Cells[0,StrGidc.Row]);
edit1.Text :=StrGidc.Cells[1,StrGidc.Row];

end;

procedure TFrmShipyard.Button3Click(Sender: TObject);
var
i:word;
Nstr:TGameShipName;
DZ:integer;
A:byte;
begin
if edit1.Text ='' then exit;
Nstr:=edit1.Text;
DZ := ShipJZ +Shipindex * $180;
A:=0;
for i:=1 to 32 do
    writeprocessmemory(GHandle,Pointer(Dz+351+i), Pointer(@A),1,tmpNum); //船只名称清除
for i:=1 to length(Nstr) do
    writeprocessmemory(GHandle,Pointer(Dz+351+i), Pointer(@Nstr[i]),1,tmpNum); //船只名称
Get_CityTK_ship(comboxship.ItemIndex);
show_CityTK_ship;
end;

procedure TFrmShipyard.Button9Click(Sender: TObject);
var
DZ,Pmoney,LL,Nj,Amoney:integer;
begin

   DZ:= ShipJZ + shipindex * $180;
   ReadProcessMemory(GHandle, Pointer(DZ+16),Pointer(@LL), 4, tmpNum);//船只最大容量
   ReadProcessMemory(GHandle, Pointer(DZ+20),Pointer(@Nj), 4, tmpNum);//船只最大耐久
   if (LL>$88B80)  then exit;
   Amoney:=strtoint(StrGidc.Cells[6,StrGidc.row]);
   Pmoney:=Get_Money;
   if Pmoney<Amoney then
      exit
      else
     Pmoney:=Pmoney-Amoney;
     if Pmoney<0 then
        begin
          Sbar.Panels[0].Text :='金钱不足';
          exit;
        end;
     Write_Money(Pmoney);

   LL:=LL*2;Nj:=Nj*2;
   writeprocessmemory(GHandle,Pointer(DZ+16),Pointer(@LL),4,tmpNum);//---船只最大容量
   writeprocessmemory(GHandle,Pointer(DZ+20),Pointer(@NJ),4,tmpNum);//---船只最大耐久
   writeprocessmemory(GHandle,Pointer(DZ+24),Pointer(@NJ),4,tmpNum);//---船只头前耐久

Sbar.Panels[0].Text :='已升级所选船只船';
Get_CityTK_ship(comboxship.ItemIndex);
show_CityTK_ship;
end;

procedure TFrmShipyard.Button10Click(Sender: TObject);
var
DZ,Pmoney,LL,Nj,Amoney,i:integer;
begin

for i:=1 to  CLshipList[0] do
  begin
   Pmoney:=Get_Money;
   Amoney:=strtoint(StrGidc.Cells[6,i]);
   Pmoney:=Pmoney-Amoney;
   if Pmoney<0 then
       begin
          Sbar.Panels[0].Text :='金钱不足';
          exit;
        end;
   DZ:= ShipJZ + CLshipList[i] * $180;
   ReadProcessMemory(GHandle, Pointer(DZ+20),Pointer(@Nj), 4, tmpNum);//船只最大耐久
   Write_Money(Pmoney);
   writeprocessmemory(GHandle,Pointer(DZ+24),Pointer(@NJ),4,tmpNum);//---船只头前耐久
end;
end;

// MED3 004B0B34: refresh the selected battle-ship list.
procedure TFrmShipyard.RefreshBattleShips;
var
  I, DZ, MaxNJ, CurrentNJ: Integer;
  Count: Word;
begin
  for I:=1 to BattleShipCount do
  begin
    DZ:=ShipJZ+StrToInt(StrGid2.Cells[0,I])*$180;
    ReadProcessMemory(GHandle,Pointer(DZ+$14),@MaxNJ,4,tmpNum);
    ReadProcessMemory(GHandle,Pointer(DZ+$18),@CurrentNJ,4,tmpNum);
    StrGid2.Cells[5,I]:=IntToStr(Round(CurrentNJ/MaxNJ*100))+'%';
    ReadProcessMemory(GHandle,Pointer(DZ+$40),@Count,2,tmpNum);
    StrGid2.Cells[2,I]:=IntToStr(Count);
    // The final binary displays the sailor count in both columns.
    StrGid2.Cells[4,I]:=IntToStr(Count);
    ReadProcessMemory(GHandle,Pointer(DZ+$42),@Count,2,tmpNum);
    if Count=$FFFF then StrGid2.Cells[3,I]:=''
    else StrGid2.Cells[3,I]:=IntToStr(Count);
  end;
end;

// MED3 004B0834: append the current docked ship, then refresh all listed ships.
procedure TFrmShipyard.StrGidcDblClick(Sender: TObject);
begin
  if StrGidc.Row=0 then Exit;
  Inc(BattleShipCount);
  StrGid2.RowCount:=BattleShipCount+1;
  StrGid2.Cells[0,BattleShipCount]:=StrGidc.Cells[0,StrGidc.Row];
  StrGid2.Cells[1,BattleShipCount]:=StrGidc.Cells[2,StrGidc.Row];
  RefreshBattleShips;
end;

// MED3 004B0920: retain a blank data row after clearing the list.
procedure TFrmShipyard.Button11Click(Sender: TObject);
var
  I: Integer;
begin
  BattleShipCount:=0;
  StrGid2.RowCount:=2;
  for I:=0 to 5 do StrGid2.Cells[I,1]:='';
end;

// MED3 004B0970: crew/swords, durability and disabled weapon slots.
procedure TFrmShipyard.Button12Click(Sender: TObject);
var
  I, J, DZ, Capacity, MaxNJ: Integer;
  Crew: Word;
  Weapon, Replacement: Byte;
begin
  if BattleShipCount=0 then Exit;
  Replacement:=5;
  for I:=1 to BattleShipCount do
  begin
    DZ:=ShipJZ+StrToInt(StrGid2.Cells[0,I])*$180;
    ReadProcessMemory(GHandle,Pointer(DZ+$10),@Capacity,4,tmpNum);
    Crew:=Capacity div 2000;
    WriteProcessMemory(GHandle,Pointer(DZ+$40),@Crew,2,tmpNum);
    WriteProcessMemory(GHandle,Pointer(DZ+$154),@Crew,2,tmpNum);
    ReadProcessMemory(GHandle,Pointer(DZ+$14),@MaxNJ,4,tmpNum);
    WriteProcessMemory(GHandle,Pointer(DZ+$18),@MaxNJ,4,tmpNum);
    for J:=0 to 23 do
    begin
      ReadProcessMemory(GHandle,Pointer(DZ+$13C+J),@Weapon,1,tmpNum);
      if Weapon=$FF then
        WriteProcessMemory(GHandle,Pointer(DZ+$13C+J),@Replacement,1,tmpNum);
    end;
  end;
  RefreshBattleShips;
end;

end.
