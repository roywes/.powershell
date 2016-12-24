# ANSI - http://poshcode.org/6485
$e = ([char]27) + "["
$global:ANSI = @{
   ESC = ([char]27) + "["
   Clear = "${e}0m"
   fg = @{
      Clear       = "${e}39m"

      Black       = "${e}30m";  DarkGray    = "${e}90m"
      DarkRed     = "${e}31m";  Red         = "${e}91m"
      DarkGreen   = "${e}32m";  Green       = "${e}92m"
      DarkYellow  = "${e}33m";  Yellow      = "${e}93m"
      DarkBlue    = "${e}34m";  Blue        = "${e}94m"
      DarkMagenta = "${e}35m";  Magenta     = "${e}95m"
      DarkCyan    = "${e}36m";  Cyan        = "${e}96m"
      Gray        = "${e}37m";  White       = "${e}97m"
   }
   bg = @{
      Clear       = "${e}49m"
      Black       = "${e}40m"; DarkGray    = "${e}100m"
      DarkRed     = "${e}41m"; Red         = "${e}101m"
      DarkGreen   = "${e}42m"; Green       = "${e}102m"
      DarkYellow  = "${e}43m"; Yellow      = "${e}103m"
      DarkBlue    = "${e}44m"; Blue        = "${e}104m"
      DarkMagenta = "${e}45m"; Magenta     = "${e}105m"
      DarkCyan    = "${e}46m"; Cyan        = "${e}106m"
      Gray        = "${e}47m"; White       = "${e}107m"
   }
}

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
  ## $real_last_exit_code = $LASTEXITCODE
  ## $Host.UI.RawUI.ForegroundColor = "White"
  ## Write-Host "`n$env:UserName@$env:ComputerName" -NoNewLine -ForegroundColor Green
  ## Write-Host " PowerShell" -NoNewLine -ForegroundColor Magenta
  ## Write-Host " $pwd" -NoNewLine -ForegroundColor Yellow
  ## if ($env:venv) {
  ##   Write-Host " ($env:venv)" -NoNewLine -ForegroundColor Red
  ## }
  ## if($found_posh_git){
  ##   checkGit($pwd.ProviderPath)
  ## }
  ## $global:LASTEXITCODE = $real_last_exit_code
  ## Write-Host $MyShellPromptSuffix -NoNewLine -ForegroundColor DarkGray
  ## return " "

  $(&{
    "$($ANSI.fg.Green)`n$env:UserName@$env:ComputerName"
    "$($ANSI.fg.Magenta)PowerShell"
    "$($ANSI.fg.Yellow)$pwd"
    if ($env:venv) {
      "$($ANSI.fg.Red)($env:venv)"
    }
    "$($ANSI.fg.DarkGray)$MyShellPromptSuffix $($ANSI.Clear)"
  }) -Join " "
}

# vim: ts=2 sts=2 sw=2 et ai si
