unit UMain;

interface

{$I DEFTEXT.inc}

uses
  UZT, EhLibMTE,
  {$IFDEF USE_DXGETTEXT}
    JvGnugettext, sCommonData,
  {$ENDIF USE_DXGETTEXT}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, acAlphaImageList,
  Vcl.ExtCtrls, Vcl.StdCtrls, sMemo, Vcl.Menus, Vcl.ComCtrls, sPageControl,
  sPanel, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, Data.DB, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh,
  sSkinProvider, sSkinManager, Vcl.AppEvnts,
  PropFilerEh, PropStorageEh;

type
  TfrmTZMain = class(TForm)
    trayIcon: TTrayIcon;
    mmoText: TsMemo;
    tmrZt: TTimer;
    pmTray: TPopupMenu;
    g: TDBGridEh;
    qryMem: TMemTableEh;
    dsMem: TDataSource;
    sSkinManager1: TsSkinManager;
    sSkinProvider1: TsSkinProvider;
    mmMain: TMainMenu;
    miExit: TMenuItem;
    miRefresh: TMenuItem;
    miRefreshPM: TMenuItem;
    miExitPM: TMenuItem;
    ilTrAni: TImageList;
    ApplicationEvents1: TApplicationEvents;
    miSep01: TMenuItem;
    miOpen: TMenuItem;
    statBar: TStatusBar;
    miZabbix: TMenuItem;
    miOptions: TMenuItem;
    pmG: TPopupMenu;
    miSetMSG: TMenuItem;
    RegPropStorageManEh1: TRegPropStorageManEh;
    PropStorageEh1: TPropStorageEh;
    ilTr: TImageList;
    miLang: TMenuItem;
    miShowLog: TMenuItem;
    procedure btnConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gGetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont;
      var Background: TColor; State: TGridDrawState);
    procedure miExitClick(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure trayIconDblClick(Sender: TObject);
    procedure ApplicationEvents1Restore(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure WMQueryEndSession (var Msg : TWMQueryEndSession); message WM_QueryEndSession;
    procedure miZabbixClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure miSetMSGClick(Sender: TObject);
    procedure qryMemAfterInsert(DataSet: TDataSet);
    procedure miLangClick(Sender: TObject);
    procedure miShowLogClick(Sender: TObject);
  private
    SysClose:integer;
    zt:TZt;
    FmaxError:Integer;

    ShowMain      :Integer;
    ShowBable     :Integer;
    procedure Start(const full:Boolean=True);
    procedure Stop(const full:Boolean=True);
    procedure mmoText_Lines_add(s: string);
  public
    inifile:string;
    EventTemplates:TStringList;
  end;

var
  frmTZMain: TfrmTZMain;

const
  SIteration = 'iteration';
  SUser = 'user';
  SCheck = 'Check';
  SCheck2 = 'Check2';
  SExtIni = '.ini';
  SLanguages = 'languages';
  SLangList = 'default';
  SProjLang = 'en';
  SShellExecuteOpen = 'open';
  SIniSectionMain = 'Main';
  SIniSectionView = 'View';
  SIniSectionAlarm = 'Alarm';
  SIniSectionEventTemplate = 'EventTemplate';
  SRegPathAutoRun = '\Software\Microsoft\Windows\CurrentVersion\Run';

implementation

uses system.json, DateUtils, shellapi, uOptions, System.IniFiles, uSetMSG
  {$IFDEF USE_DXGETTEXT}, languagecodes{$ENDIF};

{$R *.dfm}


resourcestring
  StrStartEditOptions = 'Start edit Options? (or exit)';
  StrNotFond = 'Not fond!';
  StrD = 'd';
  StrH = 'h';
  StrM = 'm';
  StrNoConnection = 'No Connection';

Function xwFindColumnEh(c:TDBGridColumnsEh;FieldName:String):integer;
var i:integer;
begin
  result:=-1;
  for i:=0 to c.Count-1 do
    if UpperCase(c[i].FieldName)=UpperCase(FieldName) then begin
      result:=i;
      break;
    end;
end;

function Time2String(const d1,d2:TDateTime):string;
var
  z:Integer;
begin
  z:=Trunc(DaySpan(d1, d2));
  if z>2 then
    Result:=IntToStr(z)+StrD
  else begin
    z:=Trunc(HourSpan(d1, d2));
    if z>4 then
      Result:=IntToStr(z)+StrH
    else begin
      z:=Trunc(MinuteSpan(d1, d2));
      Result:=IntToStr(z)+StrM
    end;
  end;
end;

procedure TfrmTZMain.mmoText_Lines_add(s:string);
begin
  if miShowLog.Checked
  then mmoText.Lines.add(s);
end;

procedure TfrmTZMain.btnConnectClick(Sender: TObject);
var
  maxError:Integer;

  procedure InsertRec(const ATriggerId:string; const AHost, ADescription, APriority:string;
                      const AIteration:TDateTime;
                      const ALastchange:TDateTime=0;
                      const AComments:string='';
                      const AError:string='';
                      const AHostId:string='');
  var
    insert:Boolean;
  begin
    insert:= not qryMem.Locate(STriggerId,ATriggerId,[]);
    if not insert then
      insert:=qryMem.FieldByName(SIteration).AsDateTime=AIteration;
    if insert
    then qryMem.Insert
    else qryMem.Edit;
    if insert
    then qryMem.FieldByName('step').AsInteger:=1
    else qryMem.FieldByName('step').AsInteger:=qryMem.FieldByName('step').AsInteger+1;
    qryMem.FieldByName(STriggerId).AsString:=ATriggerId;
    qryMem.FieldByName(SHost).AsString:=AHost;
    qryMem.FieldByName(SDescription).AsString:=ADescription;
    qryMem.FieldByName(SPriority).AsString:=APriority;
    qryMem.FieldByName('priorityT').AsString:=StatusT[qryMem.FieldByName(SPriority).AsInteger];
    if strtoint(ATriggerId)>0
    then qryMem.FieldByName(SLastchange).AsDateTime:=ALastchange
    else if insert
         then qryMem.FieldByName(SLastchange).AsDateTime:=AIteration;
    qryMem.FieldByName('T').AsString:=Time2String(qryMem.FieldByName(SLastchange).AsDateTime, AIteration);
    qryMem.FieldByName(SComments).AsString:=AComments;
    qryMem.FieldByName(SError).AsString:=AError;
    qryMem.FieldByName(SHostId).AsString:=AHostId;
    qryMem.FieldByName(SIteration).AsDateTime:=AIteration;
    if maxError<qryMem.FieldByName(SPriority).AsInteger
    then maxError:=qryMem.FieldByName(SPriority).AsInteger;
    qryMem.Post;
  end;
  procedure InsertError(const AError:string; const AIteration:TDateTime; ACode:string='0'); overload;
  begin
    mmoText_Lines_add(AError);
    InsertRec(ACode, zt.url, AError, '0', AIteration);
  end;
  procedure InsertError(const AError:string; const AIteration:TDateTime; ACode:integer);overload;
  begin
    InsertError(AError,AIteration,IntToStr(ACode));
  end;
var
  jt,ja:TJSONArray;
  jo:TJSONObject;
  i:integer;
  sListTriggerId,sBabbleHint:TStringList;
  iteration:TDateTime;

begin
  mmoText.Lines.Clear;
  maxError:=-1;
  iteration:=Now;
  try
    zt.Connected;
    mmoText_Lines_add(zt.au);
    if zt.connect then begin
      if statBar.Panels[2].Text=''
      then statBar.Panels[2].Text:='Zabbix '+zt.GetVersion;
    end;
  except
    on E: Exception do InsertError(E.Message,iteration);
  end;

  if zt.connect then begin
    try
      jt:=zt.GetTrigger as TJSONArray;
      try
        mmoText_Lines_add(zt.lastsender);
        mmoText_Lines_add(zt.lastResult);
        for i := 0 to jt.Count-1 do begin
          try
            jo:=(jt.Items[i] as TJSONObject);
            InsertRec(jo.GetValue(STriggerId).Value,
                      jo.GetValue(SHost).Value,
                      jo.GetValue(SDescription).Value,
                      jo.GetValue(SPriority).Value,
                      Iteration,
                      UnixToDateTime(StrToInt(jo.GetValue(SLastchange).Value),false),
                      jo.GetValue(SComments).Value,
                      jo.GetValue(SError).Value,
                      jo.GetValue(SHostId).Value);
          except
            on E: Exception do InsertError(E.Message,iteration,i);
          end;
        end;
      finally
        jt.Free;
      end;
    except
      on E: Exception do InsertError(E.Message,iteration);
    end;
  end else begin
    InsertError(StrNoConnection,iteration);
  end;

  trayIcon.balloonhint:='';
  sBabbleHint:=TStringList.Create;
  sListTriggerId:=TStringList.Create;
  try
    sListTriggerId.Sorted:=True;
    sListTriggerId.Duplicates:=dupIgnore;
    try
      qryMem.First;
      while not qryMem.eof do begin
        if qryMem.FieldByName(SIteration).AsDateTime<iteration
        then begin
          sBabbleHint.Add('Ok:'+qryMem.FieldByName(SHost).AsString+':'+qryMem.FieldByName('T').AsString);
          sBabbleHint.Add(qryMem.FieldByName(SDescription).AsString);
          sBabbleHint.Add('');
          qryMem.Delete;
        end else begin
          if (qryMem.FieldByName('step').AsInteger=1) and (qryMem.FieldByName(SPriority).AsInteger>=ShowBable) then begin
            sBabbleHint.Add(qryMem.FieldByName(SHost).AsString+':'+qryMem.FieldByName('T').AsString);
            sBabbleHint.Add(qryMem.FieldByName(SDescription).AsString);
            sBabbleHint.Add('');
          end;
          sListTriggerId.Add(qryMem.FieldByName(STriggerId).AsString);
          qryMem.Next;
        end;
      end;
    except
      on E: Exception do InsertError(E.Message,iteration,-1);
    end;

    if sListTriggerId.Count>0 then begin
      try
        ja:=zt.GetEvent(TJSONArrayCreate(sListTriggerId)) as TJSONArray;
        mmoText_Lines_add(zt.lastsender);
        mmoText_Lines_add(zt.lastResult);
        try
          for i := 0 to ja.Count-1 do begin
            try
              jo:=(ja.Items[i] as TJSONObject);
              if qryMem.Locate(STriggerId, jo.GetValue(SObjectId).Value,[]) then begin
                if (qryMem.FieldByName(SEventID).AsString='') then begin
                  qryMem.Edit;
                  qryMem.FieldByName(SEventID).AsString:=jo.GetValue(SEventID).Value;
                  qryMem.FieldByName(SClock).AsDateTime:=UnixToDateTime(StrToInt(jo.GetValue(SClock).Value),false);
                  if (jo.GetValue(SAcknowledges) as TJSONArray).Count>0 then begin
                    jo:=(jo.GetValue(SAcknowledges) as TJSONArray).items[0] as TJSONObject;
                    qryMem.FieldByName(SUser).AsString:=jo.GetValue(SAlias).Value;
                    qryMem.FieldByName(SClock).AsDateTime:=UnixToDateTime(StrToInt(jo.GetValue(SClock).Value),false);//Ёто врем€ текста, выше - другое врем€
                    qryMem.FieldByName('ET').AsString:=Time2String(qryMem.FieldByName(SClock).AsDateTime, iteration);
                    if qryMem.FieldByName(SMessage).AsString<>jo.GetValue(SMessage).Value then begin
                      sBabbleHint.Add(qryMem.FieldByName(SHost).AsString+':'+qryMem.FieldByName('T').AsString);
                      sBabbleHint.Add(qryMem.FieldByName(SDescription).AsString);
                      sBabbleHint.Add(qryMem.FieldByName(SUser).AsString+':'+jo.GetValue(SMessage).Value);
                      sBabbleHint.Add('');
                    end;
                    qryMem.FieldByName(SMessage).AsString:=jo.GetValue(SMessage).Value;
                  end;
                  qryMem.post;
                end;
              end else raise Exception.Create(StrNotFond+' Triggerid='+jo.GetValue(STriggerId).Value);
            except
              on E: Exception do InsertError(E.Message,iteration,-i);
            end;
          end;
        finally
          ja.Free;
        end;
      except
        on E: Exception do InsertError(E.Message,iteration,-2);
      end;
    end;
    trayIcon.balloonhint:=sBabbleHint.text;
  finally
    sBabbleHint.Free;
    sListTriggerId.Free;
  end;

  if trayIcon.balloonhint<>''
  then trayIcon.showballoonHint;

  if maxError=-1 then maxError:=6;


  if FmaxError<>maxError then begin
    trayIcon.Visible:=False;
    ilTr.GetIcon(maxError, trayIcon.Icon);
    trayIcon.Visible:=True;
    ilTr.GetIcon(maxError, Icon);
    ilTr.GetIcon(maxError, Application.Icon);

    i:=xwFindColumnEh(g.Columns,SPriority);
    if i=-1 then raise Exception.Create('FindColumn(Priority)=nil');
    g.Columns[i].Title.ImageIndex:=maxError;

    if (maxError>FmaxError) and (maxError<>6) and (maxError >=ShowMain)
    then miOpenClick(self);
    FmaxError:=maxError;
  end;
end;


procedure TfrmTZMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if SysClose=0 then begin
    CanClose:=false;
    Application.Minimize;
  end else CanClose:=True;
end;

procedure TfrmTZMain.FormCreate(Sender: TObject);
var
  s:TStringList;
  x:TMenuItem;
  i:Integer;
begin
  SysClose:=0;
  inifile:=Copy(ParamStr(0),1,length(ParamStr(0))-4)+SExtIni;
  application.ShowMainForm:=false;

  {$IFDEF USE_DXGETTEXT}
  DefaultInstance.Bindtextdomain(ExtractFilePath(ParamStr(0)),SLanguages);
  s:=TStringList.Create;
  try
    ///don't tranclete
    DefaultInstance.GetListOfLanguages (SLangList,s);
    s.Insert(0,SProjLang);
    for i:=0 to s.Count-1 do begin
      x:=TMenuItem.Create(Self);
      x.Hint:=s[i];
      x.Caption:=dgettext(SLanguages,languagecodes.getlanguagename(s[i]));
      x.OnClick:=miLangClick;
      x.RadioItem:=True;
      x.GroupIndex:=1;
      if languagecodes.getlanguagename(DefaultInstance.GetCurrentLanguage)=languagecodes.getlanguagename(s[i])
      then x.Checked:=True;
      miLang.Add(x);
    end;
    miLang.OnClick:=nil;
  finally
    s.Free;
  end;
  TranslateComponent(self);
//  // Convert the language names to an English language name using isotolanguagenames.mo
//  DefaultInstance.TranslateProperties (s,'isotolanguagenames');
//  DefaultInstance.BindtextdomainToFile ('isotolanguagenames',extractfilepath(paramstr(0))+'isotolanguagenames.mo');
  {$ELSE}
    miLang.Free;
  {$ENDIF}
  AfterLoc;

  Start;
end;

procedure TfrmTZMain.FormDestroy(Sender: TObject);
begin
  stop;
end;

procedure TfrmTZMain.gGetCellParams(Sender: TObject; Column: TColumnEh;
  AFont: TFont; var Background: TColor; State: TGridDrawState);
var
  i:Integer;
begin
  Background:=StatusC[qryMem.FieldByName(SPriority).AsInteger];
  if Length(qryMem.FieldByName(SMessage).AsString)>0 then begin
    AFont.Style:=[fsBold];
    AFont.Color:=EventMsgC[High(EventMsgC)];
    for I := Low(EventMsgK) to High(EventMsgK) do
      if copy(qryMem.FieldByName(SMessage).AsString,1,1)=EventMsgK[i]
      then AFont.Color:=EventMsgC[i];
  end else begin
    AFont.Color:=clBlack;
    AFont.Style:=[];
  end;
end;

procedure TfrmTZMain.miExitClick(Sender: TObject);
begin
  SysClose:=2;
  Close;
end;

procedure TfrmTZMain.miLangClick(Sender: TObject);
begin
  mmoText_Lines_add(DefaultInstance.GetCurrentLanguage+'=>'+_('Log'));
  UseLanguage((Sender as TMenuItem).hint);
  mmoText_Lines_add('=>'+DefaultInstance.GetCurrentLanguage+' '+self.Name+' '+_('Log'));
  ReTranslateComponent(self);
  (Sender as TMenuItem).Checked:=True;
  AfterLoc;
  btnConnectClick(Self);
//  qryMem.First;
//  while not qryMem.eof do begin
//    qryMem.edit;
//    qryMem.FieldByName('priorityT').AsString:=StatusT[qryMem.FieldByName(SPriority).AsInteger];
//    qryMem.post;
//    qryMem.Next;
//  end;
end;

procedure TfrmTZMain.miOpenClick(Sender: TObject);
begin
  show(); //делает форму видимой
  application.Restore;
  setForegroundWindow(handle); //выдвигает окно на первый план
end;

procedure TfrmTZMain.miOptionsClick(Sender: TObject);
var
  frmOptions: TfrmOptions;
begin
  frmOptions:= TfrmOptions.create(self);
  try
    Stop;
    Self.Hide;
    frmOptions.ShowModal;
  finally
    Self.Show;
    frmOptions.free;
    Start;
  end;
end;

procedure TfrmTZMain.miSetMSGClick(Sender: TObject);
var
  frmSetMsg: TfrmSetMsg;
  jo:TJSONArray;
  bm:TBookmark;
  i:Integer;
  procedure check(const Value:Boolean=True);
  begin
    qryMem.Edit;
    qryMem.FieldByName(SCheck).AsBoolean:=Value;
    qryMem.FieldByName(SCheck2).AsBoolean:=Value;
    qryMem.Post;
  end;
begin
  Stop(False);
  bm :=  qryMem.Bookmark;
  frmSetMsg:= TfrmSetMsg.create(self);
  try
    try
      qryMem.DisableControls;
//      qryMem.First;
//      while not qryMem.Eof do begin
//        check(False);
//        qryMem.Next;
//      end;
      if g.SelectedRows.Count>0 then
        for i := 0 to g.SelectedRows.Count - 1 do begin
          g.DataSource.DataSet.GotoBookmark(Pointer(g.SelectedRows.Items[i]));
          check;
        end
      else check;
    finally
      qryMem.EnableControls;
    end;
    qryMem.Filter:=SCheck+'=True';
    qryMem.Filtered:=True;
    if frmSetMsg.ShowModal=1 then begin
      jo:=TJSONArray.create;
      try
        try
          qryMem.DisableControls;
          qryMem.First;
          while not qryMem.Eof do begin
            if qryMem.FieldByName(SCheck2).AsBoolean
            then jo.Add(qryMem.FieldByName(SEventID).AsString);
            if qryMem.FieldByName(SCheck).AsBoolean
            then check(False) //Filtered:=True
            else qryMem.Next;
          end;
        finally
          qryMem.EnableControls;
        end;
        if frmSetMsg.cbbAddEventType.ItemIndex<>High(EventMsgT)
        then frmSetMsg.cbbMSG.Text:=EventMsgK[frmSetMsg.cbbAddEventType.ItemIndex]+' '+frmSetMsg.cbbMSG.Text;
        zt.SetEventMSG(jo.Clone as TJSONArray,frmSetMsg.cbbMSG.Text)
      finally
        jo.Free;
      end;
    end;
  finally
    qryMem.Filtered:=false;
    frmSetMsg.Free;
    Start(False);
  end;
  qryMem.Bookmark := bm;
end;

procedure TfrmTZMain.miShowLogClick(Sender: TObject);
begin
  miShowLog.Checked:=not miShowLog.Checked;
  mmoText.Visible:=miShowLog.Checked;
  if miShowLog.Checked then btnConnectClick(Sender);
end;

procedure TfrmTZMain.miZabbixClick(Sender: TObject);
begin
    shellapi.ShellExecute(Application.handle, SShellExecuteOpen,
               PChar(zt.URLu),
               nil,
               nil, SW_SHOWNORMAL);

end;

procedure TfrmTZMain.qryMemAfterInsert(DataSet: TDataSet);
begin
  qryMem.FieldByName(SCheck).AsBoolean:=false;
end;

procedure TfrmTZMain.Start(const full:Boolean=True);
var
  ini : TIniFile;
  URL           :String ;
  Login         :String ;
  Pswd          :String ;
  URLP          :String ;
  Options       :Boolean;
  EventData     :Boolean;
  ShowStart     :Integer;
  Interval      :Integer;
  lang          :string;
  i:Integer;
begin
  FmaxError:=0;
  ShowStart:=2;
  if full then begin
    URL:='';
    Options:=True;
    EventData:=True;
    Interval:=1;
    EventTemplates:=TStringList.create;
    ini := TIniFile.Create(frmTZMain.inifile);
    if fileexists(inifile) then
      try
        URL           :=ini.ReadString (SIniSectionMain ,'URL'             ,''  );
        Login         :=ini.ReadString (SIniSectionMain ,'Login'           ,''  );
        Pswd          :=ini.ReadString (SIniSectionMain ,'PSWD'            ,''  );
        URLP          :=ini.ReadString (SIniSectionMain ,'URLP'            ,''  );
        Options       :=ini.ReadBool   (SIniSectionView ,'ShowMenuOptions' ,True);
        EventData     :=ini.ReadBool   (SIniSectionView ,'ShowMenuSetMSG'  ,True);
        Lang          :=ini.ReadString (SIniSectionView ,'Lang'            ,''  );
        ShowStart     :=ini.ReadInteger(SIniSectionAlarm,'ShowFormOnStart',2   );
        ShowMain      :=ini.ReadInteger(SIniSectionAlarm,'ShowMainForm'   ,3   );
        ShowBable     :=ini.ReadInteger(SIniSectionAlarm,'ShowPopupMSG'   ,1   );
        Interval      :=ini.ReadInteger(SIniSectionMain ,'Interval'        ,1   );
        ini.ReadSectionValues(SIniSectionEventTemplate,EventTemplates);
        for I := 0 to EventTemplates.Count-1 do
          EventTemplates[i]:=EventTemplates.ValueFromIndex[i];
      finally
        ini.Free;
      end
    else URL:='';

    if (URL='') or (Login='') or (Pswd='') then begin
      if Application.MessageBox(PChar(inifile+' '+StrNotFond),
        PChar(StrStartEditOptions), MB_OKCANCEL + MB_ICONQUESTION + MB_TOPMOST)=idOk
      then miOptionsClick(nil)
      else begin
        SysClose:=3;
        TrayIcon.Visible:=True;
        close;
        Application.Terminate;
      end;
      exit
    end;

    //'alefezt','alefezt','http://192.168.0.3/zabbix/'
    zt:=TZt.Create(login,pswd,URL);
    zt.url_up:=URLP;
    statBar.Panels[0].Text:=zt.login;
    statBar.Panels[1].Text:=zt.URL;
    miOptions.Visible:=Options;
    miSetMSG.Visible:=EventData;
    tmrZt.Interval:=Interval*60000;

    {$IFDEF USE_DXGETTEXT}
    if Lang <> '' then begin
      UseLanguage(Lang);
      ReTranslateComponent(self);
    end;
    {$ENDIF USE_DXGETTEXT}

//  i:=xwFindColumnEh(g.Columns,SPriority);
//  if i=-1 then raise Exception.Create('FindColumn(Priority)=nil');
//  with g.Columns[i] do begin
//    picklist.clear;
//    keylist.clear;
//    for i := Low(StatusT) to High(StatusT) do begin
//      picklist.Add(StatusT[i]);
//      keylist.add(inttostr(i));
//    end;
//  end;
  end;

  btnConnectClick(nil);
  tmrZt.Enabled:=True;
  TrayIcon.Visible:=True;
  if full then begin
    if (FmaxError <>6) and (FmaxError>=ShowStart)
    then miOpenClick(self);
  end;
end;

procedure TfrmTZMain.Stop(const full:Boolean=True);
begin
//  EventTemplates.clear;
  tmrZt.Enabled:=False;
  TrayIcon.Visible:=false;
  if full then EventTemplates.free;
  if full then zt.free;
end;

procedure TfrmTZMain.trayIconDblClick(Sender: TObject);
begin
  show(); //делает форму видимой
  application.Restore;
  setForegroundWindow(handle); //выдвигает окно на первый план
end;

procedure TfrmTZMain.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  SysClose:=1;
  Close;
  Msg.Result := 1; //ћожно закрывать
end;

procedure TfrmTZMain.ApplicationEvents1Minimize(Sender: TObject);
begin
//”бираем с панели задач
  TrayIcon.Visible:=true;
  Hide;
end;

procedure TfrmTZMain.ApplicationEvents1Restore(Sender: TObject);
begin
  show(); //делает форму видимой
end;

{$IFDEF USE_DXGETTEXT}
initialization
  //TP_GlobalIgnoreClassProperty(TAction,'Category');
  TP_GlobalIgnoreClassProperty(TControl,'ImeName');
  TP_GlobalIgnoreClassProperty(TControl,'HelpKeyword');
  TP_GlobalIgnoreClass(TMonthCalendar);
  TP_GlobalIgnoreClass(TStatusBar);

  TP_IgnoreClassProperty(TMenuItem,'Hint');

  TP_GlobalIgnoreClassProperty(TControl,'ImeName');
  TP_GlobalIgnoreClassProperty(TControl,'HelpKeyword');
  TP_GlobalIgnoreClass(TFont);

  TP_GlobalIgnoreClass(TsCtrlSkinData);
  TP_GlobalIgnoreClass(TsSkinManager);
  TP_GlobalIgnoreClass(TsSkinProvider);

  TP_GlobalIgnoreClass(TPropStorageEh);
  TP_GlobalIgnoreClass(TPropWriterEh);
  TP_GlobalIgnoreClass(TPropStorageManagerEh);
  TP_GlobalIgnoreClassProperty(TColumnEh,'FieldName');
  TP_GlobalIgnoreClass(TMemTableEh);


  TP_GlobalIgnoreClassProperty(TMTDataFieldEh,'DefaultExpression');
  TP_GlobalIgnoreClassProperty(TMTDataFieldEh,'Name');
  TP_GlobalIgnoreClassProperty(TMTDataFieldEh,'FieldName');
  TP_GlobalIgnoreClassProperty(TMTNumericDataFieldEh,'DisplayFormat');
  TP_GlobalIgnoreClassProperty(TMTNumericDataFieldEh,'EditFormat');

  TP_GlobalIgnoreClassProperty(TField,'DefaultExpression');
  TP_GlobalIgnoreClassProperty(TField,'Name');
  TP_GlobalIgnoreClassProperty(TField,'FieldName');
  TP_GlobalIgnoreClassProperty(TField,'KeyFields');
  TP_GlobalIgnoreClassProperty(TField,'DisplayName');
  TP_GlobalIgnoreClassProperty(TField,'LookupKeyFields');
  TP_GlobalIgnoreClassProperty(TField,'LookupResultField');
  TP_GlobalIgnoreClassProperty(TField,'Origin');
  TP_GlobalIgnoreClass(TParam);
  TP_GlobalIgnoreClassProperty(TFieldDef,'Name');
  TP_GlobalIgnoreClassProperty(TDataset,'Filter');

//  TP_GlobalIgnoreClassProperty(TADOQuery,'CommandText');
//  TP_GlobalIgnoreClassProperty(TADOQuery,'ConnectionString');
//  TP_GlobalIgnoreClassProperty(TADOQuery,'DatasetField');
//  TP_GlobalIgnoreClassProperty(TADOQuery,'Filter');
//  TP_GlobalIgnoreClassProperty(TADOQuery,'IndexFieldNames');
//  TP_GlobalIgnoreClassProperty(TADOQuery,'IndexName');
//  TP_GlobalIgnoreClassProperty(TADOQuery,'MasterFields');
//  TP_GlobalIgnoreClassProperty(TADOTable,'IndexFieldNames');
//  TP_GlobalIgnoreClassProperty(TADOTable,'IndexName');
//  TP_GlobalIgnoreClassProperty(TADOTable,'MasterFields');
//  TP_GlobalIgnoreClassProperty(TADOTable,'TableName');
//  TP_GlobalIgnoreClassProperty(TDataset,'CommandText');
//  TP_GlobalIgnoreClassProperty(TDataset,'ConnectionString');
//  TP_GlobalIgnoreClassProperty(TDataset,'DatasetField');
//  TP_GlobalIgnoreClassProperty(TDataset,'IndexFieldNames');
//  TP_GlobalIgnoreClassProperty(TDataset,'IndexName');
//  TP_GlobalIgnoreClassProperty(TDataset,'MasterFields');
  AddDomainForResourceString('delphi');
{$ENDIF USE_DXGETTEXT}


end.
