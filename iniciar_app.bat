@echo off
setlocal
cd /d "%~dp0"

set "PYTHON_EXE=C:\Users\Diego Calderon G\AppData\Local\Python\pythoncore-3.14-64\python.exe"
if not exist "%PYTHON_EXE%" set "PYTHON_EXE=python"

echo =========================================
echo Academia Horizonte - Certificados
echo Servidor: http://localhost:5000
echo Presiona Ctrl+C para detener...
echo =========================================

"%PYTHON_EXE%" app.py
pause