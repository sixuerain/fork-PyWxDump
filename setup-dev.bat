@echo off
chcp 65001 >nul
echo ============================================
echo PyWxDump Dev Setup (Non-Windows)
echo ============================================
echo.
echo WARNING: This setup skips Windows-only packages.
echo Full functionality requires Windows + WeChat.
echo.

REM Check if conda is installed
where conda >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Conda is not installed or not in PATH.
    echo.
    pause
    exit /b 1
)

echo [INFO] Found Conda installation
call conda --version
echo.

set ENV_NAME=pywxdump-dev

call conda info --envs | findstr /C:"%ENV_NAME%" >nul
if %errorlevel% equ 0 (
    echo [INFO] Environment '%ENV_NAME%' already exists.
    choice /C YN /M "Remove and recreate it"
    if %errorlevel% equ 1 (
        call conda env remove -n %ENV_NAME% -y
    ) else (
        call conda activate %ENV_NAME%
        goto :install_packages
    )
)

echo [INFO] Creating environment: %ENV_NAME%
call conda create -n %ENV_NAME% python=3.11 -y
call conda activate %ENV_NAME%

:install_packages
echo.
echo [INFO] Installing cross-platform packages...
pip install setuptools wheel psutil pycryptodomex silk-python requests pillow flask pyahocorasick pyahocorasick

echo.
echo ============================================
echo Dev setup completed!
echo ============================================
echo.
echo Note: Windows-only features (pywin32, pymem) are excluded.
echo To use WeChat memory reading, run on actual Windows.
echo.
echo Available features on this platform:
echo   - Database decryption (with key)
echo   - Web UI / Flask server
echo   - Message parsing and export
echo.
pause
