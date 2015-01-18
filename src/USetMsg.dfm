object frmSetMsg: TfrmSetMsg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Set Event Message'
  ClientHeight = 454
  ClientWidth = 715
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    715
    454)
  PixelsPerInch = 96
  TextHeight = 13
  object cbbAddEventType: TsComboBox
    Left = 8
    Top = 354
    Width = 209
    Height = 22
    Anchors = [akLeft, akBottom]
    Alignment = taLeftJustify
    BoundLabel.Active = True
    BoundLabel.Caption = 'Status'
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -11
    BoundLabel.Font.Name = 'Tahoma'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclTopLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'COMBOBOX'
    VerticalAlignment = taAlignTop
    Style = csOwnerDrawFixed
    Color = 15984326
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = -1
    ParentFont = False
    TabOrder = 1
    OnDrawItem = cbbAddEventTypeDrawItem
  end
  object pnlEditOk: TsPanel
    Left = 0
    Top = 417
    Width = 715
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    SkinData.SkinSection = 'PANEL'
    object btnOk: TsButton
      AlignWithMargins = True
      Left = 492
      Top = 3
      Width = 107
      Height = 31
      Align = alRight
      Caption = '&Ok'
      ImageIndex = 10
      Images = DMImg.ilBtn16
      ModalResult = 1
      TabOrder = 0
      SkinData.SkinSection = 'BUTTON'
    end
    object btnCancel: TsButton
      AlignWithMargins = True
      Left = 605
      Top = 3
      Width = 107
      Height = 31
      Align = alRight
      Caption = '&Cancel'
      ImageIndex = 11
      Images = DMImg.ilBtn16
      ModalResult = 2
      TabOrder = 1
      SkinData.SkinSection = 'BUTTON'
    end
  end
  object g: TDBGridEh
    Left = 0
    Top = 0
    Width = 714
    Height = 335
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoFitColWidths = True
    ColumnDefValues.Title.TitleButton = True
    ColumnDefValues.Title.ToolTips = True
    ColumnDefValues.ToolTips = True
    DataSource = frmTZMain.dsMem
    DynProps = <>
    Flat = True
    FrozenCols = 3
    IndicatorOptions = []
    Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs]
    OptionsEh = [dghFixed3D, dghResizeWholeRightPart, dghHighlightFocus, dghClearSelection, dghFitRowHeightToText, dghAutoSortMarking, dghMultiSortMarking, dghTraceColSizing, dghIncSearch, dghRowHighlight, dghDblClickOptimizeColWidth, dghDialogFind, dghColumnResize, dghColumnMove, dghAutoFitRowHeight, dghExtendVertLines]
    ReadOnly = True
    RowHeight = 2
    RowLines = 1
    RowPanel.Active = True
    SortLocal = True
    TabOrder = 0
    OnDblClick = gDblClick
    Columns = <
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Priority'
        Footers = <>
        Title.ImageIndex = 1
        Width = 20
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Check2'
        Footers = <>
        Width = 20
        InRowLinePos = 1
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'priorityT'
        Footers = <>
        Width = 81
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Error'
        Footers = <>
        Width = 162
        InRowLinePos = 1
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Host'
        Footers = <>
        Width = 80
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Description'
        Footers = <>
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Message'
        Footers = <>
        Width = 304
        InRowLinePos = 1
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Lastchange'
        Footers = <>
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'clock'
        Footers = <>
        InRowLinePos = 1
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'T'
        Footers = <>
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'ET'
        Footers = <>
        InRowLinePos = 1
      end
      item
        DynProps = <>
        EditButtons = <>
        FieldName = 'Comments'
        Footers = <>
        Width = 65
      end
      item
        Alignment = taRightJustify
        DynProps = <>
        EditButtons = <>
        FieldName = 'User'
        Footers = <>
        Width = 65
        InRowLinePos = 1
      end>
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object cbbMSG: TsComboBox
    Left = 8
    Top = 392
    Width = 699
    Height = 21
    AutoCloseUp = True
    Anchors = [akLeft, akRight, akBottom]
    Alignment = taLeftJustify
    BoundLabel.Active = True
    BoundLabel.Caption = 'Message'
    BoundLabel.Indent = 0
    BoundLabel.Font.Charset = DEFAULT_CHARSET
    BoundLabel.Font.Color = clWindowText
    BoundLabel.Font.Height = -11
    BoundLabel.Font.Name = 'Tahoma'
    BoundLabel.Font.Style = []
    BoundLabel.Layout = sclTopLeft
    BoundLabel.MaxWidth = 0
    BoundLabel.UseSkinColor = True
    SkinData.SkinSection = 'COMBOBOX'
    VerticalAlignment = taAlignTop
    Color = 15984326
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = -1
    ParentFont = False
    TabOrder = 2
    OnDrawItem = cbbMSGDrawItem
  end
  object sSkinProvider1: TsSkinProvider
    AddedTitle.Font.Charset = DEFAULT_CHARSET
    AddedTitle.Font.Color = clNone
    AddedTitle.Font.Height = -11
    AddedTitle.Font.Name = 'Tahoma'
    AddedTitle.Font.Style = []
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 36
    Top = 281
  end
  object PropStorageEh1: TPropStorageEh
    Section = 'SetMSG'
    StorageManager = frmTZMain.RegPropStorageManEh1
    StoredProps.Strings = (
      '<P>.Height'
      '<P>.Left'
      '<P>.PixelsPerInch'
      '<P>.Top'
      '<P>.Width'
      'g.<P>.Columns.ColumnsIndex'
      'g.<P>.Columns.<ForAllItems>.Width')
    Left = 36
    Top = 216
  end
end
