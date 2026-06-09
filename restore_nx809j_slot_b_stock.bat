@echo off
setlocal EnableExtensions
chcp 65001 >nul

set "BACKUP_DIR=C:\Users\adriano\Desktop\zte\ZTEToolBoxParBak_2026.05.05_01.18.26.366\images"
set "SLOT=b"

echo.
echo REDMAGIC 11 Pro NX809J - restaurar boot/recovery stock do slot %SLOT%
echo.
echo Este script grava SOMENTE estas particoes:
echo   boot_%SLOT%
echo   vendor_boot_%SLOT%
echo   init_boot_%SLOT%
echo   recovery_%SLOT%
echo   dtbo_%SLOT%
echo   vbmeta_%SLOT%
echo   vbmeta_system_%SLOT%
echo.
echo Ele NAO grava userdata, metadata, persist, super, modem ou EFS.
echo.
echo Pasta do backup:
echo "%BACKUP_DIR%"
echo.

if not exist "%BACKUP_DIR%" (
    echo ERRO: pasta de backup nao encontrada.
    echo.
    pause
    exit /b 1
)

where fastboot >nul 2>nul
if errorlevel 1 (
    echo ERRO: fastboot nao encontrado no PATH.
    echo.
    pause
    exit /b 1
)

for %%F in (
    boot_%SLOT%.img
    vendor_boot_%SLOT%.img
    init_boot_%SLOT%.img
    recovery_%SLOT%.img
    dtbo_%SLOT%.img
    vbmeta_%SLOT%.img
    vbmeta_system_%SLOT%.img
) do (
    if not exist "%BACKUP_DIR%\%%F" (
        echo ERRO: arquivo ausente: "%BACKUP_DIR%\%%F"
        echo.
        pause
        exit /b 1
    )
)

echo Aparelhos em fastboot:
fastboot devices
echo.
echo Confirme que o telefone esta no modo bootloader/fastboot.
echo Para cancelar, feche esta janela ou pressione Ctrl+C.
echo.
pause

call :flash_part boot_%SLOT% boot_%SLOT%.img || goto :failed
call :flash_part vendor_boot_%SLOT% vendor_boot_%SLOT%.img || goto :failed
call :flash_part init_boot_%SLOT% init_boot_%SLOT%.img || goto :failed
call :flash_part recovery_%SLOT% recovery_%SLOT%.img || goto :failed
call :flash_part dtbo_%SLOT% dtbo_%SLOT%.img || goto :failed
call :flash_part vbmeta_%SLOT% vbmeta_%SLOT%.img || goto :failed
call :flash_part vbmeta_system_%SLOT% vbmeta_system_%SLOT%.img || goto :failed

echo.
echo Marcando slot %SLOT% como ativo...
fastboot --set-active=%SLOT%
if errorlevel 1 goto :failed

echo.
echo Estado dos slots:
fastboot getvar current-slot 2>&1
fastboot getvar slot-unbootable:%SLOT% 2>&1
fastboot getvar slot-successful:%SLOT% 2>&1

echo.
echo Reiniciando o aparelho...
fastboot reboot
if errorlevel 1 goto :failed

echo.
echo Restauracao enviada com sucesso. Aguarde o Android iniciar.
echo.
pause
exit /b 0

:flash_part
echo.
echo Gravando %~1 <= %BACKUP_DIR%\%~2
fastboot flash %~1 "%BACKUP_DIR%\%~2"
exit /b %ERRORLEVEL%

:failed
echo.
echo ERRO: a restauracao parou por falha em um comando fastboot.
echo.
pause
exit /b 1
