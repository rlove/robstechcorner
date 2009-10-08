unit RttiUtils;
// MIT License
//
// Copyright (c) 2009 - Robert Love
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
uses SysUtils,Classes,Rtti,TypInfo;
type
  ERttiMemberHelperException = class(Exception);
  // Make things a bit easier.
  TRttiMemberHelper = class helper for TRttiMember
  private
    function GetType: TRttiType;
  published
  public
    function GetValue(Instance: Pointer): TValue; overload;
    function GetValue(const Instance : TValue) : TValue; overload;
    procedure SetValue(Instance: Pointer; const AValue: TValue); overload;
    procedure SetValue(const Instance: TValue; const AValue: TValue); overload;
    property MemberType : TRttiType read GetType;
  end;

  TCustomAttributeClass = class of TCustomAttribute;

  TAttrUtils = class(TObject)
   public
     class function HasAttribute(aType : pTypeinfo;aClass : TCustomAttributeClass;var Attr : TCustomAttribute) : Boolean; overload;
     class function HasAttribute(aContext : TRttiContext; aType : TRttiObject;aClass : TCustomAttributeClass;var Attr : TCustomAttribute) : Boolean; overload;
     class function HasAttributes(aType : pTypeinfo;aClass : TCustomAttributeClass;var Attrs : TArray<TCustomAttribute>) : Boolean; overload;
     class function HasAttributes(aContext : TRttiContext; aType : TRttiObject;aClass : TCustomAttributeClass;var Attrs : TArray<TCustomAttribute>) : Boolean; overload;

     class function GetAttribute(aType : pTypeinfo;aClass : TCustomAttributeClass) :  TCustomAttribute; overload;
     class function GetAttribute(aContext : TRttiContext; aType : TRttiObject;aClass : TCustomAttributeClass): TCustomAttribute ; overload;

     class function GetAttributes(aType : pTypeinfo;aClass : TCustomAttributeClass) :  TArray<TCustomAttribute>; overload;
     class function GetAttributes(aContext : TRttiContext; aType : TRttiObject;aClass : TCustomAttributeClass): TArray<TCustomAttribute> ; overload;
  end;


implementation

{ TRttiMemberHelper }

function TRttiMemberHelper.GetType: TRttiType;
begin
 Assert(Assigned(Self)); // For those who forget to check first.
 if Self is TRttiProperty then
    result := TRttiProperty(Self).PropertyType
 else if Self is TRttiField then
     result := TRttiField(Self).FieldType
 else //if Self is TRttiMethod then
      //     result := TRttiMethod(self).  hmmm Don't know how to get to the  TRttiMethodType and I don't need it
   result := nil;
end;

function TRttiMemberHelper.GetValue(Instance: Pointer): TValue;
begin
  Assert(Assigned(Self)); // For those who forget to check first.
  if InheritsFrom(TRttiProperty) then
     result := TRttiProperty(Self).GetValue(Instance)
  else if InheritsFrom(TRttiField) then
     result := TRttiField(Self).GetValue(Instance)
  else  raise ERttiMemberHelperException.CreateFmt('Expecting Property or Field, found: %s',[ClassName]);

end;

procedure TRttiMemberHelper.SetValue(Instance: Pointer; const AValue: TValue);
begin
  Assert(Assigned(Self)); // For those who forget to check first.
  if InheritsFrom(TRttiProperty) then
     TRttiProperty(Self).SetValue(Instance,aValue)
  else if InheritsFrom(TRttiField) then
     TRttiField(Self).SetValue(Instance,aValue)
  else raise ERttiMemberHelperException.Create('Expecting Property or Field');
end;

function TRttiMemberHelper.GetValue(const Instance: TValue): TValue;
begin
  if Instance.isObject then
  begin
    result := GetValue(Instance.AsObject);
  end
  else
  begin
    result := GetValue(Instance.GetReferenceToRawData);
  end;
end;

procedure TRttiMemberHelper.SetValue(const Instance: TValue; const AValue: TValue);
begin
  if Instance.isObject then
  begin
    SetValue(Instance.AsObject,AValue);
  end
  else
  begin
    SetValue(Instance.GetReferenceToRawData,aValue)
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

class function TAttrUtils.GetAttribute(aContext: TRttiContext; aType: TRttiObject;
  aClass: TCustomAttributeClass): TCustomAttribute;
var
 lAttr : TCustomAttribute;
begin
  Assert(Assigned(aType));
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
  aType: TRttiObject; aClass: TCustomAttributeClass): TArray<TCustomAttribute>;
var
  Attrs : TArray<TCustomAttribute>;
  lp,idx : Integer;
begin
  Assert(Assigned(aType));
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

class function TAttrUtils.HasAttribute(aContext: TRttiContext; aType: TRttiObject;
  aClass: TCustomAttributeClass; var Attr: TCustomAttribute): Boolean;
begin
  Attr := GetAttribute(aContext,aType,aClass);
  result := Assigned(Attr);
end;

class function TAttrUtils.HasAttributes(aContext: TRttiContext;
  aType: TRttiObject; aClass: TCustomAttributeClass;
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


end.
