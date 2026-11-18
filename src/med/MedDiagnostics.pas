unit MedDiagnostics;

interface

procedure TraceMed(const Text: string);

implementation

uses Winapi.Windows, System.SysUtils, System.Classes;

procedure TraceMed(const Text: string);
var
  Name: array[0..32767] of Char;
  FileName: string;
  Stream: TFileStream;
  Bytes: TBytes;
begin
  // Opt-in file beside MED3.dll; diagnostics never alter exception semantics.
  try
    if GetModuleFileName(HInstance, Name, Length(Name)) = 0 then Exit;
    FileName := ExtractFilePath(string(Name));
    if not FileExists(FileName+'MED-recovery-diagnostics.enable') then Exit;
    FileName := FileName+'MED-recovery-diagnostics.log';
    if FileExists(FileName) then
      Stream := TFileStream.Create(FileName, fmOpenWrite or fmShareDenyWrite)
    else Stream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
    try
      Stream.Seek(0, soEnd);
      Bytes := TEncoding.UTF8.GetBytes(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now)+' '+
        'pid='+IntToStr(GetCurrentProcessId)+' thread='+IntToStr(GetCurrentThreadId)+' '+Text+sLineBreak);
      if Length(Bytes)>0 then Stream.WriteBuffer(Bytes[0],Length(Bytes));
    finally Stream.Free; end;
  except
    // A diagnostic filesystem failure must not change the program behavior.
  end;
end;

end.
