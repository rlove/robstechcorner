object Form8: TForm8
  Left = 0
  Top = 0
  Caption = 'Form8'
  ClientHeight = 302
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 88
    Top = 32
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Button1: TButton
    Left = 88
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 88
    Top = 64
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button2: TButton
    Left = 200
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Binder1: TBinder
    SourceType = 'uModel.TPerson'
    Bindings = <
      item
        DestObject = Edit1
        BehaviorType = 'TMemberBindingBehavior'
        Behavior.DestMemberName = 'Text'
        Behavior.SourceMemberName = 'FirstName'
        Behavior.ReadOnly = False
      end
      item
        DestObject = Label1
        BehaviorType = 'TMemberBindingBehavior'
        Behavior.DestMemberName = 'Caption'
        Behavior.SourceMemberName = 'LastName'
        Behavior.ReadOnly = True
      end>
    Left = 528
    Top = 72
  end
end
