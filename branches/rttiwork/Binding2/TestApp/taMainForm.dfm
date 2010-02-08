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
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 40
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
  end
  object Binder1: TBinder
    SourceType = 'uModel.TEmployee'
    Bindings = <
      item
        SourceMember = 'EmployeeNum'
        DestObject = Button1
        BehaviorType = 'TTest2'
        Behavior.Test2 = 'asdf222'
      end
      item
        BehaviorType = 'TTest1'
        Behavior.Test1 = 'Blah111'
      end>
    Left = 480
    Top = 40
  end
end
