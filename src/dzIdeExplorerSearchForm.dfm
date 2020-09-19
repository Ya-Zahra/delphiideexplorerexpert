object f_dzIdeExplorerSearch: Tf_dzIdeExplorerSearch
  Left = 434
  Top = 251
  Width = 313
  Height = 152
  BorderIcons = [biSystemMenu]
  Caption = 'Search'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    297
    113)
  PixelsPerInch = 96
  TextHeight = 13
  object SearchForLabel: TLabel
    Left = 8
    Top = 8
    Width = 54
    Height = 13
    Caption = '&Search for:'
    FocusControl = ed_Name
  end
  object ed_Name: TEdit
    Left = 8
    Top = 24
    Width = 281
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object rb_ComponentName: TRadioButton
    Left = 8
    Top = 60
    Width = 113
    Height = 17
    Caption = '&Component name'
    Checked = True
    TabOrder = 1
    TabStop = True
  end
  object rb_TypeName: TRadioButton
    Left = 8
    Top = 84
    Width = 113
    Height = 17
    Caption = '&Type name'
    TabOrder = 2
  end
  object b_Ok: TButton
    Left = 136
    Top = 80
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object b_Cancel: TButton
    Left = 216
    Top = 80
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object chk_: TCheckBox
    Left = 136
    Top = 56
    Width = 97
    Height = 17
    Caption = 'Recursively'
    TabOrder = 5
  end
end
