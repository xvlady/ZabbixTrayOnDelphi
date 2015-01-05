program ZabbixTray;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {frmTZMain},
  httpsend in 'F:\comp\synapse\source\lib\httpsend.pas',
  UZT in 'UZT.pas';

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTZMain, frmTZMain);
  Application.Run;
end.
