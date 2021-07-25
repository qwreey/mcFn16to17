@echo off
build\bin\luvit.exe build
if %USRBIN% NEQ "" (
    copy .\rebuild.exe %USRBIN%\rebuild.exe
)