unit ObjBinder;
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
//
// Prototype Object Binding System.
// Although no code from this blog post,
// I would like to credit Cobus Krugerwith helping spur some thoughts
// http://sourcecodeadventures.wordpress.com/2009/11/18/inducing-the-great-divide/
interface
 uses
   SysUtils, Classes, Controls,
   Rtti, TypInfo, Generics.Collections;

 type
  // Using an Interface, was doing to use two anonymous methods but
  // rand into Internal Errors, and found existing QC items.
  ITypeMapping = interface
     function SourceToDest(Source : TValue) : TValue;
     function DestToSource(Source : TValue) : TValue;
     function Compare(Source : TValue; Dest : TValue) : Integer;
  end;

  TDefaultTypeMapping = class(TInterfacedObject,ITypeMapping)
     function SourceToDest(Source : TValue) : TValue;
     function DestToSource(Dest : TValue) : TValue;
     function Compare(Source : TValue; Dest : TValue) : Integer;
  end;

  TObjectBinder = class(TObject)
  protected
    type
      TBinding = class(TObject)
        TypeMapping : ITypeMapping;
        ReadOnly : Boolean;
        DestObj : TObject;
        DestMember : TRttiMember;
        SourceMember : TRttiMember;
        constructor Create(aSourceMember : TRttiMember; aDestObject : TObject;aDestMember : TRttiMember;aReadOnly : Boolean;aTypeMapping : ITypeMapping);
        procedure Save(Instance : TObject);
        procedure Load(Instance : TObject);
        function IsChanged(Instance : TObject) : Boolean;
      end;
    var
      FCtx : TRttiContext;
      FSourceClass : TClass;
      FDefaultTypeMapping : ITypeMapping;
      FBindings : TObjectList<TBinding>;
  public
    constructor Create(aSourceClass : TClass);
    destructor Destroy; override;
    procedure Binding(aPropName : String;aDestObject : TObject;aMemberName : String; aReadOnly : Boolean = false;aTypeMapping : ITypeMapping = nil );
    function IsChanged(Instance : TObject) : Boolean;
    procedure Save(Instance : TObject);
    procedure Load(Instance : TObject);
  end;


implementation
uses RttiUtils;
{ TObjectBinder }


procedure TObjectBinder.Binding(aPropName: String; aDestObject: TObject;
  aMemberName: String; aReadOnly: Boolean; aTypeMapping: ITypeMapping);
var
 lBinding : TBinding;
 lSourceMember : TRttiMember;
 lDestMember : TRttiMember;
begin
 // TODO: Handle Support for more than one Default ITypeMapping
 // based on common conversions.
 // Example: IntToStr/StrToInt etc...
 // For Now types must match or a custom ITypeMapping must be provided
 if Not Assigned(aTypeMapping) then
    aTypeMapping := FDefaultTypeMapping;

 //TODO: Change Exception Classes
 // Property first if unassigned then try field.
 lSourceMember := FCtx.GetType(FSourceClass).GetProperty(aPropName);
 if not Assigned(lSourceMember) then
    lSourceMember := FCtx.GetType(FSourceClass).GetField(aPropName);
 if not Assigned(lSourceMember) then
   raise Exception.CreateFmt('Unable to locate %s Member %s',[FSourceClass.ClassName,aPropName]);

 // Property first if unassigned then try field.
 lDestMember := FCtx.GetType(aDestObject.ClassInfo).GetProperty(aMemberName);
 if not Assigned(lDestMember) then
    lDestMember := FCtx.GetType(aDestObject.ClassInfo).GetField(aMemberName);
 if not Assigned(lDestMember) then
   raise Exception.CreateFmt('Unable to locate %s Member %s',[aDestObject.ClassName,aMemberName]);

 lBinding := TBinding.Create(lSourceMember,aDestObject,lDestMember,aReadOnly,aTypeMapping);

 FBindings.Add(lBinding);
end;

constructor TObjectBinder.Create(aSourceClass: TClass);
begin
  FSourceClass := aSourceClass;
  FDefaultTypeMapping := TDefaultTypeMapping.Create;
  FBindings := TObjectList<TBinding>.Create;
end;

destructor TObjectBinder.Destroy;
begin
  FBindings.Free;
  inherited;
end;

function TObjectBinder.IsChanged(Instance: TObject): Boolean;
var
 Binding : TBinding;
begin
 result := false;
 for Binding in FBindings do
 begin
   if Binding.IsChanged(Instance) then
      exit(true);
 end;
end;

procedure TObjectBinder.Load(Instance: TObject);
var
 Binding : TBinding;
begin
 for Binding in FBindings do
   Binding.Load(Instance);
end;

procedure TObjectBinder.Save(Instance: TObject);
var
 Binding : TBinding;
begin
 for Binding in FBindings do
   Binding.Save(Instance);
end;

{ TDefaultObjectBinder }

function TDefaultTypeMapping.Compare(Source, Dest: TValue): Integer;
begin
 // Really UniCodeCompareStr (Annoying VCL Name for backwards compatablity)
 result := AnsiCompareStr(Source.ToString,Dest.ToString); //
end;

function TDefaultTypeMapping.DestToSource(Dest: TValue): TValue;
begin
 result := Dest;
end;

function TDefaultTypeMapping.SourceToDest(Source: TValue): TValue;
begin
  result := Source;
end;


{ TObjectBinder.TBinding }

constructor TObjectBinder.TBinding.Create(aSourceMember: TRttiMember;
  aDestObject: TObject; aDestMember: TRttiMember; aReadOnly: Boolean;
  aTypeMapping: ITypeMapping);
begin
  SourceMember := aSourceMember;
  DestObj := aDestObject;
  DestMember := aDestMember;
  ReadOnly := aReadOnly;
  TypeMapping := aTypeMapping;
end;


function TObjectBinder.TBinding.IsChanged(Instance: TObject): Boolean;
var
 DestValue : TValue;
 SourceValue : TValue;
begin
  // Get Current Value of Instance
  SourceValue := SourceMember.GetValue(Instance);
  // Get Current Value of DestObj
  DestValue := DestMember.GetValue(DestObj);
  // Peform Comparision
  result := (TypeMapping.Compare(SourceValue,DestValue) <> 0);
end;

procedure TObjectBinder.TBinding.Load(Instance: TObject);
var
  Value : TValue;
begin
  // Get Current Value of Instance
  Value := SourceMember.GetValue(Instance);
  // Convert from one TValue format to desired TValue Format
  Value := TypeMapping.SourceToDest(Value);
  // Save it to DestObj
  DestMember.SetValue(DestObj,Value);
end;

procedure TObjectBinder.TBinding.Save(Instance: TObject);
var
  Value : TValue;
begin
  if ReadOnly then Exit;  
  // Get Current Value of DestObj
  Value := DestMember.GetValue(DestObj);
  // Convert from one TValue format to desired TValue Format
  Value := TypeMapping.DestToSource(Value);
  // Save it to Instance
  SourceMember.SetValue(Instance,Value);
end;

end.
