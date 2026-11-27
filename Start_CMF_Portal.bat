@echo off
setlocal enabledelayedexpansion

REM Resolve the folder containing this .bat file (strip trailing backslash)
set "PORTAL_DIR=%~dp0"
if "%PORTAL_DIR:~-1%"=="\" set "PORTAL_DIR=%PORTAL_DIR:~0,-1%"
set "PORT=8080"
set "URL=http://localhost:%PORT%/CMF_Web_portal.aspx"

REM Locate IIS Express
set "IIS_EXE=C:\Program Files\IIS Express\iisexpress.exe"
if not exist "%IIS_EXE%" set "IIS_EXE=C:\Program Files (x86)\IIS Express\iisexpress.exe"
if not exist "%IIS_EXE%" (
    echo [ERROR] IIS Express not found in Program Files.
    echo Please install IIS Express and try again.
    pause
    exit /b 1
)

REM Stop any existing IIS Express instance so port 8080 is free
tasklist /FI "IMAGENAME eq iisexpress.exe" 2>nul | find /I "iisexpress.exe" >nul
if "%ERRORLEVEL%"=="0" (
    echo Stopping existing IIS Express instance...
    taskkill /F /IM iisexpress.exe >nul 2>&1
    timeout /t 1 /nobreak >nul
)

echo Starting CMF Web Portal from: %PORTAL_DIR%
echo Portal URL: %URL%
echo.

REM Launch browser in background after a short delay for IIS Express to bind
start "" /B cmd /c "timeout /t 2 /nobreak >nul && start "" "%URL%""

REM Run IIS Express in this window (press Q or close window to stop)
"%IIS_EXE%" /path:"%PORTAL_DIR%" /port:%PORT%

endlocal
