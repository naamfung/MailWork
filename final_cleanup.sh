#!/bin/sh
# final_cleanup.sh - 最终清理：替换所有残留的旧导入路径（包括 go.mod、文档、源码）

# 创建新的备份目录（避免覆盖之前的）
backup_dir="final_cleanup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir "$backup_dir"
echo "创建备份目录: $backup_dir"

# 备份所有可能受影响的文件（保留目录结构）
find . -type f \
    \( -name '*.go' -o -name 'go.mod' -o -name '*.md' -o -name '*.txt' -o -name '*.yaml' -o -name '*.yml' \) \
    ! -path '*/.git/*' ! -path '*/import_replace_backup*' ! -path '*/final_cleanup_backup*' -print | while read file; do
    rel_path="${file#./}"
    target_dir="$backup_dir/$(dirname "$rel_path")"
    mkdir -p "$target_dir"
    cp "$file" "$backup_dir/$rel_path"
    echo "已备份: $file"
done

# 完整替换规则（按长度降序，包含所有裸模块路径）
rules="
# github.com/naamfung 深层路径
s#github\.com/naamfung/MailWork/MailWork-Server/api#MailWork/MailWork-Server/api#g
s#github\.com/naamfung/MailWork/MailWork-Server/config#MailWork/MailWork-Server/config#g
s#github\.com/naamfung/MailWork/MailWork-Server/imap#MailWork/MailWork-Server/imap#g
s#github\.com/naamfung/MailWork/MailWork-Server/smtp#MailWork/MailWork-Server/smtp#g
s#github\.com/naamfung/MailWork-UI/assets#MailWork/MailWork-UI/assets#g
s#github\.com/naamfung/MailWork-UI/config#MailWork/MailWork-UI/config#g
s#github\.com/naamfung/MailWork-UI/web#MailWork/MailWork-UI/web#g
s#github\.com/naamfung/MailWork/config#MailWork/config#g
s#github\.com/naamfung/mhsendmail/cmd#MailWork/mhsendmail/cmd#g
s#github\.com/naamfung/http#MailWork/http#g
s#github\.com/naamfung/MailWork-Server#MailWork/MailWork-Server#g
s#github\.com/naamfung/data#MailWork/data#g
s#github\.com/naamfung/smtp#MailWork/smtp#g
s#github\.com/naamfung/storage#MailWork/storage#g
s#github\.com/naamfung/mhsendmail#MailWork/mhsendmail#g
s#github\.com/naamfung/MailWork-UI#MailWork/MailWork-UI#g
s#github\.com/naamfung/MailWork#MailWork#g

# github.com/mailwork 深层路径
s#github\.com/mailwork/MailWork-UI/assets#MailWork/MailWork-UI/assets#g
s#github\.com/mailwork/MailWork-UI/config#MailWork/MailWork-UI/config#g
s#github\.com/mailwork/MailWork-UI/web#MailWork/MailWork-UI/web#g
s#github\.com/mailwork/MailWork/config#MailWork/MailWork/config#g
s#github\.com/mailwork/http#MailWork/http#g
s#github\.com/mailwork/data#MailWork/data#g
s#github\.com/mailwork/storage#MailWork/storage#g
s#github\.com/mailwork/MailWork-Server/api#MailWork/MailWork-Server/api#g
s#github\.com/mailwork/MailWork-Server/config#MailWork/MailWork-Server/config#g
s#github\.com/mailwork/MailWork-Server/smtp#MailWork/MailWork-Server/smtp#g
s#github\.com/mailwork/MailWork-Server/imap#MailWork/MailWork-Server/imap#g
s#github\.com/mailwork/mhsendmail#MailWork/mhsendmail#g
s#github\.com/mailwork/MailWork-UI#MailWork/MailWork-UI#g
s#github\.com/mailwork/MailWork-Server#MailWork/MailWork-Server#g
s#github\.com/mailwork/MailWork#MailWork#g
"

# 递归处理所有相关文件（排除 .git 和备份目录）
find . -type f \
    \( -name '*.go' -o -name 'go.mod' -o -name '*.md' -o -name '*.txt' -o -name '*.yaml' -o -name '*.yml' \) \
    ! -path '*/.git/*' ! -path '*/import_replace_backup*' ! -path '*/final_cleanup_backup*' -print | while read file; do

    echo "正在处理: $file"

    # 构建 sed 参数（使用 Here Document 避免子 shell 问题）
    set -- -i.bak
    while IFS= read -r rule; do
        # 跳过注释行和空行
        case "$rule" in
            \#*|"") continue ;;
            *) set -- "$@" -e "$rule" ;;
        esac
    done <<EOF
$rules
EOF

    # 执行替换
    sed "$@" "$file"
    if [ $? -eq 0 ]; then
        echo "  已修改: $file (备份为 $file.bak)"
    else
        echo "  错误: 修改 $file 失败，请检查"
    fi
done

echo ""
echo "============================================================"
echo "所有文件处理完毕。原始文件已完整备份至: $backup_dir"
echo "每个被修改的文件还生成了单独的 .bak 备份。"
echo ""
echo "接下来请执行以下操作："
echo "1. 检查修改结果，确认旧路径是否已清除："
echo "   grep -r 'github.com/naamfung\\|github.com/mailwork' . | grep -v '\\.bak' | grep -v 'final_cleanup_backup'"
echo ""
echo "2. 如果一切正常，运行 go mod tidy 验证依赖："
echo "   go mod tidy"
echo ""
echo "3. 确认无误后，可删除所有备份："
echo "   rm -rf \"$backup_dir\""
echo "   find . -type f -name '*.go.bak' -delete"
echo "   find . -type f -name 'go.mod.bak' -delete"
echo "   find . -type f -name '*.md.bak' -delete"
echo "   # 以及其他文档备份"
echo ""
echo "4. 更新 Git 远程地址（如果需要）："
echo "   git remote set-url origin <新仓库地址>"
echo "============================================================"