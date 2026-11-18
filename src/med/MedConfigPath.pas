unit MedConfigPath;

interface

function MedConfigFileName: string;

implementation

uses Winapi.Windows, System.SysUtils;

function MedConfigFileName: string;
var
  Buffer: array[0..32767] of Char;
  Count: DWORD;
begin
  // In MED3.dll, HInstance identifies this DLL, not its game host EXE.
  Count := GetModuleFileName(HInstance, Buffer, Length(Buffer));
  if (Count = 0) or (Count >= DWORD(Length(Buffer))) then
    raise Exception.Create('Cannot resolve MED module directory');
  Result := ExtractFilePath(string(Buffer)) + 'MED.ini';
end;

end.
