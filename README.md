# Died Or Not · AI Fullstack Scaffold

这是一个 **为 AI 编程时代设计的最小可用全栈 App 脚手架**，
基于真实案例「死了么」APP 抽象而来，目标是：

> **让 AI 更容易写对代码，让人类更专注业务本身。**

---

## 一、整体架构

### 技术选型

| 层级 | 技术 |
|----|----|
| 前端 | SwiftUI（声明式 UI） |
| 后端 | Supabase（ADB Supabase） |
| 认证 | Anonymous Auth |
| 数据 | PostgreSQL + RLS |
| 服务端逻辑 | Supabase Edge Functions |
| 定时任务 | Supabase Cron Jobs |

### 架构原则

- 前端即全栈（无自建后端服务）
- 声明式优先（UI / SQL / 权限）
- 数据库即规则中心（RLS）
- 最小上下文，最大确定性（AI 友好）

---

## 二、目录结构

```text
died-or-not-scaffold/
├── README.md                    # 项目说明
├── DEPLOYMENT.md                # 部署指南
├── TESTING.md                   # 测试指南
├── .env.example                 # 环境变量模板
├── deploy.sh                    # 一键部署脚本
├── supabase/
│   ├── config.toml             # Supabase 配置
│   ├── migrations/
│   │   ├── 001_init.sql        # 表结构
│   │   ├── 002_rls.sql         # 行级安全策略
│   │   └── 003_cron_job.sql    # 定时任务配置
│   ├── setup-cron.sql          # Cron 任务设置脚本
│   └── functions/
│       ├── check-missed-check-ins/
│       │   ├── index.ts        # 定时扫描未签到用户
│       │   └── deno.json       # Deno 配置
│       └── send-notification-email/
│           ├── index.ts        # 发送通知
│           └── deno.json       # Deno 配置
└── ios/
    └── DiedOrNot/
        ├── Package.swift        # Swift Package 配置
        ├── Config.swift         # 应用配置
        ├── App/
        │   └── DiedOrNotApp.swift
        ├── Services/
        │   └── SupabaseManager.swift  # Supabase 客户端管理
        └── Views/
            └── CheckInView.swift
```

---

## 三、核心能力说明

### 1. 匿名认证（Anonymous Auth）

- App 首次启动即匿名登录
- Supabase 自动生成 user_id
- 无注册 / 无密码 / 无感绑定
- 数据通过 RLS 自动隔离

适合 MVP / 单设备场景。

---

### 2. 数据库即规则

**防重复签到**：

```sql
unique (user_id, check_in_date)
```

**权限隔离**：

```sql
auth.uid() = user_id
```

所有安全规则前移至数据库层，
避免 AI 在业务代码中反复写错权限判断。

---

### 3. Edge Functions

#### check-missed-check-ins

- 每天由 Cron 触发
- 扫描所有用户最近签到时间
- 连续 2 天未签到 → 触发通知

#### send-notification-email

- 接收用户信息
- 发送邮件 / 可扩展短信、微信、钉钉

服务端逻辑 **极少、确定、可替换**。

---

## 四、快速开始

### 方式一：本地开发环境

#### 1. 安装依赖

```bash
# 安装 Supabase CLI
brew install supabase/tap/supabase

# 安装 Deno（用于 Edge Functions）
brew install deno
```

#### 2. 启动本地 Supabase

```bash
# 启动本地 Supabase（需要 Docker）
supabase start

# 应用数据库迁移
supabase db reset
```

#### 3. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，填入 supabase start 输出的本地凭证
```

#### 4. 运行 iOS 应用

```bash
# 使用 Xcode 打开项目
open ios/DiedOrNot

# 在 Config.swift 中配置本地 URL
# 然后在 Xcode 中 Run
```

---

### 方式二：使用云端 Supabase

#### 1. 创建 Supabase 项目

访问 [Supabase](https://supabase.com) 创建新项目

#### 2. 一键部署

```bash
# 登录 Supabase
supabase login

# 关联项目
supabase link --project-ref <你的项目ID>

# 一键部署
./deploy.sh
```

#### 3. 配置定时任务

在 Supabase SQL Editor 中执行 `supabase/setup-cron.sql`（替换项目 URL 和密钥）

#### 4. 配置 iOS 应用

在 [Config.swift](ios/DiedOrNot/Config.swift) 中填入你的 Supabase URL 和 API Key

---

### 详细文档

- [部署指南](DEPLOYMENT.md) - 完整的生产环境部署说明
- [测试指南](TESTING.md) - 各项功能的测试方法

---

## 五、核心功能实现

### 1. iOS 应用

#### SupabaseManager（服务层）
- 自动匿名登录
- 创建用户记录
- 签到功能（防重复）
- 查询签到状态

#### CheckInView（视图层）
- 响应式 UI
- 加载状态管理
- 错误处理和展示
- 用户 ID 显示

### 2. Edge Functions

#### check-missed-check-ins
- 扫描所有用户最后签到时间
- 计算距今天数
- 超过 2 天触发通知
- 返回详细执行结果

#### send-notification-email
- 接收用户信息
- 记录通知日志
- 可扩展邮件服务集成（SendGrid / AWS SES）

### 3. 数据库设计

#### 表结构
- `users` - 用户信息（id, name, emergency_email）
- `check_ins` - 签到记录（user_id, check_in_date）

#### 安全策略
- RLS 行级安全：用户只能访问自己的数据
- 唯一约束：防止同一天重复签到
- 外键约束：数据完整性保证

---

## 六、适用场景

- AI 快速落地 MVP
- 个人 / 小团队 App
- 前端主导的全栈应用
- 无复杂后端工程需求
- 学习 Supabase + SwiftUI 全栈开发

---

## 七、设计哲学

> AI 编程时代，
> **最重要的不是写多少代码，而是设计多少"不会被写错的约束"。**

这个脚手架的目标是：

- 减少后端工程复杂度
- 压缩上下文规模
- 提高 AI 输出的确定性
- 支撑持续迭代而不返工

### AI 友好的设计原则

1. **声明式优先** - SwiftUI / SQL / RLS 都是声明式，减少过程式代码
2. **约束前置** - 数据库层面的约束，不依赖业务代码
3. **最小惊讶** - 功能行为符合直觉，减少心智负担
4. **可观测性** - 完善的日志和错误信息

---

## 八、技术亮点

### 1. 无后端服务器
完全基于 Supabase BaaS，无需自建后端服务器、无需容器编排、无需负载均衡。

### 2. 行级安全（RLS）
数据访问控制在数据库层面实现，前端代码无需关心权限判断。

### 3. 匿名认证
用户无需注册即可使用，降低使用门槛，适合快速验证想法。

### 4. Edge Functions
使用 Deno 运行时，接近零冷启动，全球分布式部署。

### 5. 定时任务
使用 PostgreSQL 原生 pg_cron，无需额外的任务调度服务。

---

## 九、下一步扩展建议

### 功能扩展
- [ ] 添加用户资料编辑功能
- [ ] 集成真实邮件服务（SendGrid / AWS SES / Resend）
- [ ] 添加推送通知（APNs）
- [ ] 实现签到历史查看
- [ ] 添加统计图表

### 技术扩展
- [ ] 添加 Android 应用（Kotlin + Jetpack Compose）
- [ ] 添加 Web 应用（React / Vue / Svelte）
- [ ] 实现账号关联（从匿名升级到正式账号）
- [ ] 添加单元测试和 E2E 测试
- [ ] 性能监控和错误追踪

### AI 工程扩展
- [ ] 抽象为通用 AI App Starter
- [ ] 封装成 CLI（create-ai-app）
- [ ] 增加 Rules / Skills 约束 AI 编码
- [ ] 提供更多场景模板

---

## 十、常见问题

### Q: 为什么选择 Supabase 而不是 Firebase？
A: Supabase 基于 PostgreSQL，数据模型更灵活，RLS 更强大，且完全开源。

### Q: 匿名账号会过期吗？
A: 默认不会过期，但可以在 Supabase 控制台配置过期策略。

### Q: 可以迁移到自己的服务器吗？
A: 可以，Supabase 是开源的，可以自托管。

### Q: 如何扩展到多平台？
A: Supabase SDK 支持多平台（iOS / Android / Web / Flutter），可以复用后端逻辑。

---

## 十一、参考资源

- [Supabase 官方文档](https://supabase.com/docs)
- [SwiftUI 官方教程](https://developer.apple.com/tutorials/swiftui)
- [Deno 官方文档](https://deno.land/manual)
- [PostgreSQL RLS 文档](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)

---

Happy hacking! 🚀

有问题欢迎提 Issue 或 PR。
