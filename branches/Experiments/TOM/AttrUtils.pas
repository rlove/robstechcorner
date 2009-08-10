unit AttrUtils;

interface
uses
  SysUtils, Classes, TypInfo, Rtti;
type
   TAttributeTarget = (atType,atProperty,atField,atParam);
   TAttributeTargets = set of TAttributeTarget;
const
   atAll =  [atType..atParam];
type
  // There is most likely a ton of different ways you may want to restrict
  // Attributes.   This handles a majority of them, allowing me to custom
  // code the rest.
  TAttributeUsage = class(TCustomAttribute)
  private
    FAllowMultiple: Boolean;
    FTarget: TAttributeTargets;
    FAllowedTypes: TTypeKinds;
  published
    constructor Create(aTarget : TAttributeTargets;aAllowMultiple : Boolean;aAllowedTypes : TTypeKinds);
    property Target : TAttributeTargets read FTarget;
    property AllowMultiple : Boolean read FAllowMultiple;
    property AllowedTypes : TTypeKinds read FAllowedTypes;
   end;

  EAttributeValidationException = class(Exception);

  TCustomAttributeClass = class of TCustomAttribute;
  
  TAttrUtils = class(TObject)
  private
    class procedure ValidateAttr(aContext: TRttiContext; aType: TRttiType); static;
   protected
     class procedure ValidateTypeAttr(aContext : TRttiContext;aType : TrttiType; aAttr : TCustomAttribute); inline;
     class procedure ValidatePropAttr(aContext : TRttiContext;aType : TrttiType; aProp : TRttiProperty; aAttr : TCustomAttribute); inline;
     class procedure ValidateFieldAttr(aContext : TRttiContext;aType : TrttiType; aField : TRttiField; aAttr : TCustomAttribute);  inline;
     class procedure ValidateParamAttr(aContext : TRttiContext;aType : TrttiType;aMethod : TRttiMethod; aParam : TRttiParameter; aAttr : TCustomAttribute); inline;
   public
     class procedure ValidateType(aType : pTypeInfo); overload;
     class procedure ValidateType(aContext : TRttiContext; aType : TRttiType); overload;
     class function HasAttribute(aType : pTypeinfo;aClass : TCustomAttributeClass;var Attr : TCustomAttribute) : Boolean; overload;
     class function HasAttribute(aContext : TRttiContext; aType : TRttiType;aClass : TCustomAttributeClass;var Attr : TCustomAttribute) : Boolean; overload;
     class function HasAttributes(aType : pTypeinfo;aClass : TCustomAttributeClass;var Attrs : TArray<TCustomAttribute>) : Boolean; overload;
     class function HasAttributes(aContext : TRttiContext; aType : TRttiType;aClass : TCustomAttributeClass;var Attrs : TArray<TCustomAttribute>) : Boolean; overload;     

     class function GetAttribute(aType : pTypeinfo;aClass : TCustomAttributeClass) :  TCustomAttribute; overload;
     class function GetAttribute(aContext : TRttiContext; aType : TRttiType;aClass : TCustomAttributeClass): TCustomAttribute ; overload;

     class function GetAttributes(aType : pTypeinfo;aClass : TCustomAttributeClass) :  TArray<TCustomAttribute>; overload;
     class function GetAttributes(aContext : TRttiContext; aType : TRttiType;aClass : TCustomAttributeClass): TArray<TCustomAttribute> ; overload;

     
   end;


implementation

{ TAttrUtils }

class procedure TAttrUtils.ValidateType(aType: pTypeInfo);
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 try
   ValidateType(c, c.GetType(aType));
 finally
   c.Free;
 end;
end;

class function TAttrUtils.GetAttribute(aType: pTypeinfo;
  aClass: TCustomAttributeClass): TCustomAttribute;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 try
   result := GetAttribute(c, c.GetType(aType),aClass);
 finally
   c.Free;
 end;
end;

class function TAttrUtils.GetAttribute(aContext: TRttiContext; aType: TRttiType;
  aClass: TCustomAttributeClass): TCustomAttribute;
var
 lAttr : TCustomAttribute;
begin
  for lAttr in aType.GetAttributes do
  begin
    if lAttr is aClass then
    begin
      exit(lAttr);
    end;
  end;
  result := nil;
end;

class function TAttrUtils.GetAttributes(aContext: TRttiContext;
  aType: TRttiType; aClass: TCustomAttributeClass): TArray<TCustomAttribute>;
var
  Attrs : TArray<TCustomAttribute>;
  lp,idx : Integer;
begin
  Attrs := aType.GetAttributes;
  SetLength(result,Length(Attrs));
  idx := 0;
  for lp := 0 to Length(Attrs) - 1 do
  begin
    if Attrs[lp] is aClass then
    begin
      result[idx] := Attrs[lp];
      inc(idx);
    end;
  end;
  SetLength(result,idx);
end;

class function TAttrUtils.GetAttributes(aType: pTypeinfo;
  aClass: TCustomAttributeClass): TArray<TCustomAttribute>;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 try
   result := GetAttributes(c, c.GetType(aType),aClass);
 finally
   c.Free;
 end;
end; 

class function TAttrUtils.HasAttribute(aType: pTypeinfo;
  aClass: TCustomAttributeClass; var Attr: TCustomAttribute): Boolean;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 try
   result := HasAttribute(c, c.GetType(aType),aClass,Attr);
 finally
   c.Free;
 end;
end;

class function TAttrUtils.HasAttribute(aContext: TRttiContext; aType: TRttiType;
  aClass: TCustomAttributeClass; var Attr: TCustomAttribute): Boolean;
begin
  Attr := GetAttribute(aContext,aType,aClass);
  result := Assigned(Attr);  
end;

class function TAttrUtils.HasAttributes(aContext: TRttiContext;
  aType: TRttiType; aClass: TCustomAttributeClass;
  var Attrs: TArray<TCustomAttribute>): Boolean;
begin
  Attrs := GetAttributes(aContext,aType,aClass);
  result := Length(Attrs) > 0;  
end;

class function TAttrUtils.HasAttributes(aType: pTypeinfo;
  aClass: TCustomAttributeClass; var Attrs: TArray<TCustomAttribute>): Boolean;
var
 c : TRttiContext;
begin
 c := TRttiContext.Create;
 try
   result := HasAttributes(c, c.GetType(aType),aClass,Attrs);
 finally
   c.Free;
 end;
end;

class procedure TAttrUtils.ValidateAttr(aContext : TRttiContext; aType: TRttiType);
begin

end;

class procedure TAttrUtils.ValidateFieldAttr(aContext: TRttiContext;
  aType: TrttiType; aField: TRttiField; aAttr: TCustomAttribute);
begin

end;

class procedure TAttrUtils.ValidateParamAttr(aContext: TRttiContext;
  aType: TrttiType; aMethod: TRttiMethod; aParam: TRttiParameter;
  aAttr: TCustomAttribute);
begin

end;

class procedure TAttrUtils.ValidatePropAttr(aContext: TRttiContext;
  aType: TrttiType; aProp: TRttiProperty; aAttr: TCustomAttribute);
begin

end;

class procedure TAttrUtils.ValidateType(aContext : TRttiContext;aType : TRttiType);
var
 Attr : TCustomAttribute;
 Prop : TRttiProperty;
 Field : TRttiField;
 Param : TRttiParameter;
begin
 for Attr in aType.GetAttributes do
 begin
    ValidateTypeAttr(aContext,aType,Attr);
 end;
 
 for Prop in aType.GetProperties do
 begin
    for Attr in Prop.GetAttributes do
    begin
      ValidatePropAttr(aContext,aType,Prop,Attr);
    end;
 end;

 for Field in aType.GetFields do
 begin
    for Attr in Field.GetAttributes do
    begin
      ValidateFieldAttr(aContext,aType,Field,Attr);
    end;
 end;

 for Field in aType.GetFields do
 begin
    for Attr in Field.GetAttributes do
    begin
      ValidateFieldAttr(aContext,aType,Field,Attr);
    end;
 end;                                   

 
end;

class procedure TAttrUtils.ValidateTypeAttr(aContext: TRttiContext;
  aType: TrttiType; aAttr: TCustomAttribute);
var
  A  : TCustomAttribute;
  AU : TAttributeUsage;
  Attr : TCustomAttribute;
  Cnt : Integer;
begin
  if HasAttribute(aContext,aContext.GetType(aAttr.ClassInfo) ,TAttributeUsage,a) then
  begin
    AU := (A as TAttributeUsage);
    if not AU.AllowMultiple then
    begin
      Cnt = 0;
      for Attr in aType.GetAttributes do
      begin
        if Attr is Attr.ClassType then
          inc(Cnt);
      end;
    //TODO: Get better messages :-)
      if Cnt > 1 then
         raise EAttributeValidationException.Create('Validation Error');
    end;
    if not atType in AU.Target then
         raise EAttributeValidationException.Create('Validation Error');
    if not aType.TypeKind in AU.AllowedTypes then
         raise EAttributeValidationException.Create('Validation Error');    

  end;
end;

{ TAttributeUsage }
constructor TAttributeUsage.Create(aTarget: TAttributeTargets;
  aAllowMultiple: Boolean; aAllowedTypes: TTypeKinds);
begin
  FTarget := aTarget;
  FAllowMultiple := aAllowMultiple;
  FAllowedTypes := aAllowedTypes;
end;

end.
