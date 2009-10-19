unit AbstractRTTI;
// Allows Developer to create custom type mappings, so that things
// that use this, such as Xml Serialization can take type and
// represent them in a different way and the Xml Serialization
// engine would not know anything special.

// SideNote: Because things like GetAtttrbutes are abstracted as well
// it leaves open the potential to allow Attributes to a class at runtime

// Acronyms
// ats - Abstract Type System


interface
uses
  SysUtils,Classes, Rtti, TypInfo, Generics.Collections;
type


  TatsObject = class abstract(TObject)
  public
     function GetAttributes: TArray<TCustomAttribute>; virtual; abstract;
  end;

  TatsNamedObject = class abstract(TatsObject)
  private
    function GetName: string; virtual; abstract;
  public
    property Name: string read GetName;
  end;

  // Goal Abstract functionality TRttiProperty and TRttiField
  TatsValueMember = class abstract(TatsNamedObject)
  protected
    function GetMemberType: TRttiType; virtual; abstract;
    function GetIsReadable: Boolean; virtual; abstract;
    function GetIsWritable: Boolean; virtual; abstract;
    function DoGetValue(Instance: Pointer): TValue; virtual; abstract;
    procedure DoSetValue(Instance: Pointer; const AValue: TValue); virtual; abstract;
    function GetVisibility: TMemberVisibility; virtual; abstract;
  public
    property IsReadable: Boolean read GetIsReadable;
    property IsWritable: Boolean read GetIsWritable;

    function GetValue(Instance: Pointer): TValue;
    procedure SetValue(Instance: Pointer; const AValue: TValue);

    property MemberType : TRttiType read GetMemberType;
    property Visibility: TMemberVisibility read GetVisibility;
  end;

  TatsRTTIValueMember = class abstract(TatsValueMember)
  protected
    FMember : TRttiMember;
    function GetName : String; override;
    function GetVisibility: TMemberVisibility; override;
  public
    constructor Create(aMember : TRttiMember); virtual;
    function GetAttributes: TArray<TCustomAttribute>; override;
  end;

  TatsRTTIProperty = class (TatsRTTIValueMember)
  protected
    function GetMemberType: TRttiType; override;
    function GetIsReadable: Boolean; override;
    function GetIsWritable: Boolean; override;
    function DoGetValue(Instance: Pointer): TValue; override;
    procedure DoSetValue(Instance: Pointer; const AValue: TValue); override;
  public
    constructor Create(aMember : TRttiMember); override;
  end;

  TatsRTTIField = class (TatsRTTIValueMember)
  protected
    function GetMemberType: TRttiType; override;
    function GetIsReadable: Boolean; override;
    function GetIsWritable: Boolean; override;
    function DoGetValue(Instance: Pointer): TValue; override;
    procedure DoSetValue(Instance: Pointer; const AValue: TValue); override;
  public
    constructor Create(aMember : TRttiMember); override;
  end;

  TCustomAttributeClass = class of TCustomAttribute;

  TatsValueType = class abstract(TObject)
  protected
    FValue : TValue;
    function GetValue : TValue; virtual;
    procedure SetValue(const aValue: TValue); virtual;
  public
    property Value : TValue read GetValue write SetValue;

    function GetFields: TArray<TatsValueMember>; virtual; abstract;
    function GetProperties: TArray<TatsValueMember>; virtual; abstract;

    function GetField(const AName: string): TatsValueMember; virtual;
    function GetProperty(const AName: string): TatsValueMember; virtual;

    function GetAttributes: TArray<TCustomAttribute>; virtual; abstract;

    function HasAttribute(aClass : TCustomAttributeClass) : Boolean; overload; virtual;
    function HasAttribute(aClass : TCustomAttributeClass;var Attr : TCustomAttribute) : Boolean; overload; virtual;


  end;

  TatsRTTIValueType = class(TatsValueType)
  protected
    FFieldList : TObjectList<TatsValueMember>;
    FPropertyList : TObjectList<TatsValueMember>;
    procedure Clear;
    procedure SetValue(const aValue: TValue); override;
    procedure PopulateFields; virtual;
    procedure PopulateProperties; virtual;
  public
    function GetFields: TArray<TatsValueMember>; override;
    function GetProperties: TArray<TatsValueMember>; override;
    function GetAttributes: TArray<TCustomAttribute>;  override;


    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TatsValueTypeFactory = class(TObject)
  public
    class function CreateValueType(Value : TValue;);
  end;

implementation
type
  TListHelper = class // taken from implemenation in Rtti.pas
  public
    class function ToArray<T>(AList: TList<T>): TArray<T>;
  end;

class function TListHelper.ToArray<T>(AList: TList<T>): TArray<T>;
var
  i: Integer;
begin
  SetLength(Result, AList.Count);
  for i := 0 to AList.Count - 1 do
    Result[i] := AList[i];
end;


function TatsValueMember.GetValue(Instance: Pointer): TValue;
begin
  if not IsReadable then
    raise EPropWriteOnly.Create(Name);
  Result := DoGetValue(Instance);
end;

procedure TatsValueMember.SetValue(Instance: Pointer;
  const AValue: TValue);
begin
  if not IsWritable then
    raise EPropReadOnly.Create(Name);
  DoSetValue(Instance, AValue);
end;

{ TRttiMemberValue }

constructor TatsRTTIValueMember.Create(aMember: TRttiMember);
begin
  FMember := aMember;
end;

function TatsRTTIValueMember.GetAttributes: TArray<TCustomAttribute>;
begin
  result := FMember.GetAttributes;
end;

function TatsRTTIValueMember.GetName: String;
begin
  result := FMember.Name;
end;

function TatsRTTIValueMember.GetVisibility: TMemberVisibility;
begin
 result := FMember.Visibility;
end;


{ TatsRTTIProperty }

constructor TatsRTTIProperty.Create(aMember: TRttiMember);
begin
  inherited;
  Assert(aMember is TRttiProperty);
end;

function TatsRTTIProperty.DoGetValue(Instance: Pointer): TValue;
begin
  result := TRttiProperty(fMember).GetValue(Instance);
end;

procedure TatsRTTIProperty.DoSetValue(Instance: Pointer; const AValue: TValue);
begin
  TRttiProperty(fMember).setValue(Instance,AValue);
end;

function TatsRTTIProperty.GetIsReadable: Boolean;
begin
  result := TRttiProperty(fMember).IsReadable;
end;

function TatsRTTIProperty.GetIsWritable: Boolean;
begin
  result := TRttiProperty(fMember).IsWritable;
end;

function TatsRTTIProperty.GetMemberType: TRttiType;
begin
 result := TRttiProperty(fMember).PropertyType;
end;

{ TatsRTTIField }

constructor TatsRTTIField.Create(aMember: TRttiMember);
begin
  inherited;
  Assert(aMember is TRttiField);
end;

function TatsRTTIField.DoGetValue(Instance: Pointer): TValue;
begin
  result := TRttiField(fMember).GetValue(Instance);
end;

procedure TatsRTTIField.DoSetValue(Instance: Pointer; const AValue: TValue);
begin
  TRttiField(fMember).SetValue(Instance,AValue);
end;

function TatsRTTIField.GetIsReadable: Boolean;
begin
 result := true;
end;

function TatsRTTIField.GetIsWritable: Boolean;
begin
 result := true;
end;

function TatsRTTIField.GetMemberType: TRttiType;
begin
 result := TRttiField(fMember).FieldType;
end;

{ TatsValueType }

function TatsValueType.GetField(const AName: string): TatsValueMember;
begin
  for Result in GetFields do
    if SameText(Result.Name, AName) then
      Exit;
  Result := nil;
end;

function TatsValueType.GetProperty(const AName: string): TatsValueMember;
begin
  for Result in GetProperties do
    if SameText(Result.Name, AName) then
      Exit;
  Result := nil;
end;

function TatsValueType.GetValue: TValue;
begin
  result := FValue;
end;


function TatsValueType.HasAttribute(aClass: TCustomAttributeClass): Boolean;
var
 Attr : TCustomAttribute;
begin
 result := HasAttribute(aClass,Attr);
end;

function TatsValueType.HasAttribute(aClass: TCustomAttributeClass;
  var Attr: TCustomAttribute): Boolean;
var
 lAttr : TCustomAttribute;
begin
 for lAttr in GetAttributes do
 begin
   if lAttr is aClass then
   begin
     Attr := lAttr;
     exit(true);
   end;
 end;
 Attr := nil;
 result := false;
end;

procedure TatsValueType.SetValue(const aValue: TValue);
begin
  FValue := aValue;
end;

{ TatsRTTIValueType }

procedure TatsRTTIValueType.Clear;
begin
  FFieldList.Clear;
  FPropertyLIst.Clear;
end;

constructor TatsRTTIValueType.Create;
begin
   FFieldList := TObjectList<TatsValueMember>.Create;
   FPropertyLIst := TObjectList<TatsValueMember>.Create;
end;

destructor TatsRTTIValueType.Destroy;
begin
  FFieldList.Free;
  FPropertyLIst.Free;
  inherited;
end;

function TatsRTTIValueType.GetAttributes: TArray<TCustomAttribute>;
var
  C : TRttiContext;
  t : TRttiType;
begin
 C := TRttiContext.Create;
 result :=  C.GetType(value.TypeInfo).GetAttributes;
end;

function TatsRTTIValueType.GetFields: TArray<TatsValueMember>;
begin
  PopulateFields;
  result := TListHelper.ToArray<TatsValueMember>(FFieldList);
end;

function TatsRTTIValueType.GetProperties: TArray<TatsValueMember>;
begin
  PopulateProperties;
  result := TListHelper.ToArray<TatsValueMember>(FPropertyList);
end;

procedure TatsRTTIValueType.PopulateFields;
var
  C : TRttiContext;
  t : TRttiType;
  field : TRttiField;
begin
 C := TRttiContext.Create;
 t :=  C.GetType(value.TypeInfo);
 for field in t.GetFields do
   FFieldList.Add(TatsRTTIField.Create(field));
end;

procedure TatsRTTIValueType.PopulateProperties;
var
  C : TRttiContext;
  t : TRttiType;
  prop : TRttiProperty;
begin
 C := TRttiContext.Create;
 t :=  C.GetType(value.TypeInfo);
 for prop in t.GetProperties do
   FFieldList.Add(TatsRTTIField.Create(prop));
end;

procedure TatsRTTIValueType.SetValue(const aValue: TValue);
begin
 if FValue.TypeInfo <> aValue.TypeInfo then
    Clear;

 inherited;
end;




end.
