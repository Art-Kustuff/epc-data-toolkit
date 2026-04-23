<# 
.SYNOPSIS
Organizes engineering documents into discipline / document-type folders based on naming convention.

.DESCRIPTION
Scans a source folder, parses engineering document file names, maps discipline and document type codes,
then copies or moves files into a structured destination tree.

Features:
- Supports dry run (-LogOnly)
- Supports recursive scan (-Recurse)
- Supports copy or move mode (-MoveFiles)
- Handles name collisions safely
- Sends unknown / unmatched files to _Unsorted
- Writes CSV log and JSON summary
- Supports summary-only console mode (-SummaryOnly)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $false)]
    [string]$DestPath = ".\Organized",

    [Parameter(Mandatory = $false)]
    [switch]$LogOnly,

    [Parameter(Mandatory = $false)]
    [switch]$MoveFiles,

    [Parameter(Mandatory = $false)]
    [switch]$Recurse,

    [Parameter(Mandatory = $false)]
    [switch]$Overwrite,

    [Parameter(Mandatory = $false)]
    [switch]$SummaryOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -----------------------------
# Configuration / lookup tables
# -----------------------------
$DisciplineCodes = @{
    "PR" = "Piping"
    "PI" = "Piping"
    "EL" = "Electrical"
    "IN" = "Instrumentation"
    "IC" = "Instrumentation"
    "ME" = "Mechanical"
    "MT" = "Mechanical"
    "CE" = "Civil"
    "CV" = "Civil"
    "ST" = "Structural"
    "TE" = "Telecom"
    "TC" = "Telecom"
    "AR" = "Architectural"
    "HV" = "HVAC"
    "CP" = "Cathodic_Protection"
}

$DocTypeCodes = @{
    "PID"  = "P_and_ID"
    "PFD"  = "Process_Flow_Diagram"
    "SLD"  = "Single_Line_Diagram"
    "DTS"  = "Datasheet"
    "MTO"  = "Material_Take_Off"
    "ISO"  = "Isometric"
    "LAY"  = "Layout"
    "GA"   = "General_Arrangement"
    "SCH"  = "Schedule"
    "CAL"  = "Calculation"
    "SPEC" = "Specification"
    "MR"   = "Material_Requisition"
    "TBE"  = "Technical_Bid_Evaluation"
    "DRW"  = "Drawing"
}

$NamePatterns = @(
    '^(?<Project>\d{3})-(?<Contract>\d{2})-(?<Disc>[A-Z]{2,3})-(?<DocType>[A-Z]{2,5})-(?<Number>\d{4,6})(?:-(?<Rev>[A-Z0-9]+))?$',
    '^(?<Disc>[A-Z]{2,3})-(?<DocType>[A-Z]{2,5})-(?<Number>\d{4,6})(?:-(?<Rev>[A-Z0-9]+))?$'
)

# -----------------------------
# Helper functions
# -----------------------------
function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor DarkGray
    Write-Host $Text -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor DarkGray
}

function Resolve-SafeFolderName {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return "_Unknown" }
    return ($Name -replace '[\\/:*?"<>|]', '_').Trim()
}

function Resolve-TargetFilePath {
    param(
        [string]$FolderPath,
        [string]$FileName,
        [switch]$Overwrite
    )

    $targetPath = Join-Path $FolderPath $FileName

    if ($Overwrite -or -not (Test-Path $targetPath)) {
        return $targetPath
    }

    $base = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $ext  = [System.IO.Path]::GetExtension($FileName)
    $i = 1

    do {
        $candidate = Join-Path $FolderPath ("{0}_dup{1}{2}" -f $base, $i, $ext)
        $i++
    } while (Test-Path $candidate)

    return $candidate
}

function Parse-DocumentName {
    param([string]$FileName)

    $baseName  = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $extension = [System.IO.Path]::GetExtension($FileName)

    foreach ($pattern in $NamePatterns) {
        if ($baseName -match $pattern) {
            $discCode    = $Matches["Disc"]
            $docTypeCode = $Matches["DocType"]

            $discipline = if ($DisciplineCodes.ContainsKey($discCode)) {
                $DisciplineCodes[$discCode]
            } else {
                "_UnknownDiscipline"
            }

            $docType = if ($DocTypeCodes.ContainsKey($docTypeCode)) {
                $DocTypeCodes[$docTypeCode]
            } else {
                "_UnknownDocType"
            }

            return [PSCustomObject]@{
                FileName    = $FileName
                BaseName    = $baseName
                Extension   = $extension
                Project     = $Matches["Project"]
                Contract    = $Matches["Contract"]
                DiscCode    = $discCode
                Discipline  = $discipline
                DocTypeCode = $docTypeCode
                DocType     = $docType
                Number      = $Matches["Number"]
                Revision    = $Matches["Rev"]
                Parsed      = $true
                ParseStatus = if ($discipline -eq "_UnknownDiscipline" -or $docType -eq "_UnknownDocType") { "PARTIAL_MATCH" } else { "OK" }
            }
        }
    }

    return [PSCustomObject]@{
        FileName    = $FileName
        BaseName    = $baseName
        Extension   = $extension
        Project     = $null
        Contract    = $null
        DiscCode    = $null
        Discipline  = "_Unsorted"
        DocTypeCode = $null
        DocType     = $null
        Number      = $null
        Revision    = $null
        Parsed      = $false
        ParseStatus = "NO_PATTERN_MATCH"
    }
}

# -----------------------------
# Validation
# -----------------------------
if (-not (Test-Path $SourcePath)) {
    throw "SourcePath not found: $SourcePath"
}

# Create destination folder in all modes, including LogOnly,
# because logs/summary are written there as well.
if (-not (Test-Path $DestPath)) {
    New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
}

# -----------------------------
# Collect files
# -----------------------------
Write-Section "ENGINEERING DOCUMENT ORGANIZER"
Write-Host "Source:      $SourcePath" -ForegroundColor Gray
Write-Host "Destination: $DestPath" -ForegroundColor Gray
Write-Host "Mode:        $(if ($LogOnly) { 'LOG ONLY (dry run)' } elseif ($MoveFiles) { 'MOVE' } else { 'COPY' })" -ForegroundColor Gray
Write-Host "Recursive:   $($Recurse.IsPresent)" -ForegroundColor Gray
Write-Host "Overwrite:   $($Overwrite.IsPresent)" -ForegroundColor Gray
Write-Host "SummaryOnly: $($SummaryOnly.IsPresent)" -ForegroundColor Gray

$files = if ($Recurse) {
    Get-ChildItem -Path $SourcePath -File -Recurse
} else {
    Get-ChildItem -Path $SourcePath -File
}

if (-not $files -or $files.Count -eq 0) {
    Write-Warning "No files found."
    return
}

Write-Host ""
Write-Host ("Found {0} files" -f $files.Count) -ForegroundColor Green

# -----------------------------
# Main processing loop
# -----------------------------
$results   = New-Object System.Collections.Generic.List[object]
$processed = 0
$copied    = 0
$moved     = 0
$unsorted  = 0
$errors    = 0

foreach ($file in $files) {
    $processed++
    $parsed = Parse-DocumentName -FileName $file.Name

    if (-not $parsed.Parsed) {
        $targetFolder = Join-Path $DestPath "_Unsorted"
        $unsorted++
    }
    else {
        $disciplineFolder = Resolve-SafeFolderName $parsed.Discipline
        $docTypeFolder    = Resolve-SafeFolderName $parsed.DocType
        $targetFolder     = Join-Path (Join-Path $DestPath $disciplineFolder) $docTypeFolder
    }

    $targetFile = Resolve-TargetFilePath -FolderPath $targetFolder -FileName $file.Name -Overwrite:$Overwrite

    try {
        if ($LogOnly) {
            if (-not $SummaryOnly) {
                Write-Host ("[DRY-RUN] {0} -> {1}" -f $file.FullName, $targetFile) -ForegroundColor Yellow
            }
            $status = "DRY_RUN"
        }
        else {
            if (-not (Test-Path $targetFolder)) {
                New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
            }

            if ($MoveFiles) {
                Move-Item -Path $file.FullName -Destination $targetFile -Force:$Overwrite
                $moved++
                $status = "MOVED"
            }
            else {
                Copy-Item -Path $file.FullName -Destination $targetFile -Force:$Overwrite
                $copied++
                $status = "COPIED"
            }

            if (-not $SummaryOnly) {
                Write-Host ("[{0}] {1} -> {2}" -f $status, $file.Name, $targetFile) -ForegroundColor Green
            }
        }
    }
    catch {
        $errors++
        $status = "ERROR"
        Write-Warning ("Failed to process {0}: {1}" -f $file.Name, $_.Exception.Message)
    }

    $results.Add([PSCustomObject]@{
        FileName         = $file.Name
        SourcePath       = $file.FullName
        TargetPath       = $targetFile
        Project          = $parsed.Project
        Contract         = $parsed.Contract
        Discipline       = $parsed.Discipline
        DisciplineCode   = $parsed.DiscCode
        DocumentType     = $parsed.DocType
        DocumentTypeCode = $parsed.DocTypeCode
        DocumentNumber   = $parsed.Number
        Revision         = $parsed.Revision
        Parsed           = $parsed.Parsed
        ParseStatus      = $parsed.ParseStatus
        ActionStatus     = $status
    })
}

# -----------------------------
# Logs
# -----------------------------
if (-not (Test-Path $DestPath)) {
    New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
}

$timestamp       = Get-Date -Format "yyyyMMdd_HHmmss"
$logCsvPath      = Join-Path $DestPath ("organizer_log_{0}.csv" -f $timestamp)
$summaryJsonPath = Join-Path $DestPath ("organizer_summary_{0}.json" -f $timestamp)

$results | Export-Csv -Path $logCsvPath -NoTypeInformation -Encoding UTF8

$summary = [PSCustomObject]@{
    Timestamp       = (Get-Date).ToString("s")
    SourcePath      = $SourcePath
    DestinationPath = $DestPath
    Recursive       = $Recurse.IsPresent
    DryRun          = $LogOnly.IsPresent
    MoveMode        = $MoveFiles.IsPresent
    Overwrite       = $Overwrite.IsPresent
    SummaryOnly     = $SummaryOnly.IsPresent
    TotalFiles      = $processed
    Copied          = $copied
    Moved           = $moved
    Unsorted        = $unsorted
    Errors          = $errors
    ByDiscipline    = @(
        $results |
        Group-Object Discipline |
        Sort-Object Count -Descending |
        ForEach-Object {
            [PSCustomObject]@{
                Discipline = $_.Name
                Count      = $_.Count
            }
        }
    )
    ByDocumentType  = @(
        $results |
        Group-Object DocumentType |
        Sort-Object Count -Descending |
        ForEach-Object {
            [PSCustomObject]@{
                DocumentType = $_.Name
                Count        = $_.Count
            }
        }
    )
}

$summary | ConvertTo-Json -Depth 5 | Set-Content -Path $summaryJsonPath -Encoding UTF8

# -----------------------------
# Console summary
# -----------------------------
Write-Section "SUMMARY"
Write-Host ("Processed: {0}" -f $processed) -ForegroundColor White
Write-Host ("Copied:    {0}" -f $copied) -ForegroundColor White
Write-Host ("Moved:     {0}" -f $moved) -ForegroundColor White
Write-Host ("Unsorted:  {0}" -f $unsorted) -ForegroundColor Yellow
Write-Host ("Errors:    {0}" -f $errors) -ForegroundColor Red
Write-Host ""
Write-Host ("CSV log:   {0}" -f $logCsvPath) -ForegroundColor Gray
Write-Host ("JSON sum:  {0}" -f $summaryJsonPath) -ForegroundColor Gray
