<#
.SYNOPSIS
    Automates morning infrastructure deployment of geographic target job portals.
.DESCRIPTION
    Launches a hardcoded array of targeted regional public sector and institutional 
    employment portals within a specified driving radius. Designed to eliminate 
    administrative friction, platform drift, and time blindness during daily pipeline audits.
.PARAMETER TargetPortals
    An array of explicitly declared, deep-linked URLs representing secure hunting perimeters.
.EXAMPLE
    .\Launch-JobHunt.ps1
.NOTES
    Author: Marcellous Lee Jones
    Version: 1.0
    Target Perimeter: Valdosta-Thomasville-Tifton-Lake City (60-minute radius)
    Exclusions: Third-party scraping aggregators (Dice.com)
#>
# Launch-JobHunt.ps1
# Purpose: Single-click execution to open direct, deep-linked job filters.

Write-Host "Initializing Pipeline Deployment..." -ForegroundColor Cyan

# Force explicit array string separation using trailing commas
# ==============================================================================
# TARGET PORTAL REGIONS
# ==============================================================================

$TargetPortals = @(
    # 🏥 --- REGIONAL HEALTHCARE ANCHORS ---
    "https://careers.sgmc.org/", # South Georgia Medical Center
    "https://css-tiftregional-prd.inforcloudsuite.com/hcm/Jobs/list/JobPosting.SearchForJobsResults?csk.showusingxi=true&csk.JobBoard=EXTERNAL&csk.HROrganization=1", # Southwell Health/Tift Regional Medical Center
	"https://recruiting.ultipro.com/COL1042CRME/JobBoard/5ac3f35f-7e01-49ff-ad53-0acc27b4cee7/?q=&o=postedDateDesc", # Colquitt Regional Medical Center
    "https://pm.healthcaresource.com/cs/archbold#/search", # Archbold Medical Center
	"https://clinchmh.org/job-listings/", # Clinch Memorial Hospital
	"https://careers.hcahealthcare.com/", # HCA Healthcare

    # 🎓 --- HIGHER EDUCATION & INSTITUTIONAL ---
    "https://careers.hprod.onehcm.usg.edu/psc/careers/CAREERS/HRMS/c/HRS_HRAM_FL.HRS_CG_SEARCH_FL.GBL?FOCUS=Applicant&SiteId=51000", # Valdosta State University
    "https://careers.georgia.gov/jobs-search?search_api_fulltext_home=wiregrass+georgia+technical+college", # Wiregrass Georgia Technical College
    "https://pcom.wd108.myworkdayjobs.com/External", # PCOM Moultrie
    "https://www.thomasu.edu/about/employment/", # Thomas University
	"https://careers.hprod.onehcm.usg.edu/psc/careers/CAREERS/HRMS/c/HRS_HRAM_FL.HRS_CG_SEARCH_FL.GBL?FOCUS=Applicant&SiteId=88000&", # South Georgia State College
    "https://www.nfc.edu/about/employment-opportunities/employment-openings", # North Florida College
	"https://www.schooljobs.com/careers/fgcedu" # Florida Gateway College
)
# ==============================================================================
Write-Host "Launching background browser engine..." -ForegroundColor Yellow

foreach ($URL in $TargetPortals) {
    # Trim any hidden spaces and enforce string conversion
    $CleanURL = $URL.Trim()
    Start-Process $CleanURL
    Start-Sleep -Milliseconds 400
}

Write-Host "Deployment complete. 30-Minute Hunting Window Active!" -ForegroundColor Green