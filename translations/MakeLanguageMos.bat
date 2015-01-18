@echo off
set LANGUAGE=%1
if %LANGUAGE%!==! goto help

ren default.po saved.po
: test the existence of dxgettext
dxgettext -q -b .\ 1> tmp1.txt 2> tmp2.txt
if errorlevel 1 goto nodxgettext
del default.po
ren saved.po default.po

: process all the po files in the directory
echo Updating %LANGUAGE%...
if exist %LANGUAGE%\*.mo del /Q %LANGUAGE%\*.mo
for %%f IN (%LANGUAGE%\*.po) DO msgfmt %%f -o %%f.mo
cd %LANGUAGE%
ren *.po *.pob
ren *.po.mo *.
ren *.po *.mo
ren *.pob *.po
cd ..
copy /Y %LANGUAGE%\*.mo ..\..\bin\locale\%LANGUAGE%\LC_MESSAGES

goto end

:nodxgettext
ren saved.po default.po
echo DxGettext was not found.
echo This script requires dxgettext from http://dxgettext.sf.net
goto end

:help
echo MakeLanguageMo.bat - Creates the Mo files for one language in CnxManager
echo.
echo Usage: MakeLanguageMo.bat LangId
echo.
echo     LangId is the Id of the language to update. It will
echo     be used as the directory name where to find the po files
echo     for the given language

:end
del /q tmp?.txt
set LANGUAGE=
set TARGET=
