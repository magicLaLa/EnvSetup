- Windows 下开发环境安装脚本
```bash
# 使用管理员运行
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/magicLaLa/EnvSetup/main/win_install.ps1'))
```

- Mac 下使用 Zinit 来管理脚本，使 `zsh` 启动速度提升，关键在于 `nvm` 太耗时了
  - 首先安装 [`Zinit`](https://github.com/zdharma-continuum/zinit)，然后根据如下配置
    [Mac .zshrc 配置](.zshrc)