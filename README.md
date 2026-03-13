# dev-setup-cn 🚀

> 中国开发者的一键开发环境配置脚本 — 解决网络、工具链、常用软件全套问题

[![Stars](https://img.shields.io/github/stars/huanglei288766/dev-setup-cn?style=social)](https://github.com/huanglei288766/dev-setup-cn)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-支持-brightgreen)](scripts/macos.sh)
[![Linux](https://img.shields.io/badge/Linux-支持-brightgreen)](scripts/linux.sh)

## 😤 你是否遇到过这些问题？

- `npm install` 卡死，几十分钟毫无进展
- `pip install` 总是超时，换源了还是慢
- Homebrew 安装要等半小时
- Docker pull 镜像要等到天亮
- GitHub clone 总是 connection reset
- IDE 插件下载失败

**一条命令，全部解决！**

## 🚀 一键安装

```bash
# macOS
curl -fsSL https://raw.githubusercontent.com/huanglei288766/dev-setup-cn/main/install.sh | bash

# Linux (Ubuntu/Debian)
curl -fsSL https://raw.githubusercontent.com/huanglei288766/dev-setup-cn/main/install.sh | bash -s -- --linux
```

**约 5 分钟完成全套配置。**

## ✅ 包含内容

### 镜像源配置

| 工具 | 替换为 |
|------|--------|
| npm | 腾讯云镜像 |
| pip | 阿里云镜像 |
| Homebrew | 清华 TUNA 镜像 |
| Docker | 多个国内镜像源（自动切换最快） |
| Maven | 阿里云镜像 |
| Go modules | GOPROXY.cn |

### 开发工具安装

- Homebrew（macOS）
- Node.js LTS + pnpm
- Python 3.12 + uv
- Java 17 (Temurin) + Maven
- Go 最新版
- Docker Desktop 配置
- Git 基础配置

### Claude Code 网络优化

- 自动配置 Claude API 代理
- AWS Bedrock 中国区访问优化

## 📋 选择性安装

```bash
# 只配置镜像源，不安装软件
./install.sh --mirrors-only

# 只安装前端开发环境
./install.sh --frontend

# 只安装 Java 开发环境
./install.sh --java

# 只配置 Git
./install.sh --git
```

## 🔧 手动配置参考

如果你不想运行脚本，可以参考以下手动配置：

- [npm 镜像配置](docs/npm-mirror.md)
- [pip 镜像配置](docs/pip-mirror.md)
- [Docker 镜像配置](docs/docker-mirror.md)
- [Git 代理配置](docs/git-proxy.md)

## 📊 Star 历史

[![Star History](https://api.star-history.com/svg?repos=huanglei288766/dev-setup-cn&type=Date)](https://star-history.com/#huanglei288766/dev-setup-cn)

## 📄 License

MIT © [huanglei288766](https://github.com/huanglei288766)
