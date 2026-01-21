#!/bin/bash

# Docker 状态检查脚本

echo "🔍 检查 Docker 安装状态..."
echo ""

# 检查 Docker 是否已安装
if command -v docker &> /dev/null; then
    echo "✅ Docker 已安装"
    docker --version
    echo ""

    # 检查 Docker 是否正在运行
    if docker info &> /dev/null 2>&1; then
        echo "✅ Docker 正在运行"
        echo ""
        echo "🎉 Docker 已准备就绪！"
        echo ""
        echo "下一步: 运行启动脚本"
        echo "   ./start-local.sh"
    else
        echo "⚠️  Docker 已安装但未运行"
        echo ""
        echo "请执行以下步骤:"
        echo "1. 打开 Applications 文件夹"
        echo "2. 双击 Docker 图标启动"
        echo "3. 等待菜单栏的 Docker 图标不再闪烁"
        echo "4. 再次运行此脚本检查状态"
    fi
else
    echo "⏳ Docker 尚未安装完成"
    echo ""
    echo "当前状态："
    echo "- Homebrew 正在下载 Docker Desktop"
    echo "- Docker.dmg 文件约 600-800MB"
    echo "- 下载时间取决于网络速度（通常 3-10 分钟）"
    echo ""
    echo "请稍候，安装完成后会自动继续..."
    echo ""
    echo "您可以运行以下命令查看进度："
    echo "   brew list --cask | grep docker"
fi
