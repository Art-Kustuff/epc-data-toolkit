# EPC Engineering Data Quality Toolkit

Public-safe toolkit and portfolio repository for engineering data validation, reporting readiness checks, and dashboard-oriented data preparation in EPC/LNG environments.

This repository brings together a small set of practical utilities and concepts used to improve the reliability of engineering and progress reporting by checking data quality before it reaches dashboards, KPIs, or management reports.

## Portfolio context

This repository supports two portfolio case studies:

- **Case 02 — Tag Data Quality Monitoring & Validation Framework**
- **Case 03 — Data Validation Pipeline & Reporting Refresh Prototype**

The goal is not to expose project-specific data or internal company workflows, but to demonstrate the validation logic, reporting controls, and architecture thinking behind more reliable engineering data analytics.

## What this repository covers

The toolkit is built around four recurring problems in EPC engineering data work:

1. **Tag data quality**
   - missing fields
   - placeholder values
   - duplicates
   - weak parent / drawing / source traceability
   - inconsistent completeness by discipline

2. **Data quality over time**
   - week-over-week improvement / regression tracking
   - field-level trend monitoring
   - health checks across snapshots

3. **Reporting readiness**
   - planning / setup issues that distort downstream reporting
   - readiness gaps before KPI dashboards are refreshed
   - upstream checks before management views are trusted

4. **Refresh pipeline thinking**
   - extract → validate → prepare → refresh logic
   - cleaner reporting datasets before BI refresh
   - machine-readable outputs for traceability and review

## Repository structure

```text
epc-data-toolkit/
├── README.md
├── tools/
│   ├── tag_register_validator.py
│   ├── weekly_health_check.py
│   ├── planning_setup_validator.py
│   ├── fwbs_suggester.py
│   ├── auto_refresh_pipeline.py
│   └── file_organizer.ps1
├── docs/
│   ├── dashboard_case02.png
│   ├── dashboard_case03.png
│   ├── file_organizer_console.png
│   ├── file_organizer_before_after.png
│   └── file_organizer_log_example.csv
└── examples/
    └── sample_naming_convention.txt
```

## Main tools

### 1. Tag Register Validator
**File:** `tools/tag_register_validator.py`

Single-file engineering data quality check for EasyPlant Tag Register exports.

**Covers:**
- mandatory field checks
- placeholder detection
- duplicate tags
- parent tag self-reference
- naming convention issues
- completeness heatmap by discipline
- source-oriented completeness review

**Portfolio role:** core logic behind **Case 02**.

---

### 2. Weekly Health Check
**File:** `tools/weekly_health_check.py`

Compares two engineering data snapshots and highlights:
- completeness improvements
- regressions week over week
- field-level quality trends
- reporting-readiness changes across snapshots

**Portfolio role:** extends Case 02 from a static validator into trend / regression monitoring.

---

### 3. Planning Setup Validator
**File:** `tools/planning_setup_validator.py`

Checks planning setup and reporting configuration for issues that can reduce reporting reliability, such as:
- quantity without manhours
- MHR without quantity
- inconsistent setup conditions
- configuration gaps affecting downstream reporting
- invalid or incomplete readiness fields

**Portfolio role:** readiness / setup validation layer inside **Case 02**.

---

### 4. FWBS Suggestion Logic
**File:** `tools/fwbs_suggester.py`

Applies controlled pattern-based logic to support missing FWBS assignment review.

**Purpose:**
- identify likely breakdown mapping candidates
- support engineering review
- reduce manual searching for repeat mapping patterns

This is designed as a **review-support utility**, not a blind auto-update mechanism.

**Portfolio role:** remediation-support utility inside **Case 02**.

---

### 5. Auto Refresh Pipeline
**File:** `tools/auto_refresh_pipeline.py`

Prototype pipeline for:
- extracting engineering datasets
- running validation checks upstream
- preparing cleaner reporting datasets
- supporting reporting refresh workflows
- generating machine-readable outputs for review / traceability

**Portfolio role:** core logic behind **Case 03**.

---

### 6. PowerShell Document Organizer
**File:** `tools/file_organizer.ps1`

Small PowerShell utility for routing engineering deliverables into discipline / document-type folders based on naming convention.

**Features:**
- dry-run mode
- recursive scan
- copy / move mode
- collision-safe naming
- CSV log
- JSON summary
- fallback routing to `_Unsorted`

**Portfolio role:** supporting Windows-side automation utility inside the broader toolkit.

## Quick start

Install dependencies:

```bash
pip install pandas openpyxl
```
Run a utility:
```bash
python tools/tag_register_validator.py
python tools/weekly_health_check.py
python tools/planning_setup_validator.py
python tools/fwbs_suggester.py
```
Run the PowerShell organizer:
```bash
.\tools\file_organizer.ps1 -SourcePath "C:\Docs" -DestPath "C:\Organized" -LogOnly
```
Run the refresh pipeline prototype:
```bash
python tools/auto_refresh_pipeline.py --files ./exports/ --output ./dashboard_data
```
Some tools in this repository are portfolio-oriented utilities and may require local input files or safe example datasets to run.

## Public-safe note

All examples in this repository are presented in a public-safe format.

Where applicable:
- project-specific values were removed or generalized
- counts and metrics may be masked, rounded, or modified
- contractor references are anonymized
- examples are shown to demonstrate logic, not live operational status

## Why this matters

In large EPC environments, dashboards are only useful when the underlying engineering data is reliable.

This toolkit is built around one idea:

**improve trust in reporting by validating data before it reaches management views.**

## Related portfolio cases

- **Case 02 — Tag Data Quality Monitoring & Validation Framework**
- **Case 03 — Data Validation Pipeline & Reporting Refresh Prototype**

## Author

**Artem Kustov**  
Engineering Data & Reporting Specialist  
Doha, Qatar

Portfolio: `https://art-kustuff.github.io/`  
GitHub: `https://github.com/Art-Kustuff`
