unit TestRTTI;

interface
uses
  TestFramework, TypInfo, Classes, RTTI, RttiUtils, SysUtils,Generics.Collections;
type
  // let everything be visible for these tests.
  {$RTTI EXPLICIT
      METHODS(DefaultFieldRttiVisibility)
      FIELDS(DefaultFieldRttiVisibility)
      PROPERTIES(DefaultFieldRttiVisibility)}

  TTestFieldVisibility = class(TObject)
  private
    Fprivate : IInterface;
  protected
    Fprotected : IInterface;
  public
    Fpublic : IInterface;
  published
    Fpublished : IInterface;
  end;

  TTestPropVisibility = class(TObject)
  private
    Fprivate : IInterface;
    property propPrivate : IInterface read Fprivate write FPrivate;
  protected
    Fprotected : IInterface;
    property propProtected : IInterface read Fprotected write Fprotected;
  public
    Fpublic : IInterface;
    property propPublic : IInterface read Fpublic write Fpublic;
  published
    Fpublished : IInterface;
    property propPublished : IInterface read Fpublished write Fpublished;
  end;


  TTestFieldTypes = class(TObject)
  public
    FInteger: Integer;
    FUnicodeString : UnicodeString;
    FAnsiString : AnsiString;
    FShortString : ShortString;
    FWideChar : WideChar;
    FAnsiChar : AnsiChar;
    FEnum : TFloatFormat;
    FDouble : Double;
    FSet : TSysCharSet;
    FBoolean : Boolean;
    FDateTime : TDateTime;
    FObject : TObject;
    FClass : TClass;
    FAI : array[0..9] of integer;
    FAIDyn : array of integer;
    FRecord : TSearchRec;
    FVariantPackedRec : LongRec;
    FPackedRec : TFloatRec;
  end;

  TFixedIntArray = array[0..9] of integer;
  TDynamicIntArray = array of Integer;
  TTestPropTypes = class(TObject)
  private
    FInteger: Integer;
    FUnicodeString : UnicodeString;
    FAnsiString : AnsiString;
    FShortString : ShortString;
    FWideChar : WideChar;
    FAnsiChar : AnsiChar;
    FEnum : TFloatFormat;
    FDouble : Double;
    FSet : TSysCharSet;
    FBoolean : Boolean;
    FDateTime : TDateTime;
    FObject : TObject;
    FClass : TClass;
    FAI : TFixedIntArray;
    FAIDyn : TDynamicIntArray;
    FRecord : TSearchRec;
    FVariantPackedRec : LongRec;
    FPackedRec : TFloatRec;
  public
    property propInteger : Integer read FInteger write FInteger;
    property propUnicodeString : UnicodeString read FUnicodeString write FUnicodeString;
    property propAnsiString : AnsiString read FAnsiString write FAnsiString;
    property propShortString : ShortString read FShortString write FShortString;
    property propWideChar : WideChar read FWideChar write FWideChar;
    property propAnsiChar : AnsiChar read FAnsiChar write FAnsiChar;
    property propEnum : TFloatFormat read FEnum write FEnum;
    property propDouble : Double read FDouble write FDouble;
    property propSet : TSysCharSet read FSet write FSet;
    property propBoolean : Boolean read FBoolean write FBoolean;
    property propDateTime : TDateTime read FDateTime write FDateTime;
    property propObject : TObject read FObject write FObject;
    property propClass : TClass read FClass write FClass;
    property propAI : TFixedIntArray read FAI write FAI;
    property propAIDyn : TDynamicIntArray read FAIDyn write FAIDyn;
    property propRecord : TSearchRec read FRecord write FRecord;
    property propVariantPackedRec : LongRec read FVariantPackedRec write FVariantPackedRec;
    property propPackedRec : TFloatRec read FPackedRec write FPackedRec;
  end;

  TRttiTestCase = class(TTestCase)
  published
    procedure FieldTestVisibility;
    procedure FieldTestStandardTypes;
    procedure FieldTestRecords;
    procedure FieldTestFixedLenArray;
    procedure FieldTestDynamicArray;

    procedure PropTestVisibility;
    procedure PropTestStandardTypes;
    procedure PropTestRecords;
    procedure PropTestFixedLenArray;
    procedure PropTestDynamicArray;

    procedure TestCreateRecord;
    procedure TestCreateObject;

    procedure TestSetGetPropValues;

    procedure TestInvokeTListIntEnum;

  end;

implementation

{ TRttiTestCase }

procedure TRttiTestCase.TestCreateObject;
var
 c : TRttiContext;
 v : TValue;
 o : TObject;
begin
 c := TRttiContext.Create;
 v := c.GetType(TTestFieldTypes).GetMethod('Create').Invoke(TTestFieldTypes,[]);
 Check(v.IsObject,'No Object Created');
 Check(v.Kind = tkClass,'Invalid Type Kind');
 Check(v.TypeInfo = TTestFieldTypes.ClassInfo,'Invalid TypeInfo');
 Check(v.IsInstanceOf(TTestFieldTypes),'IsInstanceOf');
 o := v.AsObject;
 // first check does this so really testing TValue Assignment.
 CheckIs(O,TTestFieldTypes,'Invalid Class');
 c.Free;
end;

procedure TRttiTestCase.TestCreateRecord;
type
 PType = ^TDispatchMessage;
var
 c : TRttiContext;
 v : TValue;
 r : TDispatchMessage;
begin
 TValue.Make(nil,TypeInfo(TDispatchMessage),v);
 check(v.TypeInfo = TypeInfo(TDispatchMessage),'Invalid TypeInfo');
 Check(v.Kind = tkRecord,'Invalid Type Kind');
 c := TRttiContext.Create;
 c.GetType(v.TypeInfo).GetField('MsgID').SetValue(v.GetReferenceToRawData,3947);
 v.ExtractRawData(@r);
 CheckEquals(3947,r.MsgID);
 c.Free;
end;

procedure TRttiTestCase.TestInvokeTListIntEnum;
var
 L : TList<Integer>;
 L2 : TLIst<Integer>;
 C : TRttiContext;
 T : TRttiType;
 LV : TValue;

 lEnumMethod : TRttiMethod;
 lType : TRttiType;
 lEnumerator : TValue;
 lEnumType : TRttiType;
 lMoveNextMethod : TRttiMethod;
 lCurrentProp : TRttiProperty;
 ValuePtr : Pointer;

begin
 L := TList<Integer>.Create;
 L2 := TList<Integer>.Create;
 try
 L.Add(1);
 L.Add(2);
 C := TRttiContext.Create;
{$REGION 'test1'}
 T :=  C.GetType(L.ClassInfo);
 lEnumerator := T.GetMethod('GetEnumerator').Invoke(L,[]);

 lEnumType :=  C.GetType(lEnumerator.TypeInfo);
 lMoveNextMethod := lEnumType.GetMethod('MoveNext');
 lCurrentProp := lEnumType.GetProperty('Current');

 Check(Assigned(LMoveNextMethod),'MoveNext method not found');
 Check(Assigned(lCurrentProp),'Current property not found');

 while lMoveNextMethod.Invoke(lEnumerator.AsObject,[]).asBoolean do
 begin
   L2.Add(lCurrentProp.GetValue(lEnumerator.AsObject).AsOrdinal);
 end;

 CheckEquals(L.Count,L2.Count);
 CheckEquals(1,L2.Items[0]);
 CheckEquals(2,L2.Items[1]);
{$ENDREGION}

 LV := L;
 L2.Clear;

 T :=  C.GetType(LV.TypeInfo);
 lEnumMethod := T.GetMethod('GetEnumerator');
 lEnumerator := lEnumMethod.Invoke(LV,[]);

 lEnumType :=  C.GetType(lEnumerator.TypeInfo);
 lMoveNextMethod := lEnumType.GetMethod('MoveNext');
 lCurrentProp := lEnumType.GetProperty('Current');

 Check(Assigned(LMoveNextMethod),'MoveNext method not found');
 Check(Assigned(lCurrentProp),'Current property not found');

 while lMoveNextMethod.Invoke(lEnumerator.AsObject,[]).asBoolean do
 begin
   L2.Add(lCurrentProp.GetValue(lEnumerator.AsObject).AsOrdinal);
 end;
//
 CheckEquals(L.Count,L2.Count);
 CheckEquals(1,L2.Items[0]);
 CheckEquals(2,L2.Items[1]);


 finally
   L.Free;
   L2.Free;
 end;



end;

procedure TRttiTestCase.TestSetGetPropValues;
var
 c : TRttiContext;
 o : TTestPropTypes;
 I : Integer;
 str : String;
begin
 c := TRttiContext.Create;
 o := TTestPropTypes.Create;
 c.GetType(TTestPropTypes).GetProperty('propInteger').SetValue(o,1234);
 CheckEquals(1234,c.GetType(TTestPropTypes).GetProperty('propInteger').GetValue(o).AsInteger,'propInteger');

 c.GetType(TTestPropTypes).GetProperty('propUnicodeString').SetValue(o,'1234-String');
 CheckEquals('1234-String',c.GetType(TTestPropTypes).GetProperty('propUnicodeString').GetValue(o).AsString,'propString');
 o.Free;
 c.Free;
end;

procedure TRttiTestCase.FieldTestDynamicArray;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAIDyn')),'Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAIDyn').FieldType),'Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FAIDyn').FieldType.TypeKind = tkDynArray,'Field Type Incorrect');
 c.Free;
end;

procedure TRttiTestCase.FieldTestFixedLenArray;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAI')),'Field Missing');
// Removed Checks as it's by design not to have this information.
// Although it would be nice to have someday :-)
// Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAI').FieldType),'Field Type Missing');
// Check(c.GetType(TTestFieldTypes).GetField('FAI').FieldType.TypeKind = tkArray,'Field Type Incorrect');
 c.Free;
end;

procedure TRttiTestCase.FieldTestStandardTypes;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FInteger')),'FInteger Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FInteger').FieldType),'FInteger Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FInteger').FieldType.TypeKind = tkInteger,'FInteger Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FUnicodeString')),'FUnicodeString Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FUnicodeString').FieldType),'FUnicodeString Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FUnicodeString').FieldType.TypeKind = tkUString,'FUnicodeString Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAnsiString')),'FAnsiString Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAnsiString').FieldType),'FAnsiString Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FAnsiString').FieldType.TypeKind = tkLString,'FAnsiString Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FShortstring')),'FShortstring Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FShortstring').FieldType),'FShortstring Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FShortstring').FieldType.TypeKind = tkString,'FShortstring Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FWideChar')),'FWideChar Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FWideChar').FieldType),'FWideChar Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FWideChar').FieldType.TypeKind = tkWChar,'FWideChar Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAnsiChar')),'FAnsiChar Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FAnsiChar').FieldType),'FAnsiChar Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FAnsiChar').FieldType.TypeKind = tkChar,'FAnsiChar Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FDouble')),'FDouble Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FDouble').FieldType),'FDouble Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FDouble').FieldType.TypeKind = tkFloat,'FDouble Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FEnum')),'FEnum Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FEnum').FieldType),'FEnum Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FEnum').FieldType.TypeKind = tkEnumeration,'FEnum Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FSet')),'FSet Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FSet').FieldType),'FSet Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FSet').FieldType.TypeKind = tkSet,'FSet Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FBoolean')),'FBoolean Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FBoolean').FieldType),'FBoolean Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FBoolean').FieldType.TypeKind = tkEnumeration,'FBoolean Field Type Incorrect');
 CheckEquals('System.Boolean',c.GetType(TTestFieldTypes).GetField('FBoolean').FieldType.QualifiedName,'FBoolean Field Type Name Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FDateTime')),'FDateTime Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FDateTime').FieldType),'FDateTime Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FDateTime').FieldType.TypeKind = tkFloat,'FDateTime Field Type Incorrect');
 CheckEquals('System.TDateTime',c.GetType(TTestFieldTypes).GetField('FDateTime').FieldType.QualifiedName,'FDateTime Field Type Name Incorrect');


 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FObject')),'FObject Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FObject').FieldType),'FObject Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FObject').FieldType.TypeKind = tkClass,'FObject Field Type Incorrect');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FClass')),'FClass Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FClass').FieldType),'FClass Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FClass').FieldType.TypeKind = tkClassRef,'FClass Field Type Incorrect');

 c.Free;
end;

procedure TRttiTestCase.FieldTestRecords;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FRecord')),'FRecord Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FRecord').FieldType),'FRecord Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FRecord').FieldType.TypeKind = tkRecord,'FRecord Field Type Incorrect');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FRecord').FieldType.GetField('Name')),'FRecord unable to find Name Field');
 CheckEquals('SysUtils.TFileName', c.GetType(TTestFieldTypes).GetField('FRecord').FieldType.GetField('Name').FieldType.QualifiedName,'FRecord unable to find Name Field Type');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FPackedRec')),'FPackedRec Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FPackedRec').FieldType),'FPackedRec Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FPackedRec').FieldType.TypeKind = tkRecord,'FPackedRec Field Type Incorrect');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FPackedRec').FieldType.GetField('Negative')),'FPackedRec unable to find Name Field');
 CheckEquals('System.Boolean', c.GetType(TTestFieldTypes).GetField('FPackedRec').FieldType.GetField('Negative').FieldType.QualifiedName,'FPackedRec unable to find Name Field Type');

 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FVariantPackedRec')),'FVariantPackedRec Field Missing');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FVariantPackedRec').FieldType),'FVariantPackedRec Field Type Missing');
 Check(c.GetType(TTestFieldTypes).GetField('FVariantPackedRec').FieldType.TypeKind = tkRecord,'FVariantPackedRec Field Type Incorrect');
 Check(Assigned(c.GetType(TTestFieldTypes).GetField('FVariantPackedRec').FieldType.GetField('Lo')),'FVariantPackedRec unable to find Name Field');
 CheckEquals('System.Word', c.GetType(TTestFieldTypes).GetField('FVariantPackedRec').FieldType.GetField('Lo').FieldType.QualifiedName,'FVariantPackedRec unable to find Name Field Type');

 c.Free;
end;

procedure TRttiTestCase.FieldTestVisibility;
var
 c : TRttiContext;
begin
 //QC: 76195
 c := TRttiContext.Create;
 Check(mvPrivate = c.GetType(TTestFieldVisibility).GetField('Fprivate').Visibility,'Private Failed');
 Check(mvprotected = c.GetType(TTestFieldVisibility).GetField('Fprotected').Visibility,'protected Failed');
 Check(mvpublic = c.GetType(TTestFieldVisibility).GetField('Fpublic').Visibility,'public Failed');
 Check(mvpublished = c.GetType(TTestFieldVisibility).GetField('Fpublished').Visibility,'published Failed');
 c.Free;
end;

procedure TRttiTestCase.PropTestDynamicArray;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAIDyn')),'Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAIDyn').PropertyType),'Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propAIDyn').PropertyType.TypeKind = tkDynArray,'Prop Type Incorrect');
 c.Free;
end;

procedure TRttiTestCase.PropTestFixedLenArray;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAI')),'Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAI').PropertyType),'Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propAI').PropertyType.TypeKind = tkArray,'Prop Type Incorrect');
 c.Free;
end;

procedure TRttiTestCase.PropTestStandardTypes;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propInteger')),'propInteger Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propInteger').PropertyType),'propInteger Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propInteger').PropertyType.TypeKind = tkInteger,'propInteger Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propUnicodeString')),'propUnicodeString Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propUnicodeString').PropertyType),'propUnicodeString Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propUnicodeString').PropertyType.TypeKind = tkUString,'propUnicodeString Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAnsiString')),'propAnsiString Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAnsiString').PropertyType),'propAnsiString Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propAnsiString').PropertyType.TypeKind = tkLString,'propAnsiString Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propShortstring')),'propShortstring Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propShortstring').PropertyType),'propShortstring Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propShortstring').PropertyType.TypeKind = tkString,'propShortstring Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propWideChar')),'propWideChar Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propWideChar').PropertyType),'propWideChar Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propWideChar').PropertyType.TypeKind = tkWChar,'propWideChar Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAnsiChar')),'propAnsiChar Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propAnsiChar').PropertyType),'propAnsiChar Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propAnsiChar').PropertyType.TypeKind = tkChar,'propAnsiChar Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propDouble')),'propDouble Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propDouble').PropertyType),'propDouble Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propDouble').PropertyType.TypeKind = tkFloat,'propDouble Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propEnum')),'propEnum Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propEnum').PropertyType),'propEnum Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propEnum').PropertyType.TypeKind = tkEnumeration,'propEnum Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propSet')),'propSet Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propSet').PropertyType),'propSet Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propSet').PropertyType.TypeKind = tkSet,'propSet Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propBoolean')),'propBoolean Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propBoolean').PropertyType),'propBoolean Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propBoolean').PropertyType.TypeKind = tkEnumeration,'propBoolean Prop Type Incorrect');
 CheckEquals('System.Boolean',c.GetType(TTestPropTypes).GetProperty('propBoolean').PropertyType.QualifiedName,'propBoolean Prop Type Name Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propDateTime')),'propDateTime Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propDateTime').PropertyType),'propDateTime Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propDateTime').PropertyType.TypeKind = tkFloat,'propDateTime Prop Type Incorrect');
 CheckEquals('System.TDateTime',c.GetType(TTestPropTypes).GetProperty('propDateTime').PropertyType.QualifiedName,'propDateTime Prop Type Name Incorrect');


 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propObject')),'propObject Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propObject').PropertyType),'propObject Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propObject').PropertyType.TypeKind = tkClass,'propObject Prop Type Incorrect');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propClass')),'propClass Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propClass').PropertyType),'propClass Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propClass').PropertyType.TypeKind = tkClassRef,'propClass Prop Type Incorrect');

 c.Free;
end;

procedure TRttiTestCase.PropTestRecords;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propRecord')),'propRecord Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propRecord').PropertyType),'propRecord Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propRecord').PropertyType.TypeKind = tkRecord,'propRecord Prop Type Incorrect');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propRecord').PropertyType.GetField('Name')),'propRecord unable to find Name Field');
 CheckEquals('SysUtils.TFileName', c.GetType(TTestPropTypes).GetProperty('propRecord').PropertyType.GetField('Name').FieldType.QualifiedName,'propRecord unable to find Name Prop Type');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propPackedRec')),'propPackedRec Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propPackedRec').PropertyType),'propPackedRec Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propPackedRec').PropertyType.TypeKind = tkRecord,'propPackedRec Prop Type Incorrect');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propPackedRec').PropertyType.GetField('Negative')),'propPackedRec unable to find Name Field');
 CheckEquals('System.Boolean', c.GetType(TTestPropTypes).GetProperty('propPackedRec').PropertyType.GetField('Negative').FieldType.QualifiedName,'propPackedRec unable to find Name Prop Type');

 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propVariantPackedRec')),'propVariantPackedRec Prop Missing');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propVariantPackedRec').PropertyType),'propVariantPackedRec Prop Type Missing');
 Check(c.GetType(TTestPropTypes).GetProperty('propVariantPackedRec').PropertyType.TypeKind = tkRecord,'propVariantPackedRec Prop Type Incorrect');
 Check(Assigned(c.GetType(TTestPropTypes).GetProperty('propVariantPackedRec').PropertyType.GetField('Lo')),'propVariantPackedRec unable to find Name Field');
 CheckEquals('System.Word', c.GetType(TTestPropTypes).GetProperty('propVariantPackedRec').PropertyType.GetField('Lo').FieldType.QualifiedName,'propVariantPackedRec unable to find Name Prop Type');

 c.Free;
end;

procedure TRttiTestCase.PropTestVisibility;
var
 c : TRttiContext;
begin
 //QC: 76195
 c := TRttiContext.Create;
 Check(mvPrivate = c.GetType(TTestPropVisibility).GetProperty('propPrivate').Visibility,'Private Failed');
 Check(mvprotected = c.GetType(TTestPropVisibility).GetProperty('propProtected').Visibility,'protected Failed');
 Check(mvpublic = c.GetType(TTestPropVisibility).GetProperty('propPublic').Visibility,'public Failed');
 Check(mvpublished = c.GetType(TTestPropVisibility).GetProperty('propPublished').Visibility,'published Failed');
 c.Free;
end;


initialization
   RegisterTest(TRttiTestCase.Suite);
end.
