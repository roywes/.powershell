# Set shell encoding to UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
$MyShellPromptSuffix = "`nλ"

# Emacs mode is better. C-d closes shell :)
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Set-Alias which Get-Command
Set-Alias -Name cd -Value Push-Location -Option AllScope

function which ($item) {
  (Get-Command $item).Path
}

function abspath ($item) {
  # (Resolve-Path $item).Path
  [IO.Path]::GetFullPath($item)
}

function basename ($item) {
  [IO.Path]::GetFileName($item)
}

function dirname ($item) {
  [IO.Path]::GetDirectoryName($item)
}

function dirs {
  Get-Location -Stack
}

function workon($venv) {
  $ov=$env:venv
  $op=$env:Path
  $env:Path="$HOME\venvs\$venv\scripts;$env:Path";
  $env:venv="$venv"
  powershell -NoLogo
  $env:Path=$op
  $env:venv=$ov
}

function With-Path-Prefix ($path) {
  $op=$env:Path
  $env:Path="$path;$env:Path"
  powershell -NoLogo
  $env:Path=$op
}

try {
  Import-Module -Name "posh-git" -ErrorAction Stop >$null
  $found_posh_git = $true
} catch {
  Write-Warning "Missing Posh-Git: install with 'Install-Module Posh-Git' and restart"
  $found_posh_git = $true
}

function checkGit($Path) {
  if (Test-Path -Path (Join-Path $Path '.git')) {
    Write-VcsStatus
    return
  }
  $SplitPath = Split-Path $Path
  If ($SplitPath) {
    checkGit($SplitPath)
  }
}

# Set up prompt, adding git prompt parts
function global:prompt {
  $real_last_exit_code = $LASTEXITCODE
  $Host.UI.RawUI.ForegroundColor = "White"
  Write-Host "`n$env:UserName@$env:ComputerName" -NoNewLine -ForegroundColor Green
  Write-Host " PowerShell" -NoNewLine -ForegroundColor Magenta
  Write-Host " $pwd" -NoNewLine -ForegroundColor Yellow
  if ($env:venv) {
    Write-Host " ($env:venv)" -NoNewLine -ForegroundColor Red
  }
  if($found_posh_git){
    checkGit($pwd.ProviderPath)
  }
  $global:LASTEXITCODE = $real_last_exit_code
  Write-Host $MyShellPromptSuffix -NoNewLine -ForegroundColor DarkGray
  return " "
}
