#!/bin/sh

# 构建和部署 MailWork Docker 容器的脚本

# 镜像名称
IMAGE_NAME="naamfung/mailwork"

# 容器名称
CONTAINER_NAME="mailwork"

# 端口映射
SMTP_PORT=1025
IMAP_PORT=143
HTTP_PORT=8025

# 存储类型 (memory, mongodb, maildir)
STORAGE_TYPE="memory"

# Maildir 路径 (仅当 STORAGE_TYPE=maildir 时使用)
MAILDIR_PATH="./maildir"

# 显示帮助信息
show_help() {
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示帮助信息"
    echo "  -b, --build         构建 Docker 镜像"
    echo "  -r, --run           运行 Docker 容器"
    echo "  -d, --detach        后台运行容器"
    echo "  -p, --pull          从 Docker Hub 拉取镜像"
    echo "  -s, --stop          停止并移除容器"
    echo "  --storage <type>     设置存储类型 (memory, mongodb, maildir)"
    echo "  --maildir <path>     设置 Maildir 路径 (仅当 storage=maildir 时使用)"
    echo "  --image <name>       设置镜像名称"
    echo "  --container <name>   设置容器名称"
    echo ""
    echo "示例:"
    echo "  $0 --build --run              # 构建镜像并运行容器"
    echo "  $0 --pull --run --detach      # 拉取镜像并后台运行容器"
    echo "  $0 --run --storage maildir    # 使用 Maildir 存储运行容器"
}

# 构建镜像
build_image() {
    echo "构建 Docker 镜像: $IMAGE_NAME"
    docker build -t "$IMAGE_NAME" .
    if [ $? -eq 0 ]; then
        echo "镜像构建成功！"
    else
        echo "镜像构建失败，请检查错误信息。"
        exit 1
    fi
}

# 拉取镜像
pull_image() {
    echo "从 Docker Hub 拉取镜像: $IMAGE_NAME"
    docker pull "$IMAGE_NAME"
    if [ $? -eq 0 ]; then
        echo "镜像拉取成功！"
    else
        echo "镜像拉取失败，请检查错误信息。"
        exit 1
    fi
}

# 运行容器
run_container() {
    # 检查容器是否已存在
    if docker ps -a | grep -q "$CONTAINER_NAME"; then
        echo "容器 $CONTAINER_NAME 已存在，正在停止并移除..."
        docker stop "$CONTAINER_NAME" > /dev/null 2>&1
        docker rm "$CONTAINER_NAME" > /dev/null 2>&1
    fi

    # 准备运行命令
    RUN_CMD="docker run"
    
    # 如果需要后台运行
    if [ "$DETACH" = "true" ]; then
        RUN_CMD="$RUN_CMD -d"
    fi
    
    # 设置容器名称
    RUN_CMD="$RUN_CMD --name "$CONTAINER_NAME""
    
    # 映射端口
    RUN_CMD="$RUN_CMD -p $SMTP_PORT:1025 -p $IMAP_PORT:143 -p $HTTP_PORT:8025"
    
    # 设置存储类型
    if [ "$STORAGE_TYPE" = "maildir" ]; then
        # 创建 Maildir 目录
        mkdir -p "$MAILDIR_PATH"
        RUN_CMD="$RUN_CMD -e MH_STORAGE=maildir -v "$(realpath "$MAILDIR_PATH")":/maildir"
    elif [ "$STORAGE_TYPE" = "mongodb" ]; then
        RUN_CMD="$RUN_CMD -e MH_STORAGE=mongodb"
    fi
    
    # 添加镜像名称
    RUN_CMD="$RUN_CMD $IMAGE_NAME"
    
    echo "运行 Docker 容器: $CONTAINER_NAME"
    echo "命令: $RUN_CMD"
    
    # 执行运行命令
    eval $RUN_CMD
    
    if [ $? -eq 0 ]; then
        echo "容器运行成功！"
        echo "SMTP 端口: $SMTP_PORT"
        echo "IMAP 端口: $IMAP_PORT"
        echo "HTTP 端口: $HTTP_PORT"
        echo "存储类型: $STORAGE_TYPE"
        if [ "$STORAGE_TYPE" = "maildir" ]; then
            echo "Maildir 路径: $MAILDIR_PATH"
        fi
    else
        echo "容器运行失败，请检查错误信息。"
        exit 1
    fi
}

# 停止并移除容器
stop_container() {
    echo "停止并移除容器: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" > /dev/null 2>&1
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "容器已停止并移除。"
    else
        echo "容器停止或移除失败，请检查错误信息。"
        exit 1
    fi
}

# 解析命令行参数
DETACH="false"
BUILD="false"
RUN="false"
PULL="false"
STOP="false"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build)
            BUILD="true"
            shift
            ;;
        -r|--run)
            RUN="true"
            shift
            ;;
        -d|--detach)
            DETACH="true"
            shift
            ;;
        -p|--pull)
            PULL="true"
            shift
            ;;
        -s|--stop)
            STOP="true"
            shift
            ;;
        --storage)
            if [ $# -gt 1 ]; then
                STORAGE_TYPE="$2"
                shift 2
            else
                echo "错误: --storage 需要指定存储类型"
                show_help
                exit 1
            fi
            ;;
        --maildir)
            if [ $# -gt 1 ]; then
                MAILDIR_PATH="$2"
                shift 2
            else
                echo "错误: --maildir 需要指定路径"
                show_help
                exit 1
            fi
            ;;
        --image)
            if [ $# -gt 1 ]; then
                IMAGE_NAME="$2"
                shift 2
            else
                echo "错误: --image 需要指定镜像名称"
                show_help
                exit 1
            fi
            ;;
        --container)
            if [ $# -gt 1 ]; then
                CONTAINER_NAME="$2"
                shift 2
            else
                echo "错误: --container 需要指定容器名称"
                show_help
                exit 1
            fi
            ;;
        *)
            echo "错误: 未知选项 '$1'"
            show_help
            exit 1
            ;;
    esac
done

# 执行操作
if [ "$STOP" = "true" ]; then
    stop_container
elif [ "$BUILD" = "true" ] || [ "$RUN" = "true" ] || [ "$PULL" = "true" ]; then
    if [ "$BUILD" = "true" ]; then
        build_image
    fi
    if [ "$PULL" = "true" ]; then
        pull_image
    fi
    if [ "$RUN" = "true" ]; then
        run_container
    fi
else
    echo "错误: 请指定至少一个操作 (--build, --run, --pull, --stop)"
    show_help
    exit 1
fi