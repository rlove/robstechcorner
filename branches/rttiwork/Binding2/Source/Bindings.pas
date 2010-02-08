unit Bindings;

interface
uses Classes, Sysutils, Rtti, TypInfo, Generics.Collections;

const
  BindingVisibility = [mvPublic, mvPublished];

type
  EBinderException = class(Exception);

  TRttiTypeString = String;
  TRttiMemberString = String;
  TBinder = class;
  TBindingCollection = class;
  TBindingCollectionItem = class;


  TBindingBehavior = class(TPersistent)
  private
  protected
    FBindingItem: TBindingCollectionItem;
    procedure InternalSave(SourceMember : TRttiMember;DestObj : TObject); virtual; abstract;
    procedure InternalLoad(SourceMember : TRttiMember;DestObj : TObject); virtual; abstract;
    function InternalIsModified(SourceMember : TRttiMember;DestObj : TObject) : Boolean; virtual; abstract;
    procedure InternalValidate(DestObj : TObject); virtual; abstract;
  public
    constructor Create(aBindingItem : TBindingCollectionItem); virtual;
    property BindingItem : TBindingCollectionItem read FBindingItem;

    procedure Save(Source : TObject); virtual;
    procedure Load(Source : TObject); virtual;
    procedure Validate; virtual;

    function IsModified(Source : TObject) : Boolean; virtual;
  end;

  TMemberBindingBehavior = class(TBindingBehavior)

  end;


  TBindingBehaviorClass = class of TBindingBehavior;
  TBindingBehaviorClassName = String;


  TBindingCollectionItem = class(TCollectionItem)
  private
    FDestObject: TObject;
    FSourceMember: TRttiMemberString;
    FDestMember: TRttiMemberString;
    FBehaviorType: TBindingBehaviorClassName;
    FBehavior: TBindingBehavior;
    procedure SetDestObject(const Value: TObject);
    procedure SetSourceMember(const Value: TRttiMemberString);
    procedure SetDestMember(const Value: TRttiMemberString);
    function GetBindingCollection: TBindingCollection;
    procedure SetBehavior(const Value: TBindingBehavior);
    procedure SetBehaviorType(const Value: TBindingBehaviorClassName);
    function GetBinder: TBinder;
  protected
    function ValidMember(aClass : TClass; aProperty : String) : Boolean;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property BindingCollection : TBindingCollection read GetBindingCollection;
    property Binder : TBinder read GetBinder;
  published
    property SourceMember : TRttiMemberString read FSourceMember write SetSourceMember;
    // Noted at DesignTime only TComponents are supported for DestObject
    // but you can set it to any object at runtime
    property DestObject : TObject read FDestObject write SetDestObject;

    property BehaviorType : TBindingBehaviorClassName read FBehaviorType write SetBehaviorType;
    property Behavior : TBindingBehavior read FBehavior write SetBehavior;
  end;

  TBindingCollection = class(TOwnedCollection)
  protected
    FBinder : TBinder;
  public
     //TODO: Implement methods to make this show up better in Designer
     constructor Create(aBinder : TBinder);
     destructor Destroy; override;
     property Binding : TBinder read FBinder;
  end;

  TBinder = class(TComponent)
  private
  protected
    FSourceType: TRttiTypeString;
    FBindings: TBindingCollection;
    procedure SetSourceType(const Value: TRttiTypeString);
    procedure SetBindings(const Value: TBindingCollection);
  protected
    class var
     FBehaviors : TDictionary<String,TBindingBehaviorClass>;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure RegisterBehavior(aClass : TBindingBehaviorClass);
    class function LookupBehavior(aClassName : String) : TBindingBehaviorClass;
    class function BehaviorKeys : TEnumerable<String>;

  public
    constructor Create(aOwner : TComponent); override;
    destructor Destroy; Override;
  published
    property SourceType : TRttiTypeString read FSourceType write SetSourceType;
    property Bindings : TBindingCollection read FBindings write SetBindings;
  end;

implementation

{ TBinding }

class function TBinder.BehaviorKeys: TEnumerable<String>;
begin
  result := FBehaviors.Keys;
end;

constructor TBinder.Create(aOwner: TComponent);
begin
  inherited;
  FBindings := TBindingCollection.Create(self);
end;

destructor TBinder.Destroy;
begin
  FBindings.Free;
  inherited;
end;


class function TBinder.LookupBehavior(
  aClassName: String): TBindingBehaviorClass;
begin
  if not FBehaviors.TryGetValue(aClassName,result) then
     result := nil;
end;

class destructor TBinder.Destroy;
begin
  FBehaviors.Free;
end;

procedure TBinder.SetBindings(const Value: TBindingCollection);
begin
  //TODO: Change to Assign (Implement AssignTo)
  FBindings := Value;
end;

procedure TBinder.SetSourceType(const Value: TRttiTypeString);
begin
  FSourceType := Value;
end;

{ TBindingCollectionItem }


constructor TBindingCollectionItem.Create(Collection: TCollection);
begin
  inherited;
end;

destructor TBindingCollectionItem.Destroy;
begin

  inherited;
end;

function TBindingCollectionItem.GetBinder: TBinder;
begin
  result := BindingCollection.Binding;
end;

function TBindingCollectionItem.GetBindingCollection: TBindingCollection;
begin
  result := TBindingCollection(Collection);
end;

procedure TBindingCollectionItem.SetBehavior(const Value: TBindingBehavior);
begin
  FBehavior := Value;
end;

procedure TBindingCollectionItem.SetBehaviorType(
  const Value: TBindingBehaviorClassName);
var
  lBinderClass : TBindingBehaviorClass;
begin
  FBehaviorType := Value;
  if Assigned(FBehavior) and (FBehavior.ClassName <> Value) then
  begin
    FreeAndNil(FBehavior);
  end;
  if Not Assigned(FBehavior) then
  begin
    lBinderClass := TBinder.LookupBehavior(Value);
    if Assigned(lBinderClass) then
       FBehavior := lBinderClass.Create(Self);
  end;
end;

procedure TBindingCollectionItem.SetDestMember(const Value: TRttiMemberString);
begin
  FDestMember := Value;
end;

procedure TBindingCollectionItem.SetDestObject(const Value: TObject);
begin
  FDestObject := Value;
end;


procedure TBindingCollectionItem.SetSourceMember(
  const Value: TRttiMemberString);
begin
  FSourceMember := Value;
end;


function TBindingCollectionItem.ValidMember(aClass: TClass;
  aProperty: String): Boolean;
var
 C : TRttiContext;
 T : TRttiType;
 M : TRttiMember;
begin
  C := TRttiContext.Create;
  T := C.GetType(aClass);
  result := false;
  if Assigned(T) then
  begin
     M := C.GetType(aClass).GetProperty(aProperty);
     if Assigned(M) and (M.Visibility in BindingVisibility) then
       exit(true);
     M := C.GetType(aClass).GetField(aProperty);
     if Assigned(M) and (M.Visibility in BindingVisibility) then
       exit(true);
  end;
end;

{ TBindingCollection }

constructor TBindingCollection.Create(aBinder: TBinder);
begin
  inherited Create(aBinder,TBindingCollectionItem);
  FBinder := aBinder;
end;

destructor TBindingCollection.Destroy;
begin

  inherited;
end;


{ TBindingBehavior }

constructor TBindingBehavior.Create(aBindingItem: TBindingCollectionItem);
begin
  FBindingItem := aBindingItem;
end;

class constructor TBinder.Create;
begin
  FBehaviors := TDictionary<String,TBindingBehaviorClass>.Create;
//  RegisterBehavior(TTest1);
end;

class procedure TBinder.RegisterBehavior(aClass: TBindingBehaviorClass);
begin
  FBehaviors.Add(aClass.ClassName,aClass);
end;

function TBindingBehavior.IsModified(Source: TObject): Boolean;
var
 Ctx : TRttiContext;
 T : TRttiType;
 Member : TRttiMember;
begin
  T := Ctx.FindType(BindingItem.Binder.SourceType);
  if not Source.InheritsFrom(T.AsInstance.MetaclassType) then
     raise EBinderException.Create('Invalid Source Class');
  Member := T.GetProperty(BindingItem.SourceMember);
  if Not Assigned(Member) then
     Member := T.GetField(BindingItem.SourceMember);
  if Not Assigned(Member) then
     raise EBinderException.Create('Unable to locate Source Member');
  if Not Assigned(BindingItem.DestObject) then
     raise EBinderException.Create('DestObject Not Assigned');

  result := InternalIsModified(Member,BindingItem.DestObject);
end;

procedure TBindingBehavior.Load(Source: TObject);
var
 Ctx : TRttiContext;
 T : TRttiType;
 Member : TRttiMember;
begin
  T := Ctx.FindType(BindingItem.Binder.SourceType);
  if not Source.InheritsFrom(T.AsInstance.MetaclassType) then
     raise EBinderException.Create('Invalid Source Class');
  Member := T.GetProperty(BindingItem.SourceMember);
  if Not Assigned(Member) then
     Member := T.GetField(BindingItem.SourceMember);
  if Not Assigned(Member) then
     raise EBinderException.Create('Unable to locate Source Member');
  if Not Assigned(BindingItem.DestObject) then
     raise EBinderException.Create('DestObject Not Assigned');

  InternalLoad(Member,BindingItem.DestObject);
end;

procedure TBindingBehavior.Save(Source: TObject);
var
 Ctx : TRttiContext;
 T : TRttiType;
 Member : TRttiMember;
begin
  T := Ctx.FindType(BindingItem.Binder.SourceType);
  if not Source.InheritsFrom(T.AsInstance.MetaclassType) then
     raise EBinderException.Create('Invalid Source Class');

  Validate;

  Member := T.GetProperty(BindingItem.SourceMember);
  if Not Assigned(Member) then
     Member := T.GetField(BindingItem.SourceMember);
  if Not Assigned(Member) then
     raise EBinderException.Create('Unable to locate Source Member');
  if Not Assigned(BindingItem.DestObject) then
     raise EBinderException.Create('DestObject Not Assigned');

  InternalSave(Member,BindingItem.DestObject);
end;

procedure TBindingBehavior.Validate;
begin
  InternalValidate(BindingItem.DestObject);
end;

end.
