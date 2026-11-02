# Automation & Operational Efficiency Scripts

## 📌 Overview
This directory contains production-grade automation scripts designed to optimize daily workflow operations, eliminate administrative overhead, and mitigate cognitive friction/time blindness during systems engineering tasks and pipeline audits. 

Every script deployed here follows professional enterprise-grade PowerShell formatting guidelines, including full comment-based help blocks compatible with native `Get-Help` diagnostic tools.

---

## 🛠️ Script Inventory

### ⚡ [Launch-JobHunt.ps1](./Launch-JobHunt.ps1)
* **Language:** PowerShell Core / Windows PowerShell
* **Target Environment:** Client Host System
* **Purpose:** Automates the sequential infrastructure deployment of local enterprise, municipal, and institutional job boards within a defined 60-minute driving radius.

#### ⚙️ Operational Blueprint & Logic
1. **Target Perimeter Anchoring:** Hardcodes a secure array of deep-linked career portals, directly targeting local municipal systems (City of Valdosta, Lowndes County), academic frameworks (Valdosta State University, PCOM), and healthcare networks (SGMC).
2. **Platform Restrictions:** Explicitly isolates the search parameter to internal primary employer databases, intentionally locking out third-party scraping aggregators (e.g., Dice.com) to block inbound recruitment spam vectors.
3. **API Congestion Mitigation:** Utilizes a strict `Start-Sleep -Milliseconds 300` throttle delay inside the loop to prevent thread congestion and ensure stable web-browser engine initialization.
4. **Time Boxing Enforcement:** Restricts administrative overhead to a calculated 15-minute operational window, enforcing strict structural boundaries on daily workflows.

---

## 🚀 Deployment Instructions

### 📦 Creating a Single-Click Desktop Dashboard Icon
Because native Windows policies rightly restrict the direct double-click execution of raw script payloads (`.ps1`) for security reasons, the script is operationalized using an explicitly targeted execution shortcut:

1. Right-click the desktop and select **New > Shortcut**.
2. Paste the following execution argument into the location box (adjusting the target file path to your local repository directory):
   ```cmd
   powershell.exe -ExecutionPolicy Bypass -File "C:\Path\To\automation-scripts\Launch-JobHunt.ps1"
   ```
3. Name the shortcut **"Morning Job Sniper"** and assign an administrative dashboard icon.
4. Double-click to execute the automated daily scan pipeline.

---

## 📝 Best Practices & Standards
* All scripts must maintain strict string-boundary sanitation rules (e.g., explicit `.Trim()` validation) to neutralize syntax conflicts caused by complex web parameters.
* Arrays containing multi-tier URL arguments must enforce explicit trailing commas to prevent parser engine execution failures.