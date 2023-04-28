@echo off
setlocal enabledelayedexpansion

for /f "tokens=1,* delims==" %%a in ('type configuration.properties') do (
  set "%%a=%%b"
)

for %%i in (%service%) do (
    sc \\%remote_host% query %%i >nul 

    if !errorlevel! equ 0  (
        echo %%i is available in Services on %remote_host%.
        for /f "tokens=3 delims=: " %%a in ('sc \\%remote_host% query %%i ^| find "STATE"') do set state=%%a

        echo The state of %%i on %remote_host% is: !state!
        if "!state!" == "RUNNING" (
            echo %%i on %remote_host% is already running.
            
            
        ) else if "!state!" == "STOPPED" (
            echo %%i on %remote_host% is stopped.
            echo Starting %%i on %remote_host%...
            timeout /t %delay%
            sc \\%remote_host% start %%i
            
            sc \\%remote_host% query %%i | find "STATE" | find /i "RUNNING" >nul && (
                echo %%i on %remote_host% is now Started.
            )
        ) else (
            echo The state of %%i on %remote_host% is not RUNNING nor STOPPED.
        )
    ) else (
        echo %%i is not available in Services on %remote_host%.
    )
)    

pause