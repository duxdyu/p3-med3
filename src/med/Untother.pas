unit Untother;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons,Untpublic, ExtCtrls,ComObj;

type
  TFrmother = class(TForm)
    BitBtn1: TBitBtn;
    Label8: TLabel;
    Strtest: TStringGrid;
    Panel1: TPanel;
    Edit2: TEdit;
    Label4: TLabel;
    Label6: TLabel;
    Label5: TLabel;
    Edit3: TEdit;
    Edit5: TEdit;
    Button2: TButton;
    Button3: TButton;
    Edit4: TEdit;
    Button1: TButton;
    Button4: TButton;
    procedure Button2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frmother: TFrmother;
  Acity:byte;
  k:word;
implementation

{$R *.dfm}


procedure TFrmother.Button2Click(Sender: TObject);
var
sl:integer;
i,j:byte;
begin

sl:=strtoint(edit2.text);


for j:=0 to 23 do
  begin
   Get_CSCx(j,1,10);
   for i:=0 to 19 do
       begin
        sl:=Abs(CScxSL[i])*strtoint(edit3.text);
        writeprocessmemory(GHandle,Pointer(CityDZ[j]+4+i*4),Pointer(@sl),4,tmpNum);
       end;
  end;
end;




//----------------------------------------------------------------
procedure TFrmother.BitBtn1Click(Sender: TObject);
var
E:array [1..3] of integer;
F:array [1..3] of integer;
G:array [1..3] of integer;
H:array [1..3] of integer;
A:array [1..3] of Int64;
B:array [1..3] of Int64;
C:array [1..3] of Int64;
D:array [1..3] of Int64;
dx,dy,dz,dd:Int64;
x,y,z:single;
i,j,k:word;
begin

       strtest.Cells[1,0]:='富豪';
       strtest.Cells[2,0]:='富人';
       strtest.Cells[3,0]:='穷人';

for k:=0 to 8 do
begin
//       strtest.Cells[k*3+1,0]:='富豪';
//       strtest.Cells[k*3+2,0]:='富人';
//       strtest.Cells[k*3+3,0]:='穷人';
for j:=0 to 2 do
   begin
       ReadProcessMemory(GHandle, Pointer(CityDZ[j+k*3]+$2d8+0), Pointer(@E[j+1]),4,tmpNum);
       ReadProcessMemory(GHandle, Pointer(CityDZ[j+k*3]+$2d8+4), Pointer(@F[j+1]),4,tmpNum);
       ReadProcessMemory(GHandle, Pointer(CityDZ[j+k*3]+$2d8+8), Pointer(@G[j+1]),4,tmpNum);
       A[j+1]:=E[j+1];
       B[j+1]:=F[j+1];
       C[j+1]:=G[j+1];
   end;
i:=0;
//for i:=0 to 19 do
   //begin
    // strtest.Cells[0,i+1]:=SpName[i];
      for j:=0 to 2 do
        begin
           ReadProcessMemory(GHandle, Pointer(CityDZ[j+k*3]+$310+i*4), Pointer(@H[j+1]),4,tmpNum);
           D[j+1]:=H[j+1];
        end;

       dx:=D[1]*B[2]*C[3]+D[2]*B[3]*C[1]+D[3]*B[1]*C[2]-C[1]*B[2]*D[3]-B[1]*D[2]*C[3]-B[3]*C[2]*D[1];
       dy:=A[1]*D[2]*C[3]+A[2]*D[3]*C[1]+D[1]*C[2]*A[3]-C[1]*D[2]*A[3]-C[2]*D[3]*A[1]-D[1]*A[2]*C[3];
       dz:=A[1]*B[2]*D[3]+A[2]*B[3]*D[1]+B[1]*D[2]*A[3]-D[1]*B[2]*A[3]-D[2]*B[3]*A[1]-D[3]*B[1]*A[2];
       dd:=A[1]*B[2]*C[3]+A[2]*B[3]*C[1]+B[1]*C[2]*A[3]-C[1]*B[2]*A[3]-C[2]*B[3]*A[1]-B[1]*A[2]*C[3];
       x:=dx /dd*7;
       y:=dy / dd*7;
       z:=dz / dd*7;
       strtest.Cells[1,k+1]:=FormatFloat('0.000',x);
       strtest.Cells[1,k+1]:=FormatFloat('0.000',x);
       strtest.Cells[2,k+1]:=FormatFloat('0.000',Y);
       strtest.Cells[3,k+1]:=FormatFloat('0.000',Z);
end;
end;

procedure TFrmother.FormCreate(Sender: TObject);
var
i:word;
begin
Strtest.cells[0,21]:='总人数';
Strtest.cells[0,22]:='富豪';
Strtest.cells[0,23]:='富人';
Strtest.cells[0,24]:='穷人';
Strtest.cells[0,25]:='乞丐';
Button4Click(Sender);
end;


procedure TFrmother.Button3Click(Sender: TObject);
var
sl:integer;

begin
Get_CSCx(Acity,7,10);
Edit2.Text :=inttostr(Abs(CScxSL[19]));
ReadProcessMemory(GHandle, Pointer(CityDZ[Acity]+4+19*4), Pointer(@sl),4,tmpNum);
edit4.Text :=inttostr(sl);
end;




procedure TFrmother.Button1Click(Sender: TObject);
var
  iCount, jCount: Integer;
  XLApp: Variant;
  Sheet: Variant;
  I: Integer;
begin
  if not VarIsEmpty(XLApp) then
  begin
    XLApp.DisplayAlerts := False;
    XLApp.Quit;
    VarClear(XLApp);
  end;

  try
    XLApp := CreateOleObject('Excel.Application');
  except
    Exit;
  end;

  XLApp.WorkBooks.Add;
  XLApp.SheetsInNewWorkbook := 1;
      XLApp.WorkBooks[1].WorkSheets[1].Name := Name;
      Sheet := XLApp.Workbooks[1].WorkSheets[Name];

      for jCount := 0 to strtest.RowCount -1 do
        for iCount := 0 to strtest.ColCount-1 do
          Sheet.Cells[jCount + 1, iCount + 1] := strtest.Cells[iCount, jCount];;
  XlApp.Visible := True;
end;

procedure TFrmother.Button4Click(Sender: TObject);
var
i:word;
Rk:word;
begin
Get_CSCx(0,1,10);
for i:=0 to 19 do
  begin
    Strtest.Cells[0,i+1]:=SpName[i];
    Strtest.Cells [1,i+1]:=inttostr(Abs(CScxSL[i]));
  end;
edit2.Text :=inttostr(Abs(CScxSL[16]));
end;

end.
