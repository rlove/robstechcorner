program RTTIUnitsTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestRTTI in 'TestRTTI.pas',
  Testxmlserial in 'Testxmlserial.pas',
  TestXmlSerialDotNet in 'TestXmlSerialDotNet.pas',
  uSampleTest in 'PrismTestHelper\PrismTestHelper\uSampleTest.pas',
  RttiUtils in '..\RttiUtils.pas',
  xmlserial in '..\xmlserial.pas',
  TestIniPersist in 'TestIniPersist.pas',
  IniPersist in '..\IniPersist.pas';

{R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

