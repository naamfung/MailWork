@echo off

REM 编译项目，将产物输出到当前目录
go build -mod=mod -o mailhog.exe .

REM 检查编译是否成功
if %errorlevel% equ 0 (
    echo 项目编译成功！构建产物：mailhog.exe
) else (
    echo 项目编译失败，请检查错误信息。
    exit /b 1
)