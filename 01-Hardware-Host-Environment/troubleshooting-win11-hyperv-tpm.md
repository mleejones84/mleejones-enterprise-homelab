# Technical Case Study: Bypassing TPM 2.0 & Secure Boot Constraints in Hyper-V

## 1. Problem Statement
During the automated deployment phase of a Windows 11 Enterprise virtual workstation (`WIN11-PRO-02`), the Windows Setup wizard halted initialization with the following error:
> *"This PC doesn't meet the minimum system requirements to install this version of Windows."*

### Root Cause Analysis
By default, Hyper-V provisions Generation 2 virtual machines with virtualized security architectures disabled to maintain legacy OS compatibility. Windows 11 strictly enforces hardware verification checks for **Trusted Platform Module (TPM 2.0)** compliance and **Secure Boot** pathways during the initial handshake. Because these flags were missing from the VM configuration matrix, the installer blocked execution.

---

## 2. Resolution Strategy & CLI Refactoring
Rather than navigating through GUI menus, the hypervisor's hardware state was refactored directly via administrative **PowerShell**. 

### Step 1: Establish Cryptographic Protection
The initial attempt to enable the TPM engine failed due to an unconfigured key protector architecture. Hyper-V requires an encryption vault to shield virtualized security metrics. A local key protector was provisioned:

```powershell
Set-VMKeyProtector -VMName "WIN11-PRO-02" -NewLocalKeyProtector
```

### Step 2: Provision Virtual TPM & Secure Boot
With the cryptographic foundation established, the virtual motherboard firmware configurations were updated to satisfy the Windows 11 deployment constraints:

```powershell
# Enforce Secure Boot using the standard Windows signing template
Set-VMFirmware -VMName "WIN11-PRO-02" -EnableSecureBoot On -SecureBootTemplate "MicrosoftWindows"

# Activate the virtual TPM 2.0 security chip
Enable-VMTPM -VMName "WIN11-PRO-02"
```

---

## 3. Results & Operational Verification
Following the CLI refactoring:
* The Windows 11 verification block was successfully bypassed.
* Hardware-level encryption flags verified active via hypervisor telemetry.
* Network integration completed with a baseline internal latency of **0ms** across the virtual switch fabric to `DC-01`.