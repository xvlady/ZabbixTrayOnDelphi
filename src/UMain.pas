unit UMain;

interface

uses
  UZT, EhLibMTE,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, acAlphaImageList,
  Vcl.ExtCtrls, Vcl.StdCtrls, sMemo, Vcl.Menus, Vcl.ComCtrls, sPageControl,
  sPanel, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, Data.DB, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh,
  sSkinProvider, sSkinManager, Vcl.AppEvnts, sHintManager, acAlphaHints,
  PropFilerEh, PropStorageEh;

type
  TfrmTZMain = class(TForm)
    trayIcon: TTrayIcon;
    mmoText: TsMemo;
    tmrZt: TTimer;
    pmTray: TPopupMenu;
    TS_Main: TsPageControl;
    tsTab: TsTabSheet;
    tsLog: TsTabSheet;
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
  private
    SysClose:integer;
    zt:TZt;
    FmaxError:Integer;

    ShowMain      :Integer;
    ShowBable     :Integer;
    procedure Start(const full:Boolean=True);
    procedure Stop(const full:Boolean=True);
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

implementation

uses system.json, DateUtils, shellapi, uOptions, System.IniFiles, uSetMSG;
{$R *.dfm}
resourcestring
  StrNotFondTriggerid = 'Not fond triggerid=';
  StrStartEditOptions = 'Start edit Options? (or exit)';
  StrNotFond = ' not fond!';
  StrD = 'd';
  StrH = 'h';
  StrM = 'm';


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

procedure TfrmTZMain.btnConnectClick(Sender: TObject);
  procedure mmoText_Lines_add(s:string);
  begin
    if TS_Main.ActivePage=tsLog
    then mmoText.Lines.add(s);
  end;
var
  jt,ja:TJSONArray;
  jo:TJSONObject;
  i,z:integer;
  iteration:TDateTime;
  s1,s2,s3:TStringList;
  maxError:Integer;
  insert:Boolean;
begin
  mmoText.Lines.Clear;
  maxError:=0;
  zt.Connected;
  if zt.connect then begin
    if statBar.Panels[2].Text=''
    then statBar.Panels[2].Text:='Zabbix '+zt.GetVersion;
    mmoText_Lines_add(zt.au);
    jt:=zt.GetTrigger as TJSONArray;
    mmoText_Lines_add(zt.errorlong);
    mmoText_Lines_add(zt.error);
    mmoText_Lines_add(zt.lastsender);
    mmoText_Lines_add(zt.lastResult);

    s1:=TStringList.Create;
    s1.Sorted:=True;
    s1.Duplicates:=dupIgnore;
    s2:=TStringList.Create;
    s2.Sorted:=True;
    s2.Duplicates:=dupIgnore;
    s3:=TStringList.Create;
    iteration:=Now;
    for i := 0 to jt.Count-1 do begin
      jo:=(jt.Items[i] as TJSONObject);
      //{"triggerid":"13590","description":"Free disk space is less than 20% on volume C:","priority":"1","lastchange":"1416839725","comments":"","error":"","hostname":"xBig","host":"xBig","hostid":"10105"}
      insert:= not qryMem.Locate(STriggerId,jo.GetValue(STriggerId).Value,[]);
      if not insert
      then qryMem.Edit
      else begin
        qryMem.Insert;
        qryMem.FieldByName(STriggerId).AsString:=jo.GetValue(STriggerId).Value;
      end;
      qryMem.FieldByName(SHost).AsString:=jo.GetValue(SHost).Value;
      qryMem.FieldByName(SDescription).AsString:=jo.GetValue(SDescription).Value;
      qryMem.FieldByName(SPriority).AsString:=jo.GetValue(SPriority).Value;
      qryMem.FieldByName('priorityT').AsString:=StatusT[qryMem.FieldByName(SPriority).AsInteger];
      qryMem.FieldByName(SLastchange).AsDateTime:=UnixToDateTime(StrToInt(jo.GetValue(SLastchange).Value),false);
      qryMem.FieldByName('T').AsString:=Time2String(qryMem.FieldByName(SLastchange).AsDateTime, iteration);
      qryMem.FieldByName(SComments).AsString:=jo.GetValue(SComments).Value;
      qryMem.FieldByName(SError).AsString:=jo.GetValue(SError).Value;
      qryMem.FieldByName(SHostId).AsString:=jo.GetValue(SHostId).Value;
      qryMem.FieldByName(SIteration).AsDateTime:=iteration;
      if maxError<qryMem.FieldByName(SPriority).AsInteger
      then maxError:=qryMem.FieldByName(SPriority).AsInteger;
      qryMem.Post;
      s1.Add(jo.GetValue(SHostId).Value);
      s2.Add(jo.GetValue(STriggerId).Value);
      if insert and (qryMem.FieldByName(SPriority).AsInteger>2) then begin
        s3.Add(qryMem.FieldByName(SHost).AsString+':'+qryMem.FieldByName('T').AsString);
        s3.Add(qryMem.FieldByName(SDescription).AsString);
        s3.Add('');
      end;
    end;
    jt.Free;
    qryMem.First;
    while not qryMem.eof do begin
      if qryMem.FieldByName(SIteration).AsDateTime<>iteration
      then begin
        s3.Add('Ok:'+qryMem.FieldByName(SHost).AsString+':'+qryMem.FieldByName('T').AsString);
        s3.Add(qryMem.FieldByName(SDescription).AsString);
        s3.Add('');
        qryMem.Delete
      end else qryMem.Next;
    end;
    if s2.Count>0 then begin
      jt:=TJSONArray.Create;
      for I := 0 to s2.Count-1 do
        jt.Add(s2[i]);
      ja:=zt.GetEvent(jt)as TJSONArray;
      //jt.Free;
      for i := 0 to ja.Count-1 do begin
        jo:=(ja.Items[i] as TJSONObject);
        if qryMem.Locate(STriggerId, jo.GetValue(SObjectId).Value,[]) then begin
          if (qryMem.FieldByName(SIteration).AsDateTime=iteration) {or (qryMem.FieldByName('user').AsString='')} then begin
            qryMem.Edit;
            qryMem.FieldByName(SIteration).AsDateTime:=iteration+1;
            qryMem.FieldByName(SEventID).AsString:=jo.GetValue(SEventID).Value;
            qryMem.FieldByName(SClock).AsDateTime:=UnixToDateTime(StrToInt(jo.GetValue(SClock).Value));
//            qryMem.FieldByName('message').AsString:=jo.GetValue('acknowledges').ToJSON;
            if (jo.GetValue(SAcknowledges) as TJSONArray).Count>0 then begin
              jo:=(jo.GetValue(SAcknowledges) as TJSONArray).items[0] as TJSONObject;
              qryMem.FieldByName(SUser).AsString:=jo.GetValue(SAlias).Value;
              qryMem.FieldByName(SClock).AsDateTime:=UnixToDateTime(StrToInt(jo.GetValue(SClock).Value),false);
              qryMem.FieldByName('ET').AsString:=Time2String(qryMem.FieldByName(SClock).AsDateTime, iteration);
              if qryMem.FieldByName(SMessage).AsString<>jo.GetValue(SMessage).Value then begin
                s3.Add(qryMem.FieldByName(SHost).AsString+':'+qryMem.FieldByName('T').AsString);
                s3.Add(qryMem.FieldByName(SDescription).AsString);
                s3.Add(qryMem.FieldByName(SUser).AsString+':'+jo.GetValue(SMessage).Value);
                s3.Add('');
              end;
              qryMem.FieldByName(SMessage).AsString:=jo.GetValue(SMessage).Value;
            end;
            qryMem.post;
          end;
        end else raise Exception.Create(StrNotFondTriggerid+jo.GetValue(STriggerId).Value);
      end;
      ja.Free;
      mmoText_Lines_add(zt.lastsender);
      mmoText_Lines_add(zt.lastResult);
//      zt.GetHost(jh.Clone as TJSONArray);
//      mmoText_Lines_add(zt.lastsender);
//      mmoText_Lines_add(zt.lastResult);
    end;
    trayIcon.balloonhint:=s3.text;
    if s3.text<>''
    then trayIcon.showballoonHint;
    s1.Free;
    s2.Free;
    s3.Free;
    if maxError=0 then maxError:=6;
  end else begin
    mmoText_Lines_add(zt.errorlong);
    mmoText_Lines_add(zt.error);
  end;
  if FmaxError<>maxError then begin
    ilTr.GetIcon(maxError, trayIcon.Icon);
    ilTr.GetIcon(maxError, Icon);
    i:=xwFindColumnEh(g.Columns,SPriority);
    if i=-1 then raise Exception.Create('FindColumn(Priority)=nil');
    g.Columns[i].Title.ImageIndex:=maxError;

    if (maxError>FmaxError) and (maxError in [3, 4, 5])
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
begin
  SysClose:=0;
  inifile:=Copy(ParamStr(0),1,length(ParamStr(0))-4)+'.ini';
  application.ShowMainForm:=false;
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

procedure TfrmTZMain.miZabbixClick(Sender: TObject);
begin
    shellapi.ShellExecute(Application.handle, 'open',
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
  Options       :Bool   ;
  EventData     :Bool   ;
  ShowStart     :Integer;
  Interval      :Integer;
  i:Integer;
begin
  FmaxError:=0;
  if full then begin
    URL:='';
    EventTemplates:=TStringList.create;
    ini := TIniFile.Create(frmTZMain.inifile);
    if fileexists(inifile) then
      try
        URL           :=ini.ReadString ('Main','URL'             ,''  );
        Login         :=ini.ReadString ('Main','Login'           ,''  );
        Pswd          :=ini.ReadString ('Main','PSWD'            ,''  );
        URLP          :=ini.ReadString ('Main','URLP'            ,''  );
        Options       :=ini.ReadBool   ('View','ShowMenuOptions' ,True);
        EventData     :=ini.ReadBool   ('View','ShowMenuSetMSG'  ,True);
        ShowStart     :=ini.ReadInteger('Alarm','ShowFormOnStart',2   );
        ShowMain      :=ini.ReadInteger('Alarm','ShowMainForm'   ,3   );
        ShowBable     :=ini.ReadInteger('Alarm','ShowPopupMSG'   ,1   );
        Interval      :=ini.ReadInteger('Main','Interval'        ,1   );
        ini.ReadSectionValues('EventTemplate',EventTemplates);
        for I := 0 to EventTemplates.Count-1 do
          EventTemplates[i]:=EventTemplates.ValueFromIndex[i];
      finally
        ini.Free;
      end
    else URL:='';

    if (URL='') or (Login='') or (Pswd='') then begin
      if Application.MessageBox(PChar(inifile+StrNotFond),
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

end.
