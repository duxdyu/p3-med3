program MedMemoryTextTests;
{$SETPEOSVERSION 5.1}
{$SETPESUBSYSVERSION 5.1}
{$APPTYPE CONSOLE}
uses
  Winapi.UIAutomation in '..\..\src\sdk-overlay\Winapi.UIAutomation.pas', System.SysUtils, System.Classes, Winapi.Windows, MedMemoryText, MedFinalEconomy, MedLoanRulesTests, MedFireRules, MedWarModel;
var
  Bytes: TBytes;
  Count: Integer;
  Text: string;
  Caught: Boolean;
  Factories: TFinalFactoryCounts;
  PopulationUse, CityOutput, CityUse, OfficeOutput, OfficeUse: TFinalGoodsValues;
  Balance: TFinalBalance;
begin
  try
    RunLoanRuleTests;
    if (MedFirePhase(200,200,100,0)<>0) or
       (MedFirePhase(100,108,105,1)<>1) or
       (MedFirePhase(100,108,105,0)<>2) or
       (MedFirePhase(100,100,105,0)<>0) or
       (MedFirePhase(200,208,100,1)<>0) then
      raise Exception.Create('Fire phase/future preservation regression');
    if (MedWarDays(0)<>'未知') or (MedWarDays(1)<>'<1') or
       (MedWarDays(255)<>'<1') or (MedWarDays(256)<>'1') or
       (MedWarDays(257)<>'2') or (MedWarDays(High(Cardinal))<>'16777216') then
      raise Exception.Create('War next-phase day rounding regression');
    if (MedWarStage(True,True,361,0,0)<>wsApproach) or
       (MedWarStage(True,True,0,0,0)<>wsFighting) or
       (MedWarStage(True,True,0,2387,0)<>wsLooting) or
       (MedWarStage(False,True,0,1239,0)<>wsReleased) or
       (MedWarLootRemaining(2387,2560)<>1107) or
       (MedWarLootRemaining(1239,2560)<>0) then
      raise Exception.Create('War phase/half-duration transition regression');
    if (MedWarDailyStep(1600,0,0)<>43) or (MedWarDailyStep(1600,0,1)<>61) or
       (MedWarDailyStep(1600,0,2)<>92) or (MedWarDailyStep(1600,$FF,0)<>29) or
       (MedWarEstimate(193,41)<>5) or (MedWarEstimate(0,41)<>0) then
      raise Exception.Create('War conditional daily estimate regression');
    if not MedWarMessageMatches(12,$84,1358,23,1358*365+109,(1358*365+131)*256) or
       MedWarMessageMatches(12,$84,1358,22,1358*365+109,(1358*365+131)*256) or
       MedWarMessageMatches(29,$81,1358,1,1358*365+59,(1358*365+60)*256) or
       MedWarMessageMatches(12,$84,1358,23,1358*365+109,(1358*365+130)*256) then
      raise Exception.Create('War message date/start binding regression');
    if SizeOf(Pointer) <> 4 then raise Exception.Create('Requires Win32');
    Bytes := TBytes.Create($D6, $D0, $CE, $C4, $41, 0); // CP936: Chinese + ASCII
    Text := ReadGameText(GetCurrentProcess, NativeUInt(@Bytes[0]), Count);
    if (Text <> #$4E2D#$6587'A') or (Count <> 5) then
      raise Exception.Create('CP936 decode or byte-length failed');
    SetLength(Bytes, 1025);
    FillChar(Bytes[0], Length(Bytes), Ord('X'));
    Bytes[1024] := 0;
    Text := ReadGameText(GetCurrentProcess, NativeUInt(@Bytes[0]), Count);
    if (Length(Text) <> 1024) or (Count <> 1024) then
      raise Exception.Create('Long string regression');
    Caught := False;
    try ReadGameText(GetCurrentProcess, NativeUInt(@Bytes[0]), Count, 16);
    except on E: EReadError do Caught := True; end;
    if not Caught then raise Exception.Create('Missing terminator bound not enforced');
    Bytes[0] := 0;
    if ReadGameText(GetCurrentProcess, NativeUInt(@Bytes[0]), Count) <> '' then
      raise Exception.Create('Empty string failed');
    Caught := False;
    try ReadGameText(GetCurrentProcess, 0, Count);
    except on E: EOSError do Caught := True; end;
    if not Caught then raise Exception.Create('Invalid address not rejected');
    FillChar(Factories, SizeOf(Factories), 0);
    FillChar(PopulationUse, SizeOf(PopulationUse), 0);
    FillChar(CityOutput, SizeOf(CityOutput), 0);
    FillChar(CityUse, SizeOf(CityUse), 0);
    FillChar(OfficeOutput, SizeOf(OfficeOutput), 0);
    FillChar(OfficeUse, SizeOf(OfficeUse), 0);
    Factories[2] := 2;
    Factories[17] := 1;
    PopulationUse[3] := 100;
    CityOutput[3] := 200;
    CityUse[3] := 50;
    OfficeOutput[3] := 60;
    OfficeUse[3] := 70;
    CalculateFinalBalance(Factories, PopulationUse, CityOutput, CityUse, OfficeOutput, OfficeUse, 7, Balance);
    if (Balance[3,0] <> 21707) or (Balance[11,1] <> -2170) or
       (Balance[0,1] <> -5416) or (Balance[2,0] <> 11539) or (Balance[10,0] <> 5670) then
      raise Exception.Create('Terminal economy factory rates/rounding mismatch');
    if (Balance[3,7] <> 22057) or (Balance[3,12] <> 280) or (Balance[3,13] <> -770) then
      raise Exception.Create('Terminal economy combined columns mismatch');
    Writeln('PASS: CP936, byte/Unicode length, 1024-byte text, empty text, bounds and invalid memory');
    Writeln('PASS: terminal factory coefficients, whale oil exception, ceilings and economy balance columns');
  except
    on E: Exception do begin Writeln(E.ClassName, ': ', E.Message); Halt(1); end;
  end;
end.
