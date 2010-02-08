object frmBindPropTypeSelector: TfrmBindPropTypeSelector
  Left = 0
  Top = 0
  Caption = 'frmBindPropTypeSelector'
  ClientHeight = 383
  ClientWidth = 615
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 13
    Width = 68
    Height = 13
    Caption = 'Selected Type'
  end
  object Label2: TLabel
    Left = 16
    Top = 61
    Width = 96
    Height = 13
    Caption = 'Packages to Browse'
  end
  object Label3: TLabel
    Left = 320
    Top = 27
    Width = 209
    Height = 26
    Caption = 
      'Prototype Design! Really needs to be done differently to be fast' +
      ' and effective.'
    WordWrap = True
  end
  object edtSelectedType: TEdit
    Left = 16
    Top = 32
    Width = 257
    Height = 21
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 432
    Top = 341
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 518
    Top = 341
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object lvTypes: TListView
    Left = 16
    Top = 160
    Width = 577
    Height = 150
    Columns = <
      item
        Caption = 'Qualified Name'
        Width = 500
      end>
    TabOrder = 3
    ViewStyle = vsReport
    OnDblClick = lvTypesDblClick
  end
  object lbPackages: TListBox
    Left = 16
    Top = 80
    Width = 577
    Height = 74
    ItemHeight = 13
    TabOrder = 4
    OnDblClick = lbPackagesDblClick
  end
end
