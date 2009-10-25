unit DynFactory;
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
uses SysUtils, classes, Generics.Collections, RTTI, TypInfo;

type

  TFactory = class(TObject)
  private
    FLoadedPackages : TDictionary<String,HModule>;
  public
     procedure UnloadPackages; virtual;
     function LoadPackage(const Name: string): HMODULE; virtual;
     procedure UnloadPackage(const Name : string); virtual;
     class function GetClass<T : Class>(Name : String) : T; static;
     constructor Create; virtual;
     destructor Destroy; override;
  end;


implementation

{ TFactory }

constructor TFactory.Create;
begin
 FLoadedPackages := TDictionary<String,HModule>.Create;
end;

destructor TFactory.Destroy;
begin
  UnloadPackages;
  FLoadedPackages.Free;
  inherited;
end;

class function TFactory.GetClass<T>(Name: String): T;
var
 C : TRttiContext;
 v : TValue;
begin
 C := TRttiContext.Create;
 V := C.GetType(TypeInfo(T)).AsInstance.MetaclassType;
 result := v.AsType<T>;
end;

function TFactory.LoadPackage(const Name: string): HMODULE;
begin
  if Not FLoadedPackages.TryGetValue(Name,result) then
  begin
    result := SysUtils.LoadPackage(Name);
    FLoadedPackages.Add(Name,result);
  end;
end;


procedure TFactory.UnloadPackage(const Name: string);
var
 Module : HMODULE;
begin
  if FLoadedPackages.TryGetValue(Name,Module) then
  begin
    SysUtils.UnloadPackage(Module);
    FLoadedPackages.Remove(Name);
  end;
end;

procedure TFactory.UnloadPackages;
var
 Package : HMODULE;
begin
  for Package in FLoadedPackages.Values do
  begin
    SysUtils.UnloadPackage(Package);
  end;
  FLoadedPackages.Clear;
end;

end.
