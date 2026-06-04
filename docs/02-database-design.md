# 青松管家 V1.0 MVP 数据库设计

> 数据库：MySQL 8.x；字符集：`utf8mb4`；时间统一存储为 `DATETIME`；业务删除采用 `deleted_at` 软删除。

## 核心实体

| 表名 | 说明 | 关键关系 |
| --- | --- | --- |
| `users` | 用户账号，覆盖父母与子女 | 通过 `family_members` 加入家庭 |
| `families` | 家庭空间 | 一个家庭包含多个成员 |
| `family_members` | 家庭成员关系与角色 | 关联 `families` 与 `users` |
| `parent_profiles` | 父母健康档案 | 一名父母用户一份基础档案 |
| `health_records` | 血压、血糖、体重记录 | 子女可按家庭授权查看父母数据 |
| `visit_records` | 就诊记录 | 关联父母用户和录入人 |
| `files` | 上传文件元数据 | 可挂载到就诊记录等业务对象 |
| `medication_reminders` | 用药提醒规则 | 关联父母用户和创建人 |
| `medication_reminder_logs` | 提醒发送/执行日志 | 追踪微信订阅消息发送状态 |
| `wechat_subscriptions` | 微信订阅授权记录 | 用于判断是否可发送订阅消息 |

## 设计要点

1. `users.role` 表示用户默认身份，实际家庭内权限以 `family_members.member_role` 为准。
2. 子女查看父母数据时，后端必须校验二者是否在同一 `family_id` 且成员状态为 `active`。
3. 健康记录统一存放在 `health_records`，通过 `record_type` 区分血压、血糖、体重，便于趋势图统一查询。
4. 文件表使用 `owner_type + owner_id` 做弱关联，MVP 可先支持本地上传，后续平滑扩展 OSS。
5. 用药提醒先存储规则和提醒时间，由后端定时任务扫描后调用微信订阅消息。

## 初始化 SQL

完整 SQL 位于：`infra/mysql/001_init.sql`。
