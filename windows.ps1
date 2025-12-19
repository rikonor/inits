# Windows setup script
# Run with: irm https://inits.or-rikon.com/windows.ps1 | iex
# Or download and run: .\windows.ps1

#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

Write-Host "=== Windows Setup ===" -ForegroundColor Cyan

# Install winget if not present (Windows 10+)
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Installing winget..."
    $progressPreference = 'silentlyContinue'
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
    Add-AppxPackage winget.msixbundle
    Remove-Item winget.msixbundle
}

# Install packages via winget
Write-Host "Installing packages..."
$packages = @(
    "Git.Git"
    "Microsoft.WindowsTerminal"
    "Microsoft.VisualStudioCode"
    "Neovim.Neovim"
    "starship"
    "sharkdp.bat"
    "BurntSushi.ripgrep.MSVC"
    "sharkdp.fd"
    "junegunn.fzf"
    "Docker.DockerDesktop"
    "1Password.1Password"
    "Obsidian.Obsidian"
)

foreach ($package in $packages) {
    Write-Host "  Installing $package..."
    winget install --id $package --accept-source-agreements --accept-package-agreements -h
}

# Install WSL2
Write-Host "Setting up WSL2..."
wsl --install -d Ubuntu

# Clone dotfiles (Windows-specific branch or config)
Write-Host "Setting up dotfiles..."
$dotfilesPath = "$env:USERPROFILE\.dotfiles"
if (!(Test-Path $dotfilesPath)) {
    git clone https://github.com/rikonor/dotfiles.git $dotfilesPath
    # Run Windows-specific setup from dotfiles
    if (Test-Path "$dotfilesPath\windows\setup.ps1") {
        & "$dotfilesPath\windows\setup.ps1"
    }
}

# Configure Windows Terminal to use starship
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    Write-Host "Note: Configure Windows Terminal profile to run starship manually"
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host "Restart your computer to complete WSL2 installation."
