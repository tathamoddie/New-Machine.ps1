$ErrorActionPreference = 'Stop';

if ($env:Path.Contains("chocolatey"))
{
    "Choco already installed"
}
else
{
    "Installing Choco"
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

$ExistingChocoPackages = (& choco list -localonly) | % { $_.Split(' ')[0] }
function Install-ChocoIfNotAlready($name) {
    if ($ExistingChocoPackages -contains $name)
    {
        "$name already installed"
    }
    else
    {
        "Installing $name"
        & choco install $name -y
    }
}

#Install-ChocoIfNotAlready skype
#Install-ChocoIfNotAlready git.install
Install-ChocoIfNotAlready putty.install
#Install-ChocoIfNotAlready cmder
Install-ChocoIfNotAlready conemu
Install-ChocoIfNotAlready visualstudiocode
Install-ChocoIfNotAlready git
#Install-ChocoIfNotAlready Console2
#Install-ChocoIfNotAlready SublimeText3
#Install-ChocoIfNotAlready SublimeText3.PackageControl
Install-ChocoIfNotAlready fiddler4
Install-ChocoIfNotAlready beyondcompare
Install-ChocoIfNotAlready resharper
Install-ChocoIfNotAlready resharper-platform
Install-ChocoIfNotAlready filezilla
Install-ChocoIfNotAlready teamviewer
Install-ChocoIfNotAlready 7zip.install
Install-ChocoIfNotAlready sourcetree
Install-ChocoIfNotAlready tortoisegit
Install-ChocoIfNotAlready Git-Credential-Manager-for-Windows
Install-ChocoIfNotAlready vlc
Install-ChocoIfNotAlready skype
Install-ChocoIfNotAlready sysinternals
Install-ChocoIfNotAlready nodejs
Install-ChocoIfNotAlready dropbox
Install-ChocoIfNotAlready googledrive
Install-ChocoIfNotAlready malwarebytes
Install-ChocoIfNotAlready baretail
Install-ChocoIfNotAlready linqpad
Install-ChocoIfNotAlready spotify
Install-ChocoIfNotAlready treesizefree
Install-ChocoIfNotAlready speccy
Install-ChocoIfNotAlready f.lux
Install-ChocoIfNotAlready lockhunter
Install-ChocoIfNotAlready rufus.install
Install-ChocoIfNotAlready vmwareworkstation
Install-ChocoIfNotAlready crystaldiskmark
Install-ChocoIfNotAlready chutzpah
Install-ChocoIfNotAlready crashplan
Install-ChocoIfNotAlready geforce-experience
Install-ChocoIfNotAlready typescript
Install-ChocoIfNotAlready adobe-creative-cloud
Install-ChocoIfNotAlready snagit
Install-ChocoIfNotAlready github

#Install-ChocoIfNotAlready nodejs.install
#Install-ChocoIfNotAlready Jump-Location

#$OneDriveRoot = (gi HKCU:\Software\Microsoft\Windows\CurrentVersion\SkyDrive).GetValue('UserFolder')
#if (-not (Test-Path $OneDriveRoot))
#{
#    throw "Couldn't find the OneDrive root"
#}

#$SshKeyPath = Join-Path $OneDriveRoot Tools\ssh\id.ppk
#if (-not (Test-Path $SshKeyPath))
#{
#    throw "Couldn't find SSH key at $SshKeyPath"
#}

#"Setting Pageant shortcut to load the private key automatically"
# This way, I can type Win+pageant+Enter, and it's all configured
#$WshShell = New-Object -ComObject WScript.Shell
#$PageantShortcut = $WshShell.CreateShortcut((Join-Path ([Environment]::GetFolderPath("CommonStartMenu")) Programs\PuTTY\Pageant.lnk))
#$PageantShortcut.Arguments = "-i $SshKeyPath"
#$PageantShortcut.Save()

#"Setting plink.exe as GIT_SSH"
#$PuttyDirectory = $PageantShortcut.WorkingDirectory
#$PlinkPath = Join-Path $PuttyDirectory plink.exe
#[Environment]::SetEnvironmentVariable('GIT_SSH', $PlinkPath, [EnvironmentVariableTarget]::User)
#$env:GIT_SSH = $PlinkPath

#if ($env:Path.Contains("git"))
#{

#"Setting git identity"
#git status
git config --global user.name "Stephen Price"
git config --global user.email "stephen@lythixdesigns.com"

#if ((& git config push.default) -eq $null)
#{
#    "Setting git push behaviour to squelch the 2.0 upgrade message"
#    git config --global push.default simple
#}

#"Setting git aliases"
#git config --global alias.st "status"
#git config --global alias.co "checkout"
#git config --global alias.df "diff"
#git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

}

#"Setting PS aliases"
#if ((Get-Alias -Name st -ErrorAction SilentlyContinue) -eq $null) {
#    Add-Content $PROFILE "`r`n`r`nSet-Alias -Name st -Value (Join-Path `$env:ProgramFiles 'Sublime Text 3\sublime_text.exe')"
#}

#"Enabling Office smileys"
#Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\15.0\Common\Feedback -Name Enabled -Value 1

#"Reloading PS profile"
#. $PROFILE
