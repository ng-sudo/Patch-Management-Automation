<# 
.SYNOPSIS
    Installs available critical and security Windows updates
.DESCRIPTION
    Installs updates after checking for critical patches. Logs installation results.
.VERSION
    1.0
#>

param(
    [string]$LogPath = "C:\PatchManagementProject\Logs",
    [bool]$CriticalOnly = $true,
    [bool]$AutoReboot = $false
)

if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}
$LogFile = "$LogPath\PatchInstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$ErrorActionPreference = "Continue"

function Write-LogEntry {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp | $Message" | Tee-Object -FilePath $LogFile -Append
}

try {
    Write-LogEntry "Starting patch installation process..."
    Write-LogEntry "Critical Only: $CriticalOnly | Auto Reboot: $AutoReboot"
    Import-Module PSWindowsUpdate -ErrorAction Stop
    Write-LogEntry "Retrieving available updates..."
    $updates = Get-WindowsUpdate -ErrorAction Stop

    if (-not $updates) {
        Write-LogEntry "No updates available for installation"
        return @{
            Status = "Success"
            InstalledCount = 0
            FailedCount = 0
            Message = "No updates available"
        }
    }

    if ($CriticalOnly) {
        $updates = @($updates | Where-Object { 
            $_.MsrcSeverity -eq "Critical" -or $_.MsrcSeverity -eq "Important" 
        })
        Write-LogEntry "Filtered to $($updates.Count) critical/security updates"
    }

    if ($updates.Count -eq 0) {
        Write-LogEntry "No critical/security updates available"
        return @{
            Status = "Success"
            InstalledCount = 0
            FailedCount = 0
            Message = "No critical updates available"
        }
    }

    Write-LogEntry "Installing $($updates.Count) update(s)..."
    $installResult = Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction Continue
    Write-LogEntry "Patch installation completed"
    Write-LogEntry "Installation result: $installResult"

    # Check for required restart
    $restartRequired = (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -ErrorAction SilentlyContinue).Property -contains "RebootRequired"
    if ($restartRequired) {
        Write-LogEntry "System restart required"
        if ($AutoReboot) {
            Write-LogEntry "Scheduling automatic restart in 30 minutes..."
            shutdown /r /t 1800 /c "Windows patches installed, restarting system"
        }
    } else {
        Write-LogEntry "No restart required"
    }
    return @{
        Status = "Success"
        Message = "Installation completed"
        RestartRequired = $restartRequired
        Timestamp = Get-Date
    }

} catch {
    Write-LogEntry "ERROR: $($_.Exception.Message)"
    return @{
        Status = "Error"
        ErrorMessage = $_.Exception.Message
        Timestamp = Get-Date
    }
}
