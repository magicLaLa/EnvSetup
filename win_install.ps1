# 获取当前用户身份，不是 管理员的话 以管理员启动 PowerShell
# if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
#   Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs;
#   exit
# }

function Check-Command($cmdName) {
  # -ErrorAction: 确定 cmdlet 如何响应命令中的非终止错误
  return [bool](Get-Command -Name $cmdName -ErrorAction SilentlyContinue);
}

# --- 重命名 计算机 名称 （重启才会有效，放后面执行）（Write-Host: 自定义输出）
$computerName = Read-Host 'Enter New Computer Name'
Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
Rename-Computer -NewName $computerName
# ---

# --- 禁止自动待机 （powercfg：设置电源选项）
Write-Host ""
Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
powercfg /Change monitor-timeout-ac 20 # 闲时20分钟关闭屏幕
powercfg /Change standby-timeout-ac 0 # 永不待机
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 桌面图标处理
Write-Host ""
# 显示我的电脑到桌面上（通过修改 注册表 来实现）
Write-Host "Add 'This PC' Desktop Icon..." -ForegroundColor Green
$thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue
if ($item) {
  Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0
} else {
  # Out-Null 隐藏输出
  New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null
}
# 删除 edge 桌面图标
$edgeLink = $env:USERPROFILE + '\Desktop\Microsoft Edge.lnk';
Remove-Item $edgeLink -ErrorAction SilentlyContinue
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 删除 UWP 应用
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
  "Microsoft.Messaging",
  "king.com.CandyCrushSaga",
  "Microsoft.BingNews",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.People",
  "Microsoft.WindowsFeedbackHub",
  "Microsoft.YourPhone",
  "Microsoft.MicrosoftOfficeHub",
  "Fitbit.FitbitCoach",
  "Microsoft.GetHelp"
)

foreach ($uwp in $uwpRubbishApps) {
  # -Confirm 可以逐个确认是否删除
  Get-AppxPackage -Name $uwp | Remove-AppxPackage
}
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 安装 PowerShell-7.1.3-win-x64.ms
Write-Host "Install PowerShell-7..." -ForegroundColor Green
msiexec.exe /package PowerShell-7.1.3-win-x64.ms /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 通过 scoop 安装 app
Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Write-Host "[WARN] Ma de in China: some software like Google Chrome require the true Internet first" -ForegroundColor Yellow

if (Check-Command -cmdname 'scoop') {
  Write-Host "Choco is already installed, skip installation."
  scoop update
}
else {
  Write-Host ""
  Write-Host "Installing Scoop for Windows..." -ForegroundColor Green
  Write-Host "------------------------------------" -ForegroundColor Green
  Set-ExecutionPolicy Bypass -Scope Process -Force
  iwr -useb get.scoop.sh | iex
}

$env:SCOOP_GLOBAL='D:\GlobalScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

$buckets = @(
  "dorado",
  "extras",
  "nerd-fonts",
  "nirsoft"
  "nirsoft-alternative",
  "versions"
)

$mainApps = @(
  "7zip",
  "aria2",
  "FantasqueSansMono-NF",
  "git"
  "innounp",
  "openssh",
  "python38",
  "snipaste-beta",
  "starship",
  "sudo",
  "vscode"
)
$globApps = @(
  "cacert",
  "ccleaner",
  "everything",
  "grep"
  "lessmsi",
  "nvm",
  "touch",
  "wox",
  "yarn",
  "potplayer",
  "screentogif",
  "quicksetdns",
  "switchhosts",
  "picgo",
  "clash-for-windows"
)

foreach ($bucket in $buckets) {
  scoop bucket add $bucket
}

foreach ($mainApp in $mainApps) {
  scoop install $app
}
foreach ($globApp in $globApps) {
  scoop install $globApp -g
}
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 设置 git
Write-Host "Setting up Git for Windows..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
git config --global user.email "tomato.stao@gmail.com"
git config --global user.name "lalalalala"
git config --global core.autocrlf false
git config --global core.quotepath false
git config --global i18n.commitencoding utf-8
git config --global i18n.logoutputencoding utf-8
git config --global gui.encoding utf-8
git config --global i18n.commit.encoding utf-8
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 安装
# https://github.com/JanDeDobbeleer/oh-my-posh
Write-Host "oh-my-posh..." -ForegroundColor Green
Install-Module oh-my-posh -Scope CurrentUser
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 设置 posh-git
# VSCode 默认使用PowerShell，启动powershell，分别执行下面3个命令（提示都输入Yes）
# 1.设置权限
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm
# 2.使用PowerShellGet安装
PowerShellGet\Install-Module posh-git -Scope CurrentUser
# 3.全局导入posh-git
Add-PoshGitToProfile -AllHosts
# ---

# --- 设置中文
Write-Host "Enabling Chinese input method..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("zh-CN")
Set-WinUserLanguageList $LanguageList -Force
Write-Host "----------- End -----------------" -ForegroundColor Green
# ---

# --- 检查 windows 更新
Write-Host ""
Write-Host "Checking Windows updates..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Install-Module -Name PSWindowsUpdate -Force
Write-Host "Installing updates... (Computer will reboot in minutes...)" -ForegroundColor Green
Get-WindowsUpdate -AcceptAll -Install -ForceInstall -AutoReboot
# ---

Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer