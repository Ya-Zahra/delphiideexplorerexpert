object f_dzIdeExplorerSearch: Tf_dzIdeExplorerSearch
  Left = 434
  Top = 251
  BorderIcons = [biSystemMenu]
  Caption = 'Search'
  ClientHeight = 145
  ClientWidth = 297
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
    145)
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
    Top = 64
    Width = 121
    Height = 17
    Caption = '&Component name'
    Checked = True
    TabOrder = 1
    TabStop = True
  end
  object rb_TypeName: TRadioButton
    Left = 8
    Top = 88
    Width = 121
    Height = 17
    Caption = '&Type name'
    TabOrder = 2
  end
  object b_Ok: TButton
    Left = 136
    Top = 112
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
    Top = 112
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object chk_Recursive: TCheckBox
    Left = 144
    Top = 64
    Width = 145
    Height = 17
    Caption = '&Recursively'
    TabOrder = 5
  end
  object chk_EntireScope: TCheckBox
    Left = 144
    Top = 88
    Width = 145
    Height = 17
    Caption = '&Entire Scope'
    TabOrder = 6
  end
end
