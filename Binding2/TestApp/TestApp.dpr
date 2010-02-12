program TestApp;

uses
  Forms,
  taMainForm in 'taMainForm.pas' {Form8},
  Bindings in '..\Source\Bindings.pas',
  RttiUtils in '..\..\RttiUtils.pas',
  uModel in '..\ExampleModel\uModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm8, Form8);
  Application.Run;
end.
