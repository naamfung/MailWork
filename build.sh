#!/bin/sh

# 纯sh脚本，实现Makefile中的功能

VERSION="1.0.0"

# 显示帮助信息
show_help() {
    echo "使用方法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  help      显示帮助信息"
    echo "  fmt       格式化代码"
    echo "  install   安装项目"
    echo "  all       格式化代码并安装项目"
    echo "  release   构建跨平台发布版本"
    echo "  release-deps  安装发布依赖"
    echo ""
    echo "示例:"
    echo "  $0 fmt              # 格式化代码"
    echo "  $0 install          # 安装项目"
    echo "  $0 all              # 格式化代码并安装项目"
    echo "  $0 release          # 构建跨平台发布版本"
}

# 格式化代码
fmt() {
    echo "格式化代码..."
    go fmt ./...
    if [ $? -eq 0 ]; then
        echo "代码格式化成功！"
    else
        echo "代码格式化失败，请检查错误信息。"
        exit 1
    fi
}

# 生成assets.go文件
generate_assets() {
    echo "生成assets.go文件..."
    rm -rf MailWork-UI/assets/assets.go
    # 直接使用 go-bindata 命令，因为在 PowerShell 环境中路径已经正确设置
    cd MailWork-UI && go-bindata -pkg=assets -o assets/assets.go assets/... && cd ..
    if [ $? -eq 0 ]; then
        echo "assets.go文件生成成功！"
    else
        echo "assets.go文件生成失败，请检查错误信息。"
        exit 1
    fi
}

# 安装项目
install() {
    echo "安装项目..."
    generate_assets
    go install .
    if [ $? -eq 0 ]; then
        echo "项目安装成功！"
    else
        echo "项目安装失败，请检查错误信息。"
        exit 1
    fi
}

# 构建跨平台发布版本
release() {
    echo "构建跨平台发布版本..."
    
    # 生成assets.go文件
    generate_assets
    
    # 创建构建目录
    mkdir -p build
    
    # 定义要构建的平台
    PLATFORMS="linux/amd64 linux/386 darwin/amd64 darwin/arm64 windows/amd64 windows/386"
    
    # 执行构建
    for PLATFORM in $PLATFORMS; do
        OS=$(echo $PLATFORM | cut -d'/' -f1)
        ARCH=$(echo $PLATFORM | cut -d'/' -f2)
        OUTPUT="build/MailWork_${OS}_${ARCH}"
        if [ "$OS" = "windows" ]; then
            OUTPUT="${OUTPUT}.exe"
        fi
        echo "构建 $OS/$ARCH..."
        GOOS="$OS" GOARCH="$ARCH" go build -mod=mod -ldflags "-X main.version=${VERSION}" -o "$OUTPUT" .
        if [ $? -ne 0 ]; then
            echo "构建 $OS/$ARCH 失败，请检查错误信息。"
            exit 1
        fi
    done
    
    echo "跨平台发布版本构建成功！"
    echo "构建产物位于 build/ 目录"
}

# 执行指定命令
case "$1" in
    help)
        show_help
        ;;
    fmt)
        fmt
        ;;
    install)
        install
        ;;
    all)
        fmt
        install
        ;;
    release)
        release
        ;;
    *)
        echo "错误: 未知命令 '$1'"
        show_help
        exit 1
        ;;
esac