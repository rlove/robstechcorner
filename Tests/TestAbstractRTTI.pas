unit TestAbstractRTTI;
interface

uses
  TestFramework, AbstractRTTI, SysUtils, Classes, TypInfo, Rtti,
  Generics.Collections;

type
  // Don't change all the test depend on this structure
  TDummyAttribute = class(TCustomAttribute)
  end;
  // Don't change all the test depend on this structure
  TTestObject = class(TObject)
  private
    [TDummy]
    [TDummy]
    FTwoDummies : Integer;
    FTestReadonly: Integer;
    FTestReadWrite: Integer;
    FTestWriteonly: Integer;
    FPubTest: Integer;
    [TDummy]
    FVisPrivate : Integer;
  protected
    FVisProtected : Integer;
  public
    FVisPublic : Integer;
    property TestReadonly : Integer read FTestReadonly;
    property TestWriteonly : Integer write FTestWriteonly;
    [TDummy]
    property TestReadWrite : Integer read FTestReadWrite write FTestReadWrite;
  published
    property PubTest : Integer read FPubTest write FPubTest;
  end;


  // Test methods for class TatsRTTIProperty
  TestTatsRTTIProperty = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIsReadable;
    procedure TestIsWriteable;
    procedure TestGetValue;
    procedure TestSetValue;
    procedure TestMemberType;
    procedure TestVisibility;
    procedure TestGetAttributes;
    procedure TestHasAttribute;
  end;
  // Test methods for class TatsRTTIField

  TestTatsRTTIField = class(TTestCase)
  strict private
    FatsRTTIField: TatsRTTIField;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIsReadable;
    procedure TestIsWriteable;
    procedure TestGetValue;
    procedure TestSetValue;
    procedure TestMemberType;
    procedure TestVisibility;
    procedure TestGetAttributes;
    procedure TestHasAttribute;
  end;
  // Test methods for class TatsRTTIValueType

  TestTatsRTTIValueType = class(TTestCase)
  strict private
    FValueType: TatsRTTIValueType;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestValue;
    procedure TestGetFields;
    procedure TestGetProperties;
    procedure TestGetField;
    procedure TestGetProperty;
    procedure TestGetAttributes;
    procedure TestHasAttribute;
  end;



implementation

procedure TestTatsRTTIProperty.SetUp;
begin

end;

procedure TestTatsRTTIProperty.TearDown;
begin
end;

procedure TestTatsRTTIProperty.TestGetAttributes;
var
 lTest : TatsRTTIProperty;
 Ctx : TRttiContext;
 lTestObj : TTestObject;
 Attrs : TArray<TCustomAttribute>;
begin
 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('PubTest'));
 Attrs := lTest.GetAttributes;
 CheckFalse(Assigned(Attrs));
 lTest.Free;

 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadWrite'));
 Attrs := lTest.GetAttributes;
 CheckTrue(Assigned(Attrs));
 CheckEquals(1,Length(Attrs));
 CheckIs(Attrs[0],TDummyAttribute);
 lTest.Free;
end;

procedure TestTatsRTTIProperty.TestGetValue;
var
 lTest : TatsRTTIProperty;
 Ctx : TRttiContext;
 lTestObj : TTestObject;
begin
 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadWrite'));

 lTestObj := TTestObject.Create;
 lTestObj.TestReadWrite := 230;

 CheckEquals(230,lTest.GetValue(lTestObj).AsInteger);
 lTestObj.Free;
end;

procedure TestTatsRTTIProperty.TestHasAttribute;
begin

end;

procedure TestTatsRTTIProperty.TestIsReadable;
var
 lTest : TatsRTTIProperty;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadonly'));
 CheckTrue(lTest.IsReadable);
 lTest.Free;

 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestWriteonly'));
 CheckFalse(lTest.IsReadable);
 lTest.Free;

 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadWrite'));
 CheckTrue(lTest.IsReadable);
 lTest.Free;
end;

procedure TestTatsRTTIProperty.TestIsWriteable;
var
 lTest : TatsRTTIProperty;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadonly'));
 CheckFalse(lTest.IsWritable);
 lTest.Free;

 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestWriteonly'));
 CheckTrue(lTest.IsWritable);
 lTest.Free;

 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadWrite'));
 CheckTrue(lTest.IsWritable);
 lTest.Free;
end;

procedure TestTatsRTTIProperty.TestMemberType;
var
 lTest : TatsRTTIProperty;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadonly'));
 CheckTrue(lTest.MemberType.IsOrdinal);
 CheckEquals('System.Integer',lTest.MemberType.QualifiedName);
 lTest.Free;
end;

procedure TestTatsRTTIProperty.TestSetValue;
var
 lTest : TatsRTTIProperty;
 Ctx : TRttiContext;
 lTestObj : TTestObject;
begin
 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadWrite'));

 lTestObj := TTestObject.Create;
 lTestObj.TestReadWrite := 0; // default something other than test value

 lTest.setValue(lTestObj,230);

 CheckEquals(230,lTestObj.TestReadWrite);
 lTestObj.Free;
end;

procedure TestTatsRTTIProperty.TestVisibility;
var
 lTest : TatsRTTIProperty;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('TestReadonly'));
 Check(lTest.Visibility = mvPublic);
 lTest.Free;

 lTest := TatsRTTIProperty.Create(Ctx.GetType(TTestObject.ClassInfo).GetProperty('PubTest'));
 Check(lTest.Visibility = mvPublished);
 lTest.Free;

end;

procedure TestTatsRTTIField.SetUp;
begin
end;

procedure TestTatsRTTIField.TearDown;
begin
end;

procedure TestTatsRTTIField.TestGetAttributes;
var
 lTest : TatsRTTIField;
 Ctx : TRttiContext;
 lTestObj : TTestObject;
 Attrs : TArray<TCustomAttribute>;
begin
 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FPubTest'));
 Attrs := lTest.GetAttributes;
 CheckFalse(Assigned(Attrs));
 lTest.Free;

 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FVisPrivate'));
 Attrs := lTest.GetAttributes;
 CheckTrue(Assigned(Attrs));
 CheckEquals(1,Length(Attrs));
 CheckIs(Attrs[0],TDummyAttribute);
 lTest.Free;

 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FTwoDummies'));
 Attrs := lTest.GetAttributes;
 CheckTrue(Assigned(Attrs));
 CheckEquals(2,Length(Attrs));
 CheckIs(Attrs[0],TDummyAttribute);
 CheckIs(Attrs[1],TDummyAttribute);
 lTest.Free;

end;

procedure TestTatsRTTIField.TestGetValue;
var
 lTest : TatsRTTIField;
 Ctx : TRttiContext;
 lTestObj : TTestObject;
begin
 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FTestReadWrite'));

 lTestObj := TTestObject.Create;
 lTestObj.TestReadWrite := 230;

 CheckEquals(230,lTest.GetValue(lTestObj).AsInteger);
 lTestObj.Free;
end;

procedure TestTatsRTTIField.TestHasAttribute;
begin

end;

procedure TestTatsRTTIField.TestIsReadable;
var
 lTest : TatsRTTIField;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FTestWriteonly'));
 // Should always be true for Fields
 CheckTrue(lTest.IsReadable);
 lTest.Free;
end;

procedure TestTatsRTTIField.TestIsWriteable;
var
 lTest : TatsRTTIField;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FTestReadonly'));
 // Should always be true for Fields
 CheckTrue(lTest.IsWritable);
 lTest.Free;
end;

procedure TestTatsRTTIField.TestMemberType;
var
 lTest : TatsRTTIField;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FTestReadonly'));
 CheckTrue(lTest.MemberType.IsOrdinal);
 CheckEquals('System.Integer',lTest.MemberType.QualifiedName);
 lTest.Free;
end;

procedure TestTatsRTTIField.TestSetValue;
var
 lTest : TatsRTTIField;
 Ctx : TRttiContext;
 lTestObj : TTestObject;
begin
 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FTestReadWrite'));

 lTestObj := TTestObject.Create;
 lTestObj.TestReadWrite := 0; // default something other than test value

 lTest.setValue(lTestObj,230);

 CheckEquals(230,lTestObj.TestReadWrite);
 lTestObj.Free;
end;

procedure TestTatsRTTIField.TestVisibility;
var
 lTest : TatsRTTIField;
 Ctx : TRttiContext;
begin
 Ctx := TRttiContext.Create;
 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FVisPrivate'));
 Check(lTest.Visibility = mvPrivate);
 lTest.Free;

 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FVisProtected'));
 Check(lTest.Visibility = mvProtected);
 lTest.Free;

 lTest := TatsRTTIField.Create(Ctx.GetType(TTestObject.ClassInfo).GetField('FVisPublic'));
 Check(lTest.Visibility = mvPublic);
 lTest.Free;
end;

procedure TestTatsRTTIValueType.SetUp;
begin
  FValueType := TatsRTTIValueType.create;
end;

procedure TestTatsRTTIValueType.TearDown;
begin
  FValueType.Free;
  FValueType  := nil;
end;

procedure TestTatsRTTIValueType.TestGetAttributes;
begin

end;

procedure TestTatsRTTIValueType.TestGetField;
begin

end;

procedure TestTatsRTTIValueType.TestGetFields;
var
 T : TTestObject;
begin
 T := TTestObject.Create;
 FValueType.Value := 1;
 CheckEquals(0,Length(FValueType.GetFields));
 FValueType.Value := T;
 CheckEquals(8,Length(FValueType.GetFields));
 CheckIs(FValueType.GetFields[0],TatsRTTIField);
 // Done twice as screwed up cache once
 CheckEquals(8,Length(FValueType.GetFields));
 T.Free;
 FValueType.Value := 0;
 CheckEquals(0,Length(FValueType.GetFields));
end;

procedure TestTatsRTTIValueType.TestGetProperties;
var
 T : TTestObject;
begin
 T := TTestObject.Create;
 FValueType.Value := 1;
 CheckEquals(0,Length(FValueType.GetProperties));
 FValueType.Value := T;
 CheckEquals(4,Length(FValueType.GetProperties));
 CheckIs(FValueType.GetProperties[0],TatsRTTIProperty);
 // Done twice as screwed up cache once
 CheckEquals(4,Length(FValueType.GetProperties));
 T.Free;
 FValueType.Value := 0;
 CheckEquals(0,Length(FValueType.GetProperties));
end;

procedure TestTatsRTTIValueType.TestGetProperty;
begin

end;

procedure TestTatsRTTIValueType.TestHasAttribute;
begin

end;

procedure TestTatsRTTIValueType.TestValue;
begin
  CheckTrue(FValueType.Value.IsEmpty);
  FValueType.Value := 1;
  CheckEquals(1,FValueType.Value.AsInteger);
end;

initialization
   RegisterTest(TestTatsRTTIProperty.Suite);
   RegisterTest(TestTatsRTTIField.Suite);
   RegisterTest(TestTatsRTTIValueType.Suite);


end.
