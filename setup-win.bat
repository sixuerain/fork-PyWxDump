@echo off
chcp 65001 >nul
echo ============================================
echo PyWxDump Windows Setup
echo ============================================
echo.

REM Check if conda is installed
where conda >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Conda is not installed. Downloading and installing Miniconda...
    echo.

    REM Download Miniconda installer
    set MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
    set INSTALLER=miniconda_installer.exe

    echo [INFO] Downloading Miniconda from %MINICONDA_URL% ...
    powershell -Command "Invoke-WebRequest -Uri '%MINICONDA_URL%' -OutFile '%INSTALLER%'"

    if not exist %INSTALLER% (
        echo [ERROR] Failed to download Miniconda installer.
        echo.
        echo Please install manually from: https://docs.conda.io/en/latest/miniconda.html
        pause
        exit /b 1
    )

    echo [INFO] Installing Miniconda silently...
    start /wait "" %INSTALLER% /InstallationType=JustMe /AddToPath=1 /RegisterPython=0 /S /D=%UserProfile%\Miniconda3

    if %errorlevel% neq 0 (
        echo [ERROR] Miniconda installation failed.
        del %INSTALLER% 2>nul
        pause
        exit /b 1
    )

    echo [INFO] Cleaning up installer...
    del %INSTALLER%

    echo [INFO] Miniconda installed. Refreshing environment...
    set "PATH=%UserProfile%\Miniconda3;%UserProfile%\Miniconda3\Scripts;%UserProfile%\Miniconda3\Library\bin;%PATH%"

    REM Verify conda is now available
    where conda >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Conda installation verification failed.
        echo Please close this window and run the script again.
        pause
        exit /b 1
    )

    echo [SUCCESS] Miniconda installed successfully!
    echo.
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
