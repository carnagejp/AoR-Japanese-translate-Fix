@echo off
setlocal enabledelayedexpansion
set "PATCHDIR=%~dp0"
for %%I in ("%PATCHDIR%..") do set "GAMEROOT=%%~fI"
set "DATADIR="
for /d %%D in ("%GAMEROOT%\*_Data") do (
    if exist "%%D\resources.assets" set "DATADIR=%%D"
)
if not defined DATADIR goto :err_nodatadir
if not exist "!DATADIR!\resources.assets.bak" goto :err_nobak
echo 日本語化パッチを外し、元の resources.assets に戻します。
copy /y "!DATADIR!\resources.assets.bak" "!DATADIR!\resources.assets" >nul
if errorlevel 1 goto :err_copy
del "!DATADIR!\resources.assets.bak" >nul 2>&1
echo 元に戻しました。このフォルダは削除して構いません。
pause
exit /b 0
:err_nodatadir
echo [ERROR] ゲームの「*_Data」フォルダが見つかりませんでした。
echo このフォルダをゲーム本体のexeと同じフォルダに置いてから実行してください。
pause
exit /b 1
:err_nobak
echo [ERROR] バックアップ（resources.assets.bak）が見つかりません。
echo パッチが未適用か、バックアップが削除されています。
echo Steamの「ゲームファイルの整合性を確認」で元に戻せます。
pause
exit /b 1
:err_copy
echo [ERROR] ファイルの復元に失敗しました。
pause
exit /b 1
