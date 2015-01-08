// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
program ZabbixTray;

uses
  Vcl.Forms,
  windows,
  UMain in 'UMain.pas' {frmTZMain},
  httpsend in 'F:\comp\synapse\source\lib\httpsend.pas',
  UZT in 'UZT.pas',
  UOptions in 'UOptions.pas' {frmOptions},
  USetMsg in 'USetMsg.pas' {frmSetMsg};

{$R *.res}

var
  mhApp: THandle;

begin
  Application.Initialize;


//const
//  AppHandleName = 'MyApp_Name';
//
//begin
//  mhApp:=OpenMutex(MUTEX_ALL_ACCESS, True, PChar(AppHandleName));
//  if (mhApp<>0) then begin
  mhApp:=FindWindow(PChar('TApplication'), PChar('ZabbixTray'));
  if (mhApp<>0) and (System.DebugHook = 0) then
//    if IsIconic(mhApp) then
      ShowWindow(mhApp, SW_Restore)
//    else
//      SetForegroundWindow(mhApp);
//  end
//    else
//  begin
//    mhApp := CreateMutex(nil, false, PChar(AppHandleName));
//    if (mhApp = 0 ) then
//      raise Exception.Create('WIN32 API Error:'+#13#10 +
//            SysErrorMessage(GetLastError));
//  end;
//end;
  //Application.MainFormOnTaskbar := True;
  else
    Application.CreateForm(TfrmTZMain, frmTZMain);
  Application.Title:='ZabbixTray';
  Application.Run;
end.
