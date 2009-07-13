unit RenameParserUnits;

interface
uses SysUtils, Classes;

type
 EtomParserRenameError = class(Exception);
 TomParserRename = class(TObject)
  private
    FCastaliaDirectory: String;
    FFilesToProcess : TStringList;
    FOutputDirectory: String;
    FNewName: String;
    procedure SetCastaliaDirectory(const Value: String);
    procedure SetOutputDirectory(const Value: String);
    procedure SetNewName(const Value: String);
    procedure ProcessFile(const FileName : String);
  protected
    procedure CheckFilesExist;
  public
   constructor Create;
   destructor Destroy; override;
   property CastaliaDirectory : String read FCastaliaDirectory write SetCastaliaDirectory;
   property OutputDirectory : String read FOutputDirectory write SetOutputDirectory;
   property NewName : String read FNewName write SetNewName;
   procedure Execute;
 end;

implementation

const
  sCastalia = 'Castalia';


{ TomParserRename }

procedure TomParserRename.CheckFilesExist;
var
 S : String;
begin
 for S in FFilesToProcess do
 begin
   if not FileExists(FCastaliaDirectory +  S) then
   begin
     raise EtomParserRenameError.CreateFmt('Unable To locate Required File: %S',[S]);
   end;
 end;
end;

constructor TomParserRename.Create;
begin
  FFilesToProcess := TStringList.Create;
  FFilesToProcess.Add('CastaliaPasLex.Pas');
  FFilesToProcess.Add('CastaliaPasLexTypes.Pas');
  FFilesToProcess.Add('CastaliaSimplePasPar.Pas');
  FFilesToProcess.Add('CastaliaSimplePasParTypes.Pas');
  // don't really need to do but doing it, just to be complete
  FFilesToProcess.Add('CastaliaParserDefines.inc');
end;

destructor TomParserRename.Destroy;
begin

  inherited;
end;

procedure TomParserRename.Execute;
var
 FileName : String;
begin
  CheckFilesExist;
  ForceDirectories(FOutputDirectory);
  for FileName in FFilesToProcess do
  begin
    ProcessFile(FileName);
  end;
end;

procedure TomParserRename.ProcessFile(const FileName: String);
var
 SL : TStringList;
 lOldNameNoExt : String;
 lNewFileName : String;
 lNewNameNoExt : String;
 lFile : String;
begin
// This is easier than dog fooding the parser that we are trying to changing :-)
 SL := TStringList.Create;
 try
   SL.LoadFromFile(FCastaliaDirectory + FileName);

   for lFile in FFilesToProcess do
   begin
     lOldNameNoExt := ChangeFileExt(lFile,'');
     lNewNameNoExt := StringReplace(lOldNameNoExt,sCastalia,FNewName,[rfIgnoreCase]);
     // Do Replace in the file (i.e. unit FileName; uses statement; {$I }, etc... );
     SL.Text := StringReplace(SL.Text,lOldNameNoExt,lNewNameNoExt,[rfIgnoreCase,rfReplaceAll]);
   end;
   // Save old File with New FileName;
   lNewFileName := StringReplace(FileName,sCastalia,FNewName,[rfIgnoreCase]);
   SL.SaveToFile(FOutputDirectory + lNewFileName);
 finally
   SL.Free;
 end;
end;

procedure TomParserRename.SetCastaliaDirectory(const Value: String);
begin
  FCastaliaDirectory := IncludeTrailingPathDelimiter(ExpandFileName(Value));
end;

procedure TomParserRename.SetNewName(const Value: String);
begin
  FNewName := Value;
end;

procedure TomParserRename.SetOutputDirectory(const Value: String);
begin
  FOutputDirectory := IncludeTrailingPathDelimiter(ExpandFileName(Value));
end;

end.
