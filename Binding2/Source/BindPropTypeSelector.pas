unit BindPropTypeSelector;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,Rtti;

type

// Prototype Design! Really needs to be done differently to be fast and effective.
// Things to Consider:
//  Everything in 2010 has a filter list
//  Ability to permenatly filter out packages that may never be used such as DesignTime IDE Packages
//  Ability to filter to Runtime packages only??  Maybe selectable list better
//    as it's possible you could have a designtime only package with model classses as they are not building with
//    packages.
//  Performance, dialog needs to be fast to load and use.
  TfrmBindPropTypeSelector = class(TForm)
    edtSelectedType: TEdit;
    Label1: TLabel;
    btnOK: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    lvTypes: TListView;
    lbPackages: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure lbPackagesDblClick(Sender: TObject);
    procedure lvTypesDblClick(Sender: TObject);
  private
    Ctx : TRttiContext;
    function GetSelectedType: String;
    procedure SetSelectedType(const Value: String);
    { Private declarations }
  public
    { Public declarations }
    property SelectedType : String read GetSelectedType write SetSelectedType;
  end;

var
  frmBindPropTypeSelector: TfrmBindPropTypeSelector;

implementation


{$R *.dfm}

{ TfrmBindPropTypeSelector }

procedure TfrmBindPropTypeSelector.FormCreate(Sender: TObject);
var
  P : TRttiPackage;
begin
  lbPackages.Items.Clear;
  Ctx := TRttiContext.Create;
  for p in Ctx.GetPackages do
  begin
    lbPackages.Items.AddObject(p.Name,p);
  end;
end;

function TfrmBindPropTypeSelector.GetSelectedType: String;
begin
  result := edtSelectedType.Text;
end;

procedure TfrmBindPropTypeSelector.lbPackagesDblClick(Sender: TObject);
var
 P : TRttiPackage;
 T : TRttiType;
 item : TListItem;
begin
  lvTypes.Items.Clear;
  if lbPackages.ItemIndex = -1 then
     exit;
  p := lbPackages.Items.Objects[lbPackages.ItemIndex] as TRttiPackage;
  for T in p.GetTypes do
  begin
    if T.IsPublicType then
    begin
      item := lvTypes.Items.Add;
      item.Caption := t.QualifiedName;     
    end;
  end;

end;

procedure TfrmBindPropTypeSelector.lvTypesDblClick(Sender: TObject);
begin
  if Assigned(lvTypes.ItemFocused) then 
     edtSelectedType.Text := lvTypes.ItemFocused.Caption;
end;

procedure TfrmBindPropTypeSelector.SetSelectedType(const Value: String);
begin
  edtSelectedType.Text := Value;
end;

end.
