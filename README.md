# Enterprise Hybrid Infrastructure & Automation Sandbox

## 🧠 Operational Philosophy & The Triage Instinct
My transition into Systems Administration is backed by a 20-year foundation in high-pressure culinary operations and enterprise queue triage, bridging technical engineering with strict process discipline to deliver resilient infrastructure.

---

## 🏛️ Repository Architecture & Portfolio Roadmap
This master repository functions as a multi-phased implementation guide documenting the deployment, network segmentation, automation, and cloud synchronization of an isolated enterprise enclave.

*   `📁 01-Hardware-Host-Environment` — Bare-metal diagnostic triage & Type-1 Hyper-V configuration
*   `📁 02-Core-Infrastructure` — Active Directory Domain Services, DNS Scavenging, DHCP provisioning
*   `📁 03-Identity-IAM-Automation` — Account Lifecycles via PowerShell, CSV Ingestion, RBAC validation
*   `📁 04-Group-Policy-Hardening` — [IN PROGRESS] Functional GPO tiering & Inheritance troubleshooting telemetry
*   `📁 05-Cloud-Hybrid-EntraID` — [IN PROGRESS] M365 Developer Tenant, Entra Cloud Sync, Hybrid IAM

---

## 💻 Tech Stack & Lab Specifications
*   **Host Hardware:** Dell Precision 3440 | Intel Core i7-10700 (8 Cores, 16 Threads) | 16 GB RAM | 512 GB SATA SSD
*   **Host OS / Hypervisor:** Windows 11 Pro (Hyper-V Virtualization Layer)
*   **Directory Services:** Windows Server 2022 (Forest/Domain Functional Level: Windows Server 2022)
*   **Core Subnet Typography:** Gateway: `10.0.10.1` | Subnet: `10.0.10.0/24` | DC & DNS: `10.0.10.10` | DHCP Range: `10.0.10.50 - 10.0.10.254`

---

## 🚀 Key Engineering Milestones
*   **Hardware & Hypervisor:** Configured an isolated testing environment with automated Windows 11 OOBE registry bypasses.
*   **Infrastructure Automation:** Built a programmatic PowerShell suite for Active Directory provisioning and closed-loop user onboarding/offboarding lifecycle management.
*   **Group Policy & DNS:** Established a deterministic 14-day DNS scavenging topology. Engineered a modular GPO architecture featuring a planned inheritance block failure analysis simulation.
*   **Next Phase:** Preparing the integration of an M365 Developer Sandbox, Entra Cloud Sync, and Microsoft Graph PowerShell SDK migration.

*For the complete and unabridged configuration details, code blocks, and deployment logs, please refer to the primary repository documentation.*