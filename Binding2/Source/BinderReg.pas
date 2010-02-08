unit BinderReg;

interface

procedure Register;

implementation
uses DesignIntf, DesignEditors, Classes, Bindings, BindPropEditors;

procedure Register;
begin

  RegisterComponents('Rob''s Tech Corner',[TBinder]);
  RegisterPropertyEditor(TypeInfo(TRttiTypeString),TBinder,'SourceType',TRttiTypeStringProperty);
  RegisterPropertyEditor(TypeInfo(TBindingBehaviorClassName),TBindingCollectionItem,'BehaviorType',TBehaviorTypeProperty);
  RegisterPropertyEditor(TypeInfo(TRttiMemberString),TBindingCollectionItem,'SourceMember', TSourceMemberProperty);
  RegisterPropertyEditor(TypeInfo(TBindingBehavior),TBindingCollectionItem,'Behavior',TBehaviorProperty);

  // Although you can bind at run time to any object at design time
  // your limited to TComponent Descendants
  RegisterPropertyEditor(TObject.ClassInfo,TBindingCollectionItem,'DestObject',TComponentProperty);

end;

end.
