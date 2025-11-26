# Windows Patch Management Automation

## Overview
Automated Windows patch management system built with PowerShell. Detects, installs, and reports on critical security patches.

## Features
- ✅ Automatic Windows Update Detection
- ✅ Critical & Security Patch Installation
- ✅ Comprehensive Logging
- ✅ HTML & CSV Compliance Reports
- ✅ Scheduled Task Support
- ✅ Email Notifications (Optional)

## Prerequisites
- Windows 10 (Build 19041+) or Windows Server 2008 R2+
- PowerShell 5.1 or later
- Administrator privileges
- PSWindowsUpdate Module

## Installation

### 1. Clone Repository
git clone https://github.com/chamarthinagendravarma-spec/PatchManagementAutomation.git

cd PatchManagementAutomation

### 2. Install Dependencies
Install-Module -Name PSWindowsUpdate -Force

### 3. Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

## Usage

### Run All Operations
.\Scripts\PatchManagementMain.ps1 -Operation "Full"

### Check for Updates Only
.\Scripts\PatchCheck.ps1 -LogPath ".\Logs"

### Install Updates Only
.\Scripts\PatchInstall.ps1 -LogPath ".\Logs"

### Generate Report Only
.\Scripts\GenerateReport.ps1 -ReportPath ".\Reports"

## File Structure
PatchManagementAutomation/
├── Scripts/
│ ├── PatchCheck.ps1 # Check for available updates
│ ├── PatchInstall.ps1 # Install patches
│ ├── GenerateReport.ps1 # Create compliance reports
│ └── PatchManagementMain.ps1 # Main orchestration
├── Config/
│ └── config.json # Configuration settings
├── Logs/ # Generated logs
├── Reports/ # Generated reports
├── README.md
└── LICENSE

## Configuration
Edit `Config/config.json` to customize:
- Critical patches only
- Auto reboot settings
- Email notifications
- Scheduled task timing

## Scheduled Task Setup
1. Open Task Scheduler
2. Create Basic Task
3. Name: Patch-Management-Automation
4. Trigger: Daily at 2:00 AM
5. Action: Run PowerShell with script path

## Logging
- **Location:** `Logs/` directory
- **Retention:** 90 days (configurable)
- **Files:**
  - `PatchCheck_*.log` - Patch detection logs
  - `PatchInstall_*.log` - Installation logs
  - `GenerateReport_*.log` - Report generation logs
  - `Main_*.log` - Main execution logs

## Reports
- **Location:** `Reports/` directory
- **Formats:**
  - HTML Report - Comprehensive visual report
  - CSV Report - Raw data export for analysis

## Troubleshooting

### PSWindowsUpdate Module Not Found
Install-Module -Name PSWindowsUpdate -Force

### Execution Policy Error
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

### No Updates Available
This is normal on freshly patched systems. Run `.Scripts\PatchCheck.ps1` to verify available updates.

## License
MIT License - See LICENSE file

## Support
For issues and improvements, please open an issue on GitHub.

## Author
Your Name

## Changelog
### v1.0 (Initial Release)
- Core patch checking functionality
- Automatic installation of critical patches
- Logging system
- HTML/CSV report generation
- Scheduled task support
