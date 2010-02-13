unit BinderReg;
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

procedure Register;

implementation
uses DesignIntf, DesignEditors, Classes, Bindings, BindPropEditors;

procedure Register;
begin

  RegisterComponents('Rob''s Tech Corner',[TBinder]);
  RegisterPropertyEditor(TypeInfo(TRttiTypeString),TBinder,'SourceType',TRttiTypeStringProperty);
  RegisterPropertyEditor(TypeInfo(TBindingBehaviorClassName),TBindingCollectionItem,'BehaviorType',TBehaviorTypeProperty);
  RegisterPropertyEditor(TypeInfo(TRttiMemberString),TMemberBindingBehavior,'SourceMemberName', TSourceMemberProperty);
  RegisterPropertyEditor(TypeInfo(TRttiMemberString),TMemberBindingBehavior,'DestMemberName', TDestMemberProperty);
  RegisterPropertyEditor(TypeInfo(TBindingBehavior),TBindingCollectionItem,'Behavior',TBehaviorProperty);

  // Although you can bind at run time to any object at design time
  // your limited to TComponent Descendants
  RegisterPropertyEditor(TObject.ClassInfo,TBindingCollectionItem,'DestObject',TComponentProperty);

end;

end.
