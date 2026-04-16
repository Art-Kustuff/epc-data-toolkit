# EPC Engineering Data Quality Toolkit

Public-safe toolkit and portfolio repository for engineering data validation, reporting readiness checks, and dashboard-oriented data preparation in EPC/LNG environments.

This repository groups together practical utilities and concepts used to improve the reliability of engineering and progress reporting by checking data quality before it reaches dashboards or management reports.

## What this repository covers

This repository supports two portfolio case studies:

- **Case 02 — Tag Data Quality Monitoring & Validation Framework**
- **Case 03 — Proposed Data Validation Pipeline & Reporting Refresh**

The four utilities below support these case studies by covering different aspects of data validation, reporting readiness, and reporting pipeline design.

The focus is not on exposing project-specific data or internal workflows, but on demonstrating the validation logic, reporting controls, and architecture thinking behind reliable engineering data analytics.

## Repository contents

### 1. Weekly Health Check
Compares two engineering data snapshots and highlights:

- completeness improvements
- regressions week over week
- field-level quality trends
- reporting-readiness changes across datasets

**Purpose:** show how data quality evolves over time instead of relying on a single static snapshot.

### 2. Planning Setup Validator
Checks planning setup and reporting configuration for issues that can reduce reporting reliability, such as:

- quantity without manhours
- inconsistent setup conditions
- configuration gaps affecting downstream reporting
- invalid or incomplete readiness fields

**Purpose:** detect upstream setup issues before they distort KPI reporting and dashboards.

### 3. FWBS Suggestion Logic
Applies controlled pattern-based logic to support missing FWBS assignment review.

**Purpose:** help identify likely breakdown mapping candidates while keeping final review under engineering control.

> This is designed as a review-support utility, not a blind auto-update mechanism.

### 4. Dashboard Pipeline Concept
Illustrative architecture concept for:

- extracting engineering datasets
- running validation checks upstream
- preparing cleaner reporting datasets
- supporting reporting refresh workflows

**Purpose:** demonstrate how validation logic can be integrated into a broader reporting pipeline.

## Quick start

Install dependencies:

```bash
pip install pandas openpyxl
```

Run a utility:

```bash
python weekly_health_check.py
python planning_setup_validator.py
```

> Some tools in this repository are portfolio-oriented utilities and may require local input files or safe example datasets to run.

## Portfolio positioning

This repository is intended as a **public portfolio artifact**.
It demonstrates how engineering data can be:

- validated before reporting
- monitored over time
- checked for reporting readiness
- prepared for more reliable BI / dashboard refresh

It is not intended to expose live project data, confidential structures, or internal company reporting models.

## Public-safe note

All examples in this repository are presented in a **public-safe format**.

Where applicable:

- project-specific values were removed or generalized
- counts and metrics may be masked, rounded, or modified
- contractor references are anonymized
- examples are shown to demonstrate logic, not live operational status

## Tech stack

- Python
- Excel-based data processing
- Power BI reporting workflows
- EPC / LNG engineering data context
- EasyPlant-oriented reporting logic
- Validation-first reporting approach

## Why this matters

In large EPC environments, dashboards are only useful when the underlying engineering data is reliable.

This toolkit is built around one idea:

**improve trust in reporting by validating data before it reaches management views.**

## Related portfolio cases

- **Case 02:** Tag Data Quality Monitoring & Validation Framework
- **Case 03:** Proposed Data Validation Pipeline & Reporting Refresh

## Author

**Artem Kustov**
Engineering Data & Reporting Specialist
Doha, Qatar

Portfolio: `art-kustuff.github.io`
GitHub: `github.com/Art-Kustuff`
