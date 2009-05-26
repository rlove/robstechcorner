unit tomClasses;

interface
uses
  SysUtils, Classes, Generics.Defaults, Generics.Collections, tomIntf, TypInfo;
type
{$M+}
  TOMSource = class(TObject)

  end;

  TOMSourceClass = class of TOMSource;

  TOMAttribute = class(TInterfacedObject,ITOMAttributes)
  protected
    FAssignedBySource: Boolean;
    FValues: TDictionary<String,String>;
    FSourceClass: TOMSourceClass;
    FLazyLoad: Boolean;
    FRequired: Boolean;
    FSourceName: String;
    procedure SetSourceName(const Value: String);
    function GetSourceName: String;
    procedure SetAssignedBySource(const Value: Boolean);
    procedure SetLazyLoad(const Value: Boolean);
    procedure SetRequired(const Value: Boolean);
    procedure SetValues(const Value: TDictionary<String,String>);
    function GetAssignedBySource: Boolean;
    function GetLazyLoad: Boolean;
    function GetRequired: Boolean;
    function GetValues: TDictionary<String,String>;
  published
    property SourceName : String read GetSourceName write SetSourceName;
    property AssignedBySource : Boolean read GetAssignedBySource write SetAssignedBySource;
    property Required : Boolean read GetRequired write SetRequired;
    property LazyLoad : Boolean read GetLazyLoad write SetLazyLoad;
    property Values : TDictionary<String,String> read GetValues write SetValues;
    constructor Create;
    destructor Destroy; override;
  end;


  TOMProperty<T> = class(TInterfacedObject,ITOMPropertyBase,ITOMProperty<T>)
  private
  protected
    FAttributes : ITOMAttributes;
    FPropName : String;
    FOriginalValue: T;
    FComparer: IComparer<T>;
    FChanged : Boolean;
    FState: TOMPropertyState;
    FValue: T;
    FEntity : ITOMEntity;
    procedure SetState(const Value: TOMPropertyState); virtual;
    procedure SetOriginalValue(const Value: T); virtual;
    procedure SetValue(const Value: T); virtual;
    procedure SetComparer(const Value: IComparer<T>); virtual;
    procedure SetEntity(const Value: ITOMEntity); virtual;

    function GetChanged: Boolean; virtual;
    function GetComparer: IComparer<T>; virtual;
    function GetEntity: ITOMEntity; virtual;
    function GetOriginalValue: T; virtual;
    function GetState: TOMPropertyState; virtual;
    function GetValue: T; virtual;
    function GetPropType: PTypeInfo; virtual;
    function GetPropName: String; virtual;
    procedure SetPropName(const Value: String); virtual;
    function GetAttributes: ITOMAttributes; virtual;

  public
    constructor Create(const Name : String;const Entity : ITOMEntity); overload; virtual;
    constructor Create(const Name : String;const Entity : ITOMEntity;const aComparer : IComparer<T>); overload; virtual;
    destructor Destroy; override;
    property PropType : PTypeInfo read GetPropType;
    property Value : T read GetValue write SetValue;
    property OriginalValue :  T read GetOriginalValue write SetOriginalValue;
    property Changed : Boolean read GetChanged;
    property State : TOMPropertyState read GetState write SetState;
    property Entity : ITOMEntity read GetEntity write SetEntity;
    property Comparer: IComparer<T> read GetComparer write SetComparer;
    property PropName : String read GetPropName write SetPropName;
    property Attributes : ITOMAttributes read GetAttributes;

  end;



  TOMCustomEntity = class(TInterfacedObject,ITOMEntity)
  private
  protected
  public
//    property Attributes : TObjectList<TOMAttribute>;

  published
  end;
  {$M-}

implementation

{ TOMAttribute }

constructor TOMAttribute.Create;
begin
  FValues := TDictionary<String,String>.Create()
end;


destructor TOMAttribute.Destroy;
begin
  FreeAndNil(FValues);
  inherited;
end;

function TOMAttribute.GetAssignedBySource: Boolean;
begin
  result := FAssignedBySource;
end;

function TOMAttribute.GetLazyLoad: Boolean;
begin
  result := FLazyLoad;
end;


function TOMAttribute.GetRequired: Boolean;
begin
  result := FRequired;
end;


function TOMAttribute.GetSourceName: String;
begin
  result := FSourceName;
end;

function TOMAttribute.GetValues: TDictionary<String,String>;
begin
  Result := FValues;
end;

procedure TOMAttribute.SetAssignedBySource(const Value: Boolean);
begin
  FAssignedBySource := Value;
end;

procedure TOMAttribute.SetLazyLoad(const Value: Boolean);
begin
  FLazyLoad := Value;
end;


procedure TOMAttribute.SetRequired(const Value: Boolean);
begin
  FRequired := Value;
end;


procedure TOMAttribute.SetSourceName(const Value: String);
begin
  FSourceName := Value;
end;

procedure TOMAttribute.SetValues(const Value: TDictionary<String,String>);
begin
  FValues := Value;
end;

{ TOMProperty<T> }

constructor TOMProperty<T>.Create(const Name : String;const Entity: ITOMEntity);
begin
  FPropName := Name;
  FEntity := Entity;
  FComparer := TComparer<T>.Default;
  FAttributes := TOMAttribute.Create;
end;

constructor TOMProperty<T>.Create(const Name : String;const Entity: ITOMEntity;
  const aComparer: IComparer<T>);
begin
  FPropName := Name;
  FEntity := Entity;
  FComparer := aComparer;
  if FComparer = nil then
  begin
    FComparer := TComparer<T>.Default;
  end;
  FAttributes := TOMAttribute.Create;
end;

destructor TOMProperty<T>.Destroy;
begin
  FEntity := nil;
  FComparer := nil;
  FAttributes := nil;
  inherited;
end;

function TOMProperty<T>.GetAttributes: ITOMAttributes;
begin
  result := FAttributes;
end;

function TOMProperty<T>.GetChanged: Boolean;
begin
  result := FChanged;
end;

function TOMProperty<T>.GetComparer: IComparer<T>;
begin
  Result := FComparer;
end;

function TOMProperty<T>.GetEntity: ITOMEntity;
begin
  Result := FEntity;
end;



function TOMProperty<T>.GetOriginalValue: T;
begin
 result := FOriginalValue;
end;

function TOMProperty<T>.GetPropName: String;
begin
 result := FPropName;
end;

function TOMProperty<T>.GetPropType: PTypeInfo;
begin
  result := TypeInfo(T);
end;

function TOMProperty<T>.GetState: TOMPropertyState;
begin
 result := FState;
end;

function TOMProperty<T>.GetValue: T;
begin
  result := FValue;
end;


procedure TOMProperty<T>.SetComparer(const Value: IComparer<T>);
begin
  FComparer := Value;
end;

procedure TOMProperty<T>.SetEntity(const Value: ITOMEntity);
begin
  FEntity := Value;
end;

procedure TOMProperty<T>.SetOriginalValue(const Value: T);
begin
  FOriginalValue := Value;
end;


procedure TOMProperty<T>.SetPropName(const Value: String);
begin
   FPropName := Value;
end;

procedure TOMProperty<T>.SetState(const Value: TOMPropertyState);
begin
  FState := Value;
end;

procedure TOMProperty<T>.SetValue(const Value: T);
begin
  if (FComparer.Compare(FValue,Value) <> 0) and (FState <> psLoading) then
  begin
    FChanged := True;
  end;

  if FState = psLoading then
  begin
    FChanged := False;
    FOriginalValue := Value;
  end;

  FValue := Value;
end;


end.
