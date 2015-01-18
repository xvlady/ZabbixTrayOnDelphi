@echo off

: The languages that are known to CnxManager
set LANGUAGES=fr sv

echo Create MO files for the known languages and places 
echo them in the appropriate directory
echo Current languages: %LANGUAGES%

ren default.po saved.po
: test the existence of dxgettext
dxgettext -q 1>tmp1.txt 2>tmp2.txt
if errorlevel 1 goto nodxgettext
del default.po
ren saved.po default.po

: first, generate the mo file
echo Generating Mo files for each language...
FOR %%l IN (%LANGUAGES%) DO call MakeLanguageMos %%l 

echo Mo files generated
echo.

: cleanup
: echo Cleaning up...
: del ..\common\default.po ..\forms\default.po ..\default.po cat.po clean?.po uniq.po

goto end

:nodxgettext
ren saved.po default.po
echo DxGettext was not found.
echo This script requires dxgettext from http://dxgettext.sf.net

:end
if exist tmp1.txt del /q tmp?.txt
set LANGUAGES=
