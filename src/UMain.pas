unit UMain;

interface

uses
  UZT, EhLibMTE,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, acAlphaImageList,
  Vcl.ExtCtrls, Vcl.StdCtrls, sMemo, Vcl.Menus, Vcl.ComCtrls, sPageControl,
  sPanel, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, Data.DB, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh,
  sSkinProvider, sSkinManager, Vcl.AppEvnts, sHintManager, acAlphaHints;

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
    ilTr: TsAlphaImageList;
    miZabbix: TMenuItem;
    procedure btnConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gGetCellParams(Sender: TObject; Column: TColumnEh; AFont: TFont;
      var Background: TColor; State: TGridDrawState);
    procedure miExitClick(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure trayIconClick(Sender: TObject);
    procedure trayIconDblClick(Sender: TObject);
    procedure trayIconBalloonClick(Sender: TObject);
    procedure ApplicationEvents1Restore(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure WMQueryEndSession (var Msg : TWMQueryEndSession); message WM_QueryEndSession;
    procedure miZabbixClick(Sender: TObject);
  private
    SysClose:integer;
    zt:TZt;
    FmaxError:Integer;
  public
    { Public declarations }
  end;

var
  frmTZMain: TfrmTZMain;

implementation

uses system.json, DateUtils, shellapi;
{$R *.dfm}
resourcestring
  StrNotFondTriggerid = 'Not fond triggerid=';

const
  SIteration = 'iteration';
  SUser = 'user';

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
      z:=Trunc(DaySpan(qryMem.FieldByName(SLastchange).AsDateTime, iteration));
      if z>2
      then qryMem.FieldByName('T').AsString:=IntToStr(z)+'d'
      else begin
        z:=Trunc(HourSpan(qryMem.FieldByName(SLastchange).AsDateTime, iteration));
        if z>4
        then qryMem.FieldByName('T').AsString:=IntToStr(z)+'h'
        else begin
          z:=Trunc(MinuteSpan(qryMem.FieldByName(SLastchange).AsDateTime, iteration));
          qryMem.FieldByName('T').AsString:=IntToStr(z)+'m'
        end;
      end;
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
              qryMem.FieldByName(SClock).AsDateTime:=UnixToDateTime(StrToInt(jo.GetValue(SClock).Value));
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
var
  ini:TStringList;
  s:string;
//  i:integer;
begin
  FmaxError:=0;

  s:=Copy(ParamStr(0),1,length(ParamStr(0))-4)+'.ini';
  if not fileexists(s)
  then begin
    SysClose:=3;
    raise Exception.Create(s+' not fond!');
  end;
  ini:=TStringList.create;
  try
    ini.LoadFromFile(s);
    //'alefezt','alefezt','http://192.168.0.3/zabbix/'
    zt:=TZt.Create(ini.Values['login'],ini.Values['pswd'],ini.Values['URL']);
    zt.url_up:=ini.Values['URLP'];
  finally
    ini.Free;
  end;
  statBar.Panels[0].Text:=zt.login;
  statBar.Panels[1].Text:=zt.URL;
  SysClose:=0;
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
  btnConnectClick(Sender);
  tmrZt.Enabled:=True;
  application.ShowMainForm:=false;
  TrayIcon.Visible:=True;
  if not (FmaxError in [0,1,6])
  then miOpenClick(self);
end;

procedure TfrmTZMain.FormDestroy(Sender: TObject);
begin
  zt.free;
end;

procedure TfrmTZMain.gGetCellParams(Sender: TObject; Column: TColumnEh;
  AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  Background:=StatusC[qryMem.FieldByName(SPriority).AsInteger];
  if Length(qryMem.FieldByName(SMessage).AsString)>0 then begin
    AFont.Style:=[fsBold];
    if copy(qryMem.FieldByName(SMessage).AsString,1,1)='-' then AFont.Color:=clGray
    else if copy(qryMem.FieldByName(SMessage).AsString,1,1)='!' then AFont.Color:=clRed
    else if copy(qryMem.FieldByName(SMessage).AsString,1,1)='*' then AFont.Color:=clBlue
    else AFont.Color:=clGreen
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

procedure TfrmTZMain.miZabbixClick(Sender: TObject);
begin
    shellapi.ShellExecute(Application.handle, 'open',
               PChar(zt.URLu),
               nil,
               nil, SW_SHOWNORMAL);

end;

procedure TfrmTZMain.trayIconBalloonClick(Sender: TObject);
begin
//
end;

procedure TfrmTZMain.trayIconClick(Sender: TObject);
begin
//  TrayIcon.visible:=true; // делаем значок в трее видимым
//  trayicon.balloontitle:=('Текст 1');
//  trayicon.balloonhint:=('Текст 2');
//  trayicon.showballoonHint;// показываем наше уведомление
end;

procedure TfrmTZMain.trayIconDblClick(Sender: TObject);
begin
//  TrayIcon.ShowBalloonHint;
//  ShowWindow(Handle,SW_RESTORE);
  show(); //делает форму видимой
  application.Restore;
  setForegroundWindow(handle); //выдвигает окно на первый план
//  TrayIcon.Visible:=False;
end;

procedure TfrmTZMain.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  SysClose:=1;
  Close;
  Msg.Result := 1; //Можно закрывать
end;

procedure TfrmTZMain.ApplicationEvents1Minimize(Sender: TObject);
begin
//Убираем с панели задач
  TrayIcon.Visible:=true;
  Hide;
//  ShowWindow(Handle,SW_HIDE);  // Скрываем программу
//  ShowWindow(Application.Handle,SW_HIDE);  // Скрываем кнопку с TaskBar'а
//  SetWindowLong(Application.Handle, GWL_EXSTYLE,
//  GetWindowLong(Application.Handle, GWL_EXSTYLE) or (not WS_EX_APPWINDOW));
end;

procedure TfrmTZMain.ApplicationEvents1Restore(Sender: TObject);
begin
  show(); //делает форму видимой
//  TrayIcon.ShowBalloonHint;
//  ShowWindow(Handle,SW_RESTORE);
//  SetForegroundWindow(Handle);
//  TrayIcon.Visible:=False;
end;

end.
