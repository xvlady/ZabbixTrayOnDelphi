unit UOptions;

interface

{$I DEFTEXT.inc}

uses
  Vcl.Forms, windows, sysutils,
  sSpinEdit, sSkinProvider, Vcl.StdCtrls, sMemo, sButton, Vcl.Controls,
  Vcl.ExtCtrls, sPanel, sComboBox, sCheckBox, System.Classes, sEdit;

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

uses uzt, System.IniFiles, umain, Registry {$IFDEF USE_DXGETTEXT},JvGnugettext {$ENDIF USE_DXGETTEXT};

resourcestring
  StrDontOpenRegistry = 'Don''t Open Registry Key ';
  StrCallMe = 'Call me';
  StrThisIsNoProblem = 'This is no problem';
  StrIDoThisTask = 'I do this task';
  StrWaitNextEvents = 'Wait next events';
  StrOk = 'Ok';

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
      if reg.OpenKey(SRegPathAutoRun,True)
      then reg.writeString('ZabbixTray',ParamStr(0))
      else raise Exception.Create(StrDontOpenRegistry+SRegPathAutoRun);
      reg.closekey();
    finally
      reg.Free;
    end;
  end else begin
    try
      reg := TRegistry.Create(KEY_READ);
      try
        reg.RootKey := HKEY_CURRENT_USER;
        reg.OpenKeyReadOnly(SRegPathAutoRun);
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
        if reg.OpenKey(SRegPathAutoRun,false) then
          reg.DeleteValue('ZabbixTray');
        reg.closekey();
      finally
        reg.Free;
      end;
    end;
  end;


  ini := TIniFile.Create(frmTZMain.inifile);
  try
    ini.WriteString (SIniSectionMain ,'URL'             ,edtURL.Text           );
    ini.WriteString (SIniSectionMain ,'Login'           ,edtLogin.Text         );
    ini.WriteString (SIniSectionMain ,'PSWD'            ,edtPswd.Text          );
    ini.WriteString (SIniSectionMain ,'URLP'            ,edtURLP.Text          );
    ini.WriteBool   (SIniSectionView ,'ShowMenuOptions' ,chkOptions.Checked    );
    ini.WriteBool   (SIniSectionView ,'ShowMenuSetMSG'  ,chkEventData.Checked  );
//    ini.WriteString (SIniSectionView 'Main' ,'Lang'           ,chkLang.text    );{ TODO -oxvv -c : options add Lang 14.01.2015 15:44:13 }
    ini.WriteInteger(SIniSectionAlarm,'ShowFormOnStart',cbbShowStart.ItemIndex);
    ini.WriteInteger(SIniSectionAlarm,'ShowMainForm'   ,cbbShowMain.ItemIndex );
    ini.WriteInteger(SIniSectionAlarm,'ShowPopupMSG'   ,cbbShowBable.ItemIndex);
    ini.WriteInteger(SIniSectionMain ,'Interval'        ,edtInterval.Value     );
    ini.WriteBool   (SIniSectionMain ,'Autorun'         ,chkAutorun.Checked    );
    ini.EraseSection(SIniSectionEventTemplate);
    for i := 0 to mmoTempl.Lines.Count-1 do
      ini.WriteString(SIniSectionEventTemplate,'T'+IntToStr(i),mmoTempl.Lines[i]);
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
    edtURL.Text           :=ini.ReadString (SIniSectionMain ,'URL'             ,''  );
    edtLogin.Text         :=ini.ReadString (SIniSectionMain ,'Login'           ,''  );
    edtPswd.Text          :=ini.ReadString (SIniSectionMain ,'PSWD'            ,''  );
    edtURLP.Text          :=ini.ReadString (SIniSectionMain ,'URLP'            ,''  );
    chkOptions.Checked    :=ini.ReadBool   (SIniSectionView ,'ShowMenuOptions' ,True);
    chkEventData.Checked  :=ini.ReadBool   (SIniSectionView ,'ShowMenuSetMSG'  ,True);
//                                            SIniSectionView
    cbbShowStart.ItemIndex:=ini.ReadInteger(SIniSectionAlarm,'ShowFormOnStart' ,2   );
    cbbShowMain.ItemIndex :=ini.ReadInteger(SIniSectionAlarm,'ShowMainForm'    ,3   );
    cbbShowBable.ItemIndex:=ini.ReadInteger(SIniSectionAlarm,'ShowPopupMSG'    ,1   );
    edtInterval.Value     :=ini.ReadInteger(SIniSectionMain ,'Interval'        ,1   );
    chkAutorun.Checked    :=ini.ReadBool   (SIniSectionMain ,'Autorun'         ,True);
    ini.ReadSectionValues(SIniSectionEventTemplate,mmoTempl.Lines);
    for I := 0 to mmoTempl.Lines.Count-1 do
      mmoTempl.Lines[i]:=mmoTempl.Lines.ValueFromIndex[i];
    if mmoTempl.Lines.Count=0 then
      mmoTempl.Lines.Text   :=
        '! '+StrCallMe+#13#10+
        '- '+StrThisIsNoProblem+#13#10+
        '* '+StrIDoThisTask+#13#10+
        '? '+StrWaitNextEvents+#13#10+
        StrOk;
    if chkAutorun.Checked then begin
      try
        reg := TRegistry.Create(KEY_READ);
        try
          reg.RootKey := HKEY_CURRENT_USER;
          reg.OpenKeyReadOnly(SRegPathAutoRun);
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
  TranslateComponent(self);
end;

end.
