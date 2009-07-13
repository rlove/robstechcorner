program RenameCastaliaParser;

{$APPTYPE CONSOLE}

// After Reading the Readme.txt for the Castalia Delphi Parser
// I realized, its highly likely I will need to the change the file names,
// as the possibility of our code being linked into the IDE is fairly high.



uses
  SysUtils,
  classes,
  RenameParserUnits in 'RenameParserUnits.pas',
  CastaliaSimplePasParTypes in '..\..\external\CastaliaDelphiParser\CastaliaSimplePasParTypes.pas',
  CastaliaPasLex in '..\..\external\CastaliaDelphiParser\CastaliaPasLex.pas',
  CastaliaPasLexTypes in '..\..\external\CastaliaDelphiParser\CastaliaPasLexTypes.pas',
  CastaliaSimplePasPar in '..\..\external\CastaliaDelphiParser\CastaliaSimplePasPar.pas',
  tomPascalUnit in '..\tomPascalUnit.pas';

var
   Renamer : TomParserRename;

begin
  try
    WriteLn('RenameCastaliaParser ');
    WriteLn('Renames the Castalia Delphi Parser. ');
    if ParamCount <> 3 then
    begin
      Writeln('Usage: ');
      WriteLn(' RenameCastaliaParser NewName CastaliaParserDirectory OutputDirectory');
      WriteLn('Example: ');
      WriteLn(' RenameCastaliaParser FooBar C:\dev\castaliaparser C:\dev\FooBarParser');
      Writeln(' Which would rename instances of "Castalia" to "FooBar" ');
    end
    else
    begin
      Renamer := TomParserRename.Create;
      try
        Renamer.NewName := ParamStr(1);
        Renamer.CastaliaDirectory := ParamStr(2);
        Renamer.OutputDirectory := ParamStr(3);
        Renamer.Execute;
      finally
        Renamer.Free;
      end;
    end;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.

