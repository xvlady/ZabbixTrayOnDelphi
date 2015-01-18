@echo off
set LANGUAGE=%1
set TARGET=%2
if %LANGUAGE%!==! goto help
if %TARGET%!==! set TARGET=default

: test the existence of the target po
if not exist %LANGUAGE%\%TARGET%.po copy .\templates\%TARGET%.po %LANGUAGE%\%TARGET%.po

: now that we are sure that all required files exist, process default.po
echo Updating %LANGUAGE%...
msgmerge --no-wrap -v --force-po -o %LANGUAGE%\%TARGET%.po %LANGUAGE%\%TARGET%.po .\templates\%TARGET%.po
if errorlevel 1 goto err
echo.
echo.
goto end

:nodxgettext
ren saved.po default.po
echo DxGettext was not found.
echo This script requires dxgettext from http://dxgettext.sf.net
goto end

:help
echo UpdateLanguage.bat - Updates one language for CnxManager
echo.
echo Usage: UpdateLanguage.bat LangId [TargetPo]
echo.
echo     LangId is the Id of the language to update. It will
echo     be used as the directory name where to find default.po
echo     for the given language
echo.
echo     TargetPo is the name of the target po file without any
echo     extension (no .po). If not specified, it defaults to default
:err
:end
set LANGUAGE=
set TARGET=
