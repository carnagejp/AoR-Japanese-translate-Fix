@echo off
setlocal enabledelayedexpansion
set "PATCHDIR=%~dp0"
for %%I in ("%PATCHDIR%..") do set "GAMEROOT=%%~fI"

echo ============================================================
echo AoR Japanese Retranslation Patch v5.2
echo (このフォルダをゲーム本体のexeと同じフォルダに置いて実行してください)
echo ============================================================
echo Patch folder : %PATCHDIR%
echo Game root    : %GAMEROOT%
echo.

rem ---- ゲームの "*_Data" フォルダをゲームルート直下から自動検出 ----
set "DATADIR="
for /d %%D in ("%GAMEROOT%\*_Data") do (
    if exist "%%D\resources.assets" set "DATADIR=%%D"
)
if not defined DATADIR goto :err_nodatadir
echo Found game data folder:
echo   !DATADIR!
echo.

rem ---- パッチデータの確認 ----
if not exist "%PATCHDIR%apply_patch.ps1" goto :err_missing
if not exist "%PATCHDIR%patch_ops.txt" goto :err_missing
if not exist "%PATCHDIR%patch_data.bin.gz" goto :err_missing
where powershell >nul 2>&1
if errorlevel 1 goto :err_nops

rem ---- 元ファイル（無改造版）: バックアップがあればそちらを使う ----
if exist "!DATADIR!\resources.assets.bak" (
    set "ORIGFILE=!DATADIR!\resources.assets.bak"
    echo [INFO] 既にパッチ導入済みのため、バックアップ（無改造版）から作り直します。
) else (
    set "ORIGFILE=!DATADIR!\resources.assets"
)
echo Original file: !ORIGFILE!
echo.
echo 日本語化ファイルを作成しています（1分ほどかかる場合があります）...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PATCHDIR%apply_patch.ps1" -Source "!ORIGFILE!" -Output "%PATCHDIR%resources.assets.PATCHED" -PatchDir "%PATCHDIR%."
set "RC=!errorlevel!"
if "!RC!"=="2" goto :err_version
if not "!RC!"=="0" goto :err_apply

if exist "!DATADIR!\resources.assets.bak" goto :do_copy
echo 元の resources.assets をバックアップしています...
copy /y "!DATADIR!\resources.assets" "!DATADIR!\resources.assets.bak" >nul
if errorlevel 1 goto :err_copy
echo Backup created: resources.assets.bak

:do_copy
echo 日本語化ファイルを配置しています...
copy /y "%PATCHDIR%resources.assets.PATCHED" "!DATADIR!\resources.assets" >nul
if errorlevel 1 goto :err_copy
del "%PATCHDIR%resources.assets.PATCHED" >nul 2>&1

echo.
echo ============================================================
echo DONE. 日本語化パッチのインストールが完了しました。
echo 元に戻したい場合は、このフォルダの uninstall.bat を実行してください。
echo ============================================================
pause
exit /b 0

:err_nodatadir
echo [ERROR] ゲームの「*_Data」フォルダが見つかりませんでした。
echo このパッチフォルダを、ゲーム本体のexeファイルと同じフォルダ
echo （"..._Data"フォルダと同じ階層）に置いてから実行してください。
pause
exit /b 1

:err_missing
echo [ERROR] パッチのファイル（apply_patch.ps1 / patch_ops.txt / patch_data.bin.gz）が
echo 見つかりません。ダウンロードしたフォルダの中身が全て揃っているか確認してください。
pause
exit /b 1

:err_nops
echo [ERROR] Windows PowerShell が見つかりません（Windows 10/11 には標準で入っています）。
pause
exit /b 1

:err_version
echo [ERROR] 元の resources.assets がこのパッチの対象バージョン（1.30b の無改造版）と一致しません。
echo ゲームがアップデートされたか、別の改造が入っている可能性があります。
echo Steamの「ゲームファイルの整合性を確認」で元に戻してから、
echo 対応する版のパッチを使用してください。
if exist "%PATCHDIR%resources.assets.PATCHED" del "%PATCHDIR%resources.assets.PATCHED" >nul 2>&1
pause
exit /b 1

:err_apply
echo [ERROR] 日本語化ファイルの作成に失敗しました（コード !RC!）。
echo ダウンロードが不完全か、ディスクの空き容量が不足している可能性があります。
echo ゲームのファイルは変更していません。
if exist "%PATCHDIR%resources.assets.PATCHED" del "%PATCHDIR%resources.assets.PATCHED" >nul 2>&1
pause
exit /b 1

:err_copy
echo [ERROR] ファイルの配置に失敗しました。ゲームを終了してから再度実行してください。
pause
exit /b 1
