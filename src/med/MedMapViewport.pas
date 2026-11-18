unit MedMapViewport;

interface

uses
  Windows, Classes, Controls, ExtCtrls;

type
  TMedMapViewport = class(TPanel)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

implementation

procedure TMedMapViewport.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  { TImage and the selection/copy overlays paint through this parent HWND.
    Present its background and children together instead of exposing the
    erased background while the large map moves. Keep this local to the map.
    CreateParams also reapplies the style after VCL recreates the handle. }
  Params.ExStyle := Params.ExStyle or WS_EX_COMPOSITED;
end;

initialization
  RegisterClass(TMedMapViewport);

finalization
  UnRegisterClass(TMedMapViewport);

end.
