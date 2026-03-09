#!/bin/sh

# 编译并安装项目
go install -mod=mod .

# 检查安装是否成功
if [ $? -eq 0 ]; then
    echo "项目安装成功！可执行文件已安装到 GOPATH/bin 目录，文件名为：mailwork"
else
    echo "项目安装失败，请检查错误信息。"
    exit 1
fi