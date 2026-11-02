# AD-StaleAccountAudit.ps1
# Purpose: Audit and report on inactive domain accounts older than 90 days.

Import-Module ActiveDirectory

# Define parameters
$DaysInactive = 90
$CutOffDate = (Get-Date).AddDays(-$DaysInactive)
$ReportPath = "C:\IT-Operations\Reports\StaleAccounts_$(Get-Date -Format 'yyyyMMdd').csv"

Write-Host "Starting Active Directory stale account audit..." -ForegroundColor Cyan

# Fetch users who haven't logged in since the cutoff date
$StaleUsers = Get-ADUser -Filter {Enabled -eq $true} -Properties LastLogonDate, Department, Title | 
    Where-Object { $_.LastLogonDate -lt $CutOffDate -and $_.LastLogonDate -ne $null }

if ($StaleUsers.Count -eq 0) {
    Write-Host "No stale accounts detected. System compliant." -ForegroundColor Green
} else {
    Write-Host "Found $($StaleUsers.Count) stale accounts. Exporting report..." -ForegroundColor Yellow
    
    # Format and export the payload
    $StaleUsers | Select-Object Name, SamAccountName, Department, Title, LastLogonDate | 
        Export-Csv -Path $ReportPath -NoTypeInformation
        
    Write-Host "Audit complete. Report generated at: $ReportPath" -ForegroundColor Green
}