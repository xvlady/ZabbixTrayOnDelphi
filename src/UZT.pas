unit UZT;

interface

uses
  {$IFDEF USE_DXGETTEXT}
    JvGnugettext,
  {$ENDIF USE_DXGETTEXT}
  System.Classes, system.json, Graphics;

type
  TZt = class (TObject)
  private
    FConnect:Boolean;
    procedure SetConnect(const Value: Boolean);
    function post(const ji:TJSONObject; var jo:TJSONObject):boolean;
    function GetValue(const method:string;
                      const params:TJSONValue=nil;
                      const autintiphication:Boolean=true):TJSONValue;
  public
    login:string;
    password:string;
    URL:string;
    url_up:string;//Адрес по которому посылать пользователя
    au:string;
    lastResult:string;
    lastSender:string;
    constructor Create(const Alogin:string='';const APassword:string=''; const AURL:string='');
    function urlu:string;
    function urla:string;
    procedure Connected;
    procedure ReConnect;
    function GetVersion: string;
    function GetTrigger: TJSONValue;
    function GetEvent(const ja:TJSONArray): TJSONValue;
    function GetHost(const ja:TJSONArray): TJSONValue;
    function SetEventMSG(const ja: TJSONArray; const msg: String): TJSONValue;
    property Connect:Boolean read FConnect write SetConnect;
  end;
resourcestring
  StrNone='None';
  StrInformation='Information';
  StrWarning='Warning';
  StrAverage='Average';
  StrHigh='High';
  StrDisaster='Disaster';
  StrOkSt='-';
  StrAction='Requires user action';
  StrNotActive='False Alarm';
  StrInWork='In Progress';
  StrQuest='Specified';
  StrOkEvent='Corrected';
  StrOkOther='Other';
const
//StatusHTML: array [0..6] of Integer=($cecece,$d6f6ff      ,$efefcc  ,$ddaaaa  ,$ff8888,$ff0000,$aaffaa);
//StatusHTML: array [0..6] of Integer=($1F5E1F,$327232      ,$703158  ,$5D1F44  ,$8F3F3F,$762727,$aaffaa);
  StatusHTML: array [0..6] of Integer=($DBDBDB,$D6F6FF      ,$FFF6A5  ,$FFB689  ,$FF9999,$FF3838,$aaffaa);
  EventMsgK: array [0..4]       of char=('!','-','*','?',' ');
  EventMsgC: array [0..5]    of Integer=(clRed,clGray,clBlue,clAqua,clGreen,clGreen);
  STriggerId='triggerid';
  SHost='host';
  SDescription='description';
  SPriority='priority';
  SLastchange='lastchange';
  SComments = 'comments';
  SError = 'error';
  SHostId = 'hostid';
  SEventID = 'eventid';
  SClock = 'clock';
  SAcknowledges = 'acknowledges';
  SMessage = 'message';
  SAlias = 'alias';
  SObjectId = 'objectid';
  SApiJsonRpcPhp = 'api_jsonrpc.php';

//  .disaster { background: #FF3838 !important; }
//  .high { background: #FF9999 !important; }
//  .average { background: #FFB689 !important; }
//  .warning { background: #FFF6A5 !important; }
//  .information { background: #D6F6FF !important; }
//  .not_classified { background: #DBDBDB !important; }

  function TJSONArrayCreate(S:TStrings):TJSONArray;
  procedure AfterLoc;

var
  StatusC: array [0..6] of Integer;
  StatusT: array [0..6]     of string=(StrNone ,StrInformation, StrWarning, StrAverage, StrHigh, StrDisaster, StrOkSt);
  EventMsgT: array [0..5]     of string=(StrAction,StrNotActive, StrInWork, StrQuest, StrOkEvent, StrOkOther);
  //StatusT: array [0..6] of string;
implementation

uses httpsend, synautil, SysUtils, windows;

resourcestring
  StrUnknowResult = 'Unknow result:';
  StrErrorConnectionData = 'Error Connection Data';
  StrOtherErrorConnecti = 'Other Error Connection';
  StrLoginError = 'Login error';

  function TJSONArrayCreate(S:TStrings):TJSONArray;
  var
    i:Integer;
  begin
    result:=TJSONArray.Create;
    for I := 0 to s.Count-1 do
      result.Add(s[i]);
  end;
{ TZt }

constructor TZt.Create(const Alogin, APassword, AURL: string);
begin
  FConnect:=False;
  au:='';
  lastResult:='';
  lastSender:='';
  if Alogin<>''    then login:=Alogin;
  if APassword<>'' then Password:=APassword;
  if AURL<>''      then URL:=AURL;
end;

function TZt.GetVersion:string;
var
  jo: TJSONValue;
begin
  jo:=GetValue('apiinfo.version');
  if jo<>nil
  then result:=jo.Value
  else result:='-';
end;

function TZt.GetValue(const method:string;
                      const params:TJSONValue=nil;
                      const autintiphication:Boolean=true):TJSONValue;
var
  jo,ji: TJSONObject;
begin
  result:=nil;
  lastSender:='';
  lastResult:='';
  if autintiphication then begin
    if not FConnect then Connected;
    if not FConnect then exit;
  end;
  ji:=TJSONObject.Create;
  try
    ji.AddPair('jsonrpc', '2.0');
    ji.AddPair('method', method);
    if params<>nil then
//        ji.AddPair('params',params);
      ji.AddPair('params',(params.Clone) as TJSONValue);
    if autintiphication then
      ji.AddPair('auth', au);
    ji.AddPair('id', '1');
    lastSender:=ji.ToString;
    if post(ji,jo) then begin
      if jo=nil then begin
        lastResult:='nil';
        raise Exception.Create(StrErrorConnectionData);
      end else if (jo.Get(SError)<>nil) then begin
        lastResult:=jo.Get(SError).JsonValue.ToString;
        jo:=jo.Get(SError).JsonValue as TJSONObject;
        if autintiphication
        then raise Exception.Create(StrLoginError+#13#10+jo.Get('data').JsonValue.Value)
        else raise Exception.Create(jo.Get('data').JsonValue.Value);
      end else if (jo.Get('result')<>nil) then begin
        lastResult:=jo.Get('result').JsonValue.ToString;
        result:=jo.Get('result').JsonValue;
      end else begin
        lastResult:=jo.ToString;
        raise Exception.Create(StrUnknowResult+jo.ToString);
      end
    end else begin
      raise Exception.Create(StrOtherErrorConnecti);
    end;
  finally
    ji.Free;
  end;
end;

function TZt.GetEvent(const ja: TJSONArray): TJSONValue;
var
  jo2: TJSONObject;
begin
  jo2:= TJSONObject.Create;
  jo2.AddPair('output','extend');
  jo2.AddPair('select_acknowledges','extend');
  jo2.AddPair('sortfield','clock');
  jo2.AddPair('sortorder','DESC');
  if ja<>nil then
    jo2.AddPair('objectids',ja);
  jo2.AddPair('filter',TJSONObject.Create( TJSONPair.Create('value', TJSONNumber.Create(1))));
  result:=GetValue('event.get',jo2);
  jo2.Free;
end;

function TZt.SetEventMSG(const ja: TJSONArray; const msg:String): TJSONValue;
var
  jo2: TJSONObject;
begin
  jo2:= TJSONObject.Create;
  jo2.AddPair('eventids',ja);
  jo2.AddPair('message',msg);
  result:=GetValue('event.acknowledge',jo2);
  jo2.Free;
end;

function TZt.GetHost(const ja: TJSONArray): TJSONValue;
var
  jo2: TJSONObject;
begin
  jo2:= TJSONObject.Create;
  jo2.AddPair('output','extend');
  if ja<>nil then
    jo2.AddPair('hostids',ja);
  result:=GetValue('host.get',jo2);
  jo2.Free;
end;

function TZt.GetTrigger:TJSONValue;
var
  jo2: TJSONObject;
  ja: TJSONArray;
begin
  jo2:= TJSONObject.Create;
//  {"jsonrpc":"2.0","method":"trigger.get","params":{"output":["triggerid","description","priority","status","lastchange","description","url","value","comments","error","templateid","type","value_flags","flags"],"filter":{"value":1},"sortfield":"priority","sortorder":"DESC","expandData":"1","expandDescription":"1"},"auth":"96a075c9a26d21114b74f09cd65d1133","id":"1"}
//  {"triggerid":"13590","description":"Free disk space is less than 20% on volume C:","priority":"1","status":"0","lastchange":"1416839725","url":"","value":"1","comments":"","error":"","templateid":"0","type":"0","flags":"4","hostname":"xBig","host":"xBig","hostid":"10105","value_flags":"0"}
  ja:=TJSONArray.Create(STriggerId,SDescription);
  ja.Add(SPriority);
//  ja.Add('status');
  ja.Add(SLastchange);
//  ja.Add('url');
//  ja.Add('value');
  ja.Add(SComments);
  ja.Add(SError);
//  ja.Add('type');
//  ja.Add('value_flags');
//  ja.Add('flags');
//  ja.Add('hostname');
//  ja.Add('hostid');
  jo2.AddPair('output',ja);
  jo2.AddPair('filter',TJSONObject.Create( TJSONPair.Create('value', TJSONNumber.Create(1))));
  jo2.AddPair('sortfield',SPriority);
  jo2.AddPair('sortorder','ASC');
  jo2.AddPair('expandData','1');
  jo2.AddPair('expandDescription','1');
  jo2.AddPair('expandComment','1');
//  jo2.AddPair('expandExpression','1');

  result:=GetValue('trigger.get',jo2);
  jo2.Free;
end;

//http://www.sdn.nl/SDN/Artikelen/tabid/58/view/View/ArticleID/3230/Reading-and-Writing-JSON-with-Delphi.aspx
procedure TZt.Connected;
var
  jo: TJSONValue;
  jo2: TJSONObject;
begin
  if FConnect then Exit;
  jo2:= TJSONObject.Create;
  jo2.AddPair('user',Login);
  jo2.AddPair('password',Password);
  jo:=GetValue('user.login',jo2,false);
  FConnect:=jo<>nil;
  if FConnect
  then au:=jo.Value
  else au:='';
  jo2.Free;
end;

procedure TZt.SetConnect(const Value: Boolean);
begin
  if Value=FConnect then Exit;
  au:='';
  if Value
  then connected
  else FConnect := false;
end;

function TZt.urla: string;
begin
  result:=url+SApiJsonRpcPhp;
end;

function TZt.urlu: string;
begin
  if url_up<>''
  then result:=url_up
  else result:=url;
end;

function TZt.post(const ji: TJSONObject; var jo: TJSONObject): boolean;
  function HttpPostURL(const URL, URLData: string; const Data: TStream): Boolean;
  var
    HTTP: THTTPSend;
  begin
    HTTP := THTTPSend.Create;
    try
      WriteStrToStream(HTTP.Document, URLData);
      HTTP.MimeType := 'application/json-rpc';
      Result := HTTP.HTTPMethod('POST', URL);
      if Result
      then Data.CopyFrom(HTTP.Document, 0);
    finally
      HTTP.Free;
    end;
  end;
var
  Data:TStringStream;
begin
  Data:=TStringStream.Create('');
  Result:= HttpPostURL(urla,ji.ToJSON,Data);
  if Result then begin
    Data.Position:=0;
    jo:=TJSONObject.ParseJSONValue(Data.DataString) as TJSONObject;
  end else jo:=nil;
end;


procedure TZt.ReConnect;
begin
  Connect:=False;
  Connected;
end;

procedure AfterLoc;
begin
  StatusT[0]:=StrNone;
  StatusT[1]:=StrInformation;
  StatusT[2]:= StrWarning;
  StatusT[3]:= StrAverage;
  StatusT[4]:= StrHigh;
  StatusT[5]:= StrDisaster;
  StatusT[6]:= StrOkSt;
  EventMsgT[0]:=StrAction;
  EventMsgT[1]:=StrNotActive;
  EventMsgT[2]:= StrInWork;
  EventMsgT[3]:= StrQuest;
  EventMsgT[4]:= StrOkEvent;
  EventMsgT[5]:= StrOkOther;
end;

function ColorToRGB(Color:TColor):TColor;
var
  r, g, b: Byte;
begin
  b    := Color        mod 256;
  g    := Color shr 8  mod 256;
  r    := Color shr 16 mod 256;
  result:=B shl 16 or G shl 8 or R;
end;
var
  i:Integer;
begin
  for i:=0 to 6 do begin
    StatusC[i]:=ColorToRGB(StatusHTML[i]);
//    StatusT[i]:='#'+IntToHex(StatusHTML[i],2)+' #'+IntToHex(StatusC[i],2)
  end;
end.
