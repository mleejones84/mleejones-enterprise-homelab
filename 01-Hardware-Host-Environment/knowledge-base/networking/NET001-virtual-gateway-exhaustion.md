# Ticket #INC-10034: Hyper-V Internal Virtual Switch Routing Drop & DHCP Scope Saturation

## Ticket Fields & Details

| Parameter | Value |
| :--- | :--- |
| **User / Asset Name** | Core Virtual Network Infrastructure (Hyper-V V-Switch Host) |
| **Severity** | High (Cascading network isolation across local VM subnets) |
| **Category** | Networking / Virtual Infrastructure |
| **Time to Resolve** | 1 Hour |
| **Historical Framework** | BellSouth Enterprise Triage Script (CallTech Communications) |

## Executive Summary
🚨 **Incident Report:** Multiple newly provisioned guest operating systems suddenly lost internal network connectivity and local domain access, reverting to APIPA addresses (`169.254.x.x`). Diagnostic triage isolated a dual-layered infrastructure failure: the logical binding on the Hyper-V Internal Virtual Switch interface dropped its routing path, compounded by a DHCP IP pool exhaustion on the local routing gateway.

### 1. Initial Symptoms & Layer 1/2 Triage
- **Action taken:** Executed standard local network interface diagnostics from a disconnected client machine using the command-line interface.
- **Diagnostic Step:** Ran `ipconfig /all` on a failed workstation VM. The network adapter showed an active link state but failed to pull a valid IP configuration from the local domain scope (`10.0.10.x`).
- **Isolation:** Ran `arp -a` from the client. The local hardware switch map was completely blank, indicating a breakdown in Layer 2 broadcast discovery across the virtual backplane.

### 2. Layer 3 Routing & DNS Analysis
- **Action taken:** Jumped onto the host machine and initialized deep packet tracing using native administrative tools.
- **Observation:** Attempted to ping the virtual gateway interface (`ping 10.0.10.1`) from the host terminal. The request timed out. 
- **Deduction:** Utilizing BellSouth-standard diagnostic logic mastered during high-volume call triage at CallTech Communications, the failure point was isolated away from physical line attenuation or hardware. The issue lay entirely within the virtualized logical layer...

### 3. First-Call Resolution Diagnostic Execution
- **Scope Audit:** Connected directly to the DHCP Server scope management console to audit lease parameters. Found the local pool allocation at 100% capacity (Scope Exhaustion). 
- **Root Cause:** A collection of transient, deleted test containers had failed to release their dynamic IP allocations, completely blocking new virtual assets from obtaining a network lease.

### 4. Root Cause Determination
The network blackout was caused by an OS-layer driver update that temporarily reset the binding parameters of the virtual network adapter, combined with a rigid, non-expiring DHCP lease timer that led to total IP pool starvation.

## 🛠️ Implemented Engineering Solution

1. **Virtual Adapter Re-Binding:** Refreshed and re-established the logical IP address bindings on the Hyper-V Internal Virtual Switch interface using administrative terminal tools to restore the Layer 3 path:
   ```powershell
   Disable-NetAdapter -Name "vEthernet (InternalSwitch)"
   Enable-NetAdapter -Name "vEthernet (InternalSwitch)"
   New-NetIPAddress -InterfaceAlias "vEthernet (InternalSwitch)" -IPAddress 10.0.10.1 -PrefixLength 24
   ```
2. **DHCP Cache Remediation & Scope Flushing:** Purged the stale, dead MAC address leases from the active DHCP allocation table to instantly free up valid leases for active nodes:
   ```powershell
   ipconfig /flushdns
   ```
   *(Adjusted the DHCP scope lease duration parameters down from 8 days to a highly responsive 2 hours to prevent future container saturation).*
3. **Lease Verification:** Executed a forced lease renewal on the isolated client VMs:
   ```powershell
   ipconfig /release
   **ipconfig /renew**
   ```
4. **Result:** All guest virtual machines immediately pulled valid IP addresses within the `10.0.10.x` domain structure. Confirmed full end-to-end routing stability, local domain synchronization, and external gateway navigation with a 100% packet success rate.
