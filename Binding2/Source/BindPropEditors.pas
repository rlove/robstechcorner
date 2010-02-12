unit BindPropEditors;

interface
uses
  Sysutils, Classes, DesignIntf, DesignEditors, Bindings, Rtti,ToolsApi;
type
  TRttiTypeStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  TRttiMemberStringProperty = class(TStringProperty)
  protected
     FCtx :  TRttiContext;
     function GetType : TRttiType; virtual; abstract;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    constructor Create(const ADesigner: IDesigner; APropCount: Integer); override;
  end;


  TSourceMemberProperty = class(TRttiMemberStringProperty)
  protected
    function GetType : TRttiType; override;
  end;

  TDestMemberProperty = class(TRttiMemberStringProperty)
  protected
    function GetType : TRttiType; override;
  end;


  TBehaviorTypeProperty = class(TStringProperty)
  protected
  public
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TBehaviorProperty = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Initialize; override;
  end;




implementation
uses
  Forms, Controls, Dialogs, BindPropTypeSelector;

{ TRttiTypeStringPropEditor }

procedure TRttiTypeStringProperty.Edit;
var
 frm : TfrmBindPropTypeSelector;
begin
  frm := TfrmBindPropTypeSelector.Create(Application);
  try
    frm.SelectedType := Value;
    if (frm.ShowModal = mrOk) then
      SetValue(frm.SelectedType);
  finally
    frm.Free;
  end;
end;

function TRttiTypeStringProperty.GetAttributes: TPropertyAttributes;
begin
  result := [paRevertable,paDialog];
end;


{ TRttiPropertyStringProperty }

constructor TRttiMemberStringProperty.Create(const ADesigner: IDesigner;
  APropCount: Integer);
begin
  inherited;
  FCtx := TRttiContext.Create;
end;


function TRttiMemberStringProperty.GetAttributes: TPropertyAttributes;
begin
  result := [paValueList];
end;

procedure TRttiMemberStringProperty.GetValues(Proc: TGetStrProc);
var
 T : TRttiType;
 Prop : TRttiProperty;
 Field : TRttiField;
begin
  T := GetType;
  if not Assigned(T) then exit;

  for Prop in T.GetProperties do
  begin
     if (Prop.Visibility in BindingVisibility) then
        Proc(Prop.Name);
  end;

  for Field in T.GetFields do
  begin
      if (Field.Visibility in BindingVisibility) then
         Proc(Field.Name);
  end;

end;


{ TDestObjectProperty }


{ TSourceMemberProperty }

function TSourceMemberProperty.GetType: TRttiType;
var
 lSourceType : String;
begin
 lSourceType :=  TBindingBehavior(GetComponent(0)).BindingItem.BindingCollection.Binding.SourceType;
 if LSourceType = '' then
    exit(nil);
 result := FCtx.FindType(lSourceType);
end;

{ TBehaviorTypeProperty }

function TBehaviorTypeProperty.GetAttributes: TPropertyAttributes;
begin
  result := [paValueList,paSortList,paVolatileSubProperties];
end;

procedure TBehaviorTypeProperty.GetValues(Proc: TGetStrProc);
var
 aClassName : String;
begin
  for aClassName in TBinder.BehaviorKeys do
  begin
    Proc(aClassName);
  end;
end;



procedure TBehaviorTypeProperty.SetValue(const Value: string);
var
  List : IDesignerSelections;
  Comp : TPersistent;
begin
  inherited;
  // Ugly Hack to cause the Behavior Property to be
  // Repainted as the sub properties have changed.
  // But it causes the focus to change which I don't like.
  // And although it does not flicker on my machine, I bet
  // it will on slower machines.
  if Assigned(Designer) then
  begin
    Comp := GetComponent(0);
    List := CreateSelectionList;
    Designer.SetSelections(List);
    List.Add(Comp);
    Designer.SetSelections(List);
  end;
end;

{ TBehaviorProperty }

function TBehaviorProperty.GetAttributes: TPropertyAttributes;
begin
  result := inherited GetAttributes;
  result := result + [paVolatileSubProperties] - [paMultiSelect];
end;

function TBehaviorProperty.GetValue: string;
var
 Behavior : TBindingBehavior;
begin
  Behavior := TBindingBehavior(GetComponent(0));
  if Assigned(Behavior) then
  begin
    result := Behavior.ClassName;// + ' ' + Behavior.DisplayDetails;
  end
  else
    result := 'Specify Behavior Type';



end;

procedure TBehaviorProperty.Initialize;
begin
  inherited;
//  ShowMessage('Test');
end;

{ TDestMemberProperty }

function TDestMemberProperty.GetType: TRttiType;
var
 lDest : TObject;
begin
 lDest :=  TBindingBehavior(GetComponent(0)).BindingItem.DestObject;
 if not Assigned(LDest) then
    exit(nil);
 result := FCtx.GetType(LDest.ClassInfo);
end;

end.
