#!/bin/bash
#
# 神盾局配置同步到 GitHub 脚本
# SHIELD Config Sync to GitHub
#
# 用途：将 OpenClaw 配置和工作目录同步到 GitHub 仓库
# 执行：~/shield-backup-git/scripts/sync-to-github.sh
#
# 局长：Ethan
# 特工：震波女 (Daisy Johnson)
# 版本：1.0
# 创建：2026-03-13
#

set -e

# ═══════════════════════════════════════════════════════════
# 配置区域
# ═══════════════════════════════════════════════════════════

REPO_DIR="$HOME/shield-backup-git"
OPENCLAW_DIR="$HOME/.openclaw"
WORKSPACE_DIR="$HOME/.openclaw/workspace"
LOG_FILE="$HOME/.shield-backups/shield-quake/git-sync.log"

# ═══════════════════════════════════════════════════════════
# 函数定义
# ═══════════════════════════════════════════════════════════

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

error() {
    log "❌ ERROR: $*"
    exit 1
}

success() {
    log "✅ SUCCESS: $*"
}

info() {
    log "ℹ️  INFO: $*"
}

# ═══════════════════════════════════════════════════════════
# 主程序
# ═══════════════════════════════════════════════════════════

info "开始神盾局配置同步到 GitHub..."

# 创建日志文件
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# 同步配置文件
info "同步配置文件..."
cp "$OPENCLAW_DIR/openclaw.json" "$REPO_DIR/config/" 2>/dev/null || info "⚠️ openclaw.json 未找到"
cp "$OPENCLAW_DIR/agents/main/agent/models.json" "$REPO_DIR/config/" 2>/dev/null || info "⚠️ models.json 未找到"

# 同步工作空间
info "同步工作空间..."
cp "$WORKSPACE_DIR/AGENTS.md" "$REPO_DIR/workspace/" 2>/dev/null || info "⚠️ AGENTS.md 未找到"
cp "$WORKSPACE_DIR/MEMORY.md" "$REPO_DIR/workspace/" 2>/dev/null || info "⚠️ MEMORY.md 未找到"
cp "$WORKSPACE_DIR/SESSION-STATE.md" "$REPO_DIR/workspace/" 2>/dev/null || info "⚠️ SESSION-STATE.md 未找到"

# 同步学习记录
info "同步学习记录..."
mkdir -p "$REPO_DIR/workspace/.learnings"
cp "$WORKSPACE_DIR/.learnings/"* "$REPO_DIR/workspace/.learnings/" 2>/dev/null || info "⚠️ .learnings/ 未找到"

# 同步每日日志
info "同步每日日志..."
mkdir -p "$REPO_DIR/workspace/memory"
cp "$WORKSPACE_DIR/memory/"* "$REPO_DIR/workspace/memory/" 2>/dev/null || info "⚠️ memory/ 未找到"

# 同步文档
info "同步文档..."
mkdir -p "$REPO_DIR/docs"
cp "$WORKSPACE_DIR/.openclaw/docs/SHIELD-BACKUP-MANUAL.md" "$REPO_DIR/docs/" 2>/dev/null || info "⚠️ 备份手册未找到"

# 提交和推送
cd "$REPO_DIR"
info "提交变更..."
if git add . && git diff --cached --quiet; then
    info "无变更，跳过提交"
else
    git commit -m "🔄 配置同步 $(date '+%Y-%m-%d %H:%M:%S')" || info "⚠️ 无变更或已提交"
    info "推送至 GitHub..."
    git push origin main 2>/dev/null || info "⚠️ 推送失败（可能无网络）"
fi

success "神盾局配置同步完成！"