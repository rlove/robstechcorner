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
uses SysUtils,Classes,Rtti;
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

end.
