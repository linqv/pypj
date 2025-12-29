@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set PROJECT_DIR=%~dp0
cd /d "%PROJECT_DIR%"

set VENV_DIR=.venv
set SERVER_HOST=127.0.0.1
set API_PORT=8765
set WEB_PORT=5500

echo ==============================
echo AI Assistant Launcher
echo ==============================
echo Project: %PROJECT_DIR%
echo venv   : %VENV_DIR%
echo API    : http://%SERVER_HOST%:%API_PORT%
echo Web    : http://%SERVER_HOST%:%WEB_PORT%/static/index.html
echo.

REM Check Python
set PYTHON_CMD=
where python >nul 2>&1
if %errorlevel%==0 (
  set PYTHON_CMD=python
) else (
  where py >nul 2>&1
  if %errorlevel%==0 (
    set PYTHON_CMD=py -3
  ) else (
    echo ERROR: Python not found. Please install Python 3.
    pause
    exit /b 1
  )
)

echo Using Python: %PYTHON_CMD%
echo.

REM Check requirements.txt
if not exist "requirements.txt" (
  echo ERROR: Missing requirements.txt
  pause
  exit /b 1
)

REM Create virtual environment
if not exist "%VENV_DIR%\Scripts\python.exe" (
  echo Creating venv: %VENV_DIR% ...
  %PYTHON_CMD% -m venv %VENV_DIR%
  if %errorlevel% neq 0 (
    echo ERROR: Failed to create venv
    pause
    exit /b 1
  )
  echo venv created.
) else (
  echo venv exists.
)
echo.

REM Activate virtual environment
call "%VENV_DIR%\Scripts\activate.bat"
if %errorlevel% neq 0 (
  echo ERROR: Failed to activate venv
  pause
  exit /b 1
)

echo Activated venv: %VENV_DIR%
python --version
echo.

REM Install dependencies
echo Installing requirements...
python -m pip install -U pip >nul 2>&1
python -m pip install -U -r requirements.txt
if %errorlevel% neq 0 (
  echo ERROR: Failed to install requirements
  pause
  exit /b 1
)
echo Requirements OK.
echo.

REM Check required files
if not exist "local_server.py" (
  echo ERROR: Missing local_server.py
  pause
  exit /b 1
)

if not exist "static\index.html" (
  echo WARNING: static\index.html not found
)

REM Start API server
echo Starting local_server.py ...
start "AI_LOCAL_API" cmd /k "cd /d "%PROJECT_DIR%" && call "%PROJECT_DIR%%VENV_DIR%\Scripts\activate.bat" && python local_server.py"
timeout /t 2 /nobreak >nul

REM Start static web server
echo Starting static web server ...
start "AI_STATIC_WEB" cmd /k "cd /d "%PROJECT_DIR%" && call "%PROJECT_DIR%%VENV_DIR%\Scripts\activate.bat" && python -m http.server %WEB_PORT% --bind %SERVER_HOST%"
timeout /t 1 /nobreak >nul

REM Open browser
echo Opening browser...
start "" "http://%SERVER_HOST%:%WEB_PORT%/static/index.html"

echo.
echo Done!
echo - API: http://%SERVER_HOST%:%API_PORT%
echo - Web: http://%SERVER_HOST%:%WEB_PORT%/static/index.html
echo.
echo Close the two new windows to stop services (or Ctrl+C)
echo.
pause


