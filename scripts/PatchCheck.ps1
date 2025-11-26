<# 
.SYNOPSIS
    Checks for available Windows updates and logs results
.DESCRIPTION
    This script identifies available Windows updates including critical and security updates
.VERSION
    1.0
#>

param(
    [string]$LogPath = "C:\PatchManagementProject\Logs"
)

if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

$LogFile = "$LogPath\PatchCheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-LogEntry {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp | $Message" | Tee-Object -FilePath $LogFile -Append
}

try {
    Write-LogEntry "Starting patch check process..."
    Import-Module PSWindowsUpdate -ErrorAction Stop
    Write-LogEntry "PSWindowsUpdate module imported successfully"
    Write-LogEntry "Checking for available updates..."
    
    $updates = Get-WindowsUpdate -ErrorAction Stop

    if ($updates) {
        $updateCount = $updates.Count
        Write-LogEntry "Found $updateCount available update(s)"
        $criticalUpdates = @($updates | Where-Object { $_.MsrcSeverity -eq "Critical" })
        $securityUpdates = @($updates | Where-Object { $_.MsrcSeverity -eq "Important" })
        Write-LogEntry "Critical updates: $($criticalUpdates.Count)"
        Write-LogEntry "Security updates: $($securityUpdates.Count)"
        Write-LogEntry "Update Details:"
        foreach ($update in $updates) {
            Write-LogEntry "  - KB$($update.KBArticleID): $($update.Title) [Severity: $($update.MsrcSeverity)]"
        }
        $updateInfo = @{
            TotalCount = $updateCount
            CriticalCount = $criticalUpdates.Count
            SecurityCount = $securityUpdates.Count
            Updates = $updates
            Timestamp = Get-Date
            Status = "Success"
        }
    } else {
        Write-LogEntry "No updates available"
        $updateInfo = @{
            TotalCount = 0
            CriticalCount = 0
            SecurityCount = 0
            Updates = $null
            Timestamp = Get-Date
            Status = "Success"
        }
    }
    Write-LogEntry "Patch check completed successfully"
    return $updateInfo

} catch {
    Write-LogEntry "ERROR: $($_.Exception.Message)"
    return @{
        Status = "Error"
        ErrorMessage = $_.Exception.Message
        Timestamp = Get-Date
    }
}
