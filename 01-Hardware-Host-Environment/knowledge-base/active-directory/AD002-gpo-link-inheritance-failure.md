# Ticket #INC-10057: Client Group Policy Baseline Regression & Link Inheritance Interception


## Ticket Fields & Details

| Parameter | Value |
| :--- | :--- |
| **User / Asset Name** | Workstation VM (WIN11-PRO-02) / Identity (asmith) |
| **Severity** | Medium (Baseline compliance drift / local group vulnerability) |
| **Category** | Active Directory / Group Policy Objects |
| **Time to Resolve** | 35 Minutes |
| **Historical Framework** | CallTech Communications Service Metrics / Escalations Triage |

## Executive Summary

🚨 **Incident Report:** The virtualized client endpoint WIN11-PRO-02 experienced an unexpected configuration drift, causing a complete failure to apply corporate security baselines. Initial alerts indicated that local machine-tier security controls and idle user lockout policies had ceased execution. Systematic command-line diagnostics isolated a dual-layered architectural failure: an upstream organizational unit (OU) container-level inheritance block (gpOptions = 1) compounded by a disabled direct linkage state on the target policy object.

### 1. Initial Symptoms & Client-Side Boundary Gating

- **Action taken:** Initialized local policy verification via an administrative terminal session on the impacted Windows 11 client machine.
- **Diagnostic Constraint:** Attempted machine-scoped telemetry extraction under standard user principal context (asmith). The Windows kernel natively rejected execution throwing an explicit "Access Denied" error code, validating intact local registry security boundaries.
- **Escalation Step:** Initialized an authentic, out-of-band administrative shell injection using the native command line utility:
runas /user:mleejones\Administrator powershell.exe

### 2. Resultant Set of Policy (RSoP) Telemetry Analysis

- **Action taken:** Executed a forced policy synchronization followed by a comprehensive machine-layer configuration audit within the validated administrative terminal:
gpupdate /force
gpresult /scope computer /r
- **Observation:** The terminal telemetry exposed that the critical security object "Sec_Workstation_Hardening" had dropped completely out of the active stack and regressed to the filtered register, flagging the explicit root cause:
The following GPOs were not applied because they were filtered out:
Sec_Workstation_Hardening
Filtering: Disabled (Link)
- **Upstream Discovery:** Further log inspection revealed that the root "Default Domain Policy" was also dropped from the hardware node, flagged as: "Not Applied (Unknown Reason)". This confirmed that parent container inheritance had been actively blocked at a higher logical boundary.

### 3. Root Cause Determination

The systemic engineering failure was isolated to a two-part configuration error at the Directory Services layer:
1. The "gpOptions" database attribute on the "Workstations" OU was flipped to 1, introducing a hard Block Inheritance command that stripped the root domain baseline policies.
2. The LinkEnabled state on the direct "Sec_Workstation_Hardening" object was set to False, completely removing the local hardware defense matrix.

## Implemented Engineering Solution & Environmental Restoral

Remediation was executed entirely from the command-line subsystem on the Domain Controller (DC-01) to restore infrastructure integrity:
1. Target the Workstations OU and re-enable the GPO link path:
Set-GPLink -Name "Sec_Workstation_Hardening" -Target (Get-ADOrganizationalUnit -Filter "Name -eq 'Workstations'").DistinguishedName -LinkEnabled Yes
2. Reset the low-level database gpOptions attribute to 0 to unblock fluid inheritance down the tree:
Set-ADObject -Identity (Get-ADOrganizationalUnit -Filter "Name -eq 'Workstations'").DistinguishedName -Replace @{gpOptions = 0}
3. Final Verification: Executed a final forced update on the client workstation. Re-running the machine-scoped gpresult query confirmed that both objects successfully re-entered the active execution pool with a 100% processing success rate.