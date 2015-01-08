unit UOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sCheckBox, sSkinProvider,
  sEdit, sComboBox, sButton, Vcl.ExtCtrls, sPanel, Vcl.ComCtrls, sComboBoxes,
  sMemo;

type
  TfrmOptions = class(TForm)
    sSkinProvider1: TsSkinProvider;
    edtURL: TsEdit;
    edtLogin: TsEdit;
    edtPswd: TsEdit;
    chkOptions: TsCheckBox;
    chkEventData: TsCheckBox;
    cbbShowMain: TsComboBox;
    pnlEditOk: TsPanel;
    btnOk: TsButton;
    btnCancel: TsButton;
    edtURLP: TsEdit;
    cbbShowBable: TsComboBox;
    cbbShowStart: TsComboBox;
    mmoTempl: TsMemo;
    procedure FormCreate(Sender: TObject);
    procedure cbbShowMainDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses uzt, System.IniFiles, umain;

procedure TfrmOptions.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmOptions.btnOkClick(Sender: TObject);
var
  ini : TIniFile;
  i:Integer;
begin
  ini := TIniFile.Create(frmTZMain.inifile);
  try
    ini.WriteString ('Main','URL'             ,edtURL.Text           );
    ini.WriteString ('Main','Login'           ,edtLogin.Text         );
    ini.WriteString ('Main','PSWD'            ,edtPswd.Text          );
    ini.WriteString ('Main','URLP'            ,edtURLP.Text          );
    ini.WriteBool   ('View','ShowMenuOptions' ,chkOptions.Checked    );
    ini.WriteBool   ('View','ShowMenuSetMSG'  ,chkEventData.Checked  );
    ini.WriteInteger('Alarm','ShowFormOnStart',cbbShowStart.ItemIndex);
    ini.WriteInteger('Alarm','ShowMainForm'   ,cbbShowMain.ItemIndex );
    ini.WriteInteger('Alarm','ShowPopupMSG'   ,cbbShowBable.ItemIndex);
    ini.EraseSection('EventTemplate');
    for i := 0 to mmoTempl.Lines.Count-1 do
      ini.WriteString('EventTemplate','T'+IntToStr(i),mmoTempl.Lines[i]);
  finally
    ini.Free;
  end;
  ModalResult:=IDOK;
end;

procedure TfrmOptions.cbbShowMainDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with Control as TsComboBox do begin
    Canvas.Brush.Color := StatusC[Index] ;
    Canvas.FillRect(Rect) ;
    Canvas.TextOut(Rect.Left, Rect.Top, Items[Index]);
  end;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
var
  i:Integer;
  ini : TIniFile;
begin
  for i := 0 to 5 do
    cbbShowMain.Items.Add(StatusT[i]);
  for i := 0 to 5 do
    cbbShowBable.Items.Add(StatusT[i]);
  for i := 0 to 5 do
    cbbShowStart.Items.Add(StatusT[i]);
  ini := TIniFile.Create(frmTZMain.inifile);
  try
    edtURL.Text           :=ini.ReadString ('Main','URL'             ,''  );
    edtLogin.Text         :=ini.ReadString ('Main','Login'           ,''  );
    edtPswd.Text          :=ini.ReadString ('Main','PSWD'            ,''  );
    edtURLP.Text          :=ini.ReadString ('Main','URLP'            ,''  );
    chkOptions.Checked    :=ini.ReadBool   ('View','ShowMenuOptions' ,True);
    chkEventData.Checked  :=ini.ReadBool   ('View','ShowMenuSetMSG'  ,True);
    cbbShowStart.ItemIndex:=ini.ReadInteger('Alarm','ShowFormOnStart',2   );
    cbbShowMain.ItemIndex :=ini.ReadInteger('Alarm','ShowMainForm'   ,3   );
    cbbShowBable.ItemIndex:=ini.ReadInteger('Alarm','ShowPopupMSG'   ,1   );
    ini.ReadSectionValues('EventTemplate',mmoTempl.Lines);
    for I := 0 to mmoTempl.Lines.Count-1 do
      mmoTempl.Lines[i]:=mmoTempl.Lines.ValueFromIndex[i];
    if mmoTempl.Lines.Count=0 then
      mmoTempl.Lines.Text   :=
        '! Call me'+#13#10+
        '- Don''t porblem'+#13#10+
        '* I do this task'+#13#10+
        '? Wait next events'+#13#10+
        'Ok';
  finally
    ini.Free;
  end;
end;

end.
