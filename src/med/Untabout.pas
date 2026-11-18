unit Untabout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,Untpublic, Grids, Buttons;

type
  TFrmAbout = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Panel2: TPanel;
    StrGid: TStringGrid;
    BitBtn1: TBitBtn;
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAbout: TFrmAbout;

implementation

{$R *.dfm}

procedure TFrmAbout.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
//Panel1.Width:=FrmAbout.Width;

Button1.Left :=(FrmAbout.Width-Button1.Width)div 2+5;
end;

procedure TFrmAbout.Button1Click(Sender: TObject);
var
i:word;
begin
for i:=0 to citycunt-1 do
    strgid.Cells[0,i+1]:=inttostr(i)+'-'+CityName[i];
Game_init;
end;

procedure TFrmAbout.FormCreate(Sender: TObject);
begin
StrGid.RowCount:=citycunt+1;
Strgid.colwidths[0]:=80;

end;

procedure TFrmAbout.BitBtn1Click(Sender: TObject);
var
i,j,k,s:word;
DZ:integer;
T:array [0..39] of byte;
A0,A5,bz:byte;

begin
k:=0;
S:=$75c;
for i:=s to s+48 do
   begin
     bz:=1;
     for j:=0 to Citycunt-1 do
         begin
           DZ:=CityDZ[j]+i;
           ReadProcessMemory(GHandle, Pointer(DZ), Pointer(@T[j]),1,tmpNum);
         end;
     A0:=T[0];
     A5:=T[5];
     for j:=0 to citycunt-1 do
        begin
             //if T[0]=T[5] then
             //     begin
             //       bz:=0;
              //      break;
              //      end;
                    
            // case j of
              // 5,19,23:if (T[j]<>A5) or (bz=0) then
                         //  begin
                          //   bz:=0;
                          //   continue;
                           //  end;
               // else
                //   if (T[j]<>A0) or (bz=0) then
                 //          begin
                //             bz:=0;
                 //            continue;
                 //            end;
               // end;//end case
                //k:=k+1;
               //Strgid.ColCount :=k+1;
              // for j:=0 to citycunt-1 do
                  Strgid.Cells [i-s+1,j+1]:=inttohex(T[j],2);

         end;//end for
         //if bz=1 then
         //   begin
             //  k:=k+1;
              // Strgid.ColCount :=k+1;
              // for j:=0 to citycunt-1 do
              //    Strgid.Cells [k,j+1]:=inttostr(T[j]);
            // end;
           Strgid.Cells [i-s+1,0]:=inttostr(i);

   end;
end;



end.
