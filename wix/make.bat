set p=C:\Program Files\WiX Toolset v3.9\bin
set w=F:\APRG\ZabbixTray\wix
"%p%\candle.exe" "%w%\ZabbixTraySetup.wxs" -out "%w%\ZabbixTraySetup.wixobj"  -ext WixUtilExtension  -ext WixUIExtension -nologo
"%p%\light.exe" "%w%\ZabbixTraySetup.wixobj" -out "%w%\ZabbixTraySetup.msi"  -ext WixUtilExtension  -ext WixUIExtension  -nologo
pause