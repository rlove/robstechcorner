unit tomClasses;

interface
uses
  SysUtils,
  Classes,
  Generics.Defaults,
  Generics.Collections,
  Generics.InterfaceList,
  tomIntf,
  TypInfo;

type
  ETOMException = class(Exception);
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
    FEntity : Pointer; // Pointer to keep it weak
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

  TPropertyList = class(TInterfaceList<ITOMPropertyBase>,ITOMPropertyList)
  protected
    procedure BeforeDelete(Item : ITOMPropertyBase); override;
  public
    function GetItemByName(Name : String) : ITOMPropertyBase;
  end;


  TOMCustomEntity = class(TInterfacedObject,ITOMEntity)
  private
  protected
     FPropertyList : ITOMPropertyList;
     FState : TEntityState;
  public
     constructor Create; virtual;
     destructor Destroy; override;
     function EntityPropertyCount : Integer;
     function GetProperty(Name : String) : ITOMPropertyBase; overload;
     function GetProperty(Index : Integer) : ITOMPropertyBase; overload;
     function GetEntityState : TEntityState;
     procedure SetEntityState(const Value : TEntityState);
     property State : TEntityState read GetEntityState write SetEntityState;
  published
  end;

  TOMSourceCollectionItem = class(TCollectionItem)
  private
    FName: string;
    FSource: ITOMSource;
    procedure SetSource(const Value: ITOMSource);
  protected
    function GetDisplayName: string; override;
    procedure SetDisplayName(const Value: string); reintroduce;
  published
    property Name: string read FName write SetDisplayName;
    property Source : ITOMSource read FSource write SetSource;
  end;


  TOMSourceCollection = class(TOwnedCollection)
  public
    constructor Create(AOwner: TPersistent);
    function Find(const AName: string): TOMSourceCollectionItem;
    function IndexOf(const AName: string): Integer;
  end;


  TOMContext = class(TComponent)
  private
    FSources: TOMSourceCollection;
    procedure SetSources(const Value: TOMSourceCollection);
  public
    constructor Create(aOwner : TComponent); override;
    destructor Destroy; override;
  published
    property Sources : TOMSourceCollection read FSources write SetSources;

  end;

  {$M-}
  const
    SInvalidPropertyName = 'Invalid property Name: %s';
    SDuplicateCollectionName = 'Duplicate name ''%s'' in TOMSourceCollection';

implementation
uses RTLConsts;

{ TOMAttribute }

constructor TOMAttribute.Create;
begin
  FValues := TDictionary<String,String>.Create();
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
  FEntity := pointer(Entity);
  FComparer := TComparer<T>.Default;
  FAttributes := TOMAttribute.Create;
end;

constructor TOMProperty<T>.Create(const Name : String;const Entity: ITOMEntity;
  const aComparer: IComparer<T>);
begin
  FPropName := Name;
  FEntity := pointer(Entity);
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
  Result := ITOMEntity(FEntity);
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
  FEntity := pointer(Value);
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


{ TOMCustomEntity }

constructor TOMCustomEntity.Create;
begin
  FPropertyList := TPropertyList.Create;
end;

destructor TOMCustomEntity.Destroy;
begin
  FPropertyList.Clear;
  FPropertyList := nil;
  inherited;
end;

function TOMCustomEntity.EntityPropertyCount: Integer;
begin
  result := FPropertyList.Count;
end;

function TOMCustomEntity.GetEntityState: TEntityState;
begin
  result := FState;
end;

function TOMCustomEntity.GetProperty(Name: String): ITOMPropertyBase;
begin
  result := FPropertyList.GetItemByName(Name);
end;

function TOMCustomEntity.GetProperty(Index: Integer): ITOMPropertyBase;
begin
  result := FPropertyList.Items[Index];
end;

procedure TOMCustomEntity.SetEntityState(const Value: TEntityState);
begin
 // Maybe I should inforce some rules here... for
 // letting the implementor shoot themselves in the foot.
  FState := Value;
end;

{ TPropertyList }

procedure TPropertyList.BeforeDelete(Item: ITOMPropertyBase);
begin
  // Release the Reference
  Item.Entity := nil;
end;

function TPropertyList.GetItemByName(Name: String): ITOMPropertyBase;
var
 Item : ITOMPropertyBase;
begin
  for Item in Self do
  begin
    if (CompareText(Item.PropName,Name) = 0) then
    begin
       result := Item;
       exit;
    end;
  end;
  raise EListError.CreateFmt(SInvalidPropertyName,[Name]);
end;

{ TOMSourceCollectionItem }

function TOMSourceCollectionItem.GetDisplayName: string;
begin
 result := FName;
end;

procedure TOMSourceCollectionItem.SetDisplayName(const Value: string);
begin
  if (Value <> '') and (WideCompareText(Value, FName) <> 0) and
    (Collection is TOMSourceCollection) and
    (TOMSourceCollection(Collection).IndexOf(Value) >= 0) then
    raise ETOMException.CreateFmt(SDuplicateCollectionName, [Value]);
  FName := Value;
  inherited SetDisplayName(Value);

end;

procedure TOMSourceCollectionItem.SetSource(const Value: ITOMSource);
begin

end;

{ TOMContext }

constructor TOMContext.Create(aOwner: TComponent);
begin
  inherited;
  FSources := TOMSourceCollection.Create(Self);

end;


destructor TOMContext.Destroy;
begin
  FreeAndNil(FSources);
  inherited;
end;

procedure TOMContext.SetSources(const Value: TOMSourceCollection);
begin
  FSources := Value;
end;

{ TOMSourceCollection }

constructor TOMSourceCollection.Create(AOwner: TPersistent);
begin
 inherited Create(AOwner,TOMSourceCollectionItem);

end;

function TOMSourceCollection.Find(const AName: string): TOMSourceCollectionItem;
var
  I: Integer;
begin
  I := IndexOf(AName);
  if I < 0 then Result := nil else Result := TOMSourceCollectionItem(Items[I]);
end;

function TOMSourceCollection.IndexOf(const AName: string): Integer;
begin
  for Result := 0 to Count - 1 do
  begin
    if CompareText(TOMSourceCollectionItem(Items[Result]).Name, AName) = 0 then
    begin
       Exit;
    end;
  end;
  Result := -1;
end;

end.
