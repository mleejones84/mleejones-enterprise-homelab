# Ticket #INC-10041: Active Directory Domain Secure Channel Trust Failure

## Ticket Fields & Details

| Parameter | Value |
| :--- | :--- |
| **User / Asset Name** | Workstation VM (WIN11-PRO-02) |
| **Severity** | High (User unable to authenticate / total local lockout) |
| **Category** | Active Directory / Identity Service |
| **Time to Resolve** | 45 Minutes |

## Executive Summary
🚨 **Incident Report:** A virtualized Windows 11 workstation suddenly failed domain authentication, throwing the error: *"The trust relationship between this workstation and the primary domain failed."* Local triage isolated the root cause to a Kerberos protocol time skew exceeding the maximum allowable 5-minute threshold due to Hyper-V host-to-guest time synchronization drift.

### 1. Initial Symptoms & Software Triage
- **Action taken:** Attempted domain login using standard domain user credentials and domain administrator overrides.
- **Result:** Authentication blocked natively by the OS kernel. Switched to a local administrator account bypass (`.\localadmin`) to gain terminal access.
- **Diagnostic Step:** Audited the local Windows Security Event Viewer logs. Found **Event ID 4625 (An account failed to log on)** coupled with explicit Kerberos authentication failure codes pointing to clock skew errors.

### 2. Pre-OS & Hypervisor Environment Analysis
- **Observation:** Checked the system time on the virtual machine client vs. the physical hardware clock on the Hyper-V host server. 
- **Deduction:** The client VM clock was drifting exactly 7.5 minutes behind the primary Active Directory Domain Controller (DC-01). Because the Kerberos V5 protocol relies heavily on strict time-stamping to prevent replay attacks, it automatically invalidated the workstation's authentication tokens.

### 3. Differential Diagnostics & Isolation
- **Domain Controller Validation:** Ran `dcdiag` on the Domain Controller to ensure replication lines and DNS lookup zones were fully healthy. The DC was functioning flawlessly.
- **Hyper-V Integration Check:** Inspected the VM settings inside **Hyper-V Virtual Machine Manager**. The "Time Synchronization" option under Integration Services was checked, but the host machine itself had briefly desynced from its upstream NTP server during a routine maintenance window.

### 4. Root Cause Determination
The independent boundary test definitively isolated a Kerberos clock skew failure. The hypervisor host experienced an NTP time drift, which trickled down to the virtualized guest workstation via Hyper-V integration services, violating the default 5-minute Active Directory Kerberos security policy.

## 🛠️ Implemented Engineering Solution

1. **Host NTP Alignment:** Resynced the primary Hyper-V host tower clock using an authoritative external time provider via PowerShell:
   ```powershell
   w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:YES /update
   w32tm /resync
   ```
2. **Workstation Re-Sync:** Jumped back onto the locked-out Windows 11 VM terminal and forced an immediate hardware clock correction to match the newly synchronized Domain Controller:
   ```powershell
   w32tm /resync /force
   ```
3. **Trust Channel Reset:** Fixed the broken computer account password link inside Active Directory using a clean PowerShell command line interface bypass, avoiding the need to manually drop and re-join the domain:
   ```powershell
   Test-ComputerSecureChannel -Repair -Credential (Get-Credential)
   ```
4. **Result:** The secure trust channel was instantly restored. Executed a clean logout and confirmed the user could successfully log back in using their standard corporate Active Directory credentials with 100% stability.
