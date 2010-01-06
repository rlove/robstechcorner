unit TestXmlSerialDotNet;
// Unit Requires Project PrismTestHelper to be compiled which
// serializes and deserializes the same classes that
// are compiled and used with this test.
interface
uses
  SysUtils, CLasses,TestFramework, xmlSerial,XmlDoc, uSampleTest, windows, Rtti;
type
TXmlSerialDotNetTest = class(TTestCase)
protected
  function WinExecAndWait32(FileName: string; Visibility: Integer): DWord;
published
  procedure TestSampleTest;
end;

implementation

{ TXmlSerialDotNetTest }

procedure TXmlSerialDotNetTest.TestSampleTest;
var
  s : TXmlSerializer<SampleTest>;
  v : TValue;
  t,tc : SampleTest;
  Doc : TXMLDocument;
  DummyOwner :  TComponent;
  sc : SampleSubClass;
  testFile : String;
  AOS : ArrayOfString;
begin
  t := SampleTest.Create;
  t.Value1 := 'Blah';
  t.Value2 := EncodeDate(2002,1,3);
  t.Value3 := false;
  t.Value4 := 1234;
  t.Value5 := 3.14;
  t.Value6 := List<Integer>.Create;
  t.Value6.Add(100);
  t.Value6.Add(200);
  t.Value6.Add(300);
  SetLength(AOS,3);
  AOS[0] := 'A1';
  AOS[1] := 'A2';
  AOS[2] := 'A3';
  t.Value7 := AOS;
  t.Value8 := SampleSubClass.Create;
  t.Value8.Value1 := 'asdf';
  t.Value8.Value2 := 2001;
  t.Value9 := List<SampleSubClass>.Create;
  sc := SampleSubClass.Create;
  sc.Value1 := '1';
  sc.Value2 := 1;
  t.Value9.Add(sc);
  sc := SampleSubClass.Create;
  sc.Value1 := '2';
  sc.Value2 := 2;
  t.Value9.Add(sc);

  s := TXmlSerializer<SampleTest>.Create;
  DummyOwner :=  TComponent.Create(nil);
  Doc := TXMLDocument.Create(DummyOwner);

  testFile := ExtractFilePath(ParamStr(0)) + 'test.xml';

  s.Serialize(Doc,t);

  Doc.SaveToFile(testFile);

  //TODO: Call DotNet Serialization Test


  tc := s.Deserialize(Doc);
  CheckEquals(t.Value1,tc.Value1,'Value1');
  CheckEquals(t.Value2,tc.Value2,'Value2');
  CheckEquals(t.Value3,tc.Value3,'Value3');
  CheckEquals(t.Value4,tc.Value4,'Value4');
  CheckEquals(t.Value5,tc.Value5,'Value5');
  Check(Assigned(tc.Value6),'Assigned(tc.Value6)');
  CheckEquals(t.Value6.Count,tc.Value6.Count,'Value6.Count');
  CheckEquals(t.Value6.Items[1],tc.Value6.Items[1],'Value6.Items[1]');




  Doc.Free;
  DummyOwner.Free;
  t.Free;


end;



function TXmlSerialDotNetTest.WinExecAndWait32(FileName: string;
  Visibility: Integer): DWord;
var
  zAppName: array[0..512] of Char;
  zCurDir: array[0..255] of Char;
  WorkDir: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  StrPCopy(zAppName, FileName);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);

  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(nil,
           zAppName, { pointer to command line string }
           nil, { pointer to process security attributes }
           nil, { pointer to thread security attributes }
           false, { handle inheritance flag }
           CREATE_NEW_CONSOLE or { creation flags }
           NORMAL_PRIORITY_CLASS,
           nil, { pointer to new environment block }
           nil, { pointer to current directory name }
           StartupInfo, { pointer to STARTUPINFO }
           ProcessInfo) then
    Result := 0 { pointer to PROCESS_INF }
  else
  begin
    WaitforSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TXmlSerialDotNetTest.Suite);


end.

