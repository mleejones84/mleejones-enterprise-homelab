<#
.SYNOPSIS
    Deploys the companion Windows 11 Pro workstation (WIN11-PRO-02) for the mleejones.lab infrastructure.
.NOTES
    Author: M. Lee Jones
    Date: 2026
#>

# 1. Environmental Variables
$VMName      = "WIN11-PRO-02"
$SwitchName  = "HelpDesk-Internal"
$VHDXPath    = "C:\Hyper-V\Virtual Machines\WIN11-PRO-02\WIN11-PRO-02.vhdx"
$ISOPath     = "C:\ISO-Library\windows_11_enterprise_eval.iso"

Write-Host "🚀 Forcing sequential deployment for workstation node: $VMName..." -ForegroundColor Cyan

# 2. Forge the Gen-2 Windows 11 Hardware Container
New-VM -Name $VMName -MemoryStartupBytes 4GB -Generation 2 -NewVHDPath $VHDXPath -NewVHDSizeBytes 60GB -SwitchName $SwitchName

# 3. Tune Windows 11 Performance Constraints
Set-VMProcessor -VMName $VMName -Count 2
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $True -MinimumBytes 2GB -MaximumBytes 6GB

# 4. Mount Installation Media
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

Write-Host "🎯 [SUCCESS] $VMName hardware container successfully deployed!" -ForegroundColor Green
Write-Host "👉 Action: Open Hyper-V, start '$VMName', and tap your keyboard to boot into the client installer!" -ForegroundColor Yellow