@echo off
echo ============================================================
echo   Talentshowoff Job Board - starting local server
echo ============================================================
echo.
echo This will install a couple of small Python packages the
echo first time you run it, then start the server.
echo.
echo Once you see "Open this in your browser", go to:
echo     http://localhost:5000
echo.
echo Keep this window OPEN while you use the website.
echo Close this window (or press Ctrl+C) to stop the server.
echo ============================================================
echo.

cd /d "%~dp0backend"

python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python was not found on this computer.
    echo Please install Python from https://www.python.org/downloads/
    echo During install, check the box that says "Add Python to PATH".
    pause
    exit /b 1
)

python -m pip install --quiet -r requirements.txt

python app.py

pause
