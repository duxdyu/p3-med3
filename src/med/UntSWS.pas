unit UntSWS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,Untpublic,IniFiles, ComCtrls, Buttons,
  Spin;

type
  TFrmSWS = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel7: TPanel;
    Button3: TButton;
    ComBox: TComboBox;
    Button2: TButton;
    Panel3: TPanel;
    StrGid: TStringGrid;
    Button10: TButton;
    StrGid2: TStringGrid;
    Panel5: TPanel;
    GroupBox1: TGroupBox;
    RadGroup: TRadioGroup;
    Button1: TButton;
    Button11: TButton;
    GroupBox4: TGroupBox;
    StaBar: TStatusBar;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Button6: TButton;
    GroupBox2: TGroupBox;
    StrGid1: TStringGrid;
    Button5: TButton;
    Spin: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure ComBoxChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure RadGroupClick(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure StrGidMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button11Click(Sender: TObject);
    procedure StrGidKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StrGidMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StrGid2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StrGid2SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure StrGid1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Procedure Read_SWS(City:byte);
Procedure show_SWS(city:byte);
var
  FrmSWS: TFrmSWS;
  SWSMan:word;
  city:byte;
  SPLock:array[0..19] of byte;
  Adata:array [0..8,0..19] of integer;
  MbName:string;
  SWSMM:integer;
  BuyLock:array[0..19] of boolean;
  GameJg:array [0..19] of integer;
  MadeshipCL:array[0..4] of integer;
  MM:integer;


implementation

uses MedConfigPath;

var
WeeklyBalance, OfficeStock: array[0..19] of Integer;
RmadeCL:array [0..3,0 .. 3,0..4] of integer=
     (((14000,600,600,6000,4000),(18000,600,600,6000,4000),(22000,600,600,6000,4000),(22000,600,600,6000,4000)),
     ((24000,1000,1000,10000,6000),(28000,1000,1000,10000,6000), (32000,1000,1000,10000,6000), (32000,1000,1000,10000,6000)),
     ((36000,600,800,8000,8000),(40000,600,800,8000,8000),(44000,600,800,8000,8000),(44000,600,800,8000,8000)),
     ((60000,2000,2000,16000,10000),(69000,2000,2000,16000,10000),(78000,2000,2000,16000,10000),(78000,2000,2000,16000,10000)));


{$R *.dfm}

//-----------------------解锁-------------------------------------------
procedure Get_Lock(city:byte);
var
i,j:byte;
TA:array[0..7] of byte;
T:byte;
DZ:integer;
begin
fillchar(SpLock,sizeof(SpLock),0);
for i:=0 to 7 do Ta[i]:= BPower(2,i);

for j:=0 to 2 do
   begin
    DZ:=SWSDZ[City]+j+756;
    ReadProcessMemory(GHandle, Pointer(DZ+192), Pointer(@T),1,tmpNum);

    if T=0 then continue;
    for i:=7 downto 0  do
        begin

        if T>= Ta[i] then
             begin
               T:=T-Ta[i];
               SPlock[i+j*8]:=1;
               if T=0 then break;
              end;

        end;
   end;
end;

//-----------------------------判断事务所状态--------------------------
function SWS_ZT(ACity:byte):byte;
var
SWSMan:word;
begin
result:=0;
if  SWSDZ[ACity]=0  then exit;
if SWSDZ[ACity]>0 then
begin
    ReadProcessMemory(GHandle, Pointer(SWSDZ[ACity]+754), Pointer(@SWSMan),2,tmpNum);//事务所管理者
    if SWSMan=$FFFF then
       result:=1
       else
       result:=2;
end;
end;

//-----------------------------读事务所----------------------------------
Procedure Read_SWS(City:byte);
var
i,j:word;
DZ,DZ1,jg,CityOutput,CityUse,PopulationUse:integer;
T:byte;
Aexp:array[0..7] of byte;
begin

MM:=0;
for i:=0 to 3 do
     for j:=0 to 19 do
       Adata[i,j]:=0;
FillChar(WeeklyBalance,SizeOf(WeeklyBalance),0);
FillChar(OfficeStock,SizeOf(OfficeStock),0);
for i:=1 to 7 do
  for j:=1 to 20 do FrmSWS.StrGid.Cells[i,j]:='';
// 004B3B88 owns availability/status; 004B3FF0 still paints the zeroed table
// after this routine returns for an absent office or missing manager.
T:=SWS_ZT(City);
FrmSWS.StrGid.Enabled:=T=2;
FrmSWS.Button10.Enabled:=T=2;
FrmSWS.Button1.Enabled:=T=2;
case T of
  0: FrmSWS.StaBar.Panels[0].Text:='没有事务所';
  1: FrmSWS.StaBar.Panels[0].Text:='事务所没有管理者';
  2: FrmSWS.StaBar.Panels[0].Text:=FrmSWS.ComBox.Text;
end;
if T<>2 then Exit;
DZ:=SWSDZ[City]+756;


for i:=0 to 19  do
  begin
   ReadProcessMemory(GHandle, Pointer(DZ+i*4+96), Pointer(@Adata[0,i]),4,tmpNum);
   ReadProcessMemory(GHandle, Pointer(DZ+i*4), Pointer(@jg),4,tmpNum);
     Adata[3,i]:=abs(jg);
     if jg>0 then
        Adata[1,i]:=1
          else
            if jg=0 then
               Adata[1,i]:=0
               else
               Adata[1,i]:=-1;
    // MED3 004B3B88: weekly output minus city/population consumption.
    ReadProcessMemory(GHandle,Pointer(CityDZ[City]+$C4+i*4),@CityOutput,4,tmpNum);
    ReadProcessMemory(GHandle,Pointer(CityDZ[City]+$64+i*4),@CityUse,4,tmpNum);
    ReadProcessMemory(GHandle,Pointer(CityDZ[City]+$310+i*4),@PopulationUse,4,tmpNum);
    WeeklyBalance[i]:=(CityOutput-CityUse-PopulationUse)*7;
    ReadProcessMemory(GHandle,Pointer(SWSDZ[City]+4+i*4),@OfficeStock[i],4,tmpNum);
   end;//end for

for i:=0 to 7 do Aexp[i]:= BPower(2,i);
for j:=0 to 2 do
   begin
    DZ1:=DZ+j;
    ReadProcessMemory(GHandle, Pointer(DZ1+192), Pointer(@T),1,tmpNum);
    if T=0 then continue;
    for i:=7 downto 0  do
        begin
        if T>= Aexp[i] then
             begin
               T:=T-Aexp[i];
               Adata[2,i+j*8]:=1;
               if T=0 then break;
              end;
        end;
   end;//end for
end;


//-----------------------读取和显示内容---------------------------------
Procedure show_SWS(city:byte);
var
i,j:byte;
begin
with Frmsws do
begin
for i:=1 to 4 do
   for j:=1 to 20 do
      Strgid.Cells [i,j]:='';

for j:=0 to 19  do
  begin
  i:=sp_index(j);
  StrGid.Cells[1 ,i+1]:=inttostr(Adata[0,j] div Get_BZLX(j));

   case Adata[1,j] of
    0:strgid.Cells[2,i+1]:='---';
    -1:strgid.Cells[2,i+1]:='<--';
    1:strgid.Cells[2,i+1]:='-->';
   end;
    if Adata[2,j]=1 then
       strgid.Cells[3,i+1]:='√'
     else
       strgid.Cells[3,i+1]:='';
        strgid.Cells[4,i+1]:=inttostr(Adata[3,j]);
    if WeeklyBalance[j]>0 then
      StrGid.Cells[6,i+1]:=IntToStr(WeeklyBalance[j] div Get_BZLX(j))
    else StrGid.Cells[6,i+1]:='';
    if OfficeStock[j]>0 then
      StrGid.Cells[7,i+1]:=IntToStr(OfficeStock[j] div Get_BZLX(j))
    else StrGid.Cells[7,i+1]:='';

 end;//end for
 if StaBar.Panels.Count>1 then
   StaBar.Panels[1].Text:=IntToHex(SWSDZ[City],8);
end;//end with
end;

//-------------------------------------------------------------------
procedure TFrmSWS.ComBoxChange(Sender: TObject);
begin
 StaBar.Panels[0].Text  :=combox.Text;
city:=combox.ItemIndex ;
Home:=City; // Final binary shares the current-city byte with other forms.
Read_SWS(city);
show_SWS(city);
end;
//------------------------------下一个---------------------------------
procedure TFrmSWS.Button3Click(Sender: TObject);
begin
if combox.ItemIndex=CityCunt-1 then
combox.ItemIndex :=0
else
combox.ItemIndex :=combox.ItemIndex+1;
city:=combox.ItemIndex;
Home:=City;
Read_SWS(city);
show_SWS(city);
//label2.Caption :=inttohex(swsdz[city]+$2c0,8);
end;
//-----------------------------上一个----------------------------------
procedure TFrmSWS.Button2Click(Sender: TObject);
begin
if combox.ItemIndex=0 then
combox.ItemIndex :=CityCunt-1
else
combox.ItemIndex :=combox.ItemIndex-1;
City:=combox.ItemIndex;
Home:=City;
Read_SWS(City);
show_SWS(City);
end;
//---------------------------------------------------------------------


procedure TFrmSWS.Button4Click(Sender: TObject);
var
i:word;
DZ,jg:integer;
M,N,T:byte;
ALock:array[0..2] of byte;
AT:array[0..7] of byte;

begin
if Sws_zt(City)<>2 then exit;
for i:=0 to 2 do ALock[i]:=0;
for i:=0 to 7 do AT[i]:= BPower(2,i);
DZ:=SWSDZ[City]+756;
T:=0;


for i:=0 to 19  do
  begin
    M:=i div 8;
    N:=i mod 8;
    if Adata[2,i]=1 then  Alock[M]:=Alock[M]+AT[N];   //锁定解码

       jg:=Adata[1,i]*Adata[3,i];
       if jg<> 0 then T:=1;
       writeprocessmemory(GHandle, Pointer(DZ+i*4), Pointer(@jg),4,tmpNum);
       writeprocessmemory(GHandle, Pointer(Dz+96+i*4), Pointer(@Adata[0,i]),4,tmpNum); //数量
   end;
  writeprocessmemory(GHandle, Pointer(DZ-30), Pointer(@T),1,tmpNum);//为1事务所才能开始买卖

for i:= 0 to 2 do
    writeprocessmemory(GHandle, Pointer(DZ+i+192), Pointer(@Alock[i]),1,tmpNum);  //锁定写入

show_SWS(city);
StaBar.Panels[0].Text :='已更新当前事务所';
end;

// MED3 004B5E00: smart procurement (price templates now save on editing).
procedure TFrmSWS.Button1Click(Sender: TObject);
var
  I, Weeks: Integer;
begin
  Weeks:=Spin.Value;
  for I:=0 to 19 do
    if Adata[2,I]<>1 then
    begin
      if WeeklyBalance[I]>=Get_BZLX(I) then
      begin
        Adata[0,I]:=WeeklyBalance[I]*Weeks;
        Adata[3,I]:=Adata[4,I];
        Adata[1,I]:=-1;
      end
      else
      begin
        Adata[0,I]:=0;
        Adata[3,I]:=Adata[5,I];
        Adata[1,I]:=1;
      end;
    end;
  Show_SWS(City);
end;

//-----------------------------智能买卖---------------------------------
procedure TFrmSWS.Button7Click(Sender: TObject);
var
i:word;
begin
Get_CSCx(City,7,2);
for i:=0 to 19 do
    begin
    if  CScxSL[i]>200  then
           begin
              Adata[0,i]:=9999*Get_BZLX(i);
              Adata[3,i]:=Adata[4,i];
              Adata[1,i]:=-1;
            end
            else
            begin
              Adata[0,i]:=0;
              Adata[3,i]:=Adata[5,i];
              Adata[1,i]:=1;
            end ;
end;
show_SWS(City);
end;


//--------------------------锁定事务所-----------------------------
procedure TFrmSWS.Button6Click(Sender: TObject);
var
Atime:byte;
i,DZ:integer;
Acity:byte;

M,N:byte;
ALock:array[0..2] of byte;
AT:array[0..7] of byte;

begin
Atime:=SpinEdit1.Value ;
for i:=0 to 7 do AT[i]:= BPower(2,i);

for Acity:=0 to Citycunt-1 do
begin
if Sws_zt(ACity)<>2 then continue;
for i:=0 to 2 do ALock[i]:=0;
  FinalCityBalance(ACity,Atime);
  DZ:=SWSDZ[ACity]+756;
  for i:=0 to 19 do
    begin
      // 004B474F..004B4796: [goods*16+1], Int64 abs, round to package units.
      Adata[0,i]:=Round(Abs(FinalBalance[i,1])/Get_BZLX(i))*Get_BZLX(i);
      if Adata[0,i] >0 then
         begin
         Adata[2,i]:=1;
         writeprocessmemory(GHandle, Pointer(Dz+96+i*4), Pointer(@Adata[0,i]),4,tmpNum); //数量
         end
         else
         Adata[2,i]:=0;
    end; //end for i

 for i:=0 to 19  do
  begin
    M:=i div 8;
    N:=i mod 8;
    if Adata[2,i]=1 then  Alock[M]:=Alock[M]+AT[N];   //锁定解码
   end;

for i:= 0 to 2 do
    writeprocessmemory(GHandle, Pointer(DZ+i+192), Pointer(@Alock[i]),1,tmpNum);  //锁定写入

end;//end for Acity
Read_SWS(City);
show_SWS(City);
StaBar.Panels[0].Text :='已更新所有事务所材料锁定';
end;

//-------------------------------------------------------------
procedure TFrmSWS.FormCreate(Sender: TObject);
var
i:integer;
begin
StrGid.ColCount:=8;
for i:=0 to 19  do
  strgid.Cells[0,i+1]:=SpName[index_sp(i)];
  strgid.Cells[0,0]:='商品';
  strgid.Cells[1,0]:='储备';
  strgid.Cells[2,0]:='买卖';
  strgid.Cells[3,0]:='锁定';
  strgid.Cells[4,0]:='价格';
  strgid.Cells[5,0]:='全局采购';
  strgid.Cells[6,0]:='城镇产消';
  strgid.Cells[7,0]:='库存';

  strgid2.Cells[0,0]:='买价[模]';
  strgid2.Cells[1,0]:='卖价[模]';

  GameJg[0]:=142;GameJg[1]:=1500;GameJg[2]:=527;GameJg[3]:=41;GameJg[4]:=33;
  GameJg[5]:=200;GameJg[6]:=360;GameJg[7]:=380;GameJg[8]:=330;GameJg[9]:=1170;
  GameJg[10]:=130;GameJg[11]:=70;GameJg[12]:=440;GameJg[13]:=360;GameJg[14]:=1050;
  GameJg[15]:=110;GameJg[16]:=1100;GameJg[17]:=500;GameJg[18]:=240;GameJg[19]:=150;


end;

//---------------------------刷新-------------------------------------
procedure TFrmSWS.Button8Click(Sender: TObject);
var
i:word;
begin
MbName:=RadGroup.Items.Strings[RadGroup.itemindex];
Combox.Items.Clear;
for i:=0 to CityCunt-1 do
Combox.Items.Add (inttostr(i)+' '+Cityname[i]);
ReadProcessMemory(GHandle,Pointer($6E2F2C),@City,1,tmpNum);
if City>40 then City:=0;
Home:=City;
combox.ItemIndex :=city;
FrmSWS.RadGroupClick(Sender);
Read_SWS(city);
show_SWS(city);

end;

//-------------------------价格显示-----------------------------------
procedure TFrmSWS.RadGroupClick(Sender: TObject);
var
vFIni: TIniFile;
sFileName: string;
Stemp:string;
i,j:word;
DZ:integer;
begin
sFileName := MedConfigFileName;
MbName:=RadGroup.Items.Strings[RadGroup.itemindex];
// MED3 004B4C1C clears the working table and loads templates without game writes.
FillChar(Adata,SizeOf(Adata),0);
FillChar(WeeklyBalance,SizeOf(WeeklyBalance),0);
FillChar(OfficeStock,SizeOf(OfficeStock),0);

   vFIni := TIniFIle.Create(sFileName);

for i:=0 to 19 do
   begin
     Stemp:=vFIni.ReadString(MbName, 'B'+inttostr(i), '0');  //买
     Adata[4,i]:=strtoint(stemp);
     Stemp:=vFIni.ReadString(MbName, 'S'+inttostr(i), '0');// 卖
     Adata[5,i]:=strtoint(stemp);

     if Adata[4,i]=0 then
          Adata[4,i]:=GameJg[i];
     if Adata[5,i]=0 then
          Adata[5,i]:=GameJg[i];

       j:=sp_index(i);
       strgid2.Cells[0,j+1]:=inttostr(Adata[4,i]);
        strgid2.Cells[1,j+1]:=inttostr(Adata[5,i]);
   end;
vFIni.Free;
end;
//--------------------------------------------------
procedure TFrmSWS.SpinEdit1Change(Sender: TObject);
begin
if SpinEdit1.Value <1 then SpinEdit1.Value :=30;
if SpinEdit1.Value >30 then SpinEdit1.Value :=1;
end;
//----------------------------------------------
procedure TFrmSWS.Button10Click(Sender: TObject);
var
i:word;
begin
MM:=MM+1;
if MM>1 then MM:=-1;

for i:=0 to 19 do
begin
Adata[1,i]:=MM;
case Adata[1,i] of
    -1:
    begin
    Adata[0,i]:=9999*Get_BZLX(i);
    Adata[3,i]:=Adata[4,i];
    end;
     0:
    begin
     Adata[0,i]:=0;
     Adata[3,i]:=0;
    end;
     1:
     begin
      Adata[0,i]:=0;
      Adata[3,i]:=Adata[5,i];
    end;
    end;
end;
Button4Click(Sender); // MED3 004B5084 immediately applies the cycled mode.
end;
//-----------------------------------------------------------------
procedure TFrmSWS.StrGidMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
i,DZ,JG:integer;
ACity:Byte;
begin
if StrGid.Row=0 then Exit;
i:=index_sp(Strgid.Row-1);
case StrGid.Col of
    1,4:
         StrGid.Options:=StrGid.Options+[goEditing];
    2:
     begin
     StrGid.Options:=StrGid.Options-[goEditing];
     Adata[1,i]:=Adata[1,i]-1;
     if Adata[1,i]<-1 then Adata[1,i]:=1;
     case Adata[1,i] of
        -1:begin
             Adata[0,i]:=9999*Get_BZLX(i);
             Adata[3,i]:=Adata[4,i];
            end;
         0: begin
              Adata[0,i]:=0;
              Adata[3,i]:=0;
            end;
        1:begin
            Adata[0,i]:=0;
            Adata[3,i]:=Adata[5,i];
           end;
         end;
     end;
    3:
      begin
      StrGid.Options:=StrGid.Options-[goEditing];
      if Adata[2,i]=1 then
         Adata[2,i]:=0
         else
          Adata[2,i]:=1;
       end;
    5:
      begin
        // MED3 004B5164: apply this commodity's buy/sell choice to all offices.
        StrGid.Options:=StrGid.Options-[goEditing];
        if StrGid.Cells[5,StrGid.Row]='' then
        begin
          StrGid.Cells[5,StrGid.Row]:='√';
          Adata[1,i]:=-1;
          Adata[0,i]:=9999*Get_BZLX(i);
          Adata[3,i]:=Adata[4,i];
        end
        else
        begin
          StrGid.Cells[5,StrGid.Row]:='';
          Adata[1,i]:=1;
          Adata[0,i]:=0;
          Adata[3,i]:=Adata[5,i];
        end;
        JG:=Adata[1,i]*Adata[3,i];
        for ACity:=0 to CityCunt-1 do
          if SWS_ZT(ACity)=2 then
          begin
            DZ:=SWSDZ[ACity]+756;
            WriteProcessMemory(GHandle,Pointer(DZ+i*4),@JG,4,tmpNum);
            WriteProcessMemory(GHandle,Pointer(DZ+96+i*4),@Adata[0,i],4,tmpNum);
          end;
      end;
  end;//end case
end;


//---------------------------------------------------
procedure TFrmSWS.Button11Click(Sender: TObject);
var
i,j,c:word;
DZ,jg:integer;
begin
c:=0;
for j:=0 to Citycunt-1 do
begin
if SWS_ZT(j)<>2 then continue;
c:=c+1;
DZ:=SWSDZ[j]+756;
for i:=0 to 19  do
  begin
       ReadProcessMemory(GHandle, Pointer(DZ+i*4), Pointer(@jg),4,tmpNum);
       if jg>0 then  jg:=Adata[5,i];
       if jg<0 then  jg:=0-Adata[4,i];
       writeprocessmemory(GHandle, Pointer(DZ+i*4), Pointer(@jg),4,tmpNum);
   end;
end;
Read_SWS(City);
show_SWS(city);
StaBar.Panels[0].Text :='已更新'+inttostr(c)+'所事务所价格';
end;


//-------------------------------------------------------
procedure TFrmSWS.StrGidKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
C,R,T:integer;
begin
C:=Strgid.Col;
R:=Strgid.Row;
T:=index_sp(R-1);
case c of
   1:
   Adata[C-1,T]:=Get_Num(Strgid.Cells[c,R])*Get_BZLX(T);
   4:Adata[C-1,T]:=Get_Num(Strgid.Cells[c,R]);
   end;
end;

//--------------------------------------------------------------
procedure TFrmSWS.StrGidMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
show_sws(city);
// MED3 004B580C calls 004B44CC (the former explicit apply operation).
Button4Click(Sender);
end;



//-------------------------------------------------------------
procedure TFrmSWS.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
with StrGid do
begin
  If  ARow=0  Then exit;
  If  (ACol=0) Then exit;
  If gdSelected In State Then Canvas.Brush.Color := clHighlight;  //选中的单元格背景色和字体色
  if  AData[1,index_sp(Arow-1)]=-1  then
      Canvas.Brush.Color := RGB(6,231,249);
      Canvas.FillRect(Rect);
      Canvas.TextOut(Rect.Left + 2, Rect.Top + 2,Cells[ACol, ARow]);

end;
end;
//-----------------------------------------------------------
procedure TFrmSWS.StrGid2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
T:integer;
begin
if Strgid2.Col =2 then exit;
T:=index_sp(Strgid2.Row-1);
Adata[Strgid2.Col+4,T]:=Get_Num(Strgid2.Cells[Strgid2.Col,Strgid2.Row]);
end;




// MED3 004B5BD0; both B/S branches verified against x86, since Ghidra
// incorrectly marked the sell-price branch unreachable.
procedure TFrmSWS.StrGid2SetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var
  T: Integer;
  Ini: TIniFile;
  KeyName, Section: string;
begin
  if StrGid2.Col=2 then Exit; // 004B5C22 tests the grid's current column.
  if (ACol<0) or (ACol>1) or (ARow<1) or (ARow>20) then Exit;
  if RadGroup.ItemIndex<0 then Exit;
  T:=index_sp(ARow-1);
  Adata[ACol+4,T]:=Get_Num(Value);
  Section:=RadGroup.Items[RadGroup.ItemIndex];
  if ACol=0 then KeyName:='B' else KeyName:='S';
  Ini:=TIniFile.Create(MedConfigFileName);
  try
    Ini.WriteString(Section,KeyName+IntToStr(T),Value);
  finally
    Ini.Free;
  end;
  StaBar.Panels[0].Text:='已保存到：'+Section;
end;

// MED3 004B593C: hidden diagnostic office table.
procedure TFrmSWS.Button5Click(Sender: TObject);
var
  I, DZ: Integer;
  NextOffice: Word;
  ACity, Owner: Byte;
begin
  StrGid1.RowCount:=SWSCunt+1;
  for I:=0 to Player-1 do
  begin
    ReadProcessMemory(GHandle,Pointer(PlaysJZ+I*$650+12),@NextOffice,2,tmpNum);
    StrGid1.Cells[5,I+1]:=IntToStr(NextOffice);
  end;
  for I:=0 to SWSCunt-1 do
  begin
    DZ:=SWSJZ+I*$44C;
    if I<=High(SwsDz2) then SwsDz2[I]:=DZ;
    ReadProcessMemory(GHandle,Pointer(DZ+$2C6),@ACity,1,tmpNum);
    ReadProcessMemory(GHandle,Pointer(DZ+$2C8),@NextOffice,2,tmpNum);
    ReadProcessMemory(GHandle,Pointer(DZ+$2C4),@Owner,1,tmpNum);
    StrGid1.Cells[0,I+1]:=IntToStr(I);
    StrGid1.Cells[1,I+1]:=IntToHex(DZ,8);
    StrGid1.Cells[2,I+1]:=CityName[ACity];
    StrGid1.Cells[3,I+1]:=PopName[Owner];
    StrGid1.Cells[4,I+1]:=IntToStr(NextOffice);
  end;
end;

procedure TFrmSWS.StrGid1Click(Sender: TObject);
begin
  // The final binary uses row-1 as a city index, despite the diagnostic table
  // containing office indices. Preserve that observed call, not an inferred remap.
  if (StrGid1.Row<1) or (StrGid1.Row>CityCunt) then Exit;
  Read_SWS(StrGid1.Row-1);
  Show_SWS(StrGid1.Row-1);
end;

end.
