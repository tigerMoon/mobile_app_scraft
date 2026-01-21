#!/bin/bash

# Docker 镜像加速配置脚本

echo "⚙️  配置 Docker 镜像加速..."
echo ""

DOCKER_CONFIG_DIR="$HOME/.docker"
DOCKER_CONFIG_FILE="$DOCKER_CONFIG_DIR/daemon.json"

# 创建配置目录
mkdir -p "$DOCKER_CONFIG_DIR"

# 备份现有配置
if [ -f "$DOCKER_CONFIG_FILE" ]; then
    cp "$DOCKER_CONFIG_FILE" "$DOCKER_CONFIG_FILE.backup"
    echo "✅ 已备份现有配置到 daemon.json.backup"
fi

# 写入镜像加速配置
cat > "$DOCKER_CONFIG_FILE" << 'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.unsee.tech",
    "https://docker.1ms.run"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

echo "✅ Docker 镜像加速配置已写入"
echo ""
echo "📋 配置内容:"
cat "$DOCKER_CONFIG_FILE"
echo ""
echo "⚠️  重要：需要重启 Docker Desktop 才能生效"
echo ""
echo "重启步骤："
echo "1. 点击菜单栏的 Docker 图标"
echo "2. 选择 'Restart'"
echo "3. 等待 Docker 重启完成（图标不再闪烁）"
echo "4. 重新运行: ./start-local.sh"
echo ""
