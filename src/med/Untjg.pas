unit Untjg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids,Untpublic,IniFiles, Buttons, ComCtrls;

type
  TFrmJg = class(TForm)
    Panel3: TPanel;
    Panel5: TPanel;
    Panel1: TPanel;
    StrGidLW: TStringGrid;
    memo1: TMemo;
    StaBar: TStatusBar;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    StrGidCz: TStringGrid;
    Panel4: TPanel;
    Button2: TButton;
    ComBox1: TComboBox;
    Button3: TButton;
    Button1: TButton;
    BitBtn1: TBitBtn;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StrGidLWClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure StrGidCzDblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmJg: TFrmJg;

  LwxjDZ:array[0..100] of Integer;
implementation

uses MedMemoryText, MedConfigPath;

{$R *.dfm}

procedure TFrmJg.Button1Click(Sender: TObject);
var
i,j,k,L,xl,Visited:word;
LWpoint,LWpoint2,temp,StrPoint,Ap:integer; //,
LwCityName,Lwbz:byte;
LwTime,NowTime:integer;
LwPoints:array [0..59] of dword;
tempTime:array [0..59] of integer;
ByteLength: Integer;
TaskText: string;

begin
Ap:=Player;
ReadProcessMemory(GHandle, Pointer($6dd2b0), Pointer(@LWpoint),4,tmpNum); //基址
ReadProcessMemory(GHandle, Pointer($71cdbc), Pointer(@NowTime),4,tmpNum);
temp := PlaysJz + (Ap-1) * $650+ $A;
ReadProcessMemory(GHandle, Pointer(temp), Pointer(@xl),2,tmpNum);
j:=0;
Visited:=0;

while xl<>$FFFF  do
begin
temp:=LWpoint+xl*16;
ReadProcessMemory(GHandle, Pointer(temp+4), Pointer(@Lwbz),1,tmpNum);
  if Lwbz=$71 then
      begin
        ReadProcessMemory(GHandle, Pointer(temp+8), Pointer(@LWpoint2),4,tmpNum);
        ReadProcessMemory(GHandle, Pointer(LWpoint2+4), Pointer(@LwTime),4,tmpNum);
         if (LwTime>NowTime) and (j<=High(LwPoints)) then
             begin
              tempTime[j]:=LwTime-NowTime;
              LwPoints[j]:=temp;
              j:=j+1;
            end;
      end;
Inc(Visited);
if Visited>400 then Break;
ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@xl),2,tmpNum);
end;

StrGidLW.RowCount:=j+1;
for i:=0 to j-1 do
begin
StrGidLW.Cells [0,i+1]:=inttostr(i);
//StrGidLW.Cells [4,i+1]:=inttohex(LwPoints[i],8);

ReadProcessMemory(GHandle, Pointer(LwPoints[i]+5), Pointer(@LwCityName),1,tmpNum); //读出城市代码
StrGidLW.Cells [1,i+1]:=CityName[LwCityName];  //*************************城市名称

ReadProcessMemory(GHandle, Pointer(LwPoints[i]+12), Pointer(@StrPoint),4,tmpNum); //字符起始地址

//StrGidLW.Cells [4,i+1]:=inttohex(StrPoint,8);
TaskText := ReadGameText(GHandle, Cardinal(StrPoint), ByteLength);
LwxjDz[i]:=StrPoint+ByteLength+1;
StrGidLW.Cells [3,i+1]:=inttostr(tempTime[i] div 256+1);
StrGidLW.Cells [2,i+1]:=StringReplace(TaskText, ' ', '', [rfReplaceAll]);

  end;
end;

//*******************************************************************************
procedure TFrmJg.StrGidLWClick(Sender: TObject);
var
i:word; //读出多少个字,strcounts
temp:dword;
MemString:array[0..1000]of AnsiChar;
Count: Integer;
begin
Count := 0;
for i:=0 to 1000 do
  begin
    MemString[i]:=chr(0);
    ReadProcessMemory(GHandle, Pointer(LwxjDZ[StrGidLW.Row-1]+i+5), Pointer(@temp),4,tmpNum);//判断结束
    if (temp=$31665c5c) or (temp=$20202020) then
       Break
     else
     begin
       if not ReadProcessMemory(GHandle, Pointer(LwxjDZ[StrGidLW.Row-1]+i+5), Pointer(@MemString[i]),1,tmpNum) then
         RaiseLastOSError;
       if MemString[i] = #0 then Break;
       Inc(Count);
     end;
     end;
     memo1.Text := DecodeGameBytes(MemString[0], Count);
end;

//******************************************************************************
procedure TFrmJg.FormCreate(Sender: TObject);
begin
with StrGidLW do
   begin
    cells[0,0]:='序号';cells[1,0]:='城市'; cells[2,0]:='任务';cells[3,0]:='剩余[天]';
   end;
with StrGidcz do
   begin
    cells[0,0]:='城市';cells[1,0]:='编号'; cells[2,0]:='年龄';
    cells[3,0]:='能力';cells[4,0]:='日薪';
    ColWidths[0]:=80;
   end;

end;

function Read_Movegk:byte;
var
vFIni: TIniFile;
sFileName,temp: string;
begin
   sFileName := MedConfigFileName;
   vFIni := TIniFIle.Create(sFileName);
   temp:=vFIni.ReadString('ShipMove', 'gk', '0');
   if temp<>'' then result:=strtoint(temp)
               else
               result:=0;
end;


//----------------------------------------------------------
procedure TFrmJg.BitBtn1Click(Sender: TObject);
var
i,j,Ct,Bt:word;
DZ,Ttemp,Ctime,CCJz:integer;
A1,A2,A3:byte;
begin
StrGidcz.RowCount:=CityCunt+1;
ReadProcessMemory(GHandle, Pointer($6dfb88), Pointer(@CCJz),4,tmpNum);
ReadProcessMemory(GHandle, Pointer($71cdbc), Pointer(@Ttemp),4,tmpNum);
ComBox1.Items.Clear;
for i:=0 to CityCunt-1 do      //
   begin
       ComBox1.Items.Add(CityName[i]);
       for j:=1 to 6 do
       strgidCz.Cells[j,i+1]:='';
       DZ:=CityDZ[i]+$82e;
       strgidCz.Cells[0,i+1]:=cityname[i];
       ReadProcessMemory(GHandle, Pointer(DZ), Pointer(@Ct),2,tmpNum);
       if Ct=$FFFF then  continue;
       repeat
       BT:=Ct;
       DZ:=CCJz+Ct*16;
       ReadProcessMemory(GHandle, Pointer(Dz+8), Pointer(@A1),1,tmpNum);
       ReadProcessMemory(GHandle, Pointer(DZ), Pointer(@Ct),2,tmpNum);
       until (Ct=$FFFF) or (A1<32);
       if (A1>31) then  continue;
       ReadProcessMemory(GHandle, Pointer(Dz+4), Pointer(@Ctime),4,tmpNum);
           Ctime:=((Ttemp-Ctime)div 256) div 365;
           strgidCz.Cells[1,i+1]:=inttostr(Bt);
           strgidCz.Cells[2,i+1]:=inttostr(Ctime);
           ReadProcessMemory(GHandle, Pointer(Dz+9), Pointer(@A1),1,tmpNum);
           ReadProcessMemory(GHandle, Pointer(Dz+10), Pointer(@A2),1,tmpNum);
           ReadProcessMemory(GHandle, Pointer(Dz+11), Pointer(@A3),1,tmpNum);
           strgidCz.Cells[3,i+1]:=inttostr(A2 div 50)+','+inttostr(A1 div 50)+','+inttostr(A3 div 50);
           ReadProcessMemory(GHandle, Pointer(Dz+12), Pointer(@A1),1,tmpNum);
           strgidCz.Cells[4,i+1]:=inttostr(A1);
end;//end for

combox1.ItemIndex:=Read_Movegk;
end;



procedure TFrmJg.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
bitbtn1.Left := panel2.Left +10;
end;

procedure TFrmJg.StrGidCzDblClick(Sender: TObject);
var
CZbh:word;
TStr:string;
ccdz,Tage,NTime:integer;
begin
TStr:=Strgidcz.Cells[1,Strgidcz.row];
if Tstr='' then exit;
czbh:=strtoint(Tstr);
ReadProcessMemory(GHandle, Pointer($6dfb88), Pointer(@CCdz),4,tmpNum);
CCdz:=CCdz+czbh*16;
ReadProcessMemory(GHandle, Pointer(CCdz+4), Pointer(@Tage),4,tmpNum);
Tage:=Tage+934400;
ReadProcessMemory(GHandle, Pointer($71cdbc), Pointer(@Ntime),4,tmpNum);
if Tage>Ntime then Tage:=Ntime;
writeprocessmemory(GHandle,Pointer(CCdz+4),Pointer(@Tage),4,tmpNum);
BitBtn1Click(Sender);
end;



procedure TFrmJg.Button2Click(Sender: TObject);
var
shipPoint,temp:integer;
shipPre,shipSS:word;
shipLx,shipzt:byte;
SS:array[0..3] of word;
begin
SS[0]:=5;
SS[1]:=8;
SS[2]:=10;
SS[3]:=12;
ReadProcessMemory(GHandle, Pointer($6DFB8C), Pointer(@shipPoint),4,tmpNum); // 船只基址
temp:=PlaysJz +(Player-1)*$650+14;
ReadProcessMemory(GHandle, Pointer(temp), Pointer(@shipPre),2,tmpNum);
while shipPre<>$FFFF  do
begin
   temp := shipPoint + shipPre * $180;
   ReadProcessMemory(GHandle, Pointer(temp+ 308),Pointer(@shipzt), 1, tmpNum);//------------船只状态
   if shipzt=0 then
   begin
        ReadProcessMemory(GHandle, Pointer(temp+14),Pointer(@shipLx), 1, tmpNum);//--------------船只类型
        ReadProcessMemory(GHandle, Pointer(temp+64),Pointer(@shipSS), 2, tmpNum);//--------------船只水手数量
        if shipSS<SS[shipLx]then
           WriteProcessMemory(GHandle,Pointer(temp + 64), Pointer(@SS[shipLx]),2, tmpNum);
    end;//end shipzt=0
       ReadProcessMemory(GHandle, Pointer(temp+4), Pointer(@shipPre),2,tmpNum);
     end;//end while
end;



procedure TFrmJg.Button3Click(Sender: TObject);
var
temp:integer;
i,shipPre,shipSS:word;
M,shipLx,shipzt,gk,zt,Tgk:byte;
SS:array[0..3] of word;
begin
SS[0]:=5;
SS[1]:=8;
SS[2]:=10;
SS[3]:=12;
zt:=2;
i:=0;


gk:=combox1.ItemIndex;

ReadProcessMemory(GHandle, Pointer($6DFC70), Pointer(@shipPre),2,tmpNum);
while shipPre<>$FFFF  do
begin
   temp := ShipJZ + shipPre * $180;
   ReadProcessMemory(GHandle, Pointer(temp),Pointer(@M), 1, tmpNum);
   if M<>player-1 then
       begin
         ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@shipPre),2,tmpNum);
         continue;
       end
         else
         ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@shipPre),2,tmpNum);

   ReadProcessMemory(GHandle, Pointer(temp+ 308),Pointer(@shipzt), 1, tmpNum);//------------船只状态
   ReadProcessMemory(GHandle, Pointer(temp+14),Pointer(@shipLx), 1, tmpNum);//--------------船只类型

   if (shipzt=0)  then
   begin
        ReadProcessMemory(GHandle, Pointer(temp+64),Pointer(@shipSS), 2, tmpNum);//--------------船只水手数量
        if shipSS<SS[shipLx]then
           WriteProcessMemory(GHandle,Pointer(temp + 64), Pointer(@SS[shipLx]),2, tmpNum);
           ReadProcessMemory(GHandle, Pointer(temp+56),Pointer(@Tgk), 1, tmpNum);
           if Tgk<> gk then
            begin
             WriteProcessMemory(GHandle,Pointer(temp + 56), Pointer(@gk),1, tmpNum);
             WriteProcessMemory(GHandle,Pointer(temp + 308), Pointer(@zt),1, tmpNum);
             i:=i+1;
            end;
    end;//end shipzt=0

     end;//end while
if i>0 then
    Stabar.Panels[0].Text :='成功转移'+inttostr(i)+'艘船只'
    else
    Stabar.Panels[0].Text :='没有可移动的船只';
end;

procedure TFrmJg.Button4Click(Sender: TObject);
var
i,j,k,L,xl:word;
LWpoint,LWpoint2,temp,StrPoint,Ap:integer; //,
T,Lwbz:byte;
LwTime,NowTime:integer;
Bytetemp:char;
LwPoints:array [0..500] of integer;
tempTime:array [0..500] of integer;
MemString:array[0..500] of char;

begin
fillchar(LwPoints,sizeof(LwPoints),0);
Ap:=Player;
ReadProcessMemory(GHandle, Pointer($6dd2b0), Pointer(@LWpoint),4,tmpNum); //基址
ReadProcessMemory(GHandle, Pointer($71cdbc), Pointer(@NowTime),4,tmpNum);
temp := PlaysJz + (Ap-1) * $650+ $A;
ReadProcessMemory(GHandle, Pointer(temp), Pointer(@xl),2,tmpNum);
j:=0;

while xl<>$FFFF  do
begin
temp:=LWpoint+xl*16;
ReadProcessMemory(GHandle, Pointer(temp+4), Pointer(@Lwbz),1,tmpNum);
//  if Lwbz=$71 then
//     begin
//        ReadProcessMemory(GHandle, Pointer(temp+8), Pointer(@LWpoint2),4,tmpNum);
//        ReadProcessMemory(GHandle, Pointer(LWpoint2+4), Pointer(@LwTime),4,tmpNum);
//         tempTime[j]:=Lwtime-Nowtime;
//         if tempTime[j]>0 then
//            begin
              LwPoints[j]:=temp;
              j:=j+1;
//            end;
//      end;
ReadProcessMemory(GHandle, Pointer(temp+6), Pointer(@xl),2,tmpNum);
end;

StrGidLW.RowCount:=j+1;
for i:=0 to j-1 do
begin
Bytetemp:=char(1);
StrGidLW.Cells [0,i+1]:=inttohex(LwPoints[i],8);;
//StrGidLW.Cells [4,i+1]:=inttohex(LwPoints[i],8);
ReadProcessMemory(GHandle, Pointer(LwPoints[i]+4), Pointer(@T),1,tmpNum); //读出城市代码
StrGidLW.Cells [1,i+1]:=inttostr(T);

ReadProcessMemory(GHandle, Pointer(LwPoints[i]+5), Pointer(@T),1,tmpNum); //读出城市代码
StrGidLW.Cells [2,i+1]:=CityName[T];  //*************************城市名称

ReadProcessMemory(GHandle, Pointer(LwPoints[i]+8), Pointer(@StrPoint),4,tmpNum); //字符起始地址
StrGidLW.Cells [3,i+1]:=inttohex(StrPoint,8);
ReadProcessMemory(GHandle, Pointer(LwPoints[i]+12), Pointer(@StrPoint),4,tmpNum); //字符起始地址
StrGidLW.Cells [4,i+1]:=inttohex(StrPoint,8);
ReadProcessMemory(GHandle, Pointer(LwPoints[i]), Pointer(@StrPoint),4,tmpNum); //字符起始地址
StrGidLW.Cells [5,i+1]:=time_to_string(StrPoint);

//if StrPoint=0 then continue;

// L:=0;k:=0;
//  while (Bytetemp<>char(0)) and (L<600) do
//    begin
//      ReadProcessMemory(GHandle, Pointer(StrPoint+L), Pointer(@Bytetemp),1,tmpNum);
//      L:=L+1;
     // if Bytetemp<>chr($20) then
      //   begin
          // MemString[k]:=Bytetemp;
      //     k:=k+1;
     //     end;
//      end; // while


//LwxjDz[i]:=StrPoint+L;
//StrGidLW.Cells [3,i+1]:=inttostr(tempTime[i] div 256+1);
//StrGidLW.Cells [2,i+1]:=string(MemString);

  end;
end;

procedure TFrmJg.ComBox1Change(Sender: TObject);
var
vFIni: TIniFile;
sFileName: string;
begin
   sFileName := MedConfigFileName;
   vFIni := TIniFIle.Create(sFileName);
   vFIni.WriteString('ShipMove', 'gk',inttostr(ComBox1.ItemIndex));
end;

end.
