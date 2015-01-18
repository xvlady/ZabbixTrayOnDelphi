unit USetMsg;

interface

{$I DEFTEXT.inc}

uses
  Vcl.Forms, UMain,
  types, Vcl.Graphics, windows,
  DBGridEhGrouping, ToolCtrlsEh,
  DBGridEhToolCtrls, DynVarsEh, PropFilerEh, PropStorageEh, sSkinProvider,
  GridsEh, DBAxisGridsEh, DBGridEh, Vcl.StdCtrls, sButton, Vcl.Controls,
  Vcl.ExtCtrls, sPanel, System.Classes, sComboBox;

type
//  TsComboBox = class(sComboBox.TsComboBox)
//  public
//    procedure CreateParams(var Params: TCreateParams); override;
//  end;
  TfrmSetMsg = class(TForm)
    sSkinProvider1: TsSkinProvider;
    cbbAddEventType: TsComboBox;
    pnlEditOk: TsPanel;
    btnOk: TsButton;
    btnCancel: TsButton;
    g: TDBGridEh;
    PropStorageEh1: TPropStorageEh;
    cbbMSG: TsComboBox;
    procedure gDblClick(Sender: TObject);
    procedure cbbAddEventTypeDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure cbbMSGDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}
uses UZT, SysUtils,Messages{$IFDEF USE_DXGETTEXT},JvGnugettext {$ENDIF USE_DXGETTEXT};

procedure TfrmSetMsg.cbbAddEventTypeDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with Control as TsComboBox do begin
    Canvas.Font.Color  := EventMsgC[Index] ;
    Canvas.FillRect(Rect) ;
    Canvas.TextOut(Rect.Left, Rect.Top, Items[Index]);
  end;
end;

procedure AutoInsertComboBoxItem(ComboBox: TsCombobox; var LastLength: integer);
var
  i, ln: integer;
begin
  // Сравниваем длину текста, если новая длина меньше старой -
  // значит было удаление символов и автоподбор не нужен
  if Length(ComboBox.Text) <= LastLength then
  begin
    LastLength := Length(ComboBox.Text);
    exit;
  end;
  // Запоминаем длину текста для следующего вызова процедуры
  LastLength := Length(ComboBox.Text);
  // Ищем в списке начала строк, совпадающие с введенным текстом
  for i := 0 to ComboBox.Items.Count - 1 do
  begin
    // Для поиска с учетом регистра:
    //if Copy(ComboBox.Items[i],1,Length(ComboBox.Text)) = ComboBox.Text then
    // Для поиска без учета регистра:
    if Copy(UpperCase(ComboBox.Items[i]), 1, Length(ComboBox.Text)) = UpperCase(ComboBox.Text) then
    begin
      ln := length(ComboBox.Text);
      // Вставляем текст
      ComboBox.Text := ComboBox.Items[i];
      // Выделяем добавленный блок текста
      ComboBox.SelStart := ln;
      ComboBox.SelLength := Length(ComboBox.Items[i]) - ln;
      break;
    end;
  end;
end;

procedure TfrmSetMsg.cbbMSGDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  i:Integer;
begin
  with Control as TsComboBox do begin
    if Length(Items[Index])>0 then begin
      Canvas.Font.Style:=[fsBold];
      Canvas.Font.Color:=EventMsgC[High(EventMsgC)];
      for I := Low(EventMsgK) to High(EventMsgK) do
        if copy(Items[Index],1,1)=EventMsgK[i]
        then Canvas.Font.Color:=EventMsgC[i];
    end else begin
      Canvas.Font.Color:=clBlack;
      Canvas.Font.Style:=[];
    end;
    Canvas.FillRect(Rect) ;
    Canvas.TextOut(Rect.Left, Rect.Top, Items[Index]);
  end;
end;

procedure TfrmSetMsg.FormCreate(Sender: TObject);
var
  I:Integer;
begin
  for i := Low(EventMsgK) to High(EventMsgK) do
    cbbAddEventType.Items.Add('"'+EventMsgK[i]+'" - '+EventMsgT[i]);
  cbbAddEventType.Items.add(EventMsgT[High(EventMsgT)]);
  cbbAddEventType.ItemIndex:=High(EventMsgT);
  cbbMSG.Items.AddStrings(frmTZMain.EventTemplates);
  //cbbMSG.DroppedDown := True;
//  cbb1.Perform(CB_SHOWDROPDOWN, 1, 0);
  TranslateComponent(self);
end;

procedure TfrmSetMsg.gDblClick(Sender: TObject);
begin
  frmTZMain.qryMem.Edit;
  frmTZMain.qryMem.FieldByName(SCheck2).AsBoolean:=not frmTZMain.qryMem.FieldByName(SCheck2).AsBoolean;
  frmTZMain.qryMem.Post;
end;

{ TsComboBox }

//procedure TsComboBox.CreateParams(var Params: TCreateParams);
//begin
//  inherited;
//  if Assigned(OnDrawItem) then
//    Params.Style := Params.Style or csOwnerDrawFixed;
//end;

end.
