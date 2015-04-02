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

Install-ChocoIfNotAlready google-chrome-x64
Install-ChocoIfNotAlready skype
Install-ChocoIfNotAlready git.install
Install-ChocoIfNotAlready putty.install
Install-ChocoIfNotAlready SublimeText3
Install-ChocoIfNotAlready SublimeText3.PackageControl
Install-ChocoIfNotAlready fiddler4
Install-ChocoIfNotAlready resharper
Install-ChocoIfNotAlready nodejs.install
Install-ChocoIfNotAlready Jump-Location

if (-not (Test-Path HKCU:\Software\Microsoft\OneDrive))
{
    throw "Couldn't find a compatible install of OneDrive"
}
$OneDriveRoot = (gi HKCU:\Software\Microsoft\OneDrive).GetValue('UserFolder')
if (-not (Test-Path $OneDriveRoot))
{
    throw "Couldn't find the OneDrive root"
}

$SshKeyPath = Join-Path $OneDriveRoot Tools\ssh\id.ppk
if (-not (Test-Path $SshKeyPath))
{
    throw "Couldn't find SSH key at $SshKeyPath"
}

"Setting Pageant shortcut to load the private key automatically"
# This way, I can type Win+pageant+Enter, and it's all configured
$WshShell = New-Object -ComObject WScript.Shell
$PageantShortcut = $WshShell.CreateShortcut((Join-Path ([Environment]::GetFolderPath("CommonStartMenu")) Programs\PuTTY\Pageant.lnk))
$PageantShortcut.Arguments = "-i $SshKeyPath"
$PageantShortcut.Save()

"Setting plink.exe as GIT_SSH"
$PuttyDirectory = $PageantShortcut.WorkingDirectory
$PlinkPath = Join-Path $PuttyDirectory plink.exe
[Environment]::SetEnvironmentVariable('GIT_SSH', $PlinkPath, [EnvironmentVariableTarget]::User)
$env:GIT_SSH = $PlinkPath

"Storing GitHub's SSH key"
$SshHostKeysPath = "HKCU:\SOFTWARE\SimonTatham\PuTTY\SshHostKeys"
if (-not (Test-Path $SshHostKeysPath)) { New-Item $SshHostKeysPath -ItemType Directory -Force }
Set-ItemProperty -Path $SshHostKeysPath -Name "rsa2@22:github.com" -Value "0x23,0xab603b8511a67679bdb540db3bd2034b004ae936d06be3d760f08fcbaadb4eb4edc3b3c791c70aae9a74c95869e4774421c2abea92e554305f38b5fd414b3208e574c337e320936518462c7652c98b31e16e7da6523bd200742a6444d83fcd5e1732d03673c7b7811555487b55f0c4494f3829ece60f94255a95cb9af537d7fc8c7fe49ef318474ef2920992052265b0a06ea66d4a167fd9f3a48a1a4a307ec1eaaa5149a969a6ac5d56a5ef627e517d81fb644f5b745c4f478ecd082a9492f744aad326f76c8c4dc9100bc6ab79461d2657cb6f06dec92e6b64a6562ff0e32084ea06ce0ea9d35a583bfb00bad38c9d19703c549892e5aa78dc95e250514069"

"Setting git identity"
git config --global user.name "Tatham Oddie"
git config --global user.email "tatham@oddie.com.au"

if ((& git config push.default) -eq $null)
{
    "Setting git push behaviour to squelch the 2.0 upgrade message"
    git config --global push.default simple
}

"Setting git aliases"
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.df "diff"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

"Setting PS aliases"
if ((Get-Alias -Name st -ErrorAction SilentlyContinue) -eq $null) {
    Add-Content $PROFILE "`r`n`r`nSet-Alias -Name st -Value (Join-Path `$env:ProgramFiles 'Sublime Text 3\sublime_text.exe')"
}

"Enabling Office smileys"
if (Test-Path HKCU:\Software\Microsoft\Office\16.0\Common\Feedback)
{
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Office\16.0\Common\Feedback -Name Enabled -Value 1
}
else
{
    Write-Warning "Couldn't find a compatible install of Office"
}

"Reloading PS profile"
. $PROFILE
