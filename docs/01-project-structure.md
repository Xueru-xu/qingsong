# 青松管家 V1.0 MVP 项目目录结构

> 技术栈：微信小程序 + Taro + React + TypeScript + ECharts；NestJS + TypeORM + MySQL + JWT；微信订阅消息。

```text
qingsong/
├── apps/
│   ├── weapp/                         # 微信小程序前端（Taro + React + TypeScript）
│   │   ├── src/
│   │   │   ├── api/                   # 后端接口封装、请求拦截、JWT 注入
│   │   │   ├── assets/                # 图片、图标、全局样式资源
│   │   │   ├── components/            # 老年友好通用组件（大按钮、卡片、表单项）
│   │   │   ├── config/                # 环境变量、路由、ECharts 配置
│   │   │   ├── hooks/                 # React Hooks（登录态、数据加载、表单）
│   │   │   ├── pages/
│   │   │   │   ├── login/             # 登录页：微信登录 / 手机号绑定 / JWT 写入
│   │   │   │   ├── parent-profile/    # 父母档案页：基本信息、紧急联系人、关系绑定
│   │   │   │   ├── health-record/     # 健康记录页：血压、血糖、体重录入与列表
│   │   │   │   ├── visit-record/      # 就诊记录页：医院、科室、诊断、图片/文件上传
│   │   │   │   ├── medication-reminder/# 用药提醒页：药品、剂量、提醒时间、订阅消息
│   │   │   │   └── trend-chart/       # 趋势图页：ECharts 展示血压/血糖/体重趋势
│   │   │   ├── store/                 # 状态管理（用户、家庭成员、健康数据缓存）
│   │   │   ├── types/                 # 前端 TypeScript 类型定义
│   │   │   └── utils/                 # 时间格式化、单位换算、表单校验、上传工具
│   │   └── .gitkeep
│   │
│   └── api/                           # 后端服务（NestJS + TypeORM + MySQL）
│       ├── src/
│       │   ├── common/                # 通用能力
│       │   │   ├── decorators/        # 当前用户、角色等装饰器
│       │   │   ├── filters/           # 全局异常过滤器
│       │   │   ├── guards/            # JWT、角色、家庭权限守卫
│       │   │   ├── interceptors/      # 响应格式、日志、文件上传拦截器
│       │   │   └── pipes/             # DTO 校验与转换
│       │   ├── config/                # App、数据库、JWT、微信、上传配置
│       │   ├── database/              # TypeORM 数据源、迁移入口、种子数据
│       │   ├── migrations/            # 数据库迁移文件
│       │   └── modules/
│       │       ├── auth/              # 登录认证：微信 code 换 openId、JWT 签发
│       │       ├── users/             # 用户：父母/子女账号、资料、手机号
│       │       ├── families/          # 家庭关系：子女绑定父母、授权查看
│       │       ├── health-records/    # 健康数据：血压、血糖、体重 CRUD
│       │       ├── visit-records/     # 就诊记录：病历、处方、检查报告、附件
│       │       ├── medication-reminders/# 用药提醒：规则、执行时间、订阅消息触发
│       │       ├── files/             # 文件上传：本地存储 / OSS 适配
│       │       └── wechat/            # 微信接口：订阅消息、用户信息、模板配置
│       ├── uploads/                   # 本地上传文件（开发/测试）
│       └── test/                      # 单元测试、e2e 测试
│
├── docs/                              # 需求、数据库、API、前端模块说明
│   └── 01-project-structure.md        # 当前文件：MVP 目录结构
│
├── infra/                             # 部署与外部服务配置
│   ├── mysql/                         # MySQL 初始化脚本、开发环境配置
│   ├── oss/                           # OSS 示例配置与上传策略说明
│   └── wechat/                        # 微信订阅消息模板、权限配置说明
│
└── scripts/                           # 本地开发、构建、迁移、部署脚本
```

## 模块边界

| 模块 | 前端目录 | 后端目录 | MVP 职责 |
| --- | --- | --- | --- |
| 登录 | `apps/weapp/src/pages/login` | `apps/api/src/modules/auth` | 微信登录、JWT 获取、登录态维护 |
| 家庭成员 | `apps/weapp/src/pages/parent-profile` | `apps/api/src/modules/families` | 父母档案、子女绑定、查看授权 |
| 健康数据 | `apps/weapp/src/pages/health-record` | `apps/api/src/modules/health-records` | 血压/血糖/体重录入、列表、详情 |
| 就诊记录 | `apps/weapp/src/pages/visit-record` | `apps/api/src/modules/visit-records` | 就诊信息、病历/处方/报告附件上传 |
| 用药提醒 | `apps/weapp/src/pages/medication-reminder` | `apps/api/src/modules/medication-reminders` | 药品、剂量、提醒时间、订阅消息 |
| 趋势图 | `apps/weapp/src/pages/trend-chart` | `apps/api/src/modules/health-records` | ECharts 趋势展示、按家庭成员筛选 |
| 文件上传 | `apps/weapp/src/utils` | `apps/api/src/modules/files` | 本地/OSS 上传、附件元数据管理 |
| 微信能力 | `apps/weapp/src/api` | `apps/api/src/modules/wechat` | 微信 code、订阅消息、模板消息参数 |
