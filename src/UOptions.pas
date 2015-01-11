unit UOptions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sCheckBox, sSkinProvider,
  sEdit, sComboBox, sButton, Vcl.ExtCtrls, sPanel, Vcl.ComCtrls, sComboBoxes,
  sMemo, sSpinEdit;

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
    chkAutorun: TsCheckBox;
    edtInterval: TsSpinEdit;
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

uses uzt, System.IniFiles, umain, Registry;

procedure TfrmOptions.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmOptions.btnOkClick(Sender: TObject);
var
  ini : TIniFile;
  i:Integer;
  reg :TRegistry;
begin
  if chkAutorun.Checked then begin
    reg := TRegistry.Create();
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run',True)
      then reg.writeString('ZabbixTray',ParamStr(0))
      else raise Exception.Create('Don''t Open Key \Software\Microsoft\Windows\CurrentVersion\Run');
      reg.closekey();
    finally
      reg.Free;
    end;
  end else begin
    try
      reg := TRegistry.Create(KEY_READ);
      try
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion\Run');
        if reg.ReadString('ZabbixTray')='' then chkAutorun.Checked:=False;
        reg.closekey();
      finally
        reg.Free;
      end;
    except
      chkAutorun.Checked:=False;
    end;
    if chkAutorun.Checked then begin
      reg := TRegistry.Create();
      try
        reg.RootKey := HKEY_CURRENT_USER;
        if reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run',false) then
          reg.DeleteValue('ZabbixTray');
        reg.closekey();
      finally
        reg.Free;
      end;
    end;
  end;


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
    ini.WriteInteger('Main','Interval'        ,edtInterval.Value     );
    ini.WriteBool   ('Main','Autorun'         ,chkAutorun.Checked    );
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
  reg:TRegistry;
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
    edtInterval.Value     :=ini.ReadInteger('Main','Interval'        ,1   );
    chkAutorun.Checked    :=ini.ReadBool   ('Main','Autorun'         ,True);
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
    if chkAutorun.Checked then begin
      try
        reg := TRegistry.Create(KEY_READ);
        try
          reg.RootKey := HKEY_CURRENT_USER;
          reg.OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion\Run');
          if reg.ReadString('ZabbixTray')='' then chkAutorun.Checked:=False;
          reg.closekey();
        finally
          reg.Free;
        end;
      except
        chkAutorun.Checked:=False;
      end;
      if not chkAutorun.Checked then
        chkAutorun.State:=cbGrayed;
//        chkAutorun.AllowGrayed
    end;
  finally
    ini.Free;
  end;
end;

end.
