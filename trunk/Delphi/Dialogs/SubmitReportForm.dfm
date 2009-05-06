object frmSubmitReport: TfrmSubmitReport
  Left = 0
  Top = 0
  ClientHeight = 501
  ClientWidth = 528
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  GlassFrame.Enabled = True
  object Splitter1: TSplitter
    Left = 0
    Top = 97
    Width = 528
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 41
    ExplicitWidth = 184
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 454
    Width = 528
    Height = 47
    Align = alBottom
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 0
    object btnCancel: TButton
      AlignWithMargins = True
      Left = 441
      Top = 7
      Width = 84
      Height = 33
      Margins.Top = 7
      Margins.Bottom = 7
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 0
    end
    object btnOK: TButton
      AlignWithMargins = True
      Left = 351
      Top = 7
      Width = 84
      Height = 33
      Margins.Top = 7
      Margins.Bottom = 7
      Align = alRight
      Caption = 'OK'
      Default = True
      TabOrder = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 528
    Height = 97
    Align = alTop
    TabOrder = 1
    object lblReport: TLabel
      Left = 1
      Top = 1
      Width = 526
      Height = 13
      Align = alTop
      Caption = 'Report'
      WordWrap = True
      ExplicitWidth = 33
    end
    object memUserComment: TMemo
      Left = 1
      Top = 14
      Width = 526
      Height = 82
      Hint = 
        '"As the Chinese say, 1001 words is worth more than a picture."  ' +
        '- John McCarthy'
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ExplicitLeft = 0
      ExplicitTop = 12
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 100
    Width = 528
    Height = 354
    ActivePage = tsImage
    Align = alClient
    TabOrder = 2
    object tsImage: TTabSheet
      Caption = 'Image'
      object imgDisplay: TImage
        Left = 0
        Top = 40
        Width = 520
        Height = 286
        Hint = 
          'An old Chinese proverb "A Picture'#39#39's Meaning Can Express Ten Tho' +
          'usand Words"'
        Align = alClient
        ParentShowHint = False
        Proportional = True
        ShowHint = True
        ExplicitLeft = -11
        ExplicitTop = 79
        ExplicitWidth = 483
        ExplicitHeight = 88
      end
      object rgShotSelection: TRadioGroup
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 514
        Height = 34
        Align = alTop
        Columns = 4
        ItemIndex = 1
        Items.Strings = (
          'None'
          'Active Window'
          'Active Monitor'
          'All Monitors')
        TabOrder = 0
        OnClick = rgShotSelectionClick
      end
    end
    object tsTechDetails: TTabSheet
      Caption = 'Technical Details'
      ImageIndex = 1
      object lblTechDetails: TLabel
        Left = 0
        Top = 0
        Width = 520
        Height = 13
        Align = alTop
        Caption = 'TD'
        ExplicitWidth = 13
      end
      object memTechDetails: TMemo
        Left = 0
        Top = 13
        Width = 520
        Height = 313
        Align = alClient
        ReadOnly = True
        TabOrder = 0
      end
    end
    object tsAttach: TTabSheet
      Caption = 'Attach to Report'
      ImageIndex = 2
      DesignSize = (
        520
        326)
      object lvAttachedFiles: TListView
        Left = 0
        Top = 3
        Width = 517
        Height = 280
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'Filename'
          end
          item
            Caption = 'Description'
          end>
        TabOrder = 0
        ViewStyle = vsReport
      end
      object Button1: TButton
        Left = 0
        Top = 289
        Width = 121
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'Add Attachment'
        TabOrder = 1
      end
      object Button2: TButton
        Left = 128
        Top = 289
        Width = 161
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = 'Remove Selected Attachment'
        TabOrder = 2
      end
    end
  end
end
