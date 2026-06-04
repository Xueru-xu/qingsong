-- 青松管家 V1.0 MVP MySQL 初始化脚本
-- MySQL 8.x / utf8mb4

CREATE DATABASE IF NOT EXISTS qingsong
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE qingsong;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  open_id VARCHAR(128) NOT NULL COMMENT '微信 openId',
  union_id VARCHAR(128) NULL COMMENT '微信 unionId',
  phone VARCHAR(32) NULL COMMENT '手机号',
  nickname VARCHAR(64) NULL COMMENT '昵称',
  avatar_url VARCHAR(512) NULL COMMENT '头像URL',
  role ENUM('parent', 'child', 'admin') NOT NULL DEFAULT 'parent' COMMENT '默认用户角色',
  gender ENUM('unknown', 'male', 'female') NOT NULL DEFAULT 'unknown' COMMENT '性别',
  birthday DATE NULL COMMENT '生日',
  status ENUM('active', 'disabled') NOT NULL DEFAULT 'active' COMMENT '账号状态',
  last_login_at DATETIME NULL COMMENT '最后登录时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_open_id (open_id),
  KEY idx_users_phone (phone),
  KEY idx_users_role_status (role, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户账号';

CREATE TABLE IF NOT EXISTS families (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '家庭ID',
  name VARCHAR(64) NOT NULL COMMENT '家庭名称',
  invite_code VARCHAR(16) NOT NULL COMMENT '家庭邀请码',
  owner_user_id BIGINT UNSIGNED NOT NULL COMMENT '家庭创建人/管理员',
  status ENUM('active', 'disabled') NOT NULL DEFAULT 'active' COMMENT '家庭状态',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_families_invite_code (invite_code),
  KEY idx_families_owner_user_id (owner_user_id),
  CONSTRAINT fk_families_owner_user_id FOREIGN KEY (owner_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家庭空间';

CREATE TABLE IF NOT EXISTS family_members (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '家庭成员ID',
  family_id BIGINT UNSIGNED NOT NULL COMMENT '家庭ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  member_role ENUM('parent', 'child', 'admin') NOT NULL COMMENT '家庭内角色',
  display_name VARCHAR(64) NULL COMMENT '家庭内显示名称',
  relationship VARCHAR(32) NULL COMMENT '关系：父亲/母亲/儿子/女儿等',
  status ENUM('pending', 'active', 'rejected', 'removed') NOT NULL DEFAULT 'active' COMMENT '成员状态',
  joined_at DATETIME NULL COMMENT '加入时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_family_members_family_user (family_id, user_id),
  KEY idx_family_members_user_status (user_id, status),
  KEY idx_family_members_family_role (family_id, member_role),
  CONSTRAINT fk_family_members_family_id FOREIGN KEY (family_id) REFERENCES families(id),
  CONSTRAINT fk_family_members_user_id FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家庭成员关系';

CREATE TABLE IF NOT EXISTS parent_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '档案ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '父母用户ID',
  real_name VARCHAR(64) NOT NULL COMMENT '真实姓名',
  id_card_no VARCHAR(32) NULL COMMENT '身份证号，可按合规要求加密存储',
  emergency_contact_name VARCHAR(64) NULL COMMENT '紧急联系人姓名',
  emergency_contact_phone VARCHAR(32) NULL COMMENT '紧急联系人电话',
  chronic_diseases VARCHAR(512) NULL COMMENT '慢病信息，如高血压/糖尿病',
  allergy_history VARCHAR(512) NULL COMMENT '过敏史',
  medical_history TEXT NULL COMMENT '既往病史',
  height_cm DECIMAL(5,2) NULL COMMENT '身高 cm',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_parent_profiles_user_id (user_id),
  CONSTRAINT fk_parent_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='父母健康档案';

CREATE TABLE IF NOT EXISTS health_records (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '健康记录ID',
  parent_user_id BIGINT UNSIGNED NOT NULL COMMENT '父母用户ID',
  recorder_user_id BIGINT UNSIGNED NOT NULL COMMENT '录入人用户ID',
  record_type ENUM('blood_pressure', 'blood_glucose', 'weight') NOT NULL COMMENT '记录类型',
  systolic_mmHg SMALLINT UNSIGNED NULL COMMENT '收缩压 mmHg',
  diastolic_mmHg SMALLINT UNSIGNED NULL COMMENT '舒张压 mmHg',
  heart_rate_bpm SMALLINT UNSIGNED NULL COMMENT '心率 bpm',
  glucose_mmol_l DECIMAL(5,2) NULL COMMENT '血糖 mmol/L',
  glucose_period ENUM('fasting', 'before_meal', 'after_meal', 'bedtime', 'random') NULL COMMENT '血糖测量时段',
  weight_kg DECIMAL(5,2) NULL COMMENT '体重 kg',
  measured_at DATETIME NOT NULL COMMENT '测量时间',
  note VARCHAR(512) NULL COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_health_records_parent_type_time (parent_user_id, record_type, measured_at),
  KEY idx_health_records_recorder_user_id (recorder_user_id),
  CONSTRAINT fk_health_records_parent_user_id FOREIGN KEY (parent_user_id) REFERENCES users(id),
  CONSTRAINT fk_health_records_recorder_user_id FOREIGN KEY (recorder_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='健康数据记录';

CREATE TABLE IF NOT EXISTS visit_records (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '就诊记录ID',
  parent_user_id BIGINT UNSIGNED NOT NULL COMMENT '父母用户ID',
  recorder_user_id BIGINT UNSIGNED NOT NULL COMMENT '录入人用户ID',
  hospital_name VARCHAR(128) NOT NULL COMMENT '医院名称',
  department VARCHAR(64) NULL COMMENT '科室',
  doctor_name VARCHAR(64) NULL COMMENT '医生姓名',
  diagnosis VARCHAR(512) NULL COMMENT '诊断结果',
  treatment TEXT NULL COMMENT '治疗方案/医嘱',
  visited_at DATETIME NOT NULL COMMENT '就诊时间',
  next_visit_at DATETIME NULL COMMENT '下次复诊时间',
  note VARCHAR(512) NULL COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_visit_records_parent_time (parent_user_id, visited_at),
  KEY idx_visit_records_recorder_user_id (recorder_user_id),
  CONSTRAINT fk_visit_records_parent_user_id FOREIGN KEY (parent_user_id) REFERENCES users(id),
  CONSTRAINT fk_visit_records_recorder_user_id FOREIGN KEY (recorder_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='就诊记录';

CREATE TABLE IF NOT EXISTS files (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '文件ID',
  uploader_user_id BIGINT UNSIGNED NOT NULL COMMENT '上传人用户ID',
  owner_type ENUM('visit_record', 'parent_profile', 'health_record') NOT NULL COMMENT '业务归属类型',
  owner_id BIGINT UNSIGNED NOT NULL COMMENT '业务归属ID',
  file_name VARCHAR(255) NOT NULL COMMENT '原始文件名',
  mime_type VARCHAR(128) NOT NULL COMMENT 'MIME 类型',
  file_size BIGINT UNSIGNED NOT NULL COMMENT '文件大小 bytes',
  storage_provider ENUM('local', 'oss') NOT NULL DEFAULT 'local' COMMENT '存储方式',
  storage_key VARCHAR(512) NOT NULL COMMENT '存储 key/path',
  public_url VARCHAR(1024) NULL COMMENT '访问 URL',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_files_owner (owner_type, owner_id),
  KEY idx_files_uploader_user_id (uploader_user_id),
  CONSTRAINT fk_files_uploader_user_id FOREIGN KEY (uploader_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='上传文件元数据';

CREATE TABLE IF NOT EXISTS medication_reminders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用药提醒ID',
  parent_user_id BIGINT UNSIGNED NOT NULL COMMENT '父母用户ID',
  creator_user_id BIGINT UNSIGNED NOT NULL COMMENT '创建人用户ID',
  medicine_name VARCHAR(128) NOT NULL COMMENT '药品名称',
  dosage VARCHAR(128) NOT NULL COMMENT '剂量，如 1片/5ml',
  reminder_times JSON NOT NULL COMMENT '每日提醒时间数组，如 ["08:00","20:00"]',
  start_date DATE NOT NULL COMMENT '开始日期',
  end_date DATE NULL COMMENT '结束日期，空表示长期',
  note VARCHAR(512) NULL COMMENT '备注',
  enabled TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_medication_reminders_parent_enabled (parent_user_id, enabled),
  KEY idx_medication_reminders_creator_user_id (creator_user_id),
  CONSTRAINT fk_medication_reminders_parent_user_id FOREIGN KEY (parent_user_id) REFERENCES users(id),
  CONSTRAINT fk_medication_reminders_creator_user_id FOREIGN KEY (creator_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用药提醒规则';

CREATE TABLE IF NOT EXISTS medication_reminder_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '提醒日志ID',
  reminder_id BIGINT UNSIGNED NOT NULL COMMENT '用药提醒ID',
  parent_user_id BIGINT UNSIGNED NOT NULL COMMENT '父母用户ID',
  scheduled_at DATETIME NOT NULL COMMENT '计划提醒时间',
  sent_at DATETIME NULL COMMENT '实际发送时间',
  status ENUM('pending', 'sent', 'failed', 'acknowledged') NOT NULL DEFAULT 'pending' COMMENT '提醒状态',
  error_message VARCHAR(512) NULL COMMENT '失败原因',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_medication_logs_reminder_time (reminder_id, scheduled_at),
  KEY idx_medication_logs_parent_status_time (parent_user_id, status, scheduled_at),
  CONSTRAINT fk_medication_logs_reminder_id FOREIGN KEY (reminder_id) REFERENCES medication_reminders(id),
  CONSTRAINT fk_medication_logs_parent_user_id FOREIGN KEY (parent_user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用药提醒发送日志';

CREATE TABLE IF NOT EXISTS wechat_subscriptions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '订阅授权ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  template_id VARCHAR(128) NOT NULL COMMENT '微信订阅消息模板ID',
  scene VARCHAR(64) NOT NULL COMMENT '订阅场景，如 medication_reminder',
  status ENUM('accepted', 'rejected') NOT NULL COMMENT '授权状态',
  subscribed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  expired_at DATETIME NULL COMMENT '过期时间，长期订阅可为空',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_wechat_subscriptions_user_scene (user_id, scene, status),
  CONSTRAINT fk_wechat_subscriptions_user_id FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='微信订阅消息授权';
