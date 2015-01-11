rem c:\Program Files (x86)\Embarcadero\RAD Studio\9.0\bin\
call rsvars.bat
rem /target:Build /p:config=Release
MSBuild.exe ZabbixTray.dproj
pause