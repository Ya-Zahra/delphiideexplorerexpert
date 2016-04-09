object f_IdeExplorerFilterForm: Tf_IdeExplorerFilterForm
  Left = 250
  Top = 108
  Caption = 'Filter'
  ClientHeight = 297
  ClientWidth = 441
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnResize = FormResize
  DesignSize = (
    441
    297)
  PixelsPerInch = 96
  TextHeight = 13
  object l_Visible: TLabel
    Left = 8
    Top = 8
    Width = 145
    Height = 16
    AutoSize = False
    Caption = 'Visible:'
  end
  object l_Hidden: TLabel
    Left = 192
    Top = 8
    Width = 145
    Height = 16
    AutoSize = False
    Caption = 'Hidden:'
  end
  object b_Hide: TSpeedButton
    Left = 161
    Top = 66
    Width = 24
    Height = 24
    Caption = '>'
    OnClick = b_HideClick
  end
  object b_HideAll: TSpeedButton
    Left = 161
    Top = 36
    Width = 24
    Height = 24
    Caption = '>>'
    OnClick = b_HideAllClick
  end
  object b_Show: TSpeedButton
    Left = 161
    Top = 96
    Width = 24
    Height = 24
    Caption = '<'
    Enabled = False
    OnClick = b_ShowClick
  end
  object b_ShowAll: TSpeedButton
    Left = 161
    Top = 126
    Width = 24
    Height = 24
    Caption = '<<'
    Enabled = False
    OnClick = b_ShowAllClick
  end
  object l_Note: TLabel
    Left = 360
    Top = 24
    Width = 70
    Height = 125
    AutoSize = False
    Caption = 
      'Controls are adjusted to form size at run time. (And this not is' +
      ' hidden at runtime.)'
    Visible = False
    WordWrap = True
  end
  object b_Ok: TButton
    Left = 280
    Top = 263
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object b_Cancel: TButton
    Left = 360
    Top = 263
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object lb_Visible: TListBox
    Left = 8
    Top = 24
    Width = 146
    Height = 232
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    MultiSelect = True
    Sorted = True
    TabOrder = 0
    OnDblClick = lb_VisibleDblClick
  end
  object lb_Hidden: TListBox
    Left = 192
    Top = 24
    Width = 145
    Height = 232
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 1
    OnDblClick = lb_HiddenDblClick
  end
end
