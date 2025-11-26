<#
.SYNOPSIS
    Main patch management orchestration script
.DESCRIPTION
    Coordinates patch checking, installation, and report generation
.VERSION
    1.0
#>

param(
    [ValidateSet("Check", "Install", "Report", "Full")]
    [string]$Operation = "Full"
)

$ScriptPath = "C:\PatchManagementProject"
$ScriptsDir = "$ScriptPath\Scripts"
$LogsDir    = "$ScriptPath\Logs"
$ReportsDir = "$ScriptPath\Reports"
$MainLogFile = "$LogsDir\Main_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

foreach ($dir in $LogsDir, $ReportsDir) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Write-MainLog {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp [$Level] | $Message" | Tee-Object -FilePath $MainLogFile -Append
}

function Invoke-PatchCheck {
    Write-MainLog "Starting patch check..."
    try {
        & "$ScriptsDir\PatchCheck.ps1" -LogPath $LogsDir
        Write-MainLog "Patch check completed"
    } catch {
        Write-MainLog "Patch check failed: $($_.Exception.Message)" "ERROR"
    }
}

function Invoke-PatchInstall {
    Write-MainLog "Starting patch installation..."
    try {
        & "$ScriptsDir\PatchInstall.ps1" -LogPath $LogsDir -CriticalOnly $true -AutoReboot $false
        Write-MainLog "Patch installation completed"
    } catch {
        Write-MainLog "Patch installation failed: $($_.Exception.Message)" "ERROR"
    }
}

function Invoke-PatchReport {
    Write-MainLog "Starting report generation..."
    try {
        & "$ScriptsDir\GenerateReport.ps1" -LogPath $LogsDir -ReportPath $ReportsDir
        Write-MainLog "Report generation completed"
    } catch {
        Write-MainLog "Report generation failed: $($_.Exception.Message)" "ERROR"
    }
}

Write-MainLog "=========================================="
Write-MainLog "Windows Patch Management System Started"
Write-MainLog "Operation: $Operation"
Write-MainLog "=========================================="

try {
    switch ($Operation) {
        "Check" { Invoke-PatchCheck }
        "Install" { Invoke-PatchInstall }
        "Report" { Invoke-PatchReport }
        "Full" {
            Invoke-PatchCheck
            Invoke-PatchInstall
            Invoke-PatchReport
        }
    }
    Write-MainLog "All operations completed successfully"
} catch {
    Write-MainLog "Fatal error: $($_.Exception.Message)" "ERROR"
}

Write-MainLog "=========================================="
Write-MainLog "Windows Patch Management System Ended"
Write-MainLog "=========================================="
