unit Untplays;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls,Untpublic;

type
  TFrmPlays = class(TForm)
    Panel1: TPanel;
    StrGid1: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StrGid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPlays: TFrmPlays;

implementation

{$R *.dfm}

procedure TFrmPlays.Button1Click(Sender: TObject);
var
i:integer;
temp1,temp2:integer;
Btemp:byte;
begin
strgid1.RowCount :=Player+1;
for i:=0 to Player-1 do
    begin
    strgid1.Cells[0,i+1]:=inttostr(i);
    temp2:=PlaysJz+i*$650;
    strgid1.Cells[1,i+1]:=PopName[i];
    ReadProcessMemory(GHandle, Pointer(temp2+24), Pointer(@Btemp),1,tmpNum);
    strgid1.Cells[2,i+1]:=CityName[Btemp];
    ReadProcessMemory(GHandle, Pointer(temp2), Pointer(@temp1),4,tmpNum);
    strgid1.Cells[3,i+1]:=inttostr(temp1);
    ReadProcessMemory(GHandle, Pointer(temp2+$3ab), Pointer(@Btemp),1,tmpNum);
    strgid1.Cells[4,i+1]:=Peopcap[Btemp];
    strgid1.Cells[5,i+1]:=inttohex(temp2,8);
    //strgid1.Cells[5,i+1]:=inttohex(temp2,8);//+$3ab
    //strgid1.Cells[6,i+1]:=inttohex(temp2+$650,8);//+$3ab

    end;
end;


procedure TFrmPlays.FormCreate(Sender: TObject);
begin
with strgid1 do
 begin
  Cells[0,0]:='编号';
  Cells[1,0]:='名字';
  Cells[2,0]:='家乡';
  Cells[3,0]:='金钱';
  Cells[4,0]:='称呼';
  //Cells[6,0]:='地址';
  colwidths[0]:=40;
  colwidths[1]:=140;
 end;
end;

procedure TFrmPlays.StrGid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
With StrGid1 Do
   Begin
     If  (ACol=0) or (Arow=0)  Then exit;             //标题栏退出
     if   ARow   mod   2= 0   then
         Canvas.Brush.Color:=   RGB(255,255,255)
      else
         Canvas.Brush.Color:=   RGB(230,230,230);
     If gdSelected In State Then Canvas.Brush.Color := clHighlight;  //选中的单元格背景色和字体色
     Canvas.FillRect(Rect);
     Canvas.TextOut(Rect.Left+5 , Rect.Top + 2, Cells[ACol, ARow]);
   end;

end;





procedure TFrmPlays.Button2Click(Sender: TObject);
var
i:integer;
begin
strgid1.RowCount  :=100;
for i:=0 to 98 do
begin
strgid1.Cells [0,i+1]:=inttostr(i);
strgid1.Cells [1,i+1]:=PoPNamex[i];
strgid1.Cells [2,i+1]:=PoPNameM[i];
end;
end;

end.
