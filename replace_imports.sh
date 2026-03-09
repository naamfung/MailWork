#!/bin/sh
# replace_all.sh - 替换 Go 源码和 go.mod 中的所有错误导入路径

# 创建带时间戳的备份目录
backup_dir="import_replace_backup_$(date +%Y%m%d_%H%M%S)"
mkdir "$backup_dir"
echo "创建备份目录: $backup_dir"

# 备份所有 .go 和 go.mod 文件（保留目录结构）
find . -type f \( -name '*.go' -o -name 'go.mod' \) -print | while read file; do
    # 去除开头的 "./" 以获取相对路径
    rel_path="${file#./}"
    target_dir="$backup_dir/$(dirname "$rel_path")"
    mkdir -p "$target_dir"
    cp "$file" "$backup_dir/$rel_path"
    echo "已备份: $file -> $backup_dir/$rel_path"
done

# 定义所有替换规则（按路径长度降序排列，优先替换长路径）
rules="
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
"

# 递归处理所有 .go 和 go.mod 文件
find . -type f \( -name '*.go' -o -name 'go.mod' \) -print | while read file; do
    echo "正在处理: $file"

    # 构建 sed 参数（使用 Here Document 避免子 shell 问题）
    set -- -i.bak
    while IFS= read -r rule; do
        [ -n "$rule" ] && set -- "$@" -e "$rule"
    done <<EOF
$rules
EOF

    # 执行替换（-i.bak 会生成 .bak 备份文件）
    sed "$@" "$file"
    if [ $? -eq 0 ]; then
        echo "  已修改: $file (备份为 $file.bak)"
    else
        echo "  错误: 修改 $file 失败，请检查"
    fi
done

echo ""
echo "所有文件处理完毕。原始文件已完整备份至: $backup_dir"
echo "每个被修改的文件还生成了单独的 .bak 备份。"
echo ""
echo "接下来请执行以下操作："
echo "1. 检查修改结果，可运行 grep 确认旧路径是否已清除："
echo "   grep -r 'github.com/naamfung\\|github.com/mailwork' ."
echo "2. 如果一切正常，运行 go mod tidy 验证依赖："
echo "   go mod tidy"
echo "3. 确认无误后，可删除所有备份："
echo "   rm -rf \"$backup_dir\""
echo "   find . -type f -name '*.go.bak' -delete"
echo "   find . -type f -name 'go.mod.bak' -delete"