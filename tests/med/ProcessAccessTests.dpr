program ProcessAccessTests;
{$APPTYPE CONSOLE}
{$SETPEOSVERSION 5.1}
{$SETPESUBSYSVERSION 5.1}
uses Winapi.Windows, System.SysUtils;
const Access = PROCESS_QUERY_INFORMATION or PROCESS_VM_READ or
  PROCESS_VM_WRITE or PROCESS_VM_OPERATION;
var H: THandle; Error, Value, ReadBack, NewValue: DWORD;
    Count: NativeUInt; Info: MEMORY_BASIC_INFORMATION;
procedure Check(OK: Boolean; const Text: string);
begin
  if not OK then raise Exception.Create(Text+' error='+UIntToStr(GetLastError));
end;
begin
  try
    Check(Access=$438, 'exact rights');
    H := OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessId);
    Error := GetLastError;
    Writeln('ALL mask=',IntToHex(PROCESS_ALL_ACCESS,8),' handle=',IntToHex(H,8),' error=',Error);
    if H<>0 then CloseHandle(H);
    H := OpenProcess(Access, False, GetCurrentProcessId);
    Error := GetLastError;
    Writeln('EXACT mask=',IntToHex(Access,8),' handle=',IntToHex(H,8),' error=',Error);
    Check(H<>0, 'open self exact');
    try
      Check(GetProcessId(H)=GetCurrentProcessId, 'GetProcessId');
      Value := $12345678; ReadBack := 0; NewValue := $87654321;
      Check(ReadProcessMemory(H,@Value,@ReadBack,SizeOf(Value),Count), 'read');
      Check((Count=SizeOf(Value)) and (ReadBack=Value), 'read value');
      Check(WriteProcessMemory(H,@Value,@NewValue,SizeOf(Value),Count), 'write');
      Check((Count=SizeOf(Value)) and (Value=NewValue), 'write value');
      Check(VirtualQueryEx(H,@Value,Info,SizeOf(Info))<>0, 'query');
    finally CloseHandle(H); end;
    Writeln('PASS: exact 00000438 self open/PID/read/write/query; ALL is diagnostic only');
  except on E: Exception do begin Writeln(E.ClassName,': ',E.Message); Halt(1); end; end;
end.
