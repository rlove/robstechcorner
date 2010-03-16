unit CloneStorage;
interface
uses SysUtils, Classes, Generics.Collections, Rtti;

Type

  //Purpose the make a copy of an object or record
  //for Temporary storage.  Only used when you can't
  //create a second instance of the source object/record
  //to store the value
  TCloneValue = class(TObject)
  protected
    FCtx : TRttiContext;
    FAssignedType : TRttiType;
    FFields : TDictionary<String,TValue>;
    FProperties : TDictionary<String,TValue>;
    FValue : TValue;
    function CanHaveMembers : Boolean;
    procedure SetAssignedType(const Value: TRttiType); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure SetProperty(aName : String;Value : TValue); virtual;
    procedure SetField(aName : String; Value : TValue); virtual;
    function GetProperty(aName : String) : TValue; virtual;
    function GetField(aName : String) : TValue; virtual;

    function GetProperties : TDictionary<String,TValue>.TKeyEnumerator;
    function GetFields : TDictionary<String,TValue>.TKeyEnumerator;

    function GetMemberNames : TArray<String>;

    procedure Assign(Source: TValue); virtual;
    procedure AssignTo(Dest: TValue); virtual;

    property AssignedType : TRttiType read FAssignedType write SetAssignedType;

  end;

implementation
uses TypInfo;

{ TCloneValue }

procedure TCloneValue.Assign(Source: TValue);
var
 lProp : TRttiProperty;
 lField : TRttiField;
 lSourcePtr : Pointer;
begin
  FAssignedType := FCtx.GetType(Source.TypeInfo);
  if CanHaveMembers then
  begin
   // Determine reference for Get/SetValue
   if FAssignedType.IsInstance then
     lSourcePtr := Source.AsObject
   else
     lSourcePtr := Source.GetReferenceToRawData;

   for lProp in FAssignedType.GetProperties do
   begin
     if lProp.Visibility in [mvPublic,mvPublished] then
        SetProperty(lProp.Name,lProp.GetValue(lSourcePtr));
   end;

   for lField in FAssignedType.GetFields do
   begin
     if lField.Visibility in [mvPublic,mvPublished] then
        SetProperty(lField.Name,lField.GetValue(lSourcePtr));
   end;

  end
  else
  begin
    // I just have to store the value
    FValue := Source;
  end;
end;

procedure TCloneValue.AssignTo(Dest: TValue);
var
 lProp : TRttiProperty;
 lField : TRttiField;
 lDestPtr : Pointer;
 lDestType : TRttiType;
begin
  lDestType := FCtx.GetType(Dest.TypeInfo);
  if CanHaveMembers then // From Source!
  begin
   // Determine reference for Get/SetValue
   if FAssignedType.IsInstance then
     lDestPtr := Dest.AsObject
   else
     lDestPtr := Dest.GetReferenceToRawData;

   for lProp in lDestType.GetProperties do
   begin
     if lProp.Visibility in [mvPublic,mvPublished] then
        lProp.SetValue(lDestPtr,GetProperty(lProp.Name));
   end;

   for lField in lDestType.GetFields do
   begin
     if lField.Visibility in [mvPublic,mvPublished] then
        lField.SetValue(lDestPtr,GetField(lField.Name));
   end;

  end
  else
  begin
    // I just have to Return the value
    FValue := Dest;
  end;
end;

function TCloneValue.CanHaveMembers: Boolean;
begin
  result := Assigned(FAssignedtype) and (FAssignedType.IsInstance or FAssignedType.IsRecord);
end;

constructor TCloneValue.Create;
begin
  FCtx := TRttiContext.Create;
  FCtx.GetType(TypeInfo(Integer)); // Insure Pool Token
  FAssignedType := nil;
  FFields := TDictionary<String,TValue>.Create;
  FProperties := TDictionary<String,TValue>.Create;
end;

destructor TCloneValue.Destroy;
begin
  FFields.Free;
  FProperties.Free;

  inherited;
end;

function TCloneValue.GetField(aName: String): TValue;
begin
  if not FFields.TryGetValue(aName,result) then
     result := TValue.Empty;
end;

function TCloneValue.GetFields: TDictionary<String, TValue>.TKeyEnumerator;
begin
  result := FFields.Keys.GetEnumerator;
end;

function TCloneValue.GetMemberNames: TArray<String>;
var
 Props : TArray<String>;
 S: String;
 I : Integer;
begin
 SetLength(Result,FProperties.Count + FFields.Count);
 I := 0;
 for S in FProperties.Keys do
 begin
   result[I] := S;
   inc(I);
 end;
 for S in FFields.Keys do
 begin
   result[I] := S;
   inc(I);
 end; 

end;

function TCloneValue.GetProperties: TDictionary<String, TValue>.TKeyEnumerator;
begin
  result := FProperties.Keys.GetEnumerator;
end;

function TCloneValue.GetProperty(aName: String): TValue;
begin
  if not FProperties.TryGetValue(aName,result) then
     result := TValue.Empty;
end;

procedure TCloneValue.SetAssignedType(const Value: TRttiType);
begin
  FAssignedType := Value;
end;

procedure TCloneValue.SetField(aName: String; Value: TValue);
begin
  FFields.AddOrSetValue(aName,Value);
end;

procedure TCloneValue.SetProperty(aName: String; Value: TValue);
begin
  FProperties.AddOrSetValue(aName,Value);
end;

end.
