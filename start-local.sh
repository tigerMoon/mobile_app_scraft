#!/bin/bash

# 本地启动脚本
# 用于快速启动本地开发环境

set -e

echo "🚀 DiedOrNot 本地启动脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 步骤 1: 检查工具安装
echo "📋 步骤 1/5: 检查必要工具..."
echo ""

MISSING_TOOLS=0

# 检查 Supabase CLI
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Supabase CLI 未安装${NC}"
    echo -e "${YELLOW}   正在安装 Supabase CLI...${NC}"
    brew install supabase/tap/supabase
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Supabase CLI 安装成功${NC}"
    else
        echo -e "${RED}❌ 安装失败，请手动运行: brew install supabase/tap/supabase${NC}"
        MISSING_TOOLS=1
    fi
else
    VERSION=$(supabase --version)
    echo -e "${GREEN}✅ Supabase CLI 已安装: $VERSION${NC}"
fi

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装${NC}"
    echo -e "${YELLOW}   请从以下地址下载并安装 Docker Desktop:${NC}"
    echo "   https://www.docker.com/products/docker-desktop"
    MISSING_TOOLS=1
elif ! docker info &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker 已安装但未运行${NC}"
    echo -e "${YELLOW}   请启动 Docker Desktop 后重新运行此脚本${NC}"
    MISSING_TOOLS=1
else
    echo -e "${GREEN}✅ Docker 正在运行${NC}"
fi

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${YELLOW}⚠️  Xcode 未安装（可选）${NC}"
    echo "   如需运行 iOS 应用，请从 App Store 安装 Xcode"
else
    echo -e "${GREEN}✅ Xcode 已安装${NC}"
fi

if [ $MISSING_TOOLS -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ 缺少必要工具，请安装后重新运行此脚本${NC}"
    exit 1
fi

echo ""

# 步骤 2: 检查 Supabase 状态
echo "🔍 步骤 2/5: 检查 Supabase 状态..."
echo ""

if supabase status &> /dev/null; then
    echo -e "${GREEN}✅ Supabase 已在运行${NC}"
    echo ""
    echo "当前 Supabase 信息："
    supabase status
else
    echo -e "${YELLOW}⚠️  Supabase 未运行，正在启动...${NC}"
    echo ""
    echo "⏳ 首次启动需要下载 Docker 镜像，可能需要几分钟..."
    echo ""

    supabase start

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Supabase 启动成功！${NC}"
    else
        echo ""
        echo -e "${RED}❌ Supabase 启动失败${NC}"
        echo "请检查 Docker Desktop 是否正常运行"
        exit 1
    fi
fi

echo ""

# 步骤 3: 应用数据库迁移
echo "📦 步骤 3/5: 应用数据库迁移..."
echo ""

# 检查是否已有数据库
if supabase db reset --db-url "postgresql://postgres:postgres@localhost:54322/postgres" &> /dev/null; then
    echo -e "${GREEN}✅ 数据库迁移完成${NC}"
    echo "   - users 表已创建"
    echo "   - check_ins 表已创建"
    echo "   - RLS 策略已应用"
else
    echo -e "${YELLOW}⚠️  数据库迁移失败，尝试手动重置...${NC}"
    supabase db reset
fi

echo ""

# 步骤 4: 配置环境变量
echo "⚙️  步骤 4/5: 配置环境变量..."
echo ""

if [ -f ".env" ]; then
    echo -e "${GREEN}✅ .env 文件已存在${NC}"
else
    echo -e "${YELLOW}⚠️  .env 文件不存在，正在创建...${NC}"

    # 获取 Supabase 凭证
    SUPABASE_URL="http://localhost:54321"
    ANON_KEY=$(supabase status | grep "anon key:" | awk '{print $3}')
    SERVICE_KEY=$(supabase status | grep "service_role key:" | awk '{print $3}')

    cat > .env << EOF
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
EOF

    echo -e "${GREEN}✅ .env 文件已创建${NC}"
fi

echo ""

# 步骤 5: 显示访问信息
echo "🎉 步骤 5/5: 启动完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 获取并显示凭证
SUPABASE_URL="http://localhost:54321"
STUDIO_URL="http://localhost:54323"
ANON_KEY=$(supabase status | grep "anon key:" | awk '{print $3}')

echo -e "${BLUE}📍 访问地址:${NC}"
echo "   API URL: $SUPABASE_URL"
echo "   Studio:  $STUDIO_URL"
echo ""

echo -e "${BLUE}🔑 API Keys (已保存到 .env):${NC}"
echo "   Anon Key: ${ANON_KEY:0:20}..."
echo ""

echo -e "${BLUE}📱 运行 iOS 应用:${NC}"
echo "   1. 打开 Xcode:"
echo "      ${GREEN}open ios/DiedOrNot${NC}"
echo ""
echo "   2. 在 Xcode 中，打开 ${GREEN}Config.swift${NC}"
echo ""
echo "   3. 确认配置:"
echo "      ${YELLOW}supabaseURL = URL(string: \"$SUPABASE_URL\")!${NC}"
echo "      ${YELLOW}supabaseAnonKey = \"$ANON_KEY\"${NC}"
echo ""
echo "   4. 选择模拟器并点击 Run (⌘R)"
echo ""

echo -e "${BLUE}🌐 访问 Supabase Studio:${NC}"
echo "   浏览器打开: ${GREEN}$STUDIO_URL${NC}"
echo "   在 Studio 中可以:"
echo "   - 查看表数据 (Table Editor)"
echo "   - 运行 SQL (SQL Editor)"
echo "   - 查看用户 (Authentication)"
echo ""

echo -e "${BLUE}🧪 测试 Edge Functions:${NC}"
echo "   在新终端运行:"
echo "   ${GREEN}supabase functions serve${NC}"
echo ""
echo "   测试函数:"
echo "   ${GREEN}curl http://localhost:54321/functions/v1/check-missed-check-ins \\${NC}"
echo "   ${GREEN}  -H \"Authorization: Bearer $ANON_KEY\"${NC}"
echo ""

echo -e "${BLUE}📚 查看文档:${NC}"
echo "   快速启动: ${GREEN}cat QUICKSTART.md${NC}"
echo "   测试指南: ${GREEN}cat TESTING.md${NC}"
echo "   部署指南: ${GREEN}cat DEPLOYMENT.md${NC}"
echo ""

echo -e "${BLUE}🛑 停止 Supabase:${NC}"
echo "   运行: ${GREEN}supabase stop${NC}"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✨ 本地环境已准备就绪！Happy Hacking! 🚀${NC}"
echo ""
