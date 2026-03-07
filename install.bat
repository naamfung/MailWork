@echo off

REM 编译并安装项目
go install -mod=mod .

REM 检查安装是否成功
if %errorlevel% equ 0 (
    echo 项目安装成功！可执行文件已安装到 GOPATH/bin 目录，文件名为：mailhog
) else (
    echo 项目安装失败，请检查错误信息。
    exit /b 1
)