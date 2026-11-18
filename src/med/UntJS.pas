unit UntJS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,Untpublic;

type
  TFrmJS = class(TForm)
    StrGid: TStringGrid;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmJS: TFrmJS;
  MilitaryMark: array[1..9,0..39] of Byte;
implementation



{$R *.dfm}
procedure TFrmJS.Button1Click(Sender: TObject);
var
  i,j,CityBase,RecordBase,RecordAddress,Total,Money: Integer;
  First,NextIndex,Slot: Word;
  Kind,Current,Training,Capacity: Byte;
  Towers: array[0..2] of string;
begin
  FillChar(MilitaryMark,SizeOf(MilitaryMark),0);
  StrGid.RowCount:=CityCunt+1;
  for i:=0 to CityCunt-1 do
  begin
    CityBase:=CityDZ[i];
    ReadProcessMemory(GHandle,Pointer(CityBase+$766),@First,2,tmpNum);
    if First<>$FFFF then MilitaryMark[1,i]:=1;
    StrGid.Cells[1,i+1]:='';
    for j:=0 to 2 do
    begin
      ReadProcessMemory(GHandle,Pointer(CityBase+$7b0+j*2),@Slot,2,tmpNum);
      if Slot<>$FFFF then Break;
      StrGid.Cells[1,i+1]:=StrGid.Cells[1,i+1]+'● ';
    end;
    for j:=0 to 2 do Towers[j]:='';
    ReadProcessMemory(GHandle,Pointer(CityBase+$75c),@RecordBase,4,tmpNum);
    ReadProcessMemory(GHandle,Pointer(CityBase+$768),@NextIndex,2,tmpNum);
    while NextIndex<>$FFFF do
    begin
      RecordAddress:=RecordBase+NextIndex*8;
      ReadProcessMemory(GHandle,Pointer(RecordAddress+3),@Kind,1,tmpNum);
      ReadProcessMemory(GHandle,Pointer(RecordAddress+4),@NextIndex,2,tmpNum);
      if (Kind>=$30) and (Kind<=$35) then
      begin
        j:=(Kind-$30) div 2;
        if (Kind and 1)=0 then Towers[j]:=Towers[j]+'●'
        else Towers[j]:=Towers[j]+'■';
      end;
    end;
    for j:=0 to 2 do StrGid.Cells[j+2,i+1]:=Towers[j];
    for j:=0 to 3 do
    begin
      ReadProcessMemory(GHandle,Pointer(CityBase+$998+j),@Current,1,tmpNum);
      ReadProcessMemory(GHandle,Pointer(CityBase+$99c+j),@Training,1,tmpNum);
      if Training<>0 then
      begin
        StrGid.Cells[j+5,i+1]:=IntToStr(Current)+'['+IntToStr(Training)+']';
        MilitaryMark[j+5,i]:=1;
      end
      else if Current<>0 then StrGid.Cells[j+5,i+1]:=IntToStr(Current)
      else StrGid.Cells[j+5,i+1]:='';
    end;
    ReadProcessMemory(GHandle,Pointer(CityBase+$9a0),@Capacity,1,tmpNum);
    Total:=0;
    for j:=0 to 7 do
    begin
      ReadProcessMemory(GHandle,Pointer(CityBase+$998+j),@Current,1,tmpNum);
      Total:=(Total+Current) and $FF;
    end;
    if Total<Capacity then MilitaryMark[9,i]:=1;
    StrGid.Cells[9,i+1]:=IntToStr(Total)+'/'+IntToStr(Capacity);
    ReadProcessMemory(GHandle,Pointer(CityBase+$700),@Money,4,tmpNum);
    StrGid.Cells[10,i+1]:=IntToStr(Money);
  end;
end;


procedure TFrmJS.FormCreate(Sender: TObject);
const
  Headers: array[0..10] of string =
    ('城市','城墙','城门炮','抛射','海港炮','监察','弓箭','石弓','步兵','总兵力','城市金库');
var
  I: Integer;
begin
with Strgid do
begin
  RowCount:=CityCunt+1;
  ColCount:=11;
  for I:=0 to 4 do ColWidths[I]:=110;
  for I:=0 to 10 do Cells[I,0]:=Headers[I];
end;
end;

procedure TFrmJS.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
With StrGid Do
   Begin
     if (ACol=0) and (ARow>0) then
     begin
       Canvas.Draw(Rect.Left,Rect.Top,SpBmp[23+CityMarker[ARow-1]]);
       Canvas.TextOut(Rect.Left+25,Rect.Top+5,CityName[ARow-1]);
       Exit;
     end;
     If ACol=0 Then Exit;
     if   ARow   mod   2   =   0   then
         Canvas.Brush.Color   :=   RGB(255,255,255)
      else
         Canvas.Brush.Color   :=   RGB(220,220,220);
     If gdSelected In State Then Canvas.Brush.Color := clSilver;
     
     If  ARow<>0  Then
         begin
           Canvas.FillRect(Rect);
           if (ACol<10) and (Cells[ACol,ARow]<>'') and
              (MilitaryMark[ACol,ARow-1]<>0) then
           begin
             Canvas.Brush.Color:=$C0DCC0;
             Canvas.FillRect(Rect);
           end;
           Canvas.TextOut(Rect.Left+5,Rect.Top+5,Cells[ACol,ARow]);
         end;

    end;
end;

end.
