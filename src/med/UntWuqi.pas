unit UntWuqi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Untpublic, ComCtrls, Grids, StdCtrls;

type
  TFrmWuqi = class(TForm)
    TabControl1: TTabControl;
    StrGid: TStringGrid;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure TabControl1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmWuqi: TFrmWuqi;

implementation

{$R *.dfm}

procedure TFrmWuqi.FormCreate(Sender: TObject);
var
i:word;
begin

with Strgid do
begin
  Cells[1,0]:='刀';
  Cells[2,0]:='弓';
  Cells[3,0]:='石弓';
  Cells[4,0]:='卡槟枪';
  Cells[5,0]:='小投';
  Cells[6,0]:='小驽';
  Cells[7,0]:='大投';
  Cells[8,0]:='大驽';
  Cells[9,0]:='铁炮';
  Cells[10,0]:='加农';
  Cells[11,0]:='短剑';
  ColWidths[0]:=80;

end;
end;

procedure TFrmWuqi.Button1Click(Sender: TObject);
var
A:byte;

i,j,temp2:word;
Dz,temp,DZtemp:integer;
begin

  StrGid.ColWidths[0]:=100;
  Strgid.Rowcount:=citycunt+1;
for i:=0 to citycunt-1 do
begin
     case TabControl1.TabIndex of
       0:Dztemp:=CityDZ[i];
       1:Dztemp:=SWSDZ[i];
       end;
     if Dztemp=0 then
        begin
        for j:=1 to StrGid.ColCount-1 do
            Strgid.Cells[j,i+1]:='';
            continue;
       end;

     DZ:=Dztemp+$54;
      for j:=0 to 5 do
     begin
       ReadProcessMemory(GHandle, Pointer(DZ+j*4), Pointer(@temp2),2,tmpNum);
       if temp2=0 then
          Strgid.Cells[j+1,i+1]:=''
          else
          Strgid.Cells[j+1,i+1]:=formatfloat('0.0',temp2/10);
     end;
   DZ:=Dztemp+$124;

   for j:=0 to 5 do
     begin
       ReadProcessMemory(GHandle, Pointer(DZ+j*4), Pointer(@temp),4,tmpNum);
       if temp=0 then
          Strgid.Cells[j+5,i+1]:=''
          else
          case j of
              0,1,5:Strgid.Cells[j+5,i+1]:=formatfloat('0.0',temp div 1000);
              2,3,4:Strgid.Cells[j+5,i+1]:=formatfloat('0.0',temp div 2000);
           end;
      end;

    DZ:=Dztemp+$2BC;
    ReadProcessMemory(GHandle, Pointer(DZ), Pointer(@A),1,tmpNum);
    if A=0 then
       Strgid.Cells[11,i+1]:=''
       else
       Strgid.Cells[11,i+1]:=inttostr(A);

end;
end;

procedure TFrmWuqi.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
const
  Headers: array[1..11] of string =
    ('刀','弓','石弓','卡槟枪','小投','小驽','大投','大驽','铁炮','加农','短剑');
begin
With StrGid Do
    Begin
      if (ARow=0) and (ACol>0) then
      begin
        Canvas.TextOut(Rect.Left+10,Rect.Top+5,Headers[ACol]);
        Exit;
      end;
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
     If gdSelected In State Then Canvas.Brush.Color := clHighlight;  //选中的单元格背景色和字体色

     If  ARow<>0  Then
         begin
           Canvas.FillRect(Rect);
           //if Cells[ACol, ARow]='0.0' then Cells[ACol, ARow]:='';
           Canvas.TextOut(Rect.Left + 5, Rect.Top + 5, Cells[ACol, ARow]);
         end;

    end;
end;



procedure TFrmWuqi.TabControl1Change(Sender: TObject);
begin
FrmWuqi.Button1Click(Sender);
end;

end.
