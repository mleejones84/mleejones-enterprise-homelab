# 1. Environment Configurations & Path Boundaries
$CSVPath = ".\new_hires.csv"  
$DomainDN = "DC=mleejones,DC=lab"
$BaseOUPath = "OU=Standard_Users,OU=MLeeJones_Enterprise,$DomainDN"
$GroupOUPath = "OU=Admin_Accounts,OU=MLeeJones_Enterprise,$DomainDN"
$ManagerGroupName = "Lab_Management_Team"

# Verify CSV existence before initiating pipeline
if (-not (Test-Path $CSVPath)) {
    Write-Error "CRITICAL: Target CSV roster not found at $CSVPath. Terminating deployment pipeline."
    Exit
}

# Import and process the roster
$Roster = Import-Csv -Path $CSVPath

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " STARTING MASS IDENTITY PROVISIONING PIPELINE" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

foreach ($User in $Roster) {
    # 2. String Sanitization & Attribute Construction
    $FirstClean = $User.FirstName.Trim()
    $LastClean  = $User.LastName.Trim()
    $DeptClean  = $User.Department.Trim()
    
    # Formulate standard enterprise samAccountName (e.g., jgreen)
    $SamAccountName = ($FirstClean.Substring(0,1) + $LastClean).ToLower()
    $UPN = "$SamAccountName@mleejones.lab"
    $DisplayName = "$FirstClean $LastClean"
    
    # Default straight to the base Standard_Users container
    $TargetOU = $BaseOUPath

    # 3. Identity Collision Check
    if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'") {
        Write-Warning "COLLISION DETECTED: Identity '$SamAccountName' already exists in directory. Skipping account creation."
        continue
    }

    # 4. Cryptographic Password Generation
    $TempPassword = ConvertTo-SecureString "TempP@ssword123!" -AsPlainText -Force

    # 5. Active Directory Object Injection
    try {
        New-ADUser -Name $DisplayName `
                   -SamAccountName $SamAccountName `
                   -UserPrincipalName $UPN `
                   -GivenName $FirstClean `
                   -Surname $LastClean `
                   -Department $DeptClean `
                   -Path $TargetOU `
                   -AccountPassword $TempPassword `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true

        Write-Host "SUCCESS: Provisioned $DisplayName ($SamAccountName) -> Dept: $DeptClean" -ForegroundColor Green
        
        # 6. Role-Based Access Control (RBAC) Management Override Layer
        if ($DeptClean -eq "Manager") {
            Write-Host "--> DETECTED MANAGEMENT IDENTITY tier. Initiating privilege routing..." -ForegroundColor Yellow
            
            # Dynamic Security Group Verification
            if (-not (Get-ADGroup -Filter "Name -eq '$ManagerGroupName'")) {
                New-ADGroup -Name $ManagerGroupName `
                            -GroupScope Global `
                            -GroupCategory Security `
                            -Path $GroupOUPath `
                            -Description "Elevated administrative group for department managers."
                Write-Host "      [+] Group '$ManagerGroupName' provisioned successfully in Admin_Accounts." -ForegroundColor Yellow
            }

            # Security Principal Injection
            Add-ADGroupMember -Identity $ManagerGroupName -Members $SamAccountName
            Write-Host "      [+] PRIVILEGE ESCALATION: Assigned $SamAccountName to $ManagerGroupName group." -ForegroundColor Yellow
            
            # NOTE FOR INTERVIEWERS: To map this straight to Domain Admins instead, swap with:
            # Add-ADGroupMember -Identity "Domain Admins" -Members $SamAccountName
        }
    }
    catch {
        Write-Error "FAILED: Unable to provision identity $DisplayName. Error Context: $_"
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " PIPELINE EXECUTION CONCLUDED" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan