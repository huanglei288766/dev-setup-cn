# dev-setup-cn

> 中国开发者的一键开发环境配置脚本 — 镜像源 + Git 配置，一条命令搞定

[![Stars](https://img.shields.io/github/stars/huanglei288766/dev-setup-cn?style=social)](https://github.com/huanglei288766/dev-setup-cn)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 你是否遇到过这些问题？

- `npm install` 卡死，几十分钟毫无进展
- `pip install` 总是超时
- Homebrew 安装要等半小时
- Docker pull 镜像要等到天亮
- Maven 下载依赖慢如蜗牛
- Go modules 下载超时

**一条命令，全部解决！**

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/huanglei288766/dev-setup-cn/main/install.sh | bash
```

脚本会自动检测操作系统（macOS / Linux），无需手动指定。

## 包含内容

### 镜像源配置

| 工具 | 镜像源 |
|------|--------|
| npm | 腾讯云镜像 |
| pip | 阿里云镜像 |
| Maven | 阿里云镜像 |
| Go modules | goproxy.cn |
| Docker | DaoCloud + DockerProxy |
| Homebrew | 清华 TUNA 镜像（仅 macOS） |

### Git 基础配置

- 默认分支设为 `main`
- 行尾符处理（`core.autocrlf input`）
- pull 默认 merge 策略

## 选择性安装

```bash
# 只配置镜像源，不配置 Git
./install.sh --mirrors-only

# 只配置前端相关（npm）
./install.sh --frontend

# 只配置 Java 相关（Maven）
./install.sh --java

# 只配置 Git
./install.sh --git
```

## 手动配置参考

如果你不想运行脚本，可以手动配置：

### npm 镜像

```bash
npm config set registry https://mirrors.cloud.tencent.com/npm/
```

### pip 镜像

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
EOF
```

### Go 代理

```bash
go env -w GOPROXY=https://goproxy.cn,direct
```

### Maven 镜像

在 `~/.m2/settings.xml` 中添加阿里云镜像：

```xml
<mirrors>
  <mirror>
    <id>aliyun</id>
    <mirrorOf>*</mirrorOf>
    <url>https://maven.aliyun.com/repository/public</url>
  </mirror>
</mirrors>
```

### Docker 镜像

编辑 Docker daemon.json（macOS: `~/.docker/daemon.json`，Linux: `/etc/docker/daemon.json`）：

```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com"
  ]
}
```

### Homebrew 镜像（macOS）

```bash
export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
```

## License

MIT © [huanglei288766](https://github.com/huanglei288766)
