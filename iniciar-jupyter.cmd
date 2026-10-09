@echo off
setlocal
cd /d "%~dp0"
if not exist ".venv\Scripts\python.exe" (
  echo Falta el entorno .venv. Consultar ENTORNO.md.
  pause
  exit /b 1
)
set "JUPYTER_CONFIG_DIR=%~dp0.jupyter-local\config"
set "JUPYTER_DATA_DIR=%~dp0.jupyter-local\data"
set "JUPYTER_RUNTIME_DIR=%~dp0.jupyter-local\runtime"
set "IPYTHONDIR=%~dp0.jupyter-local\ipython"
if not exist "%IPYTHONDIR%" mkdir "%IPYTHONDIR%"
".venv\Scripts\python.exe" -m jupyterlab --ServerApp.ip=127.0.0.1 --ServerApp.root_dir="%CD%"
if errorlevel 1 pause
endlocal
