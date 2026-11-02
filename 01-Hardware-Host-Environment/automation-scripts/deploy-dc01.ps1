# 1. Environmental Variables
$VMName      = "DC-01"
$SwitchName  = "HelpDesk-Internal"
$VMPath      = "C:\Hyper-V\Virtual Machines"
$VHDXPath    = "C:\Hyper-V\Virtual Machines\DC-01\DC-01.vhdx"
$ISOPath     = "C:\ISO-Library\Windows_Server_2025_Eval.iso"

Write-Host "🚀 Forcing sequential deployment for node: $VMName..." -ForegroundColor Cyan

# 2. Forge the Gen-2 Virtual Machine Hardware Container
New-VM -Name $VMName -MemoryStartupBytes 2GB -Generation 2 -NewVHDPath $VHDXPath -NewVHDSizeBytes 60GB -SwitchName $SwitchName

# 3. Tune Compute & Memory Allocation
Set-VMProcessor -VMName $VMName -Count 2
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $True -MinimumBytes 1GB -MaximumBytes 4GB

# 4. Mount Installation Media
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

Write-Host "🎯 [SUCCESS] Hardware container successfully deployed!" -ForegroundColor Green
Write-Host "👉 Double-click 'DC-01' in Hyper-V, hit Start, and tap your keyboard to boot!" -ForegroundColor Yellow