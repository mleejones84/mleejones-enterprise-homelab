# Ticket #INC-10028: Host GPU Infrastructure Upgrade & Proprietary PSU Current Limitation Triage

## Ticket Fields & Details

| Parameter | Value |
| :--- | :--- |
| **User / Asset Name** | Host Virtualization Tower (Dell Precision 3440 SFF) |
| **Severity** | Medium (Hardware modification / expansion constraint) |
| **Category** | Hardware / Physical Infrastructure |
| **Time to Resolve** | 1.5 Hours |

## Executive Summary
🚨 **Incident Report:** The host virtualization platform required an independent, dedicated graphics processor upgrade (NVIDIA T1000) to support dense hardware-accelerated computing loads. Initial physical inspection and engineering review of the factory Dell OEM schematics revealed a critical infrastructure bottleneck: the factory-installed proprietary Power Supply Unit (PSU) lacked the required wattage output and PCIe power rails, threatening system stability.

### 1. Initial Symptoms & Hardware Constraints
- **Action taken:** Evaluated the physical chassis footprint and electrical draw profiles of the target GPU upgrade against the host tower's default specifications.
- **Observation:** The stock Dell Precision small-form-factor PSU was rated at a highly restrictive 260W maximum output. The target enterprise graphics card configuration demanded continuous stable power draw that would push the total system load dangerously close to a thermal or over-current shutdown trip point.

### 2. OEM Technical White Paper Analysis
- **Diagnostic Step:** Retrieved and analyzed the official Dell internal technical white papers and mechanical diagrams for the Precision 3440 motherboard bus routing.
- **Deduction:** The motherboard uses a proprietary 6-pin and 4-pin ATX power delivery architecture rather than a standard industry 24-pin block. To successfully bypass this constraint without bricking the core silicon, a highly specific high-output OEM replacement unit (Dell 500W Platinum PSU) had to be acquired to match the proprietary power delivery lines.

### 3. Differential Triage & Component Installation
- **Chassis Geometry Verification:** Verified the physical length and width constraints of the PCIe x16 slot using chassis schematics to prevent conflict with local SATA data lines or the CPU cooling shroud.
- **Power Rail Isolation:** Disconnected the degraded 260W module and safely mapped out the proprietary power paths. Routed the new 500W modular power rails directly to the motherboard logic boards and verified standard pin alignment.

### 4. Root Cause & Engineering Verification
The system constraint was isolated completely to proprietary physical power delivery limitations. By mapping the solution directly out of the manufacturer's structural documentation, the system load parameters were expanded safely without altering the underlying bare-metal Hyper-V platform environment.

## 🛠️ Implemented Engineering Solution

1. **Physical Component Swapping:** Safely unseated the factory 260W unit and hot-swapped the physical chassis footprint with the upgraded 500W enterprise power unit.
2. **GPU Interposition:** Seated the low-profile graphics acceleration card into the primary PCIe Gen 3 x16 motherboard slot, ensuring proper latch locking.
3. **Power Diagnostic Execution:** Booted the host machine directly into the native Dell UEFI/BIOS diagnostic environment before loading the Windows kernel. Ran a complete system stress test across all power rails to verify thermal profiles.
4. **Result:** The system verified 100% hardware compliance. Loaded the host OS, executed a clean driver stack installation, and confirmed full operational stability under peak VM emulation loads.
