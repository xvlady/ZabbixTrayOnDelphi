rem $(OUTPUTDIR) $(OUTPUTFILENAME) $(OUTPUTNAME) $(PROJECTNAME) $(OUTPUTPATH)
set OUTPUTDIR=%1
set OUTPUTFILENAME=%2
set OUTPUTNAME=%3
set PROJECTNAME=%4
set OUTPUTPATH=%5
echo 6:%6
echo 7:%7

"f:\tools\upx\upx.exe" -9 %OUTPUTPATH%
"C:\Program Files\7-Zip\7z.exe" a F:\APRG\ZabbixTray\bin\ZabbixTray.7z %OUTPUTPATH%
echo y|copy %OUTPUTPATH% %OUTPUTDIR%tools\ZabbixTray.exe
echo y|copy %OUTPUTPATH% %OUTPUTDIR%eHous\ZabbixTray.exe