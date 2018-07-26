[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop';

$IsAdmin = (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    throw "You need to run this script elevated"
}

Write-Progress -Activity "Setting execution policy"
Set-ExecutionPolicy RemoteSigned

Write-Progress -Activity "Ensuring PS profile exists"
if (-not (Test-Path $PROFILE)) {
    New-Item $PROFILE -Force
}

Write-Progress -Activity "Ensuring Chocolatey is available"
$null = Get-PackageProvider -Name chocolatey

Write-Progress -Activity "Ensuring Chocolatey is trusted"
if (-not ((Get-PackageSource -Name chocolatey).IsTrusted)) {
    Set-PackageSource -Name chocolatey -Trusted
}

@(
    "googlechrome",
    "git.install",
    "vscode",
    "slack",
    "snagit"
) | % {
    Write-Progress -Activity "Installing $_"
    Install-Package -Name $_ -ProviderName chocolatey
}

Write-Progress -Activity "Setting git identity"
$userName = (Get-WmiObject Win32_Process -Filter "Handle = $Pid").GetRelated("Win32_LogonSession").GetRelated("Win32_UserAccount").FullName
Write-Verbose "Setting git user.name to $userName"
git config --global user.name $userName
# This seems to the be MSA that was first used during Windows setup
$userEmail = (Get-WmiObject -Class Win32_ComputerSystem).PrimaryOwnerName
Write-Verbose "Setting git user.email to $userEmail"
git config --global user.email $userEmail

Write-Progress -Activity "Setting git push behaviour to squelch the 2.0 upgrade message"
if ((& git config push.default) -eq $null) {
    git config --global push.default simple
}

Write-Progress -Activity "Setting git aliases"
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.df "diff"
git config --global alias.lg "log --graph --oneline --decorate"

Write-Progress -Activity "Setting VS Code as the Git editor"
git config --global core.editor "code --wait"

Write-Progress -Activity "Installing PoshGit"
Install-Module posh-git -Scope CurrentUser
Add-PoshGitToProfile

Write-Progress -Activity "Enabling Office smileys"
if (Test-Path HKCU:\Software\Microsoft\Office\16.0) {
    if (-not (Test-Path HKCU:\Software\Microsoft\Office\16.0\Common\Feedback)) {
        New-Item HKCU:\Software\Microsoft\Office\16.0\Common\Feedback -ItemType Directory
    }
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\16.0\Common\Feedback -Name Enabled -Value 1
}
else {
    Write-Warning "Couldn't find a compatible install of Office"
}

Write-Progress -Activity "Disabling Outlook notifications"
if (Test-Path HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences) {
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences -Name ChangePointer -Value 0
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences -Name NewmailDesktopAlerts -Value 0
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences -Name PlaySound -Value 0
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\16.0\Outlook\Preferences -Name ShowEnvelope -Value 0
}
else {
    Write-Warning "Couldn't find a compatible install of Office"
}

Write-Progress "Hiding desktop icons"
if ((Get-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\).HideIcons -ne 1) {
    Set-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ -Name HideIcons -Value 1
    Get-Process explorer | Stop-Process
}

Write-Progress "Enabling PowerShell on Win+X"
if ((Get-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\).DontUsePowerShellOnWinX -ne 0) {
    Set-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ -Name DontUsePowerShellOnWinX -Value 0
    Get-Process explorer | Stop-Process
}

Write-Progress "Making c:\code"
if (-not (Test-Path c:\code)) {
    New-Item c:\code -ItemType Directory
}

Write-Progress "Making c:\temp"
if (-not (Test-Path c:\temp)) {
    New-Item c:\temp -ItemType Directory
}

Write-Progress "Enabling Windows Subsystem for Linux"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

Write-Progress -Activity "Reloading PS profile"
. $PROFILE
