#!/bin/bash

# 项目验证脚本
# 用于检查项目完整性和环境配置

set -e

echo "🔍 开始验证 DiedOrNot 项目..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
PASSED=0
FAILED=0
WARNING=0

# 检查函数
check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNING++))
}

echo "📋 检查项目文件结构..."
echo ""

# 检查核心文件
files=(
    "README.md"
    "DEPLOYMENT.md"
    "TESTING.md"
    "PROJECT_SUMMARY.md"
    ".env.example"
    "deploy.sh"
    "supabase/config.toml"
    "supabase/setup-cron.sql"
    "supabase/migrations/001_init.sql"
    "supabase/migrations/002_rls.sql"
    "supabase/migrations/003_cron_job.sql"
    "supabase/functions/check-missed-check-ins/index.ts"
    "supabase/functions/check-missed-check-ins/deno.json"
    "supabase/functions/send-notification-email/index.ts"
    "supabase/functions/send-notification-email/deno.json"
    "ios/DiedOrNot/Package.swift"
    "ios/DiedOrNot/Config.swift"
    "ios/DiedOrNot/App/DiedOrNotApp.swift"
    "ios/DiedOrNot/Services/SupabaseManager.swift"
    "ios/DiedOrNot/Views/CheckInView.swift"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        check_pass "文件存在: $file"
    else
        check_fail "文件缺失: $file"
    fi
done

echo ""
echo "🔧 检查开发工具..."
echo ""

# 检查 Supabase CLI
if command -v supabase &> /dev/null; then
    VERSION=$(supabase --version)
    check_pass "Supabase CLI 已安装: $VERSION"
else
    check_fail "Supabase CLI 未安装"
    echo "   安装命令: brew install supabase/tap/supabase"
fi

# 检查 Docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        VERSION=$(docker --version)
        check_pass "Docker 已安装并运行: $VERSION"
    else
        check_warn "Docker 已安装但未运行"
        echo "   请启动 Docker Desktop"
    fi
else
    check_fail "Docker 未安装"
    echo "   下载地址: https://www.docker.com/products/docker-desktop"
fi

# 检查 Deno
if command -v deno &> /dev/null; then
    VERSION=$(deno --version | head -n 1)
    check_pass "Deno 已安装: $VERSION"
else
    check_warn "Deno 未安装（可选）"
    echo "   安装命令: brew install deno"
fi

# 检查 Xcode
if command -v xcodebuild &> /dev/null; then
    VERSION=$(xcodebuild -version | head -n 1)
    check_pass "Xcode 已安装: $VERSION"
else
    check_fail "Xcode 未安装"
    echo "   从 App Store 安装 Xcode"
fi

echo ""
echo "📝 检查代码质量..."
echo ""

# 检查 Swift 文件语法
swift_files=$(find ios -name "*.swift" 2>/dev/null)
if [ -n "$swift_files" ]; then
    check_pass "找到 $(echo "$swift_files" | wc -l | xargs) 个 Swift 文件"
fi

# 检查 TypeScript 文件
ts_files=$(find supabase/functions -name "*.ts" 2>/dev/null)
if [ -n "$ts_files" ]; then
    check_pass "找到 $(echo "$ts_files" | wc -l | xargs) 个 TypeScript 文件"
fi

# 检查 SQL 文件
sql_files=$(find supabase/migrations -name "*.sql" 2>/dev/null)
if [ -n "$sql_files" ]; then
    check_pass "找到 $(echo "$sql_files" | wc -l | xargs) 个 SQL 迁移文件"
fi

echo ""
echo "🔐 检查配置文件..."
echo ""

# 检查 .env 文件
if [ -f ".env" ]; then
    check_pass ".env 文件存在"

    # 检查必要的环境变量
    if grep -q "SUPABASE_URL=" .env && grep -q "SUPABASE_ANON_KEY=" .env; then
        check_pass "环境变量已配置"
    else
        check_warn "环境变量未完全配置"
        echo "   请参考 .env.example 配置"
    fi
else
    check_warn ".env 文件不存在"
    echo "   运行: cp .env.example .env"
fi

# 检查 .gitignore
if [ -f ".gitignore" ]; then
    if grep -q ".env" .gitignore; then
        check_pass ".gitignore 已配置（包含 .env）"
    else
        check_warn ".gitignore 未包含 .env"
    fi
fi

echo ""
echo "📊 验证结果汇总"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ 通过: $PASSED${NC}"
echo -e "${YELLOW}⚠️  警告: $WARNING${NC}"
echo -e "${RED}❌ 失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 项目验证完成！"
    if [ $WARNING -gt 0 ]; then
        echo ""
        echo "💡 建议："
        echo "   1. 安装所有标记为警告的工具"
        echo "   2. 配置 .env 文件"
        echo "   3. 运行 'supabase start' 启动本地环境"
    fi
else
    echo "⚠️  项目存在问题，请修复上述失败的检查项"
    exit 1
fi

echo ""
echo "📚 下一步："
echo "   1. 查看 README.md 了解项目"
echo "   2. 查看 DEPLOYMENT.md 了解部署"
echo "   3. 查看 TESTING.md 了解测试"
echo ""
