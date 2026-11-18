unit UntShowShip;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls, StdCtrls, ExtCtrls,Untpublic;

type
  TFrmShowShip = class(TForm)
    Panel1: TPanel;
    StrGid: TStringGrid;
    Panel3: TPanel;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    CheckBox1: TCheckBox;

    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmShowShip: TFrmShowShip;
  procedure show_ship;
implementation

{$R *.dfm}

procedure show_ship;
var
temp,temp2,ZDll,ZDnj,DQnj,Stime,Etime:integer;
shipLX,shipZT,shipTK,shipcf,shipmd:Byte;
i,j,k,shipCZ,sNext,OwnerNext,GlobalNext:Word;
ShipL:array[0..5000] of word;
begin
fillchar(ShipL,sizeof(shipL),$FFFF);
ReadProcessMemory(GHandle, Pointer($71cdbc),Pointer(@Stime), 4, tmpNum);
ReadProcessMemory(GHandle, Pointer($71CE20), Pointer(@sNext),2,tmpNum);
K:=0;

if Frmshowship.checkbox1.Checked then
  begin
    for i:=0 to 4 do
       begin
          ReadProcessMemory(GHandle, Pointer($6DFB94+i*4), Pointer(@temp),4,tmpNum); // 海盗船只基址
          if temp=0 then continue;
             temp2:=temp +12;
             ReadProcessMemory(GHandle, Pointer(temp2), Pointer(@sNext),2,tmpNum);
             while sNext<>$FFFF  do
                  begin
                    ShipL[k]:=sNext;
                    ShipL[k]:=sNext;
                    temp:= ShipJz + sNext * $180;
                    ReadProcessMemory(GHandle, Pointer(temp+4),Pointer(@sNext), 2, tmpNum);
                    k:=k+1;
               end;//end while
          end;

    for i:=0 to Player-1 do
        begin
              temp:=PlaysJz +i*$650+ 14;
              ReadProcessMemory(GHandle, Pointer(temp), Pointer(@sNext),2,tmpNum);
               while sNext<>$FFFF do
                  begin
                   ShipL[k]:=sNext;
                   temp:= ShipJz + sNext * $180;
                   ReadProcessMemory(GHandle, Pointer(temp+4),Pointer(@sNext), 2, tmpNum);
                   k:=k+1;
                  end;
          end;
    end
    else
       begin
              temp:=PlaysJz +(Player-1)*$650+ 14;
              ReadProcessMemory(GHandle, Pointer(temp), Pointer(@sNext),2,tmpNum);
               while sNext<>$FFFF do
                  begin
                   ShipL[k]:=sNext;
                   temp:= ShipJz + sNext * $180;
                   ReadProcessMemory(GHandle, Pointer(temp+4),Pointer(@sNext), 2, tmpNum);
                   k:=k+1;
                  end;
          end;

 Frmshowship.strgid.RowCount:=k+1;
for j:=0 to k-1 do
    begin
    temp:= ShipJz + ShipL[j] * $180;
    ReadProcessMemory(GHandle, Pointer(temp), Pointer(@MaoYiZe),1,tmpNum);//---船只主人
    ReadProcessMemory(GHandle, Pointer(temp+308),Pointer(@shipZT),1,tmpNum); //-船只状态
    ReadProcessMemory(GHandle, Pointer(temp+14),Pointer(@shipLX), 1, tmpNum);//--------------船只类型
    ReadProcessMemory(GHandle, Pointer(temp+16),Pointer(@ZDll), 4, tmpNum);//----------------船只最大容量
    ReadProcessMemory(GHandle, Pointer(temp+20),Pointer(@ZDnj), 4, tmpNum);//----------------船只最大耐久
    ReadProcessMemory(GHandle, Pointer(temp+24),Pointer(@DQnj), 4, tmpNum);//----------------船只当前耐久
    ReadProcessMemory(GHandle, Pointer(temp+55),Pointer(@shipcf), 1, tmpNum);//---------------- 出发地
    ReadProcessMemory(GHandle, Pointer(temp+56),Pointer(@shipmd), 1, tmpNum);//---------------- 目的地
    ReadProcessMemory(GHandle, Pointer(temp+57),Pointer(@shipTK), 1, tmpNum);//--------------船只停靠地
    ReadProcessMemory(GHandle, Pointer(temp+66),Pointer(@shipCZ), 2, tmpNum);//--------------船只船长
    ReadProcessMemory(GHandle, Pointer(temp+72),Pointer(@Etime), 4, tmpNum);
    ReadProcessMemory(GHandle, Pointer(temp+4),Pointer(@OwnerNext),2,tmpNum);
    ReadProcessMemory(GHandle, Pointer(temp+6),Pointer(@GlobalNext),2,tmpNum);

    //显示输出－－－－－－－－显示输出－－－－－－－－显示输出－－－－－－－显示输出
    i:=j+1;
    with Frmshowship.strgid do
     begin
    //RowCount:=k+1;
    Cells [0,i]:= IntToStr(ShipL[j]);
    if  MaoYiZe>250 then
    Cells [1,i]:=inttostr(MaoYiZe)
    else
    Cells [1,i]:=PopName[MaoYiZe]; //-----------------------------------船只所有者
    Cells [2,i]:=Get_String(temp + $160);//------------------------------船只名称
    Cells [3,i]:=ShipLxName[shipLX]; //---------------------------------船只类型
    if shipCZ<>$FFFF then Cells [4,i]:=IntToStr(shipCZ)
    else Cells[4,i]:='';
    Cells[5,i]:=IntToStr(shipZT);
    case shipZt of
         0,1,2,3,6,14:
         Cells [6,i]:=CityName[shipTK];
         15:Cells [6,i]:='海上';
        else
         Cells [6,i]:='';
        end;



     Cells [7,i]:=inttostr(Zdll div 200);                     //-------船只最大容量
    if (ZDnj>0) and (DQnj<=ZDnj) then
      Cells [8,i]:='     '+inttostr(round(DQnj/ZDnj*100))+'%';//船只耐久
    if (shipmd<citycunt) and (shipZt=15) then
       Cells [9,i]:=cityname[shipmd]
       else
        Cells [9,i]:='';
      Etime:=Etime-Stime;
     if Etime>0 then
        Cells [10,i]:=formatfloat('0.00',Etime/256)
        else
         Cells [10,i]:='';
      Cells[11,i]:=IntToStr(OwnerNext);
      Cells[12,i]:=IntToStr(GlobalNext);
     end;//end with

  end;  //end while

Frmshowship. StatusBar1.Panels[0].Text :='共有'+inttostr(K)+'只船/舰队';
end;





//**********************************************************************************
procedure TFrmShowShip.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
with StrGid do
begin
  If  ARow=0  Then exit;
  If  ACol=0  Then exit;
  if   ARow   mod   2   =   0   then
      Canvas.Brush.Color   :=   RGB(255,255,255)
      else
      Canvas.Brush.Color   :=   RGB(230,230,230);
  If gdSelected In State Then Canvas.Brush.Color := clHighlight;  //选中的单元格背景色和字体色
  if  Cells[1,ARow]='255'  then
      Canvas.Brush.Color := clgray;
      Canvas.FillRect(Rect);
      Canvas.TextOut(Rect.Left + 2, Rect.Top + 2,Cells[ACol, ARow]);
   
end;

end;



//******************************************************************************


procedure TFrmShowShip.FormCreate(Sender: TObject);
begin
with strgid do
  begin
// Final 004a28d8 stores both links although its DFM declares only 11 columns.
// Retain those diagnostic values without exposing extra visible columns.
strgid.ColCount:=13;
strgid.ColWidths[11]:=0;
strgid.ColWidths[12]:=0;
strgid.ColWidths[0]:=50;
strgid.ColWidths[1]:=100;
strgid.ColWidths[2]:=90;
strgid.ColWidths[4]:=50;
Cells [0,0]:='编号';Cells [1,0]:='船主';Cells [2,0]:='船名';Cells [3,0]:='船型';Cells [4,0]:='船长';
Cells [5,0]:='状态';Cells [6,0]:='地点';Cells [7,0]:='容量';Cells [8,0]:='完好';
Cells [9,0]:='目的地';Cells [10,0]:='时间'
// Cells [9,0]:='地址'; ;Cells [14,0]:='时间';Cells [10,0]:='船速'; Cells [11,0]:='出发地';
end;

end;









procedure TFrmShowShip.CheckBox1Click(Sender: TObject);
begin
show_ship;
end;

end.
