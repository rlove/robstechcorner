unit uModel;

interface
uses
  Generics.Collections;
// Dummy Model, to verify Object Binding ProtoType.

type
  TPerson = class (TObject)
  private
    FLastName: String;
    FFirstName: String;
    procedure SetFirstName(const Value: String);
    procedure SetLastName(const Value: String);
  public
    property FirstName : String read FFirstName write SetFirstName;
    property LastName : String read FLastName write SetLastName;
  end;

  TEmployee = class(TPerson)
  private
    FEmployeeNum: String;
    FManager: TEmployee;
    procedure SetEmployeeNum(const Value: String);
    procedure SetManager(const Value: TEmployee);
  public
    property EmployeeNum : String read FEmployeeNum write SetEmployeeNum;
    property Manager : TEmployee read FManager write SetManager;
  end;

  TSalesPerson = class(TEmployee)
  private
    FCustomers: TList<TPerson>;
    procedure SetCustomers(const Value: TList<TPerson>);
  public
    constructor Create;
    destructor Destroy; override;
    property Customers : TList<TPerson> read FCustomers write SetCustomers;
  end;



implementation

{ TPerson }

procedure TPerson.SetFirstName(const Value: String);
begin
  FFirstName := Value;
end;

procedure TPerson.SetLastName(const Value: String);
begin
  FLastName := Value;
end;

{ TEmployee }

procedure TEmployee.SetEmployeeNum(const Value: String);
begin
  FEmployeeNum := Value;
end;

procedure TEmployee.SetManager(const Value: TEmployee);
begin
  FManager := Value;
end;

{ TSalesPerson }

constructor TSalesPerson.Create;
begin
   FCustomers := TList<TPerson>.Create;
end;

destructor TSalesPerson.Destroy;
begin
  FCustomers.free;
  inherited;
end;

procedure TSalesPerson.SetCustomers(const Value: TList<TPerson>);
begin
  FCustomers := Value;
end;

end.
