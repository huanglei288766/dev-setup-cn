#!/usr/bin/env bash
# dev-setup-cn — 中国开发者一键环境配置
# https://github.com/huanglei288766/dev-setup-cn

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# 检测操作系统
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
  else
    error "不支持的操作系统: $OSTYPE"
  fi
  info "检测到操作系统: $OS"
}

# 解析参数
MIRRORS_ONLY=false
FRONTEND=false
JAVA=false
GIT_ONLY=false

for arg in "$@"; do
  case $arg in
    --mirrors-only) MIRRORS_ONLY=true ;;
    --frontend) FRONTEND=true ;;
    --java) JAVA=true ;;
    --git) GIT_ONLY=true ;;
  esac
done

# 配置 npm 镜像（腾讯云）
setup_npm_mirror() {
  info "配置 npm 镜像..."
  if command -v npm &> /dev/null; then
    npm config set registry https://mirrors.cloud.tencent.com/npm/
    success "npm 镜像已设置为腾讯云"
  else
    warn "npm 未安装，跳过"
  fi
}

# 配置 pip 镜像（阿里云）
setup_pip_mirror() {
  info "配置 pip 镜像..."
  mkdir -p ~/.pip
  cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
timeout = 120
EOF
  success "pip 镜像已设置为阿里云"
}

# 配置 Maven 镜像（阿里云）
setup_maven_mirror() {
  info "配置 Maven 镜像..."
  MAVEN_SETTINGS_DIR="$HOME/.m2"
  mkdir -p "$MAVEN_SETTINGS_DIR"

  if [[ ! -f "$MAVEN_SETTINGS_DIR/settings.xml" ]]; then
    cat > "$MAVEN_SETTINGS_DIR/settings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <id>aliyun</id>
      <name>阿里云 Maven 镜像</name>
      <mirrorOf>*</mirrorOf>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
    success "Maven settings.xml 已创建（阿里云镜像）"
  else
    warn "Maven settings.xml 已存在，跳过（如需更新请手动修改 $MAVEN_SETTINGS_DIR/settings.xml）"
  fi
}

# 配置 Go 代理
setup_go_proxy() {
  info "配置 Go 代理..."
  if command -v go &> /dev/null; then
    go env -w GOPROXY=https://goproxy.cn,direct
    go env -w GONOSUMDB=*
    success "Go 代理已设置为 goproxy.cn"
  else
    warn "Go 未安装，跳过"
  fi
}

# 配置 Docker 镜像
setup_docker_mirror() {
  info "配置 Docker 镜像..."
  DOCKER_DAEMON_JSON="/etc/docker/daemon.json"

  if [[ "$OS" == "macos" ]]; then
    DOCKER_DAEMON_JSON="$HOME/.docker/daemon.json"
  fi

  # 如果 daemon.json 已存在，不覆盖（防止破坏用户已有配置）
  if [[ -f "$DOCKER_DAEMON_JSON" ]]; then
    warn "Docker daemon.json 已存在: $DOCKER_DAEMON_JSON"
    warn "请手动将以下镜像源添加到 registry-mirrors 中："
    warn "  https://docker.m.daocloud.io"
    warn "  https://dockerproxy.com"
    return
  fi

  mkdir -p "$(dirname "$DOCKER_DAEMON_JSON")"

  cat > "$DOCKER_DAEMON_JSON" << 'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com"
  ]
}
EOF
  success "Docker 镜像源已配置（DaoCloud + DockerProxy）"

  if [[ "$OS" == "linux" ]] && command -v docker &> /dev/null && command -v systemctl &> /dev/null; then
    sudo systemctl daemon-reload
    sudo systemctl restart docker 2>/dev/null || warn "Docker 重启失败，请手动重启"
  elif [[ "$OS" == "macos" ]]; then
    warn "请在 Docker Desktop 中手动重启 Docker 以使配置生效"
  fi
}

# 配置 Homebrew（macOS）
setup_homebrew_mirror() {
  if [[ "$OS" != "macos" ]]; then return; fi
  info "配置 Homebrew 镜像（清华 TUNA）..."

  SHELL_RC="$HOME/.zshrc"
  if [[ "${SHELL:-}" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
  fi

  # 避免重复写入
  if ! grep -q "HOMEBREW_API_DOMAIN" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'EOF'

# Homebrew 清华镜像 (by dev-setup-cn)
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
EOF
    success "Homebrew 镜像已写入 $SHELL_RC"
    warn "请执行 'source $SHELL_RC' 或重启终端使配置生效"
  else
    success "Homebrew 镜像已配置（跳过重复写入）"
  fi
}

# 配置 Git
setup_git() {
  info "配置 Git 基础设置..."
  git config --global init.defaultBranch main
  git config --global core.autocrlf input
  git config --global pull.rebase false
  success "Git 基础配置完成"
}

# 主流程
main() {
  echo ""
  echo "======================================"
  echo "  dev-setup-cn — 中国开发者环境配置"
  echo "======================================"
  echo ""

  detect_os

  if $GIT_ONLY; then
    setup_git
  elif $MIRRORS_ONLY; then
    setup_npm_mirror
    setup_pip_mirror
    setup_maven_mirror
    setup_go_proxy
    setup_docker_mirror
    [[ "$OS" == "macos" ]] && setup_homebrew_mirror
  elif $FRONTEND; then
    setup_npm_mirror
  elif $JAVA; then
    setup_maven_mirror
  else
    # 全量配置
    setup_git
    setup_npm_mirror
    setup_pip_mirror
    setup_maven_mirror
    setup_go_proxy
    setup_docker_mirror
    [[ "$OS" == "macos" ]] && setup_homebrew_mirror
  fi

  echo ""
  echo "======================================"
  success "配置完成！"
  echo "======================================"
  echo ""
}

main "$@"
