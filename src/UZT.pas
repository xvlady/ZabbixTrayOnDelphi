unit UZT;

interface

uses System.Classes, system.json;

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
    au:string;
    error:string;
    errorLong:string;
    lastResult:string;
    lastSender:string;
    constructor Create(const Alogin:string='';const APassword:string=''; const AURL:string='');
    procedure Connected;
    procedure ReConnect;
    function GetVersion: string;
    function GetTrigger: TJSONValue;
    function GetEvent(const ja:TJSONArray): TJSONValue;
    function GetHost(const ja:TJSONArray): TJSONValue;
    property Connect:Boolean read FConnect write SetConnect;
  end;
resourcestring
  StrNone='None';
  StrInformation='Information';
  StrWarning='Warning';
  StrAverage='Average';
  StrHigh='High';
  StrDisaster='Disaster';
  StrOk='-';
const
  StatusT: array [0..6]    of string= (@StrNone ,@StrInformation, @StrWarning, @StrAverage, @StrHigh, @StrDisaster, @StrOk);
//StatusHTML: array [0..6] of Integer=($cecece,$d6f6ff      ,$efefcc  ,$ddaaaa  ,$ff8888,$ff0000,$aaffaa);
//StatusHTML: array [0..6] of Integer=($1F5E1F,$327232      ,$703158  ,$5D1F44  ,$8F3F3F,$762727,$aaffaa);
  StatusHTML: array [0..6] of Integer=($DBDBDB,$D6F6FF      ,$FFF6A5  ,$FFB689  ,$FF9999,$FF3838,$aaffaa);
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

//  .disaster { background: #FF3838 !important; }
//  .high { background: #FF9999 !important; }
//  .average { background: #FFB689 !important; }
//  .warning { background: #FFF6A5 !important; }
//  .information { background: #D6F6FF !important; }
//  .not_classified { background: #DBDBDB !important; }

var
  StatusC: array [0..6] of Integer;
  //StatusT: array [0..6] of string;
implementation

uses httpsend, synautil, SysUtils, windows, Graphics;

function HttpPostURL(const URL, URLData: string; const Data: TStream): Boolean;
var
  HTTP: THTTPSend;
begin
  HTTP := THTTPSend.Create;
  try
    WriteStrToStream(HTTP.Document, URLData);
    HTTP.MimeType := 'application/json-rpc';
    Result := HTTP.HTTPMethod('POST', URL);
    if Result then
      Data.CopyFrom(HTTP.Document, 0);
  finally
    HTTP.Free;
  end;
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
  jo: TJSONObject;
begin
  result:=nil;
  if autintiphication then begin
    if not FConnect then Connected;
    if not FConnect then exit;
  end;
  try
    try
      jo := TJSONObject.Create;
      jo.AddPair('jsonrpc', '2.0');
      jo.AddPair('method', method);
      if params<>nil then
        jo.AddPair('params',params);
      if autintiphication then
        jo.AddPair('auth', au);
      jo.AddPair('id', '1');
      lastSender:=jo.ToString;
       if post(jo,jo) then begin
        if jo.Get('error')<>nil then begin
          jo:=jo.Get('error').JsonValue as TJSONObject;
          errorlong:=jo.Get('data').JsonValue.Value;
          error:='Ошибка соединения с сервером (не верный логин и пароль)';
        end else if jo.Get('result')<>nil then begin
          lastResult:=jo.Get('result').JsonValue.ToString;
          result:=jo.Get('result').JsonValue;
        end else begin
          lastResult:=jo.ToString;
          errorlong:='other error';
          error:='Ошибка соединения с сервером';
        end
      end else begin
          errorlong:='http ...';
          error:='Ошибка соединения с сервером (нет связи)';
      end;
    except
      on E: EJSONException do begin
        errorlong:=E.Message;
        error:='Ошибка соединения с сервером (JSON)';
      end;
      on E: Exception do begin
        errorlong:=E.Message;
        error:='Ошибка соединения с сервером';
      end;
    end;
  finally
    //jo.Free;
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
  jo: TJSONObject;
  jo2: TJSONObject;
  ja: TJSONArray;
begin
  jo2:= TJSONObject.Create;
//  {"jsonrpc":"2.0","method":"trigger.get","params":{"output":["triggerid","description","priority","status","lastchange","description","url","value","comments","error","templateid","type","value_flags","flags"],"filter":{"value":1},"sortfield":"priority","sortorder":"DESC","expandData":"1","expandDescription":"1"},"auth":"96a075c9a26d21114b74f09cd65d1133","id":"1"}
//  {"triggerid":"13590","description":"Free disk space is less than 20% on volume C:","priority":"1","status":"0","lastchange":"1416839725","url":"","value":"1","comments":"","error":"","templateid":"0","type":"0","flags":"4","hostname":"xBig","host":"xBig","hostid":"10105","value_flags":"0"}
  ja:=TJSONArray.Create('triggerid','description');
  ja.Add('priority');
//  ja.Add('status');
  ja.Add('lastchange');
//  ja.Add('url');
//  ja.Add('value');
  ja.Add('comments');
  ja.Add('error');
//  ja.Add('type');
//  ja.Add('value_flags');
//  ja.Add('flags');
//  ja.Add('hostname');
//  ja.Add('hostid');
  jo2.AddPair('output',ja);
  jo2.AddPair('filter',TJSONObject.Create( TJSONPair.Create('value', TJSONNumber.Create(1))));
  jo2.AddPair('sortfield','priority');
  jo2.AddPair('sortorder','DESC');
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

function TZt.post(const ji: TJSONObject; var jo: TJSONObject): boolean;
var
//  Data:TMemoryStream;
  Data:TStringStream;
begin
//  Data:=TMemoryStream.Create;
  Data:=TStringStream.Create('');
  Result:= HttpPostURL(url,ji.ToJSON,Data);
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

function ColorToRGB(Color:TColor):TColor;
var
  r, g, b: Byte;
begin
  b    := Color;
  g    := Color shr 8;
  r    := Color shr 16;
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
