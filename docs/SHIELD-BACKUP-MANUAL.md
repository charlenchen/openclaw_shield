# 神盾局 OpenClaw 备份系统文档

**版本：** 1.0  
**创建日期：** 2026-03-13  
**特工：** 震波女 (Daisy Johnson / Quake)  
**局长：** Ethan

---

## 📋 概述

神盾局备份系统确保 OpenClaw 配置和数据在系统故障、误操作或恶意攻击时可快速恢复。

### 核心原则

1. **自动化** - 每日自动备份，无需人工干预
2. **多层级** - 日备份、周备份、月备份三级保留
3. **可验证** - 每次备份生成 SHA256 校验和
4. **快速恢复** - 一键恢复，最小化停机时间

---

## 🏗️ 系统架构

```
神盾局备份系统
│
├── 备份脚本
│   ├── shield-backup.sh    # 备份执行
│   └── shield-restore.sh   # 恢复执行
│
├── 备份存储 (~/.shield-backups/shield-quake/)
│   ├── full_*.tar.gz       # 完整备份
│   ├── daily/              # 日备份 (7 天)
│   ├── weekly/             # 周备份 (4 周)
│   ├── monthly/            # 月备份 (12 月)
│   └── restore/            # 恢复前备份
│
└── 自动化
    ├── Cron 作业           # 每日 02:00 执行
    └── 心跳检查            # 备份状态监控
```

---

## 📦 备份内容

### 包含

| 目录 | 内容 | 重要性 |
|------|------|--------|
| `~/.openclaw/` | OpenClaw 主配置 | 🔴 核心 |
| `~/.openclaw/workspace/` | 工作目录（记忆、技能） | 🔴 核心 |
| `~/.openclaw/skills/` | 已安装技能 | 🟡 重要 |
| `~/.agents/skills/` | 全局技能库 | 🟡 重要 |
| `~/.openclaw/openclaw.json` | 主配置文件 | 🔴 核心 |

### 排除

| 类型 | 说明 |
|------|------|
| `logs/*` | 运行日志（可重新生成） |
| `completions/*` | 临时完成数据 |
| `*.log` | 日志文件 |
| `*.tmp` | 临时文件 |

---

## 🔧 使用指南

### 手动备份

```bash
# 完整备份
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh full

# 完整备份（自定义名称）
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh full emergency_20260313

# 增量备份
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh incremental

# 自动备份（根据日期决定类型）
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh auto

# 列出备份
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh list

# 验证备份
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh verify

# 查看状态
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh status
```

### 恢复操作

```bash
# 交互式恢复（推荐）
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh

# 恢复指定备份
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh /path/to/backup.tar.gz

# 强制恢复（无确认）
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh /path/to/backup.tar.gz --force

# 列出可用备份
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh list

# 验证备份
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh verify /path/to/backup.tar.gz
```

---

## 📅 自动备份计划

### Cron 配置

备份已配置为每日 **02:00** 自动执行：

```cron
# 神盾局 OpenClaw 自动备份 - 每日 02:00
0 2 * * * ~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh auto >> ~/.shield-backups/shield-quake/cron.log 2>&1
```

### 备份策略

| 类型 | 执行时间 | 保留策略 |
|------|----------|----------|
| **日备份** | 每日 02:00 | 7 天 |
| **周备份** | 每周一 02:00 | 4 周 |
| **月备份** | 每月 1 日 02:00 | 12 月 |

---

## 🔐 安全特性

### 备份验证

1. **SHA256 校验和** - 每次备份生成 `.sha256` 文件
2. **完整性测试** - 恢复前自动验证 tar 包完整性
3. **恢复前备份** - 恢复前自动创建紧急备份

### 权限控制

| 文件/目录 | 权限 | 说明 |
|-----------|------|------|
| 备份脚本 | 700 | 仅所有者可执行 |
| 备份文件 | 600 | 仅所有者可读写 |
| 备份目录 | 700 | 仅所有者可访问 |

---

## 🚨 应急恢复流程

### 场景 1：配置损坏

```bash
# 1. 列出可用备份
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh list

# 2. 执行恢复
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh

# 3. 验证恢复
openclaw status
```

### 场景 2：系统完全故障

```bash
# 1. 重新安装 OpenClaw
npm install -g openclaw

# 2. 恢复备份
~/.openclaw/workspace/.openclaw/scripts/shield-restore.sh /path/to/backup.tar.gz

# 3. 重启服务
openclaw gateway start
```

### 场景 3：误删除恢复

```bash
# 1. 找到最近备份
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh list

# 2. 恢复特定目录（手动）
tar -xzf backup.tar.gz -C ~ .openclaw/workspace/MEMORY.md

# 3. 验证文件
cat ~/.openclaw/workspace/MEMORY.md
```

---

## 📊 监控与告警

### 检查备份状态

```bash
# 查看最后备份时间
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh status

# 检查备份大小
du -sh ~/.shield-backups/shield-quake/

# 验证最新备份
~/.openclaw/workspace/.openclaw/scripts/shield-backup.sh verify
```

### 心跳集成

在 `HEARTBEAT.md` 中添加备份检查：

```markdown
# 备份检查
- [ ] 验证最新备份完整性
- [ ] 检查备份空间使用
- [ ] 确认 Cron 作业运行
```

---

## 📈 备份报告

### 生成报告

```bash
# 备份统计
echo "=== 神盾局备份报告 ===" 
echo "备份目录：~/.shield-backups/shield-quake/"
echo "总大小：$(du -sh ~/.shield-backups/shield-quake/ | cut -f1)"
echo "完整备份数：$(ls ~/.shield-backups/shield-quake/full_*.tar.gz 2>/dev/null | wc -l)"
echo "日备份数：$(ls -d ~/.shield-backups/shield-quake/daily/*/ 2>/dev/null | wc -l)"
echo "最后备份：$(ls -t ~/.shield-backups/shield-quake/full_*.tar.gz 2>/dev/null | head -1)"
```

---

## 🛠️ 维护指南

### 定期任务

| 频率 | 任务 | 命令 |
|------|------|------|
| 每周 | 验证备份完整性 | `shield-backup.sh verify` |
| 每月 | 清理过期备份 | `shield-backup.sh cleanup` |
| 每季 | 测试恢复流程 | `shield-restore.sh interactive` |
| 每年 | 审查备份策略 | 更新本文档 |

### 故障排查

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 备份失败 | 磁盘空间不足 | `df -h` 检查空间 |
| 恢复失败 | 备份文件损坏 | 验证 SHA256 校验和 |
| Cron 未执行 | 权限问题 | `chmod +x` 脚本 |
| 备份过大 | 未排除日志 | 检查排除规则 |

---

## 📝 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-03-13 | 初始版本，震波女创建 |

---

*神盾局备份系统 - 可靠运行是我们的底线*  
*最后更新：2026-03-13*
