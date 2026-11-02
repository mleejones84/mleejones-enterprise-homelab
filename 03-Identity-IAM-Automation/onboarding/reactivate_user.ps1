# 1. Environment Configurations & Path Boundaries
$DomainDN = "DC=mleejones,DC=lab"
$BaseOUPath = "OU=Standard_Users,OU=MLeeJones_Enterprise,$DomainDN"

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " ENTERPRISE IDENTITY REACTIVATION PIPELINE" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

# 2. Interactive Operator Input
$TargetUser = Read-Host -Prompt "Enter the samAccountName to reactivate"
$TargetUser = $TargetUser.Trim().ToLower()

# 3. Directory Existence Verification
try {
    $ADUser = Get-ADUser -Identity $TargetUser -Properties Description
}
catch {
    Write-Error "CRITICAL: Target identity '$TargetUser' not found in directory. Aborting."
    Exit
}

# 4. Gather New Deployment Metadata
Write-Host "`n[!] Found identity: $($ADUser.Name)" -ForegroundColor Cyan
Write-Host "[!] Current Metadata: $($ADUser.Description)" -ForegroundColor Cyan
$NewDept = Read-Host -Prompt "Enter the user's new Department"
$NewDept = $NewDept.Trim()

Write-Host "`n[!] Re-provisioning account properties..." -ForegroundColor Yellow

# 5. Execute Multi-Stage Reactivation Sequence
try {
    # Phase A: Move Object Back to Active Standard_Users OU
    Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $BaseOUPath
    Write-Host "  [+] Object migrated out of archive to active Standard_Users container." -ForegroundColor Green

    # Phase B: Reset Department and Establish Audit Trail
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $NewDescription = "REACTIVATED: $Timestamp by Admin. Current Dept: $NewDept"
    Set-ADUser -Identity $TargetUser -Department $NewDept -Description $NewDescription
    Write-Host "  [+] Department updated and fresh audit metadata appended." -ForegroundColor Green

    # Phase C: Provision New Secure Temporary Password
    $TempPassword = ConvertTo-SecureString "TempP@ssword123!" -AsPlainText -Force
    Set-ADAccountPassword -Identity $TargetUser -NewPassword $TempPassword -Confirm:$false
    Write-Host "  [+] Temporary password assigned successfully." -ForegroundColor Green

    # Phase D: Enable Account & Enforce Change at Next Logon
    Enable-ADAccount -Identity $TargetUser
    Set-ADUser -Identity $TargetUser -ChangePasswordAtLogon $true
    Write-Host "  [+] Identity status flipped to ENABLED. Password change mandated at first interactive logon." -ForegroundColor Green

    # Phase E: Role-Based Management Re-Escalation Layer (Justin Green Check)
    if ($NewDept -eq "Manager") {
        $ManagerGroupName = "Lab_Management_Team"
        Add-ADGroupMember -Identity $ManagerGroupName -Members $TargetUser
        Write-Host "  [+] RBAC MATCH: Re-assigned $TargetUser to $ManagerGroupName group." -ForegroundColor Yellow
    }

    Write-Host "`n[SUCCESS] SECURE ACCOUNT REACTIVATION COMPLETE FOR $TargetUser." -ForegroundColor Green
}
catch {
    Write-Error "CRITICAL FAILURE: Pipeline interrupted during reactivation. Error context: $_"
}

Write-Host "==========================================================" -ForegroundColor Green