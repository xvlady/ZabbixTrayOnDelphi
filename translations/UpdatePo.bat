@echo off

: The languages that are known to CnxManager
set LANGUAGES=ru de fr

echo Update PO template file and the translations derived from it
echo Current languages: %LANGUAGES%

:ren default.po saved.po
: test the existence of dxgettext
dxgettext -o ..\tmp 1>..\tmp\tmp1.txt 2>..\tmp\tmp2.txt
if errorlevel 1 goto nodxgettext
:ren saved.po default.po

echo Cleaning up...
del ..\tmp\*.po

echo Extracting strings...
dxgettext -b ..\src -o ..\tmp  *.pas *.inc *.dpr *.dfm
if errorlevel 1 goto err

ren ..\tmp\default.po default1.po
if errorlevel 1 goto err

echo remove offending empty strings...
msgremove ..\tmp\default1.po -i ignore.po -o ..\tmp\clean1.po
if errorlevel 1 goto err

echo Merge all the generated po files into one
:msgcat ..\forms\default.po ..\common\default.po ..\default.po -o cat.po -t utf-8
if errorlevel 1 goto err
 
echo ensure uniqueness
:msguniq -u --use-first cat.po -o uniq.po
ren ..\tmp\clean1.po uniq.po
if errorlevel 1 goto err

echo Updating existing translations...
msgmerge --no-wrap -o .\templates\default.po .\templates\default.po ..\tmp\uniq.po
if errorlevel 1 goto err

echo Translation template default.po has been updated
echo.

echo Updating languages...
FOR %%l IN (%LANGUAGES%) DO call UpdateLanguage.bat %%l
echo.

echo Cleaning up...
del ..\tmp\*.po

goto end

:nodxgettext
echo DxGettext was not found.
echo This script requires dxgettext from http://dxgettext.sf.net
:err
:pause
:end
if exist ..\tmp\tmp1.txt del /q ..\tmp\tmp?.txt
set LANGUAGES=
