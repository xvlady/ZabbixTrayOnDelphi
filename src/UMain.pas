unit UMain;

interface

uses
  UZT, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, acAlphaImageList,
  Vcl.ExtCtrls, Vcl.StdCtrls, sMemo, Vcl.Menus, Vcl.ComCtrls, sPageControl,
  sPanel, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, DynVarsEh,
  MemTableDataEh, Data.DB, MemTableEh, GridsEh, DBAxisGridsEh, DBGridEh,
  sSkinProvider, sSkinManager, Vcl.AppEvnts, sHintManager;

type
  TfrmTZMain = class(TForm)
    trayIcon: TTrayIcon;
    mmoText: TsMemo;
    tmrZt: TTimer;
    ilTr: TImageList;
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
    pnltop: TsPanel;
    miRefreshPM: TMenuItem;
    miExitPM: TMenuItem;
    ilTrAni: TImageList;
    ApplicationEvents1: TApplicationEvents;
    miSep01: TMenuItem;
    miOpen: TMenuItem;
    sHintManager1: TsHintManager;
    statBar: TStatusBar;
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
  private
    zt:TZt;
  public
    { Public declarations }
  end;

var
  frmTZMain: TfrmTZMain;

implementation

uses system.json, DateUtils;
{$R *.dfm}
resourcestring
  StrNotFondTriggerid = 'Not fond triggerid=';

const
  SIteration = 'iteration';
  SUser = 'user';

procedure TfrmTZMain.btnConnectClick(Sender: TObject);
  procedure mmoText_Lines_add(s:string);
  begin
    if TS_Main.ActivePage=tsLog
    then mmoText.Lines.add(s);
  end;
var
  jt,ja,jh:TJSONArray;
  jo:TJSONObject;
  i,z:integer;
  iteration:TDateTime;
  s1,s2:TStringList;
begin
  mmoText.Lines.Clear;
  zt.Connected;
  if zt.connect
  then begin

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
    iteration:=Now;
    for i := 0 to jt.Count-1 do begin
      jo:=(jt.Items[i] as TJSONObject);
      //{"triggerid":"13590","description":"Free disk space is less than 20% on volume C:","priority":"1","lastchange":"1416839725","comments":"","error":"","hostname":"xBig","host":"xBig","hostid":"10105"}
      if qryMem.Locate(STriggerId,jo.GetValue(STriggerId).Value,[])
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
          qryMem.FieldByName('T').AsString:=IntToStr(z)
        end;
      end;
      qryMem.FieldByName(SComments).AsString:=jo.GetValue(SComments).Value;
      qryMem.FieldByName(SError).AsString:=jo.GetValue(SError).Value;
      qryMem.FieldByName(SHostId).AsString:=jo.GetValue(SHostId).Value;
      qryMem.FieldByName(SIteration).AsDateTime:=iteration;
      qryMem.Post;
      s1.Add(jo.GetValue(SHostId).Value);
      s2.Add(jo.GetValue(STriggerId).Value);
    end;
    jt.Free;
    qryMem.First;
    while not qryMem.eof do begin
      if qryMem.FieldByName(SIteration).AsDateTime<>iteration
      then qryMem.Delete
      else qryMem.Next;
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
  end else begin
    mmoText_Lines_add(zt.errorlong);
    mmoText_Lines_add(zt.error);
  end;
end;


procedure TfrmTZMain.FormCreate(Sender: TObject);
begin
  zt:=TZt.Create('alefezt','alefezt','http://192.168.0.3/zabbix/api_jsonrpc.php');
  statBar.Panels[0].Text:=zt.login;
  statBar.Panels[1].Text:=zt.URL;
  btnConnectClick(Sender);
  tmrZt.Enabled:=True;
  application.ShowMainForm:=false;
  TrayIcon.Visible:=True;
  //Application.Minimize;
end;

procedure TfrmTZMain.FormDestroy(Sender: TObject);
begin
  zt.free;
end;

procedure TfrmTZMain.gGetCellParams(Sender: TObject; Column: TColumnEh;
  AFont: TFont; var Background: TColor; State: TGridDrawState);
begin
  Background:=StatusC[qryMem.FieldByName(SPriority).AsInteger];
  AFont.Color:=clBlack;
end;

procedure TfrmTZMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTZMain.miOpenClick(Sender: TObject);
begin
  show(); //делает форму видимой
  application.Restore;
  setForegroundWindow(handle); //выдвигает окно на первый план
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
