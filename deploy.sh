#!/bin/bash

# 死了么 · 部署脚本
# 用于快速部署 Supabase 数据库和 Edge Functions

set -e  # 遇到错误立即退出

echo "🚀 开始部署 DiedOrNot 应用..."
echo ""

# 检查 Supabase CLI
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI 未安装"
    echo "请运行: brew install supabase/tap/supabase"
    exit 1
fi

echo "✅ Supabase CLI 已安装"
echo ""

# 检查是否已登录
if ! supabase projects list &> /dev/null; then
    echo "❌ 未登录 Supabase"
    echo "请运行: supabase login"
    exit 1
fi

echo "✅ 已登录 Supabase"
echo ""

# 检查是否已关联项目
if [ ! -f ".git/config" ] || ! grep -q "supabase" ".git/config" 2>/dev/null; then
    echo "⚠️  未检测到项目关联"
    echo "请先运行: supabase link --project-ref <你的项目ID>"
    exit 1
fi

echo "✅ 项目已关联"
echo ""

# 部署数据库迁移
echo "📦 开始部署数据库迁移..."
supabase db push

if [ $? -eq 0 ]; then
    echo "✅ 数据库迁移完成"
else
    echo "❌ 数据库迁移失败"
    exit 1
fi
echo ""

# 部署 Edge Functions
echo "⚡️ 开始部署 Edge Functions..."

echo "  → 部署 check-missed-check-ins..."
supabase functions deploy check-missed-check-ins --no-verify-jwt

echo "  → 部署 send-notification-email..."
supabase functions deploy send-notification-email --no-verify-jwt

if [ $? -eq 0 ]; then
    echo "✅ Edge Functions 部署完成"
else
    echo "❌ Edge Functions 部署失败"
    exit 1
fi
echo ""

# 完成
echo "🎉 部署完成！"
echo ""
echo "下一步："
echo "1. 在 Supabase 控制台配置环境变量（SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY）"
echo "2. 配置定时任务（参考 DEPLOYMENT.md）"
echo "3. 配置 iOS 应用的 .env 文件"
echo "4. 运行 iOS 应用进行测试"
echo ""
