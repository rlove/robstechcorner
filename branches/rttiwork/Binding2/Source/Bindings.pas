unit Bindings;
// MIT License
//
// Copyright (c) 2010 - Robert Love
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

interface

uses
  Classes,
  Sysutils,
  Rtti,
  RttiUtils,
  TypInfo,
  Variants,
  Generics.Collections;

const
  BindingVisibility = [mvPublic, mvPublished];

type
  EBinderException = class(Exception);

  TRttiTypeString = String;
  TRttiMemberString = String;
  TBinder = class;
  TBindingCollection = class;
  TBindingCollectionItem = class;

  // Argh... The D2010 formatter really dislikes this code section
  TBindingBehavior = class(TPersistent)
  private
  protected
    FBindingItem: TBindingCollectionItem;
    procedure InternalSave(Source: TObject; DestObj: TObject); virtual; abstract;
    procedure InternalLoad(Source: TObject; DestObj: TObject); virtual; abstract;
    function InternalIsModified(Source: TObject; DestObj: TObject): Boolean; virtual; abstract;
    procedure ValidateDest(DestObj: TObject); virtual;
    function ConvertType(Value: TValue; DataType: TRttiType): TValue; virtual;
    procedure ValidateSource(Source: TObject); virtual;
    function SourceTypeSupported(SourceType: TRttiType): Boolean; virtual;
    function DestTypeSupported(DestType: TRttiType): Boolean; virtual;
  public
    constructor Create(aBindingItem: TBindingCollectionItem); virtual;
    property BindingItem: TBindingCollectionItem read FBindingItem;

    procedure Save(Source: TObject); virtual;
    procedure Load(Source: TObject); virtual;
    procedure Validate(Source: TObject); virtual;

    function DisplayDetails: string; virtual;

    function IsModified(Source: TObject): Boolean; virtual;
  end;

  TMemberBindingBehavior = class(TBindingBehavior)
  private
  protected
    FCtx: TRttiContext;
    FSourceMemberName: TRttiMemberString;
    FDestMemberName: TRttiMemberString;
    FReadOnly: Boolean;
    procedure SetReadOnly(const Value: Boolean);
    procedure SetSourceMemberName(const Value: TRttiMemberString);
    procedure SetDestMemberName(const Value: TRttiMemberString);
    function GetMember(Obj: TObject; MemberName: String): TRttiMember;
    procedure InternalSave(Source: TObject; DestObj: TObject); override;
    procedure InternalLoad(Source: TObject; DestObj: TObject); override;
    function InternalIsModified(Source: TObject; DestObj: TObject): Boolean; override;
    procedure ValidateDest(DestObj: TObject); override;
  public
    constructor Create(aBindingItem: TBindingCollectionItem); override;
    procedure Save(Source: TObject); override;
    function DisplayDetails: string; override;
  published
    property DestMemberName: TRttiMemberString read FDestMemberName write SetDestMemberName;
    property SourceMemberName: TRttiMemberString read FSourceMemberName write SetSourceMemberName;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
  end;

  TBindingBehaviorClass = class of TBindingBehavior;
  TBindingBehaviorClassName = String;

  TBindingCollectionItem = class(TCollectionItem)
  private
    FDestObject: TObject;
    FBehaviorType: TBindingBehaviorClassName;
    FBehavior: TBindingBehavior;
    procedure SetDestObject(const Value: TObject);
    function GetBindingCollection: TBindingCollection;
    procedure SetBehavior(const Value: TBindingBehavior);
    procedure SetBehaviorType(const Value: TBindingBehaviorClassName);
    function GetBinder: TBinder;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property BindingCollection: TBindingCollection read GetBindingCollection;
    property Binder: TBinder read GetBinder;
  published
    // Noted at DesignTime only TComponents are supported for DestObject
    // but you can set it to any object at runtime
    property DestObject: TObject read FDestObject write SetDestObject;

    property BehaviorType: TBindingBehaviorClassName read FBehaviorType write SetBehaviorType;
    property Behavior: TBindingBehavior read FBehavior write SetBehavior;
  end;

  TBindingCollection = class(TOwnedCollection)
  protected
    FBinder: TBinder;
    // Design Time Support
    function GetAttrCount: Integer; override;
    function GetAttr(Index: Integer): string; override;
    function GetItemAttr(Index, ItemIndex: Integer): string; override;
  public
    // TODO: Implement methods to make this show up better in Designer
    constructor Create(aBinder: TBinder);
    destructor Destroy; override;
    property Binding: TBinder read FBinder;
  end;

  TBinder = class(TComponent)
  private
  protected
    FSourceType: TRttiTypeString;
    FBindings: TBindingCollection;
    procedure SetSourceType(const Value: TRttiTypeString);
    procedure SetBindings(const Value: TBindingCollection);
  protected
    class var FBehaviors: TDictionary<String, TBindingBehaviorClass>;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure RegisterBehavior(aClass: TBindingBehaviorClass);
    class function LookupBehavior(aClassName: String): TBindingBehaviorClass;
    class function BehaviorKeys: TEnumerable<String>;

  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; Override;
    procedure Save(Instance: TObject);
    procedure Load(Instance: TObject);
  published
    property SourceType: TRttiTypeString read FSourceType write SetSourceType;
    property Bindings: TBindingCollection read FBindings write SetBindings;
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

procedure TBinder.Load(Instance: TObject);
var
  CI: TCollectionItem;
  Behavior: TBindingBehavior;
begin
  for CI in FBindings do
  begin
    Behavior := TBindingCollectionItem(CI).Behavior;
    if not assigned(Behavior) then
      raise EBinderException.Create('Unable to load Behavior Not Specified');
    Behavior.Load(Instance);
  end;
end;

class function TBinder.LookupBehavior(aClassName: String): TBindingBehaviorClass;
begin
  if not FBehaviors.TryGetValue(aClassName, result) then
    result := nil;
end;

class destructor TBinder.Destroy;
begin
  FBehaviors.Free;
end;

procedure TBinder.Save(Instance: TObject);
var
  CI: TCollectionItem;
  Behavior: TBindingBehavior;
begin
  for CI in FBindings do
  begin
    Behavior := TBindingCollectionItem(CI).Behavior;
    if not assigned(Behavior) then
      raise EBinderException.Create('Unable to save Behavior Not Specified');
    Behavior.Save(Instance);
  end;
end;

procedure TBinder.SetBindings(const Value: TBindingCollection);
begin
  // TODO: Change to Assign (Implement AssignTo)
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

procedure TBindingCollectionItem.SetBehaviorType(const Value: TBindingBehaviorClassName);
var
  lBinderClass: TBindingBehaviorClass;
begin
  FBehaviorType := Value;
  if assigned(FBehavior) and (FBehavior.ClassName <> Value) then
  begin
    FreeAndNil(FBehavior);
  end;
  if Not assigned(FBehavior) then
  begin
    lBinderClass := TBinder.LookupBehavior(Value);
    if assigned(lBinderClass) then
      FBehavior := lBinderClass.Create(self);
  end;
end;

procedure TBindingCollectionItem.SetDestObject(const Value: TObject);
begin
  FDestObject := Value;
end;

{ TBindingCollection }

constructor TBindingCollection.Create(aBinder: TBinder);
begin
  inherited Create(aBinder, TBindingCollectionItem);
  FBinder := aBinder;
end;

destructor TBindingCollection.Destroy;
begin

  inherited;
end;

function TBindingCollection.GetAttr(Index: Integer): string;
begin
  case Index of
    0: result := 'Destination';
    1: result := 'Behavior';
    2: result := 'Behavior Details';
  else result := '';
  end;
end;

function TBindingCollection.GetAttrCount: Integer;
begin
  result := 3;
end;

function TBindingCollection.GetItemAttr(Index, ItemIndex: Integer): string;
var
  Item: TBindingCollectionItem;
begin
  Item := TBindingCollectionItem(Items[ItemIndex]);
  case Index of
    0: begin
        if assigned(Item.DestObject) then
        begin
          // Really only can be TComponent at design time but rather be safe
          // than sorry, since we can bind to TObject
          if Item.DestObject is TComponent then
            result := TComponent(Item.DestObject).Name + ' : ' + Item.DestObject.ClassName
          else
            result := Item.DestObject.ClassName;
        end
        else
        begin
          result := 'Unassigned';
        end;
      end;
    1: result := Item.BehaviorType;
    2: begin
        if assigned(Item.Behavior) then
          result := Item.Behavior.DisplayDetails;
       end;
  end; // Case
end;

{ TBindingBehavior }

function TBindingBehavior.ConvertType(Value: TValue; DataType: TRttiType): TValue;

var
  VarValue: TValue; // Variant TValue
begin
  // This method could possibily make this work in a more efficent manner but this works for now.

  // Duh - Errors that should not really occur, but this is a virtual method so I can't control who calls it!
  Assert(assigned(Value.TypeInfo), 'No Type Information Found');
  Assert(assigned(DataType), 'DataType Not Specified');

  // Convert through Variant
  if not Value.TryCast(TypeInfo(Variant), VarValue) then
    raise EBinderException.CreateFmt('Input Type "%s" Not Supported.', [Value.TypeInfo.Name]);

  if not VarValue.TryCast(DataType.Handle, result) then
    raise EBinderException.CreateFmt('Output Type "%s" Not Supported.', [DataType.Name]);

end;

constructor TBindingBehavior.Create(aBindingItem: TBindingCollectionItem);
begin
  FBindingItem := aBindingItem;
end;

function TBindingBehavior.DestTypeSupported(DestType: TRttiType): Boolean;
begin
  result := DestType.IsInstance;
end;

function TBindingBehavior.DisplayDetails: string;
begin
  result := '';
end;

class constructor TBinder.Create;
begin
  FBehaviors := TDictionary<String, TBindingBehaviorClass>.Create;
  RegisterBehavior(TMemberBindingBehavior);
end;

class procedure TBinder.RegisterBehavior(aClass: TBindingBehaviorClass);
begin
  FBehaviors.Add(aClass.ClassName, aClass);
end;

function TBindingBehavior.IsModified(Source: TObject): Boolean;
begin
  Validate(Source);
  result := InternalIsModified(Source, BindingItem.DestObject);
end;

procedure TBindingBehavior.Load(Source: TObject);
begin
  Validate(Source);
  InternalLoad(Source, BindingItem.DestObject);
end;

procedure TBindingBehavior.Save(Source: TObject);
begin
  Validate(Source);
  InternalSave(Source, BindingItem.DestObject);
end;

function TBindingBehavior.SourceTypeSupported(SourceType: TRttiType): Boolean;
begin
  result := SourceType.IsInstance;
end;

procedure TBindingBehavior.Validate(Source: TObject);
begin
  ValidateSource(Source);
  ValidateDest(BindingItem.DestObject);
end;

procedure TBindingBehavior.ValidateDest(DestObj: TObject);
begin
  if not assigned(DestObj) then
    raise EBinderException.Create('DestObj not assigned');
end;

procedure TBindingBehavior.ValidateSource(Source: TObject);
var
  Ctx: TRttiContext;
  T: TRttiType;

begin
  if not assigned(Source) then
    raise EBinderException.Create('Source not assigned');
  T := Ctx.FindType(BindingItem.Binder.SourceType);
  if not Source.InheritsFrom(T.AsInstance.MetaclassType) then
    raise EBinderException.Create('Invalid Source Class');
end;

{ TMemberBindingBehavior }

constructor TMemberBindingBehavior.Create(aBindingItem: TBindingCollectionItem);
begin
  inherited;
  FCtx := TRttiContext.Create;
  // Insure Pool Created;
  FCtx.GetType(TypeInfo(Integer));

end;

function TMemberBindingBehavior.GetMember(Obj: TObject; MemberName: String): TRttiMember;
begin
  Assert(assigned(Obj));
  result := FCtx.GetType(Obj.ClassInfo).GetProperty(MemberName);
  if Not assigned(result) then
    FCtx.GetType(Obj).GetField(MemberName);
  if Not assigned(result) then
    raise EBinderException.CreateFmt('Member "%s" not found on class of type "%s"', [MemberName, Obj.ClassName]);
  if not(result.Visibility in BindingVisibility) then
    raise EBinderException.Create('Visibility of Member not Supported');
end;


function TMemberBindingBehavior.InternalIsModified(Source,
  DestObj: TObject): Boolean;
var
  SourceValue: TValue;
  DestValue: TValue;
  SourceVar : Variant;
  DestVar : Variant;
  SourceMember: TRttiMember;
  DestMember: TRttiMember;
begin
   // If the types are the same (i.e. String to String) this is alot of overhead
   // may want to change

   // Get Members
   SourceMember := GetMember(Source, FSourceMemberName);
   DestMember := GetMember(DestObj, FDestMemberName);
   // Get Source Value
   SourceValue := SourceMember.GetValue(Source);
   DestValue := DestValue;
   // Source into Dest.Type
   SourceValue := ConvertType(SourceValue,DestMember.MemberType);
   // Convert to variant
   SourceVar := SourceValue.AsType<Variant>;
   DestVar := DestValue.AsType<Variant>;
   // Actual comparision
   result := VarCompareValue(SourceVar,DestVar) = vrEqual;
end;

procedure TMemberBindingBehavior.InternalLoad(Source: TObject; DestObj: TObject);
var
  Value: TValue;
  SourceMember: TRttiMember;
  DestMember: TRttiMember;
begin
  // Get Members
  SourceMember := GetMember(Source, FSourceMemberName);
  DestMember := GetMember(DestObj, FDestMemberName);
  // Get Source Value
  Value := SourceMember.GetValue(Source);
  // Convert and Set Dest Value
  DestMember.SetValue(DestObj, ConvertType(Value, DestMember.MemberType));
end;

procedure TMemberBindingBehavior.InternalSave(Source: TObject; DestObj: TObject);

var
  Value: TValue;
  SourceMember: TRttiMember;
  DestMember: TRttiMember;
begin
  // Get Members
  SourceMember := GetMember(Source, FSourceMemberName);
  DestMember := GetMember(DestObj, FDestMemberName);
  // Get Dest Value
  Value := DestMember.GetValue(DestObj);
  // Convert and Set Source Value
  SourceMember.SetValue(Source, ConvertType(Value, SourceMember.MemberType));
end;

procedure TMemberBindingBehavior.ValidateDest(DestObj: TObject);
var
  Value: TValue;
  C: TRttiContext;
  Member: TRttiMember;
  T: TRttiType;
begin
  T := C.GetType(DestObj.ClassInfo);

  Member := T.GetProperty(FDestMemberName);
  if Not assigned(Member) then
    Member := T.GetField(FDestMemberName);
  if Not assigned(Member) then
    raise EBinderException.CreateFmt('Unable to locate "%s" Member on "%s"', [FDestMemberName, T.Name]);

  Value := Member.GetValue(DestObj);
  // ConvertType(Value,  SourceMember.MemberType);

end;

procedure TMemberBindingBehavior.Save(Source: TObject);
begin
  if not FReadOnly then
  begin
    inherited Save(Source);
  end;
end;

procedure TMemberBindingBehavior.SetDestMemberName(const Value: TRttiMemberString);
begin
  FDestMemberName := Value;
end;

procedure TMemberBindingBehavior.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure TMemberBindingBehavior.SetSourceMemberName(const Value: TRttiMemberString);
begin
  FSourceMemberName := Value;
end;

function TMemberBindingBehavior.DisplayDetails: string;
begin
  // Really only used for Design Time Collection Editor
  result := 'Source := ' + FSourceMemberName + ';   Dest :=' + FDestMemberName + ';';
end;

end.
