unit UntSc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids,Untpublic, StdCtrls, CheckLst, ExtCtrls, Buttons, ComCtrls;

type
  TFrmSc = class(TForm)
    Panel2: TPanel;
    TabControl1: TTabControl;
    StrGid: TStringGrid;
    procedure StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSc: TFrmSc;

implementation

{$R *.dfm}

const
  GoodsColumn: array[0..19] of Byte =
    (1,10,18,7,16,2,15,9,0,12,3,6,14,8,17,4,11,5,13,19);
  ColumnGoods: array[0..19] of Byte =
    (8,0,5,10,15,17,11,3,13,7,1,16,9,18,12,6,4,14,2,19);

//-------------------------------------------------------------------------
procedure TFrmSc.StrGidDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

begin

With StrGid Do
   Begin
      if (ACol=0) and (ARow>0) then
      begin
        Canvas.Draw(Rect.Left,Rect.Top,SpBmp[23+CityMarker[ARow-1]]);
        Canvas.TextOut(Rect.Left+25,Rect.Top+3,CityName[ARow-1]);
        Exit;
      end;
      If ACol=0 Then Exit;
     if   ARow   mod   2   =   0   then
         Canvas.Brush.Color   :=   RGB(255,255,255)
      else
         Canvas.Brush.Color   :=   RGB(220,220,220);
     If gdSelected In State Then Canvas.Brush.Color := clSilver;
     If  ARow=0  Then
         Canvas.Draw(Rect.Left,Rect.Top+1,SpBmp[ColumnGoods[ACol-1]])
         else
         begin
           Canvas.FillRect(Rect);
           Canvas.TextOut(Rect.Left,Rect.Top+3,Cells[ACol,ARow]);
         end;
     
    end;
end;
//-----------------------------------------------------------

procedure TFrmSc.FormCreate(Sender: TObject);
begin
  strgid.ColWidths[0]:=95;
end;

procedure TFrmSc.TabControl1Change(Sender: TObject);

  var
  i,j:word;
  temp:Integer;

begin
    strgid.RowCount:=CityCunt+1;

  case  TabControl1.TabIndex of
  0:begin
    for i:=0 to CityCunt-1 do
         for j:=0 to 19 do
           begin
              
              ReadProcessMemory(GHandle, Pointer(CityDZ[i]+j*4+4), Pointer(@temp),4,tmpNum);
              temp := round(temp / Get_BZLX(j));
              if temp=0 then StrGid.Cells[GoodsColumn[j]+1,i+1]:=''
              else StrGid.Cells[GoodsColumn[j]+1,i+1]:=IntToStr(temp);
           end;
   end;

  1: begin
     for i:=0 to CityCunt-1 do
         for j:=0 to 19 do
           begin
             StrGid.Cells[GoodsColumn[j]+1,i+1]:='';
             if SwsDZ[i]>0 then
                begin
                  ReadProcessMemory(GHandle, Pointer(SwsDZ[i]+j*4+4), Pointer(@temp),4,tmpNum);
                  temp := round(temp / Get_BZLX(j));
                  if temp<>0 then
                    StrGid.Cells[GoodsColumn[j]+1,i+1]:=IntToStr(temp);
                end;
            end;
     end;
end;
end;


end.



