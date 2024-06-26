object ACLTextureEditorDialog: TACLTextureEditorDialog
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Texture Editor'
  ClientHeight = 466
  ClientWidth = 584
  Constraints.MinHeight = 500
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object pnlPreview: TACLPanel
    AlignWithMargins = True
    Left = 8
    Top = 30
    Width = 365
    Height = 393
    Margins.Bottom = 6
    Margins.Left = 8
    Margins.Top = 7
    Align = alClient
    TabOrder = 1
    object pnlToolbar: TACLPanel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 355
      Height = 27
      Margins.Bottom = 0
      Align = alTop
      TabOrder = 0
      AutoSize = True
      Borders = []
      object cbStretchMode: TACLComboBox
        AlignWithMargins = True
        Left = 202
        Top = 3
        Width = 150
        Height = 21
        Align = alRight
        TabOrder = 0
        Buttons = <>
        Items.Strings = (
          'StretchMode: Stretch'
          'StretchMode: Tile'
          'StretchMode: Center')
        Mode = cbmList
        Text = ''
        OnSelect = cbStretchModeSelect
      end
      object cbSource: TACLComboBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 193
        Height = 21
        Align = alClient
        TabOrder = 1
        Buttons = <
          item
            ImageIndex = 0
            OnClick = cbSourceButtons0Click
          end
          item
            ImageIndex = 1
            OnClick = cbSourceButtons1Click
          end>
        ButtonsImages = ilImages
        Items.Strings = (
          'StretchMode: Stretch'
          'StretchMode: Tile'
          'StretchMode: Center')
        Mode = cbmList
        Text = ''
        OnSelect = cbSourceSelect
      end
    end
    object pnlToolbarBottom: TACLPanel
      AlignWithMargins = True
      Left = 5
      Top = 357
      Width = 355
      Height = 31
      Margins.Top = 0
      Align = alBottom
      TabOrder = 1
      Borders = []
      object btnLoad: TACLButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 75
        Height = 25
        Align = alLeft
        TabOrder = 0
        OnClick = btnLoadClick
        Caption = '&Load'
      end
      object btnSave: TACLButton
        AlignWithMargins = True
        Left = 84
        Top = 3
        Width = 75
        Height = 25
        Align = alLeft
        TabOrder = 1
        OnClick = btnSaveClick
        Caption = '&Save'
      end
      object btnClear: TACLButton
        AlignWithMargins = True
        Left = 277
        Top = 3
        Width = 75
        Height = 25
        Align = alRight
        TabOrder = 2
        OnClick = btnClearClick
        Caption = '&Clear'
      end
    end
    object pnlDisplay: TACLPanel
      AlignWithMargins = True
      Left = 8
      Top = 38
      Width = 349
      Height = 313
      Margins.All = 6
      Align = alClient
      TabOrder = 2
      Borders = []
      object pbDisplay: TPaintBox
        Left = 0
        Top = 0
        Width = 349
        Height = 313
        Align = alClient
        OnMouseDown = pbDisplayMouseDown
        OnMouseMove = pbDisplayMouseMove
        OnMouseUp = pbDisplayMouseUp
        OnPaint = pbDisplayPaint
        ExplicitLeft = 8
        ExplicitTop = -3
      end
    end
  end
  object pnlButtons: TACLPanel
    AlignWithMargins = True
    Left = 8
    Top = 432
    Width = 568
    Height = 31
    Margins.Left = 8
    Margins.Right = 8
    Align = alBottom
    TabOrder = 2
    Borders = []
    Padding.Left = 5
    object btnOk: TACLButton
      AlignWithMargins = True
      Left = 409
      Top = 3
      Width = 75
      Height = 25
      Align = alRight
      TabOrder = 1
      Caption = 'OK'
      Default = True
      ModalResult = 1
    end
    object btnCancel: TACLButton
      AlignWithMargins = True
      Left = 490
      Top = 3
      Width = 75
      Height = 25
      Align = alRight
      TabOrder = 2
      Caption = 'Cancel'
      ModalResult = 2
    end
    object btnExport: TACLButton
      AlignWithMargins = True
      Left = 89
      Top = 3
      Width = 75
      Height = 25
      Align = alLeft
      TabOrder = 0
      OnClick = btnExportClick
      Caption = '&Export'
    end
    object btnImport: TACLButton
      AlignWithMargins = True
      Left = 8
      Top = 3
      Width = 75
      Height = 25
      Align = alLeft
      TabOrder = 3
      OnClick = btnImportClick
      Caption = '&Import'
    end
  end
  object pnlSettings: TACLPanel
    AlignWithMargins = True
    Left = 376
    Top = 23
    Width = 200
    Height = 400
    Margins.Bottom = 6
    Margins.Left = 0
    Margins.Right = 8
    Margins.Top = 0
    Align = alRight
    TabOrder = 3
    Borders = []
    object gbFrames: TACLGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 0
      Width = 194
      Height = 94
      Margins.Top = 0
      Align = alTop
      TabOrder = 0
      AutoSize = True
      Caption = ' Frames '
      DesignSize = (
        194
        94)
      object Label1: TACLLabel
        AlignWithMargins = True
        Left = 10
        Top = 17
        Width = 174
        Height = 17
        Align = alTop
        SubControl.Control = seFrame
        AutoSize = True
        Caption = 'Display Frame:'
      end
      object Label2: TACLLabel
        AlignWithMargins = True
        Left = 10
        Top = 40
        Width = 174
        Height = 17
        Align = alTop
        SubControl.Control = seMax
        AutoSize = True
        Caption = 'Frames Count:'
      end
      object cbLayout: TACLComboBox
        AlignWithMargins = True
        Left = 10
        Top = 63
        Width = 174
        Height = 21
        Align = alTop
        TabOrder = 2
        Buttons = <>
        Items.Strings = (
          'Horizontal'
          'Vertical')
        Mode = cbmList
        Text = ''
        OnSelect = cbLayoutSelect
      end
      object seFrame: TACLSpinEdit
        Left = 102
        Top = 17
        Width = 82
        Height = 17
        TabOrder = 0
        OnChange = seFrameChange
        OptionsValue.MaxValue = 10
        OptionsValue.MinValue = 1
        Value = 1
      end
      object seMax: TACLSpinEdit
        Left = 102
        Top = 40
        Width = 82
        Height = 17
        TabOrder = 1
        OnChange = seMaxChange
        OptionsValue.MaxValue = 100
        OptionsValue.MinValue = 1
        Value = 1
      end
    end
    object gbMargins: TACLGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 205
      Width = 194
      Height = 101
      Align = alTop
      TabOrder = 2
      Caption = ' Sizing Margins '
      object seMarginTop: TACLSpinEdit
        Left = 59
        Top = 25
        Width = 75
        Height = 17
        TabOrder = 0
        OnChange = seMarginLeftChange
        OptionsValue.MinValue = 0
      end
      object seMarginBottom: TACLSpinEdit
        Left = 59
        Top = 71
        Width = 75
        Height = 17
        TabOrder = 3
        OnChange = seMarginLeftChange
        OptionsValue.MinValue = 0
      end
      object seMarginLeft: TACLSpinEdit
        Left = 20
        Top = 48
        Width = 75
        Height = 17
        TabOrder = 1
        OnChange = seMarginLeftChange
        OptionsValue.MinValue = 0
      end
      object seMarginRight: TACLSpinEdit
        Left = 101
        Top = 48
        Width = 75
        Height = 17
        TabOrder = 2
        OnChange = seMarginLeftChange
        OptionsValue.MinValue = 0
      end
    end
    object gbContentOffsets: TACLGroupBox
      AlignWithMargins = True
      Left = 3
      Top = 100
      Width = 194
      Height = 99
      Align = alTop
      TabOrder = 1
      Caption = ' Content Offsets '
      object seContentOffsetTop: TACLSpinEdit
        Left = 59
        Top = 23
        Width = 75
        Height = 17
        TabOrder = 0
        OnChange = seContentOffsetTopChange
        OptionsValue.MaxValue = 100
        OptionsValue.MinValue = 0
      end
      object seContentOffsetBottom: TACLSpinEdit
        Left = 59
        Top = 69
        Width = 75
        Height = 17
        TabOrder = 3
        OnChange = seContentOffsetTopChange
        OptionsValue.MaxValue = 100
        OptionsValue.MinValue = 0
      end
      object seContentOffsetLeft: TACLSpinEdit
        Left = 20
        Top = 46
        Width = 75
        Height = 17
        TabOrder = 1
        OnChange = seContentOffsetTopChange
        OptionsValue.MaxValue = 100
        OptionsValue.MinValue = 0
      end
      object seContentOffsetRight: TACLSpinEdit
        Left = 101
        Top = 46
        Width = 75
        Height = 17
        TabOrder = 2
        OnChange = seContentOffsetTopChange
        OptionsValue.MaxValue = 100
        OptionsValue.MinValue = 0
      end
    end
  end
  object cbOverride: TACLCheckBox
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 568
    Height = 15
    Margins.Bottom = 0
    Margins.Left = 8
    Margins.Right = 8
    Margins.Top = 8
    Align = alTop
    TabOrder = 0
    Caption = 'Override StyleSource Value'
    Transparent = True
    State = cbChecked
  end
  object TextureFileDialog: TACLFileDialog
    Filter = 'PNG Images|*.png;'
    Left = 328
    Top = 424
  end
  object ImportExportDialog: TACLFileDialog
    Filter = 'Skinned Image Set (*.acl32) |*.acl32;'
    Left = 280
    Top = 424
  end
  object ilImages: TACLImageList
    Left = 232
    Top = 424
    Bitmap = {
      4C49435A261100008D000000789CF3F461646462E06060611000C2FF40A028F0
      1F0A9C7CCD182000446B00B103100B0031238302444280611490007634F9FC07
      E18176C7408151FF8FFA7FD4FFA3FE1F6877D01AC0FC492A86E9774EBAF19F1C
      3C907E460623DDFFB8C04849FFB8C0A8FF47FD3FEAFF51FF0FB43B4601ED8093
      AF1D9405A251470D18C1E20D3874FEFF3F58130600FAB0DC25}
  end
end
