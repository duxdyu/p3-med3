unit Untpublic;

interface
uses  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
       TLhelp32,DateUtils,math,MedMemoryText,MedFinalEconomy;


    type
  ZuoBiao=record
  x,y:integer;
   end;

  type
   BackTime=record
   Tyear:integer;
   Tmonth:integer;
   Tday:integer;
   Thour:integer;
   end;
 type
 ShipCaptnNL=record
  M:byte;
  H:byte;
  Z:byte;
  end;
 type ShipCaption=record//船长属性
     bianhao:word;
     nianling:byte;
     maoyi:byte;
     zandou:byte;
     rixin:byte;
end;

var

GHandle,tmpNum:longword;//游戏进程句柄
CityName:array[0..39] of string; //城市名称
CityMarker:array[0..39] of Byte; // final: 0=no office, 1=office, 2=home town
PopNamex:array[0..150] of string;
PopNameM:array[0..150] of string;
PopName:array[0..150] of string;
PopCaption:array[0..7] of string;
DzhcityName:array[0..30] of string;
DzhCityLx:array[0..2] of string;
PeopCap:array[0..8]of string;
BuildName:array[0..109] of string;//终版预留110个建筑名字

SpBmp:array[0..39] of TBitmap;//终版创建40个商品/状态位图


Sccj:array[0..39,0..19] of byte;//40*20个采集数据
Ylcj:array[0..39,0..19] of byte;//40*20个采集数据
CityGC:array[0..39,0..19] of double;
CityCZ:array[0..39,0..19] of double;

//CityZB:array[0..39,0..1] of integer; //城市坐标
Haidaoship:array[0..99] of Integer;//定义100个海盗船地地址
CityDZ:array[0..39] of Integer; //城市地址 事务所
SwsDz:array[0..39] of Integer; //城市地址 事务所
SwsDz2:array[0..150] of Integer;
CLshipList:array[0..2000] of word;

CScxSL:array [0..19] of Integer;//城市物品数量。
FinalBalance: TFinalBalance;
CityCunt,MaoYiZe,Player:Byte;  // 城市总数   船只主人 玩家编号
CityJz,SWSjz,ShipJdjz,ShipJZ,PlaysJz:integer;//城市基址 事务所基址

Arestart:word;//重启次数
Swscunt:word;
Numtmp:Cardinal;//longword;
AButton,CAButton:word;
picMaxx,picMaxy:integer;
hangMax,lieMax,Home,Ecity:byte;
Strmouseup:boolean;
DelectOk:boolean;//鼠标滚动事件
MouseHook: HHOOK;
Poped,FrmMainS:Boolean;

TextOutColor:Cardinal;

lppe:TProcessEntry32;
hSnapshot:THandle;
Found:boolean;

  CityZB:array[0..39] of ZuoBiao;


SS:array[0..3] of word=(5,8,10,12);
ShipLxName:array [0 .. 4 ] of string= ('史奈卡', '克雷尔', '克  格','霍尔克','未知' );
SpName:array [0 .. 19 ] of string;

function FindProcess(aFileName: String): dword;
function ShipZT_To_string(ZT:byte):ansistring;
Function Time_To_String(Funtime:longword):string;
function Get_string(PPoint:dword):string;
Function BHtoLX(BH:Integer):String;
Function back_LW(Gday:byte;Gmonth:byte):boolean;stdcall;
Function Get_Money:integer;

procedure Write_Money(AMoney:integer);
procedure Game_init;
procedure Get_CSCx(index,Atime,Selet:byte);
procedure FinalCityBalance(City, Days: Byte);
procedure Get_PeopleName(JZ:integer);
procedure People_Name;


Function index_sp(B:byte):byte;
Function sp_index(B:byte):byte;
function Get_BZLX(id:byte):word;
function  Get_Num(str:string):integer;
function WPower(a,x:integer):integer;
function BPower(a,x:byte):byte;
function  Get_Jiema(Num:Smallint):single;
procedure Get_CityTK_ship(City:byte);

implementation

//------------------------乘方函数-----------------
function BPower(a,x:byte):byte;
var
i,B:byte;
begin
if (a=0) then
   begin
     result:=0;
       exit;
   end;

if (x=0) then
    begin
     result:=1;
     exit;
    end;

b:=1;
for i:=0 to x-1 do  b:=b*a;
result:=b;
end;


//------------------------乘方函数-----------------
function WPower(a,x:integer):integer;
var
i,B:word;
begin
if (a=0) then
   begin
     result:=0;
       exit;
   end;

if (x=0) then
    begin
     result:=1;
     exit;
    end;

B:=1;
for i:=0 to x-1 do  b:=b*a;
result:=b;
end;




Function index_sp(B:byte):byte;
begin
Case B of
0:Result:=8;//布
1:Result:=0;//稻谷
2:Result:=5;// 蜂蜜
3:Result:=10;// 鲸油
4:Result:=15;//沥青
5:Result:=17;//麻
6:Result:=11;//木材
7:Result:=3;//啤酒
8:Result:=13;//皮革
9:Result:=7;//葡萄酒
10:Result:=1;//肉
11:Result:=16;//生铁
12:Result:=9;//兽皮
13:Result:=18;//陶器
14:Result:=12;//铁制品
15:Result:=6;//香料
16:Result:=4;//盐
17:Result:=14;//羊毛
18:Result:=2;//鱼
19:Result:=19;//砖
else
Result:=0;
end;
end;

Function sp_index(B:byte):byte;
begin
Case B of
8:Result:=0;//布
0:Result:=1;//稻谷
5:Result:=2;// 蜂蜜
10:Result:=3;// 鲸油
15:Result:=4;//沥青
17:Result:=5;//麻
11:Result:=6;//木材
3:Result:=7;//啤酒
13:Result:=8;//皮革
7:Result:=9;//葡萄酒
1:Result:=10;//肉
16:Result:=11;//生铁
9:Result:=12;//兽皮
18:Result:=13;//陶器
12:Result:=14;//铁制品
6:Result:=15;//香料
4:Result:=16;//盐
14:Result:=17;//羊毛
2:Result:=18;//鱼
19:Result:=19;//砖
else
Result:=0;
end;
end;




function  Get_Jiema(Num:Smallint):single;
var
AEX,Amod:smallint;
A1,An,A2:single;
N:word;
begin
result:=0;

if Num<=0 then exit;
Aex:=120*128;
Num:=Num-Aex;

if Num<=0 then   exit;
//if Num<Aex then result:=0;
//   begin
//   result:=0;
//   exit;
//   end;
//Num:=Num-Aex;

Amod:=Num mod 128;//返回余数
AEx:=Num div 128;//乘方次数
A1:=power(2,-7);
An:=power(2,Aex-8);
A2:=(Amod/128)*power(2,Aex-7);
result:=2*An-A1+A2;


//  else

  // AEx:=(abs(Num)-16256) div 128;//乘方次数
   //Amod:=(abs(Num)-16256) mod 128;//返回余数
  // result:=0-((power(2,Aex)-1)+Amod*power(2,AEX-7))/128;
   // result:=(Num+15360) ;
// end;

end;



function  Get_Num(str:string):integer;
var
i:Integer;
begin
Result:=0;
if str='' then exit;
for  i:=1 to Length(str) do
       if not (str[i] in ['0'..'9']) then exit;
result:=strtoint(str);
end;


function Get_BZLX(id:byte):word;
begin
case id of
0, 1, 2, 11, 14, 16, 17, 19 :result := 2000;
3..10,15,18:result := 200;
else
  result := 200;
end;
end;

// Terminal MED 00478810: current + under-construction owned factories.
procedure FinalCityBalance(City, Days: Byte);
var
  Counts: TFinalFactoryCounts;
  PopulationUse, CityOutput, CityUse, OfficeOutput, OfficeUse: TFinalGoodsValues;
  Buildings, Entry: Cardinal;
  Next, Following: Word;
  Kind, Owner, Special: Byte;
  G, Steps: Integer;
  procedure ReadAt(Address: Cardinal; var Buffer; Size: Cardinal);
  var Received: NativeUInt;
  begin
    if not ReadProcessMemory(GHandle, Pointer(Address), @Buffer, Size, Received) then
      RaiseLastOSError;
    if Received <> Size then raise EReadError.Create('Incomplete economy data read');
  end;
  procedure CountChain(Index: Word; RequireOwner: Boolean);
  var K: Integer;
  begin
    Steps := 0;
    while Index <> $FFFF do
    begin
      if Steps >= $10000 then raise EReadError.Create('Cyclic building list');
      Inc(Steps);
      Entry := Buildings + Cardinal(Index)*8;
      ReadAt(Entry+4, Following, 2);
      ReadAt(Entry+3, Kind, 1);
      if RequireOwner then ReadAt(Entry+2, Owner, 1);
      K := Integer(Kind)-4;
      if (K >= 0) and (K <= 16) and ((not RequireOwner) or (Owner=Player-1)) then
      begin
        if (Special=4) and (K=1) then K := 17;
        Inc(Counts[K]);
      end;
      Index := Following;
    end;
  end;
begin
  if (City > High(CityDZ)) or (City >= CityCunt) then
    raise EArgumentOutOfRangeException.Create('Invalid economy city');
  FillChar(Counts, SizeOf(Counts), 0);
  FillChar(OfficeOutput, SizeOf(OfficeOutput), 0);
  FillChar(OfficeUse, SizeOf(OfficeUse), 0);
  ReadAt(Cardinal(CityJz)+Cardinal(City)*$9F8+$75C, Buildings, 4);
  ReadAt(Cardinal(CityJz)+Cardinal(City)*$9F8+$762, Next, 2);
  ReadAt(Cardinal(CityDZ[City])+$2CD, Special, 1);
  CountChain(Next, True);
  if SwsDz[City] > 0 then
  begin
    ReadAt(Cardinal(SwsDz[City])+$2CE, Next, 2);
    CountChain(Next, False);
  end;
  for G := 0 to 19 do
  begin
    ReadAt(Cardinal(CityDZ[City])+$310+Cardinal(G)*4, PopulationUse[G], 4);
    ReadAt(Cardinal(CityDZ[City])+$C4+Cardinal(G)*4, CityOutput[G], 4);
    ReadAt(Cardinal(CityDZ[City])+$64+Cardinal(G)*4, CityUse[G], 4);
    if SwsDz[City] > 0 then
    begin
      ReadAt(Cardinal(SwsDz[City])+$C4+Cardinal(G)*4, OfficeOutput[G], 4);
      ReadAt(Cardinal(SwsDz[City])+$64+Cardinal(G)*4, OfficeUse[G], 4);
    end;
  end;
  CalculateFinalBalance(Counts, PopulationUse, CityOutput, CityUse,
    OfficeOutput, OfficeUse, Days, FinalBalance);
end;

//------------------------------------------ //读出城市产消
procedure Get_CSCx(index,Atime,Selet:byte);
var
i,j:word;
DZtemp:cardinal;
Acity,Aplayer:byte;
SRCX:array[0..1,0..19] of integer;
SLtemp:array[0..10] of integer;
begin
//----------------------------------// 其它商人工厂产出消耗
fillchar(SRCX,sizeof(SRCX),0);
fillchar(CScxSL,sizeof(CScxSL),0);
fillchar(SLtemp,sizeof(SLtemp),0);
for i:=0 to swscunt-1 do
begin
  DZtemp:=swsjz+ i * 1100 ;
  ReadProcessMemory(GHandle, Pointer(DZtemp+ 708), Pointer(@Aplayer),1,tmpNum);
  ReadProcessMemory(GHandle, Pointer(DZtemp+ 710), Pointer(@Acity),1,tmpNum);//事务所城市
    if (Acity=index) and (Aplayer<>player-1) then
       begin
           for j:=0 to 19 do
             begin
              ReadProcessMemory(GHandle, Pointer(DZtemp+j*4+100),
                       Pointer(@SLtemp[0]),4,Numtmp); // 其它商人工厂消耗
                       SRCX[0,j]:= SRCX[0,j]+SLtemp[0];

              ReadProcessMemory(GHandle, Pointer(DZtemp+j*4+196),
                         Pointer(@SLtemp[1]),4,Numtmp);// 其它商人工厂产出
                        SRCX[1,j]:= SRCX[1,j]+SLtemp[1];
                      //SRCX[j]:= SRCX[j]-SLtemp1+SLtemp2;
              end;
        end;
   end;

For i:=0 To 19 do
begin
  ReadProcessMemory(GHandle, Pointer(CityDZ[index]+i*4+100), Pointer(@SLtemp[2]),4,Numtmp);//城镇消耗
  ReadProcessMemory(GHandle, Pointer(CityDZ[index]+i*4+196), Pointer(@SLtemp[3]),4,Numtmp);// 城镇产出
  ReadProcessMemory(GHandle, Pointer(CityDZ[index]+ $310+i*4), Pointer(@SLtemp[4]),4,Numtmp); // 人口消耗
  ReadProcessMemory(GHandle, Pointer(SwsDz[index]+i*4+100),Pointer(@SLtemp[5]),4,Numtmp); // 玩家工厂消耗
  ReadProcessMemory(GHandle, Pointer(SwsDz[index]+i*4+196),Pointer(@SLtemp[6]),4,Numtmp);// 玩家工厂产出
  case selet of
     0: CScxSL[i] :=SRCX[1,i]-SRCX[0,i];//其它商人工厂产出消耗
     1: CScxSL[i] :=SLtemp[3]-SLtemp[2];//城镇产出消耗
     2: CScxSL[i] :=SRCX[1,i]-SRCX[0,i]+SLtemp[3]-SLtemp[2]-SLtemp[4];//城镇其它商人产消与人口汪消耗
     3: CScxSL[i] :=0-SLtemp[4]; //纯人口消耗
     4: CScxSL[i] :=0- SLtemp[5];//玩家工厂消耗
     5: CScxSL[i] := SLtemp[6];  //玩家工厂产出
     6: CScxSL[i] :=SLtemp[6]-SLtemp[5]; // 玩家工厂产耗
     7: CScxSL[i] :=SLtemp[6]-SLtemp[5]+SLtemp[3]-SLtemp[2]-SLtemp[4];//玩家城镇人口产消
     8: CScxSL[i] :=SLtemp[6]-SLtemp[5]-SLtemp[2]-SLtemp[4];
     9: CScxSL[i] :=SRCX[1,i]+SLtemp[3]+SLtemp[6];//-----全部产出;
     10:CScxSL[i] :=0-(SRCX[0,i]+SLtemp[2]+SLtemp[4]+SLtemp[5]);//----全部消耗;
     11:CScxSL[i] :=SRCX[1,i]+SLtemp[3]+SLtemp[6]-(SRCX[0,i]+SLtemp[2]+SLtemp[4]+SLtemp[5]);
     12:CScxSL[i] :=SRCX[1,i];
     13:CScxSL[i] :=0-SLtemp[2]; //城镇消耗
   end;
  CScxSL[i] :=CScxSL[i]*Atime;
end;//end for
end;

//----------------读取玩金钱-------------
function Get_Money:integer;
var
DZ,Money,Aplayer:integer;
begin
Aplayer:=player;
  Dz:=PlaysJz+(Aplayer-1)*$650;
  ReadProcessMemory(GHandle, Pointer(Dz), Pointer(@Money),4,Numtmp);
  Result:=Money;
end;


//------------------写入金钱--------------------
procedure Write_Money(AMoney:integer);
var
DZ,Aplayer:integer;
begin
Aplayer:=player;
  Dz:=PlaysJz+(Aplayer-1)*$650;
  writeprocessmemory(GHandle, Pointer(Dz), Pointer(@AMoney),4,Numtmp);
end;

//----------------------------寻找进程-----------------------------
function FindProcess(aFileName: String): dword; //返回进程id
begin
Result:=0;
hSnapshot:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
lppe.dwSize:=SizeOf(TProcessEntry32);
Found:=Process32First(hSnapshot,lppe);
while Found do
 begin
  if (UpperCase(ExtractFileName(lppe.szExeFile))=UpperCase(aFileName)) or
     (UpperCase(lppe.szExeFile)=UpperCase(aFileName)) then
    begin
      Result:=lppe.th32ProcessID;
      break;
    end;
  Found := Process32Next(hSnapshot, lppe);
 end;
end;


//-------------------------读人名----------------------------------
procedure Get_PeopleName(jz:integer);
var
  ByteCount, i: Integer;
  dz: Cardinal;
  Text: string;
  BytesRead: NativeUInt;
begin
  if not ReadProcessMemory(GHandle, Pointer(JZ), @dz, SizeOf(dz), BytesRead) then
    RaiseLastOSError;
  if BytesRead <> SizeOf(dz) then raise EReadError.Create('Incomplete name table pointer');
  for i := Low(popNamex) to High(popNamex) do
  begin
    Text := ReadGameText(GHandle, dz, ByteCount);
    if ByteCount = 0 then Exit;
    case jz of
      $6E01C8: popNamex[i] := Text;
      $6E01D0: popNamem[i] := Text;
    end;
    Inc(dz, ByteCount + 1); // Advance game bytes, not UTF-16 character count.
  end;
end;

//------------------------------------------------------------------------
procedure People_Name;
var
i,DZ:integer;
T:byte;
begin
Get_PeopleName($6E01C8);
Get_PeopleName($6E01D0);
for i :=0 to player-1 do
  begin
    DZ:=PlaysJz+i*$650;
    ReadProcessMemory(GHandle, Pointer(DZ+ 28), Pointer(@T),1,tmpNum);
    PopName[i]:=PopnameX[T];
    ReadProcessMemory(GHandle, Pointer(DZ+ 29), Pointer(@T),1,tmpNum);
    PopName[i]:=PopName[i]+'  '+PopNamem[T];
    end;
end;


//-------------------------初始化------------------------------------
procedure Game_init;
var
i,temp,DZ1,DZ2:integer;
sws,k:word;
City:byte;

begin
ReadProcessMemory(GHandle, Pointer($71CE20), Pointer(@PlaysJz),4,Numtmp);//贸易者基址
ReadProcessMemory(GHandle, Pointer($71CE10), Pointer(@CityJz),4,tmpNum); //城市基址
ReadProcessMemory(GHandle, Pointer($6DFB8C), Pointer(@ShipJZ),4,tmpNum); //船只基址
ReadProcessMemory(GHandle, Pointer($71CE1C), Pointer(@SWSjz),4,tmpNum);//事务所基址
ReadProcessMemory(GHandle, Pointer($6E2F2C), Pointer(@Home),1,tmpNum);//家乡城市编号
ReadProcessMemory(GHandle, Pointer($71CDB8), Pointer(@CityCunt),1,tmpNum); //城市总数
ReadProcessMemory(GHandle, Pointer($71CDB2), Pointer(@Player),1,tmpNum);  //玩家编号
//ReadProcessMemory(GHandle, Pointer($71CE26), Pointer(@Swscunt),2,tmpNum);//事务所数量

//----------取事务所地址 -------------------------
fillchar(Swsdz,sizeof(SWSdz),0);
FillChar(CityMarker,SizeOf(CityMarker),0);
for i:=0 to 39 do CityName[i]:='';
for i:=Low(BuildName) to High(BuildName) do BuildName[i]:='';
temp:=PlaysJz+(player-1)*$650;
ReadProcessMemory(GHandle, Pointer(temp+12), Pointer(@sws),2,tmpNum);
repeat
  temp:=swsjz+ sws * $44c;
  ReadProcessMemory(GHandle, Pointer(temp+$2C6), Pointer(@City),1,tmpNum);
  SWSDZ[City]:=temp;
  if City <= High(CityMarker) then CityMarker[City] := 1;
  ReadProcessMemory(GHandle, Pointer(temp+$2C6+2), Pointer(@sws),2,tmpNum);
until sws=$FFFF ;
temp:=PlaysJz+(player-1)*$650;
ReadProcessMemory(GHandle,Pointer(temp+$18),@City,1,tmpNum);
if City <= High(CityMarker) then CityMarker[City] := 2;


//--------------取城市地址和名称------------------

for i:=0 to 39 do
  begin
      ReadProcessMemory(GHandle, Pointer($6E0080 + i * 4), Pointer(@temp),4,tmpNum);
      CityName[i]:=Get_String(temp);
  end;

for i:=0 to CityCunt-1 do
  begin
    CityDZ[i]:=CityJz+i*$9f8;  //

    ReadProcessMemory(GHandle, Pointer($71CDC0+i), Pointer(@k),1,tmpNum);
    ReadProcessMemory(GHandle, Pointer($709930+k*52), Pointer(@CityZB[i].x),2,tmpNum);
    ReadProcessMemory(GHandle, Pointer($709930+k*52+4), Pointer(@CityZB[i].y),2,tmpNum);
  end;

//-------------------------读取商品名称---------------------------------
ReadProcessMemory(GHandle, Pointer($6dd078), Pointer(@DZ1),4,Numtmp);
DZ1:=DZ1+$668;
for i:=0 to 19 do
  begin
  ReadProcessMemory(GHandle, Pointer(DZ1+i*4), Pointer(@DZ2),4,Numtmp);
  SpName[i]:=Get_string(DZ2);
end;//end for

//------------------------称号----------------------------------

for i:=0 to 7 do
  begin
    ReadProcessMemory(GHandle, Pointer($6B0614+i*4), Pointer(@DZ1),4,Numtmp);
    PeopCap[i]:=Get_string(DZ1);
  end;

//-------------------------------地中海城市名--------------------------------------
for i:=0 to 29 do
  begin
    ReadProcessMemory(GHandle, Pointer($6B9848+i*4), Pointer(@DZ1),4,Numtmp);
    DzhcityName[i]:=Get_string(dz1);
  end;
DzhcityName[30]:=Get_string($6ca710);
DzhCityLx[2]:=Get_string($6CA710); //2印第安
DzhCityLx[1]:=Get_string($6CA720); // 1军事基地
DzhCityLx[0]:=Get_string($6CA72c); // 0海港城镇

//------------------------基点建筑名称--------------------------

for i:=0 to 53 do
  begin
    ReadProcessMemory(GHandle, Pointer($6B8950+i*4), Pointer(@DZ1),4,Numtmp);
    BuildName [i+3]:=Get_string(dz1);
  end;
BuildName[100]:='工厂规划位'; // Final 00479887..004798B7 / 004798F0.



People_Name;
end;


function ShipZT_To_string(ZT:byte):ansistring; //返回船只状态
begin
case  ZT of
    0:result:='停靠';
    1:result:= '交易中';
    2:result:= '出港';
    3:result:='进港';
    6:result:= '修理';
    14:result:= '建造';
    15:result:= '航行';
    17:result:='下沉';
    18:result:='攻击';
    19:result:= '远征';
    20:result:= '海战';
     Else
     result:=inttoStr(ZT);
end;
end;



//------------------------------------------------------------------------------
Function Time_To_String(Funtime:Cardinal):string;
var
i, gyear,temp :cardinal;
 days:array[1..12] of byte;
begin
temp:=Funtime div 256;
gyear:= temp div 365;
temp:=temp mod 365+1;
for i :=1 to 12 do
  begin
      case i of
       1,3,5,7,8,10,12:days[i]:=31;
       4,6,9,11:days[i]:=30;
       2: days[i]:=28;
        end;
  end;

for i:=1 to 12 do
     if temp>days[i] then
        temp:=temp-days[i]
        else
          break;
result:=inttostr(gyear)+'-'+inttostr(i)+'-'+inttostr(temp);
End;


//-------------------------------------------------------------------------------
function Get_string(PPoint:dword):string;
var ByteCount: Integer;
begin
  Result := ReadGameText(GHandle, PPoint, ByteCount);
end;
//--------------------------------------------------------------------------------
Function BHtoLX(BH:Integer):String;
begin
Case BH of
  0, 1:result:='未知地皮';
  2:result:='城外建筑生成的道路';
   3:result:='城外道路';
   4:result:='城外水井用地';
   5:result:='已建城墙';
   6:result:='边框';
   7:result:='预留横抛射位';
   8:result:='预留竖抛射位';
   9, 10:result:='预留城墙位';
   11:result:='城外水上建筑';
   12:result:='海洋';
   13:result:='海岸山地';
   14:result:='渔夫之家空地';
   15:result:='煤矿预留地';
   16:result:='三级城墙外空地';
   17:result:='城墙外壁';
   30:result:='水上山地空地';
   31:result:='装饰物';
   32.. 47:result:='城墙外空地';
   48..63:result:='城外绿地5X4';
   128, 129:result:='改善道路';
   130:result:='建筑生成的道路';
   131:result:='城内未改善道路';
   132:result:='城内水井用地';
   139:result:='城内建筑';
   145:result:='城墙内壁';
   146:result:='水井';
   147, 152, 154:result:='建筑预留基点';
   158:result:='建筑预留地';
   159:result:='围栏';
   176.. 191:result:='5X4绿地';
   161, 163, 165, 167, 169, 171, 173, 175:
   result:='绿地3X2';
  162, 166, 170, 174:result:='绿地2X3';
  164, 168, 172:result:='绿地3X2 2X3';
  160:result:='未点亮绿地';
   else
     result:=inttostr(BH);//-------其它
  end;
end;



//-------------------------------------------------------------------------------
function back_LW(Gday:byte;Gmonth:byte):boolean;
var
tempday:byte;
begin
result:=false;
ReadProcessMemory(GHandle, Pointer($71cda8), Pointer(@tempday),1,tmpNum); //时间天
if tempday<Gday then begin
   case Gmonth of
        1,3,5,7,8,10,12:tempday:=tempday+31;
        4,6,9,11:tempday:=tempday+30;
        2: tempday:=tempday+28;
        end;
   if tempday-Gday>10 then
      result:=false
      else
        result:=true;
      end;
end;

//----------------------------显示港口停泊船只------------------------
procedure Get_CityTK_ship(City:byte);
var
temp,ZDll,ZDnj,Amoney,JDjz:integer;
shipLX,TK,AshipJb,ZR,sZT:Byte;
i,k,j,SNext,TNext:Word;
Sjmoney:array [0 .. 3] of byte;
jdL:array[0..100] of word;


begin
fillchar(CLshipList,sizeof(CLshipList),0);
fillchar(JdL,sizeof(JdL),0);
ReadProcessMemory(GHandle, Pointer($6DFB90), Pointer(@JDjz),4,Numtmp);//舰队地址
ReadProcessMemory(GHandle, Pointer($6DFC74), Pointer(@SNext),2,Numtmp);//舰队指针

k:=0;
//----------------读出所有舰队-------------------------------
while SNext<>$FFFF  do
  begin
    temp:=JDjz+SNext*60;
    TNext:=SNext;
    ReadProcessMemory(GHandle, Pointer(temp), Pointer(@ZR),1,Numtmp);
    ReadProcessMemory(GHandle, Pointer(temp+28), Pointer(@Tk),1,Numtmp);
    ReadProcessMemory(GHandle, Pointer(temp+8), Pointer(@SNext),2,Numtmp);
    ReadProcessMemory(GHandle, Pointer(temp+18), Pointer(@sZT),1,Numtmp);
    if (Zr<>Player-1) or (TK<>City) then continue;
    ReadProcessMemory(GHandle, Pointer(temp+10), Pointer(@TNext),2,Numtmp);
    jdL[k]:=TNext;
    k:=k+1;

  end;
   ReadProcessMemory(GHandle, Pointer($6DFC70), Pointer(@jdL[k]),2,Numtmp);

j:=1;
if k<>0 then
for i:=0 to k-1 do
  begin
    SNext:=jdL[i];
     while SNext<>$FFFF  do
     begin
       temp := ShipJZ + SNext * $180;
       CLshipList[j]:=SNext;
       j:=j+1;
       ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@SNext),2,Numtmp);
     end;
  end;

SNext:=jdL[k];
while SNext<>$FFFF  do
     begin
       temp := ShipJZ + SNext * $180;
       Tnext:=Snext;
       ReadProcessMemory(GHandle, Pointer(temp), Pointer(@ZR),1,Numtmp);
       ReadProcessMemory(GHandle, Pointer(temp+57), Pointer(@Tk),1,Numtmp);
       ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@SNext),2,Numtmp);
    if (Zr<>Player-1) or (TK<>City) then continue;
       CLshipList[j]:=Tnext;
       j:=j+1;
     end;
CLshipList[0]:=j-1;



end;




end.
