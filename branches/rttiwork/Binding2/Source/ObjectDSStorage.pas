unit ObjectDSStorage;

interface
uses Sysutils, CloneStorage, Rtti, DB;

Type
  TBindingCopyStorage = class;

  EBindingCopyStorage = class (Exception);

  TBindingStorageCreateEvent = function (Sender : TBindingCopyStorage) : TObject of object;

  TBindingStorageMethod = (bsCopy,bsTemp,bsDirect);

  // It possible the value may not be an TObject.
  // It also possible that you may not be able to create a copy even even
  // if Value is an Object.
  // But if we can create a copy, we can get the benefits of using it as
  // the storage mechanism.
  TBindingCopyStorage = class(TObject)
  private
    FStorageMethod: TBindingStorageMethod;
    procedure SetStorageMethod(const Value: TBindingStorageMethod);
  protected
    FCtx : TRttiContext;
    FDirect : TValue;
    FCopy : TObject;
    FCloneValue : TCloneValue;

    FOnCreateCopy: TBindingStorageCreateEvent;
    FSourceSupportsAssign: Boolean;
    FSourceClass: TClass;

    procedure SetSourceClass(const Value: TClass); virtual;
    procedure SetSourceSupportsAssign(const Value: Boolean); virtual;
    procedure AssignCopyRtti(Source : TObject; Dest : TObject);
    procedure AssignCopyMethod(Source : TObject; Dest : TObject);
    function GetMemberNames(Value : TValue) : TArray<String>; overload; virtual;
  public
    property SourceClass : TClass read FSourceClass write SetSourceClass;
    property SourceSupportsAssign : Boolean read FSourceSupportsAssign write SetSourceSupportsAssign;

    property OnCreateCopy : TBindingStorageCreateEvent read FOnCreateCopy write FOnCreateCopy;
    property StorageMethod : TBindingStorageMethod read FStorageMethod write SetStorageMethod;

    function GetMemberNames : TArray<String>; overload;
    procedure SetMemberValue(aName : String; Value : TValue);
    function GetMembervalue(aName : String) : TValue;

    procedure LoadValue(Source : TValue); virtual;
    procedure SaveValue(Source : TValue); virtual;
  end;

//  IBindingType = interface
//    ['{73C9925D-5176-4F08-92F6-93F7F8F27EFD}']
//    function ItemCount : Integer;
//    function Add(Value : TValue) : Integer;
//    procedure Insert(Index : Integer;Value : TValue);
//    procedure Delete(Index : Integer);
//    procedure PostChanges(Index : Integer; Value : TValue);
//    procedure SetMember(aName : String;Value : TValue);
//    function GetMember(aName : String) : TValue;
//    function GetMembers : TArray<String>;
//  end;

//  TStructBindingType = class(TInterfacedObject,IBindingType)
//  public // Interface Members
//    function ItemCount : Integer;
//    function Add(Value : TValue) : Integer;
//    procedure Insert(Index : Integer;Value : TValue);
//    procedure Delete(Index : Integer);
//    procedure PostChanges(Index : Integer; Value : TValue);
//    procedure SetMember(aName : String;Value : TValue);
//    function GetMember(aName : String) : TValue;
//    function GetMembers : TArray<String>;
//  public
//    constructor Create(aType : TRttiType);
//  end;
//
//  TListBindingType = class(TInterfacedObject,IBindingType)
//  public // Interface Members
//    function ItemCount : Integer;
//    function Add(Value : TValue) : Integer;
//    procedure Insert(Index : Integer;Value : TValue);
//    procedure Delete(Index : Integer);
//    procedure PostChanges(Index : Integer; Value : TValue);
//    procedure SetMember(aName : String;Value : TValue);
//    function GetMember(aName : String) : TValue;
//    function GetMembers : TArray<String>;
//  public
//    constructor Create(aType : TRttiType);
//  end;
//
//  TBindingTypeFactory = class(TObject)
//    function GetBindingType(aType : TRttiType) : IBindingType;
//  end;
//
//  TBindingData = class(Tobject)
//  private
//    FCtx : TRttiContext;
//    FBoundData : TValue;
//    FBoundType : TRttiType;
//    FBindingType : IBindingType;
//
//    procedure SetBoundData(const Value: TValue);
//    function ItemCount : Integer;
////    function Add(Value : TValue) : Integer;
////    function Insert(Index : Integer;Value : TValue);
////    function Delete(Index : Integer);
////    procedure PostChanges(Index : Integer; Value : TValue);
//  public
//    property BoundData : TValue read FBoundData write SetBoundData;
//  end;

implementation
uses TypInfo;
{ TObjectDataSetStorage }


procedure TBindingCopyStorage.AssignCopyMethod(Source, Dest: TObject);
var
 lCtx : TRttiContext;
 lAssignMethod : TRttiMethod;
 lAssignParms : TArray<TRttiParameter>;
begin
 lAssignMethod := lCtx.GetType(Dest.ClassInfo).GetMethod('Assign');
 if not Assigned(lAssignMethod) then
    raise EBindingCopyStorage.Create('Assign Method Not located on Dest.');
 // Will raise exception if lAssignMethod does not have matching params.
 lAssignMethod.Invoke(Dest,[Source]);
end;

procedure TBindingCopyStorage.AssignCopyRtti(Source, Dest: TObject);
var
 lCtx : TRttiContext;
 lField : TRttiField;
 lProp : TRttiProperty;
 lSourceType : TRttiType;
begin
// This assignment copies all public and published
// properties and fields to destination.
// This preserves Set Method that do assignment and does not make
// copies of references unless they should exist.

  if not (Dest is Source.ClassType) then
     raise EBindingCopyStorage.CreateFmt('Can not assign %s to a %s.',[Source.ClassName,Dest.ClassName]);

  lSourceType := lCtx.GetType(Source.ClassInfo);

  for lProp in lSourceType.GetProperties do
  begin
    if lProp.Visibility in [mvPublic, mvPublished] then
      lProp.SetValue(Source, lProp.GetValue(Dest));

  end;

  for lField in lSourceType.GetFields do
  begin
    if lField.Visibility in [mvPublic, mvPublished] then
      lField.SetValue(Source, lField.GetValue(Dest));
  end;
end;

function TBindingCopyStorage.GetMemberNames: TArray<String>;
begin
  case FStorageMethod of
    bsCopy: result := GetMemberNames(FCopy);
    bsTemp: result := GetMemberNames(FDirect);
    bsDirect: result := FCloneValue.GetMemberNames;
  end;
end;

function TBindingCopyStorage.GetMemberNames(Value: TValue): TArray<String>;
var
 ValueType :  TRttiType;
 PropList : TArray<TRttiProperty>;
 FieldList :  TArray<TRttiField>;
 Prop : TRttiProperty;
 Field : TRttiField;
 Size : Integer;
 Position : Integer;
begin
  ValueType := FCtx.GetType(Value.TypeInfo);
  PropList := ValueType.GetProperties;
  FieldList := ValueType.GetFields;
  Size := 0;
  // Determine Size
  for Prop in PropList do
  begin
    if Prop.Visibility in [mvPublic,mvPublished] then
    begin
       Inc(Size);
    end;
  end;
  for Field in FieldList do
  begin
    if Field.Visibility in [mvPublic,mvPublished] then
    begin
       Inc(Size);
    end;
  end;
  // Set Result Size
  SetLength(Result,Size);
  Position := 0;
  // Set Result
  for Prop in PropList do
  begin
    if Prop.Visibility in [mvPublic,mvPublished] then
    begin
       result[Position] := Prop.Name;
       Inc(Position);
    end;
  end;
  for Field in FieldList do
  begin
    if Field.Visibility in [mvPublic,mvPublished] then
    begin
       result[Position] := Field.Name;
       Inc(Position);
    end;
  end;
end;

function TBindingCopyStorage.GetMembervalue(aName: String): TValue;
begin

end;

procedure TBindingCopyStorage.LoadValue(Source: TValue);
begin
 case FStorageMethod of
   bsCopy: begin
             if Assigned(FOnCreateCopy) then
             begin
               FCopy := FOnCreateCopy(self);
               if Not Assigned(FCopy) then
                  raise EBindingCopyStorage.Create('OnCreateCopy did not return a valid Instance');
             end
             else
               FCopy := TClass.Create;

             if FSourceSupportsAssign then
               AssignCopyMethod(Source.AsObject,FCopy)
             else
               AssignCopyRtti(Source.AsObject,FCopy);
           end;
   bsTemp: FCloneValue.Assign(Source);
   bsDirect: FDirect := Source;
 end;

end;

procedure TBindingCopyStorage.SaveValue(Source: TValue);
begin
 case FStorageMethod of
   bsCopy:   if FSourceSupportsAssign then
     AssignCopyMethod(FCopy,Source.AsObject)
   else
     AssignCopyRtti(FCopy,Source.AsObject);
   bsTemp:    FCloneValue.AssignTo(Source);
   bsDirect: FDirect := Source;
 end;
end;


procedure TBindingCopyStorage.SetMemberValue(aName: String; Value: TValue);
begin

end;

procedure TBindingCopyStorage.SetSourceClass(const Value: TClass);
begin
  FSourceClass := Value;
end;

procedure TBindingCopyStorage.SetSourceSupportsAssign(const Value: Boolean);
begin
  FSourceSupportsAssign := Value;
end;


procedure TBindingCopyStorage.SetStorageMethod(
  const Value: TBindingStorageMethod);
begin
  FStorageMethod := Value;
end;

{ TBindingData }

//procedure TBindingData.SetBoundData(const Value: TValue);
//begin
//  FBoundData := Value;
//  FBoundType := FCtx.GetType(Value.TypeInfo)
//end;


end.
