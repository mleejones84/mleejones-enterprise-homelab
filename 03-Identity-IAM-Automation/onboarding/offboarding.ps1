# 1. Environment Configurations & Archive Path Boundaries
$DomainDN = "DC=mleejones,DC=lab"
$ArchiveOUPath = "OU=Disabled_Users,OU=MLeeJones_Enterprise,$DomainDN"

Write-Host "==========================================================" -ForegroundColor Red
Write-Host " ENTERPRISE IDENTITY DE-PROVISIONING LIFECYCLE" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Red

# 2. Interactive Operator Input
$TargetUser = Read-Host -Prompt "Enter the samAccountName of the user to offboard"
$TargetUser = $TargetUser.Trim().ToLower()

# 3. Directory Existence Verification
try {
    $ADUser = Get-ADUser -Identity $TargetUser -Properties MemberOf, Description
}
catch {
    Write-Error "CRITICAL: Target identity '$TargetUser' does not exist in mleejones.lab. Aborting pipeline."
    Exit
}

Write-Host "`n[!] Initiating offboarding sequence for: $($ADUser.Name) ($TargetUser)" -ForegroundColor Yellow

# 4. Create Archive OU if it doesn't exist
if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ArchiveOUPath'")) {
    New-ADOrganizationalUnit -Name "Disabled_Users" -Path "OU=MLeeJones_Enterprise,$DomainDN"
    Write-Host "[+] Created archive container: Disabled_Users" -ForegroundColor Cyan
}

# 5. Execute Multi-Stage Security Teardown
try {
    # Phase A: Account Disable & Password Scramble
    # Generates a random 32-character string to ensure the old password is totally unrecoverable
    $ScrambledPassword = [System.Web.Security.Membership]::GeneratePassword(32, 5) | ConvertTo-SecureString -AsPlainText -Force
    Set-ADAccountPassword -Identity $TargetUser -NewPassword $ScrambledPassword -Confirm:$false
    Disable-ADAccount -Identity $TargetUser
    Write-Host "  [+] Account disabled and login credentials cryptographically rotated." -ForegroundColor Green

    # Phase B: Universal Group Membership Stripping (Except Primary Group 'Domain Users')
    # This prevents 'privilege creep' if the account is ever re-enabled
    $Groups = $ADUser.MemberOf
    foreach ($Group in $Groups) {
        if ($Group -notlike "*Domain Users*") {
            Remove-ADGroupMember -Identity $Group -Members $TargetUser -Confirm:$false
        }
    }
    Write-Host "  [+] Stripped all secondary security group and administrative memberships." -ForegroundColor Green

    # Phase C: Update Directory Metadata for Audit Trails
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $NewDescription = "OFFBOARDED: $Timestamp by Admin. Original Dept: $($ADUser.Department)"
    Set-ADUser -Identity $TargetUser -Description $NewDescription
    Write-Host "  [+] Administrative description updated with explicit audit trail metadata." -ForegroundColor Green

    # Phase D: Directory Object Archive Migration
    Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $ArchiveOUPath
    Write-Host "  [+] Object successfully migrated to isolated archive container: Disabled_Users" -ForegroundColor Green

    Write-Host "`n[SUCCESS] SECURE OFFBOARDING PIPELINE COMPLETE FOR $TargetUser." -ForegroundColor Green
}
catch {
    Write-Error "CRITICAL FAILURE: Sequence interrupted during de-provisioning. Error context: $_"
}

Write-Host "==========================================================" -ForegroundColor Red