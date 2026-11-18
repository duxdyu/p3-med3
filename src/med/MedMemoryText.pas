unit MedMemoryText;

interface

uses Winapi.Windows, System.SysUtils, System.Classes;

const
  MED_GAME_CODEPAGE = 936; // Current Chinese game baseline; UI is Unicode.

function DecodeGameBytes(const Buffer; Count: Integer): string;
function ReadGameText(Process: THandle; Address: NativeUInt;
  out ByteLength: Integer; MaxBytes: Integer = 4096): string;

implementation

function DecodeGameBytes(const Buffer; Count: Integer): string;
var
  Needed: Integer;
begin
  if Count < 0 then
    raise EArgumentOutOfRangeException.Create('Negative game text size');
  Result := '';
  if Count = 0 then Exit;
  Needed := MultiByteToWideChar(MED_GAME_CODEPAGE, MB_ERR_INVALID_CHARS,
    PAnsiChar(@Buffer), Count, nil, 0);
  if Needed = 0 then RaiseLastOSError;
  SetLength(Result, Needed);
  if MultiByteToWideChar(MED_GAME_CODEPAGE, MB_ERR_INVALID_CHARS,
    PAnsiChar(@Buffer), Count, PWideChar(Result), Needed) <> Needed then
    RaiseLastOSError;
end;

function ReadGameText(Process: THandle; Address: NativeUInt;
  out ByteLength: Integer; MaxBytes: Integer): string;
var
  Buffer: TBytes;
  Value: Byte;
  ReadCount: NativeUInt;
begin
  if MaxBytes <= 0 then
    raise EArgumentOutOfRangeException.Create('Invalid game text bound');
  SetLength(Buffer, MaxBytes);
  ByteLength := 0;
  while ByteLength < MaxBytes do
  begin
    ReadCount := 0;
    if not ReadProcessMemory(Process, Pointer(Address + NativeUInt(ByteLength)),
      @Value, 1, ReadCount) then RaiseLastOSError;
    if ReadCount <> 1 then raise EReadError.Create('Incomplete game text read');
    if Value = 0 then
    begin
      Result := DecodeGameBytes(Buffer[0], ByteLength);
      Exit;
    end;
    Buffer[ByteLength] := Value;
    Inc(ByteLength);
  end;
  raise EReadError.Create('Game text has no terminator within the size limit');
end;

end.
