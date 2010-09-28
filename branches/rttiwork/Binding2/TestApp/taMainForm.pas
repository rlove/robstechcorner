unit taMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Bindings, uModel, StdCtrls, Generics.Collections;

type
  TForm8 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Button2: TButton;
    Label1: TLabel;
    Binder1: TBinder;
    Memo1: TMemo;
    Binder2: TBinder;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    Person : TPerson;
    PersonList : TList<TPerson>;
  public
    { Public declarations }
  end;

var
  Form8: TForm8;

implementation

{$R *.dfm}

procedure TForm8.Button1Click(Sender: TObject);
begin
   Binder1.Load(Person);
   Binder2.Load(PersonList);
end;

procedure TForm8.Button2Click(Sender: TObject);
begin
  Binder1.Save(Person);
end;

procedure TForm8.FormCreate(Sender: TObject);
begin
 Person := TPerson.create;
 Person.FirstName := 'Robert';
 Person.LastName := 'Love';
 PersonList := TList<TPerson>.Create;
 PersonList.Add(Person);
 PersonList.Add(Person);

end;

procedure TForm8.FormDestroy(Sender: TObject);
begin
  Person.Free;
  PersonList.Free;
end;

end.