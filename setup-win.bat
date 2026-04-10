@echo off
chcp 65001 >nul
echo ============================================
echo PyWxDump Windows Setup
echo ============================================
echo.

REM Check if conda is installed
where conda >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Conda is not installed or not in PATH.
    echo.
    echo Please install Anaconda or Miniconda first:
    echo   - Anaconda: https://www.anaconda.com/download
    echo   - Miniconda: https://docs.conda.io/en/latest/miniconda.html
    echo.
    pause
    exit /b 1
)

echo [INFO] Found Conda installation
call conda --version
echo.

REM Set environment name
set ENV_NAME=pywxdump

REM Check if environment already exists
call conda info --envs | findstr /C:"%ENV_NAME%" >nul
if %errorlevel% equ 0 (
    echo [INFO] Environment '%ENV_NAME%' already exists.
    choice /C YN /M "Do you want to remove and recreate it"
    if %errorlevel% equ 1 (
        echo [INFO] Removing existing environment...
        call conda env remove -n %ENV_NAME% -y
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to remove existing environment.
            pause
            exit /b 1
        )
    ) else (
        echo [INFO] Using existing environment. Updating packages...
        call conda activate %ENV_NAME%
        goto :install_packages
    )
)

echo.
echo [INFO] Creating new conda environment: %ENV_NAME%
call conda create -n %ENV_NAME% python=3.11 -y
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create conda environment.
    pause
    exit /b 1
)

echo.
echo [INFO] Activating environment...
call conda activate %ENV_NAME%
if %errorlevel% neq 0 (
    echo [ERROR] Failed to activate environment.
    echo Try running: conda activate %ENV_NAME%
    pause
    exit /b 1
)

:install_packages
echo.
echo [INFO] Installing packages from requirements.txt...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install some packages.
    echo.
    echo Note: If you're not on Windows, pywin32 and pymem will fail.
    echo For non-Windows development, use: setup-dev.bat instead.
    pause
    exit /b 1
)

echo.
echo ============================================
echo Setup completed successfully!
echo ============================================
echo.
echo To use PyWxDump:
echo   1. Activate environment: conda activate %ENV_NAME%
echo   2. Run the application: python -m PyWxDump
echo   3. Or use: python main.py
echo.
echo Quick start:
echo   conda activate %ENV_NAME%
echo   python -m PyWxDump wx_info --help
echo.
pause
