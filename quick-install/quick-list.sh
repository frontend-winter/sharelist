#!/bin/bash
set -e

## 克隆仓库到本地
echo "clone repository..."
git clone https://github.com/frontend-winter/sharelist.git sharelist


# 设置目录名
dir_name="list"
# 检查目录是否存在
if [ -d "$dir_name" ]; then
    # 目录存在，删除其下的所有文件
    rm -rf "${dir_name:?}"/*
    echo "已删除 '$dir_name' 下的所有文件。"
else
    # 目录不存在，创建目录并设置权限
    mkdir "$dir_name"
    chmod -R 755 "$dir_name"
    echo "已创建目录 '$dir_name' 并设置权限为 755。"
fi
cd sharelist
mv dist/* ../list
cd ..
chmod -R 755 list

yaml_file="./docker-compose.yml"

# 要检查和添加的映射
check_volume="./list:/app/resource/public/list"

# 检查文件是否存在
if [ ! -f "$yaml_file" ]; then
    echo "文件不存在: $yaml_file"
    exit 1
fi

# 检查是否已经存在该映射
if grep -q "$check_volume" "$yaml_file"; then
    echo "映射 '$check_volume' 已存在，无需添加。"
    rm -rf sharelist
    rm -rf quick-list.sh
    echo "已完成前端页面的更换"
    exit 0
fi

# 定义要添加的新映射
new_volume="      - ./list:/app/resource/public/list"

# 使用 awk 更新 docker-compose.yml
awk -v new_volume="$new_volume" '
BEGIN {
    in_chatgpt_share_server = 0;
    in_volumes = 0;
}
/chatgpt-share-server:/ {
    in_chatgpt_share_server = 1;
}
in_chatgpt_share_server && /volumes:/ {
    in_volumes = 1;
    print;
    next;
}
in_volumes && /^[ ]+- / {
    print new_volume;
    in_volumes = 0;
    in_chatgpt_share_server = 0;
}
{ print }
' docker-compose.yml > tmp_file && mv tmp_file docker-compose.yml

# 添加成功后运行 Docker 命令
if [ $? -eq 0 ]; then
    echo "映射 '$new_volume' 添加成功"
else
    echo "映射存在"
fi

rm -rf sharelist
rm -rf quick-list.sh
docker compose pull
docker compose up -d --remove-orphans
## 提示信息
echo "已完成前端页面的更换"
