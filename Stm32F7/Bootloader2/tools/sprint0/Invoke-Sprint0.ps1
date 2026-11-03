[CmdletBinding()]
param(
    [ValidateSet('S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9')]
    [string]$Scope = 'S0',

    [ValidateSet('Build', 'Flash', 'Capture', 'All', 'Restore')]
    [string]$Operation = 'All',

    [switch]$AllowFlash,

    [switch]$Incremental,

    [string]$JLinkPath,

    [string]$Device = 'STM32H723ZG',

    [ValidateSet('SWD', 'JTAG')]
    [string]$Interface = 'SWD',

    [ValidateRange(1, 50000)]
    [int]$SpeedKHz = 4000,

    # Board H7B1 enumerates as COM11 on this test workstation. This is an
    # explicit hardware-test binding, not a firmware protocol setting.
    [string]$RecoveryCdcPort = 'COM11'
)

<#
.SYNOPSIS
The single build, flash, and hardware-test entry point for bootloader scopes.

.DESCRIPTION
S0: baseline production bootloader recovery and capture.
S1: test-only direct Primary hand-off plus a GPIOG/PG7 smoke application.
S2: test-only Primary validation decision plus a packaged PG7 smoke image.
S3: production boot decision with a Primary CONFIRMED trailer record.
S4: production boot decision plus application confirmation from TEST to CONFIRMED.
S5: production recovery gate for erased, malformed, and stale Primary states.
S6: USB CDC transport and recovery protocol conformance.
S7: Secondary-slot download, abort boundary, and Primary immutability.
S8: first installation from an empty Primary slot.
S9: normal A/B activation through the scratch sector.
Build / Flash / Capture / All select the work for the chosen -Scope.

S0 Flash programs only the bootloader at 0x08000000.
S1 Flash programs a test-profile bootloader at 0x08000000 and app_smoke at
0x08020200. S1 never changes production boot decision source code.
S2 Flash programs a validation-profile bootloader and each explicit S2 test
image. It does not exercise trailer, update, or swap policy.
S3 Flash programs the production bootloader with an explicit CONFIRMED Primary
record and then checks stable and rejected trailer variants.
S4 Flash proves both the healthy confirmation path and a no-confirm control.
S5 Flash proves invalid Primary variants remain in bootloader USB recovery.
S6 Flash performs only protocol-negative testing in recovery; it never starts an update session.
S7 finalizes a candidate in Secondary and deliberately does not reset while it
is PENDING; reset/activation is covered by the following sprint.
S8 erases Primary, receives a valid Secondary candidate, then verifies the
first-install TEST-to-CONFIRMED path over two boots.
S9 provisions confirmed app_1, downloads app_2 through USB CDC only, then
verifies a scratch-assisted swap, app_2 confirmation, and app_1 preservation.

All Flash and All operations require -AllowFlash. Capture behavior is
scope-specific; S9 Capture may reset and resume the target to measure cadence,
but never erases or programs Flash.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sprint0Dir = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $sprint0Dir)
$autoEvidenceDir = Join-Path $repoRoot 'input\test_input\auto_collected'
$userEvidenceDir = Join-Path $repoRoot 'input\test_input\user_provided'

$bootBuildDir = Join-Path $repoRoot 'bootloader\bootloader\build\Debug'
$appBuildDir = Join-Path $repoRoot 'app\app_1\build\Debug'
$bootloaderElf = Join-Path $bootBuildDir 'bootloader.elf'
$bootloaderBin = Join-Path $bootBuildDir 'bootloader.bin'

$snapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader.bin'
$buildLog = Join-Path $autoEvidenceDir 'S00_build.log'
$flashLog = Join-Path $userEvidenceDir 'S00_flash_bootloader.log'
$resetLog = Join-Path $userEvidenceDir 'S00_jlink_after_reset.txt'
$dumpLog = Join-Path $userEvidenceDir 'S00_flash_capture_console.txt'
$flashDump = Join-Path $userEvidenceDir 'S00_flash_after_reset.bin'
$runSummary = Join-Path $userEvidenceDir 'S00_run_summary.md'

$s1BootBuildDir = Join-Path $repoRoot 'bootloader\bootloader\build\S1'
$s1AppBuildDir = Join-Path $repoRoot 'app\app_1\build\S1'
$s1BootloaderElf = Join-Path $s1BootBuildDir 'bootloader.elf'
$s1BootloaderBin = Join-Path $s1BootBuildDir 'bootloader.bin'
$s1AppSmokeElf = Join-Path $s1AppBuildDir 'app_smoke.elf'
$s1AppSmokeBin = Join-Path $s1AppBuildDir 'app_smoke.bin'
$s1SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s1.bin'
$s1SnapshotAppSmokeBin = Join-Path $autoEvidenceDir 'app_smoke.bin'
$s1BuildLog = Join-Path $autoEvidenceDir 'S01_build.log'
$s1FlashLog = Join-Path $userEvidenceDir 'S01_flash_test_profile.log'
$s1HandoffLog = Join-Path $userEvidenceDir 'S01_jlink_handoff.log'
$s1DumpLog = Join-Path $userEvidenceDir 'S01_flash_capture_console.txt'
$s1FlashDump = Join-Path $userEvidenceDir 'S01_flash_after_handoff.bin'
$s1RunSummary = Join-Path $userEvidenceDir 'S01_run_summary.md'
$s1TestReport = Join-Path $userEvidenceDir 'S01_TEST_REPORT.md'

$s2BootBuildDir = Join-Path $repoRoot 'bootloader\bootloader\build\S2'
$s2BootloaderElf = Join-Path $s2BootBuildDir 'bootloader.elf'
$s2BootloaderBin = Join-Path $s2BootBuildDir 'bootloader.bin'
$s2SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s2.bin'
$s2SnapshotAppSmokeBin = Join-Path $autoEvidenceDir 'app_smoke_s2_payload.bin'
$s2BuildLog = Join-Path $autoEvidenceDir 'S02_build.log'
$s2FlashLog = Join-Path $userEvidenceDir 'S02_flash_validation_cases.log'
$s2CaptureLog = Join-Path $userEvidenceDir 'S02_jlink_validation.log'
$s2RunSummary = Join-Path $userEvidenceDir 'S02_run_summary.md'
$s2TestReport = Join-Path $userEvidenceDir 'S02_TEST_REPORT.md'
$s2CaseDirectory = Join-Path $autoEvidenceDir 'S02_cases'

$s3SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s3_production.bin'
$s3SnapshotAppSmokeBin = Join-Path $autoEvidenceDir 'app_smoke_s3_payload.bin'
$s3BuildLog = Join-Path $autoEvidenceDir 'S03_build.log'
$s3FlashLog = Join-Path $userEvidenceDir 'S03_flash_trailer_cases.log'
$s3CaptureLog = Join-Path $userEvidenceDir 'S03_jlink_trailer.log'
$s3RunSummary = Join-Path $userEvidenceDir 'S03_run_summary.md'
$s3TestReport = Join-Path $userEvidenceDir 'S03_TEST_REPORT.md'
$s3CaseDirectory = Join-Path $autoEvidenceDir 'S03_cases'

$s4SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s4_production.bin'
$s4SnapshotConfirmAppBin = Join-Path $autoEvidenceDir 'app_1_s4_confirm.bin'
$s4SnapshotNoConfirmAppBin = Join-Path $autoEvidenceDir 'app_smoke_s4_no_confirm.bin'
$s4BuildLog = Join-Path $autoEvidenceDir 'S04_build.log'
$s4FlashLog = Join-Path $userEvidenceDir 'S04_flash_confirmation_cases.log'
$s4CaptureLog = Join-Path $userEvidenceDir 'S04_jlink_confirmation.log'
$s4RunSummary = Join-Path $userEvidenceDir 'S04_run_summary.md'
$s4TestReport = Join-Path $userEvidenceDir 'S04_TEST_REPORT.md'
$s4CaseDirectory = Join-Path $autoEvidenceDir 'S04_cases'

$s5SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s5_production.bin'
$s5SnapshotAppBin = Join-Path $autoEvidenceDir 'app_1_s5_restore.bin'
$s5BuildLog = Join-Path $autoEvidenceDir 'S05_build.log'
$s5FlashLog = Join-Path $userEvidenceDir 'S05_flash_recovery_cases.log'
$s5CaptureLog = Join-Path $userEvidenceDir 'S05_jlink_recovery.log'
$s5UsbLog = Join-Path $userEvidenceDir 'S05_usb_recovery_ports.log'
$s5RunSummary = Join-Path $userEvidenceDir 'S05_run_summary.md'
$s5TestReport = Join-Path $userEvidenceDir 'S05_TEST_REPORT.md'
$s5CaseDirectory = Join-Path $autoEvidenceDir 'S05_cases'

$s6SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s6_production.bin'
$s6SnapshotAppBin = Join-Path $autoEvidenceDir 'app_1_s6_restore.bin'
$s6BuildLog = Join-Path $autoEvidenceDir 'S06_build.log'
$s6FlashLog = Join-Path $userEvidenceDir 'S06_flash_protocol.log'
$s6CaptureLog = Join-Path $userEvidenceDir 'S06_jlink_protocol.log'
$s6ProtocolLog = Join-Path $userEvidenceDir 'S06_usb_protocol.json'
$s6RunSummary = Join-Path $userEvidenceDir 'S06_run_summary.md'
$s6TestReport = Join-Path $userEvidenceDir 'S06_TEST_REPORT.md'
$s6CaseDirectory = Join-Path $autoEvidenceDir 'S06_cases'

$s7SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s7_production.bin'
$s7SnapshotAppBin = Join-Path $autoEvidenceDir 'app_1_s7_candidate.bin'
$s7BuildLog = Join-Path $autoEvidenceDir 'S07_build.log'
$s7SilLog = Join-Path $autoEvidenceDir 'S07_sil.log'
$s7FlashLog = Join-Path $userEvidenceDir 'S07_flash_secondary_download.log'
$s7CaptureLog = Join-Path $userEvidenceDir 'S07_jlink_secondary_download.log'
$s7RequestLog = Join-Path $userEvidenceDir 'S07_request_update.json'
$s7AbortLog = Join-Path $userEvidenceDir 'S07_abort_protocol.json'
$s7DownloadLog = Join-Path $userEvidenceDir 'S07_download_protocol.json'
$s7PrimaryBefore = Join-Path $userEvidenceDir 'S07_primary_before.bin'
$s7PrimaryAfter = Join-Path $userEvidenceDir 'S07_primary_after.bin'
$s7SecondaryAbort = Join-Path $userEvidenceDir 'S07_secondary_after_abort.bin'
$s7SecondaryFinal = Join-Path $userEvidenceDir 'S07_secondary_pending.bin'
$s7RunSummary = Join-Path $userEvidenceDir 'S07_run_summary.md'
$s7TestReport = Join-Path $userEvidenceDir 'S07_TEST_REPORT.md'
$s7CaseDirectory = Join-Path $autoEvidenceDir 'S07_cases'

$s8SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s8_production.bin'
$s8SnapshotAppBin = Join-Path $autoEvidenceDir 'app_1_s8_first_install.bin'
$s8BuildLog = Join-Path $autoEvidenceDir 'S08_build.log'
$s8SilLog = Join-Path $autoEvidenceDir 'S08_sil.log'
$s8FlashLog = Join-Path $userEvidenceDir 'S08_flash_first_install.log'
$s8CaptureLog = Join-Path $userEvidenceDir 'S08_jlink_first_install.log'
$s8DownloadLog = Join-Path $userEvidenceDir 'S08_download_protocol.json'
$s8SecondaryPending = Join-Path $userEvidenceDir 'S08_secondary_pending.bin'
$s8PrimaryActivated = Join-Path $userEvidenceDir 'S08_primary_after_activation.bin'
$s8SecondaryActivated = Join-Path $userEvidenceDir 'S08_secondary_after_activation.bin'
$s8PrimaryStable = Join-Path $userEvidenceDir 'S08_primary_after_confirmed_reset.bin'
$s8SecondaryStable = Join-Path $userEvidenceDir 'S08_secondary_after_confirmed_reset.bin'
$s8RunSummary = Join-Path $userEvidenceDir 'S08_run_summary.md'
$s8TestReport = Join-Path $userEvidenceDir 'S08_TEST_REPORT.md'
$s8CaseDirectory = Join-Path $autoEvidenceDir 'S08_cases'

$s9App1BuildDir = Join-Path $repoRoot 'app\app_1\build\S9_app1'
$s9App2BuildDir = Join-Path $repoRoot 'app\app_1\build\S9_app2'
$s9SnapshotBootloaderBin = Join-Path $autoEvidenceDir 'bootloader_s9_production.bin'
$s9SnapshotApp1Bin = Join-Path $autoEvidenceDir 'app_1_s9_500ms.bin'
$s9SnapshotApp2Bin = Join-Path $autoEvidenceDir 'app_2_s9_3000ms.bin'
$s9BuildLog = Join-Path $autoEvidenceDir 'S09_build.log'
$s9SilLog = Join-Path $autoEvidenceDir 'S09_sil.log'
$s9FlashLog = Join-Path $userEvidenceDir 'S09_flash_ab_activation.log'
$s9CaptureLog = Join-Path $userEvidenceDir 'S09_jlink_ab_activation.log'
$s9RequestLog = Join-Path $userEvidenceDir 'S09_request_update.json'
$s9DownloadLog = Join-Path $userEvidenceDir 'S09_download_app2.json'
$s9PrimaryBefore = Join-Path $userEvidenceDir 'S09_primary_app1_before_update.bin'
$s9PrimaryPending = Join-Path $userEvidenceDir 'S09_primary_app1_pending.bin'
$s9SecondaryPending = Join-Path $userEvidenceDir 'S09_secondary_app2_pending.bin'
$s9PrimaryActivated = Join-Path $userEvidenceDir 'S09_primary_app2_confirmed.bin'
$s9SecondaryActivated = Join-Path $userEvidenceDir 'S09_secondary_app1_preserved.bin'
$s9PrimaryStable = Join-Path $userEvidenceDir 'S09_primary_after_confirmed_reset.bin'
$s9SecondaryStable = Join-Path $userEvidenceDir 'S09_secondary_after_confirmed_reset.bin'
$s9RunSummary = Join-Path $userEvidenceDir 'S09_run_summary.md'
$s9TestReport = Join-Path $userEvidenceDir 'S09_TEST_REPORT.md'
$s9CaseDirectory = Join-Path $autoEvidenceDir 'S09_cases'

function Resolve-JLinkExecutable {
    if ($JLinkPath) {
        if (-not (Test-Path -LiteralPath $JLinkPath -PathType Leaf)) {
            throw "J-Link executable does not exist: $JLinkPath"
        }
        return (Resolve-Path -LiteralPath $JLinkPath).Path
    }

    $candidates = New-Object System.Collections.Generic.List[string]
    $fromPath = Get-Command 'JLink.exe' -ErrorAction SilentlyContinue
    if ($fromPath) {
        $candidates.Add($fromPath.Source)
    }

    foreach ($programRoot in @($env:ProgramFiles, ${env:ProgramFiles(x86)}) |
            Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) }) {
        $seggerRoot = Join-Path $programRoot 'SEGGER'
        $candidates.Add((Join-Path $seggerRoot 'JLink\JLink.exe'))
        if (Test-Path -LiteralPath $seggerRoot -PathType Container) {
            Get-ChildItem -LiteralPath $seggerRoot -Directory -Filter 'JLink*' -ErrorAction SilentlyContinue |
                ForEach-Object { $candidates.Add((Join-Path $_.FullName 'JLink.exe')) }
        }
    }

    $resolved = $candidates |
        Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } |
        Select-Object -First 1
    if (-not $resolved) {
        throw "JLink.exe was not found. Install SEGGER J-Link or pass -JLinkPath 'C:\Program Files\SEGGER\JLink_Vxxx\JLink.exe'."
    }
    return (Resolve-Path -LiteralPath $resolved).Path
}

function Invoke-JLinkCommands {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Commands,

        [Parameter(Mandatory = $true)]
        [string]$LogPath,

        [switch]$Append
    )

    $jlink = Resolve-JLinkExecutable
    $tempScript = Join-Path ([System.IO.Path]::GetTempPath()) ("s00_jlink_{0}.jlink" -f [guid]::NewGuid().ToString('N'))
    try {
        [System.IO.File]::WriteAllLines($tempScript, $Commands, [System.Text.Encoding]::ASCII)
        Write-Host "J-Link log: $LogPath"
        $jlinkOutput = @(& $jlink -Device $Device -If $Interface -Speed $SpeedKHz -CommanderScript $tempScript 2>&1)
        $exitCode = $LASTEXITCODE
        $jlinkOutput | ForEach-Object { Write-Output $_ }
        $encoding = New-Object System.Text.UTF8Encoding($false)
        $writerMode = if ($Append) { [System.IO.FileMode]::Append } else { [System.IO.FileMode]::Create }
        $stream = New-Object System.IO.FileStream($LogPath, $writerMode, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
        $writer = New-Object System.IO.StreamWriter($stream, $encoding)
        try {
            foreach ($line in $jlinkOutput) { $writer.WriteLine($line.ToString()) }
        }
        finally {
            $writer.Dispose()
        }
        if ($exitCode -ne 0) {
            throw "J-Link Commander failed with exit code $exitCode. See $LogPath"
        }
        # J-Link Commander may return exit code 0 even when individual script
        # commands could not attach to the target.  Treat those diagnostics as
        # a hard test failure; proceeding would otherwise create false capture
        # evidence and can leave a partially provisioned target.
        $connectionFailure = @($jlinkOutput) -match 'Failed to initialize DAP|Could not connect to the target device|Failed to halt CPU|Unspecified error -1|VTref=0\.000V'
        if ($connectionFailure.Count -ne 0) {
            throw "J-Link target connection/programming failed. See $LogPath"
        }
    }
    finally {
        Remove-Item -LiteralPath $tempScript -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-CmakeBuild {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BuildDirectory,

        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string]$BuildLogPath
    )

    $arguments = @('--build', $BuildDirectory)
    if (-not $Incremental) {
        $arguments += '--clean-first'
    }
    "[$Label] cmake $($arguments -join ' ')" | Tee-Object -FilePath $BuildLogPath -Append
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & cmake @arguments 2>&1 |
            ForEach-Object { $_.ToString() } |
            Tee-Object -FilePath $BuildLogPath -Append
        $cmakeExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($cmakeExitCode -ne 0) {
        throw "$Label build failed with exit code $cmakeExitCode. See $BuildLogPath"
    }
}

function Save-ArtifactSnapshot {
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    if (-not (Test-Path -LiteralPath $bootloaderElf -PathType Leaf)) {
        throw "Bootloader ELF is missing: $bootloaderElf"
    }
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) {
        throw "objcopy failed with exit code $LASTEXITCODE while generating $bootloaderBin"
    }

    $artifacts = @(
        @{ Snapshot = 'bootloader.elf'; Source = 'bootloader\bootloader\build\Debug\bootloader.elf'; FlashAddress = '0x08000000' },
        @{ Snapshot = 'bootloader.bin'; Source = 'bootloader\bootloader\build\Debug\bootloader.bin'; FlashAddress = '0x08000000' },
        @{ Snapshot = 'bootloader.map'; Source = 'bootloader\bootloader\build\Debug\bootloader.map'; FlashAddress = $null },
        @{ Snapshot = 'app_1.elf'; Source = 'app\app_1\build\Debug\app_1.elf'; FlashAddress = '0x08020200' },
        @{ Snapshot = 'app_1.bin'; Source = 'app\app_1\build\Debug\app_1.bin'; FlashAddress = '0x08020200' },
        @{ Snapshot = 'app_1.map'; Source = 'app\app_1\build\Debug\app_1.map'; FlashAddress = $null }
    )

    $manifestArtifacts = @()
    foreach ($artifact in $artifacts) {
        $sourcePath = Join-Path $repoRoot $artifact.Source
        $snapshotPath = Join-Path $autoEvidenceDir $artifact.Snapshot
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw "Required build artifact is missing: $sourcePath"
        }
        Copy-Item -LiteralPath $sourcePath -Destination $snapshotPath -Force
        $item = Get-Item -LiteralPath $snapshotPath
        $manifestArtifacts += [ordered]@{
            snapshot_file = $artifact.Snapshot
            source_file = $artifact.Source.Replace('\', '/')
            intended_flash_address = $artifact.FlashAddress
            bytes = $item.Length
            modified_local = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
            sha256 = (Get-FileHash -LiteralPath $snapshotPath -Algorithm SHA256).Hash
        }
    }

    $manifest = [ordered]@{
        schema_version = 1
        sprint = 'S0'
        collected_local = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
        workspace_root = $repoRoot
        artifacts = $manifestArtifacts
    }
    $manifest | ConvertTo-Json -Depth 4 |
        Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'ARTIFACT_MANIFEST.json') -Encoding utf8
}

function Invoke-Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir -Force | Out-Null
    Set-Content -LiteralPath $buildLog -Value "Sprint 0 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'bootloader' -BuildLogPath $buildLog
    Invoke-CmakeBuild -BuildDirectory $appBuildDir -Label 'app_1' -BuildLogPath $buildLog
    Save-ArtifactSnapshot
    Write-Host "Artifact manifest: $(Join-Path $autoEvidenceDir 'ARTIFACT_MANIFEST.json')"
}

function Invoke-BaselineFlash {
    if (-not $AllowFlash) {
        throw 'Flashing is blocked. Re-run with -AllowFlash after confirming that only the bootloader reserved region may change.'
    }
    if (-not (Test-Path -LiteralPath $snapshotBootloaderBin -PathType Leaf)) {
        throw "Bootloader snapshot is missing. Run -Operation Build first: $snapshotBootloaderBin"
    }
    $bootloaderHash = (Get-FileHash -LiteralPath $snapshotBootloaderBin -Algorithm SHA256).Hash
    $flashLines = @(
        "loadbin $snapshotBootloaderBin, 0x08000000",
        'r',
        'h',
        'mem32 0x08000000, 8',
        'exit'
    )
    Invoke-JLinkCommands -Commands $flashLines -LogPath $flashLog
    Add-Content -LiteralPath $flashLog -Value "`nExpected bootloader.bin SHA-256: $bootloaderHash"
}

function Invoke-Capture {
    $diagnosticLines = @(
        'r',
        'g',
        'sleep 1000',
        'h',
        'regs',
        'mem32 0xE000ED08, 1',
        'mem32 0xE000ED28, 5',
        'mem32 0x08000000, 16',
        'mem32 0x08020000, 16',
        'mem32 0x0807F000, 32',
        'mem32 0x08080000, 16',
        'mem32 0x080DF000, 32',
        'mem32 0x080E0000, 8',
        'exit'
    )
    Invoke-JLinkCommands -Commands $diagnosticLines -LogPath $resetLog

    $dumpLines = @(
        'r',
        'h',
        "savebin $flashDump, 0x08000000, 0x00100000",
        'exit'
    )
    Invoke-JLinkCommands -Commands $dumpLines -LogPath $dumpLog
    $dumpItem = Get-Item -LiteralPath $flashDump -ErrorAction Stop
    if ($dumpItem.Length -ne 1048576) {
        throw "Flash dump size is $($dumpItem.Length) bytes, expected 1048576 bytes: $flashDump"
    }
}

function Save-RunSummary {
    $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
    $rows = @(
        '# Sprint 0 run summary',
        '',
        "- Time: $time",
        "- Requested operation: $Operation",
        "- Device: $Device",
        "- Debug interface: $Interface at $SpeedKHz kHz",
        "- Flash authorization: $AllowFlash",
        '',
        '## Outputs',
        ''
    )
    foreach ($path in @($buildLog, $flashLog, $resetLog, $dumpLog, $flashDump, (Join-Path $autoEvidenceDir 'ARTIFACT_MANIFEST.json'))) {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $item = Get-Item -LiteralPath $path
            $rows += "- $(Split-Path -Leaf $path): $($item.Length) bytes"
        }
    }
    $rows += ''
    $rows += 'The target is left halted after capture. Run `g` in J-Link Commander, or reset the board, to resume it.'
    Set-Content -LiteralPath $runSummary -Value $rows -Encoding utf8
}

function Invoke-S1CmakeConfigureAndBuild {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDirectory,

        [Parameter(Mandatory = $true)]
        [string]$BuildDirectory,

        [Parameter(Mandatory = $true)]
        [string]$ToolchainFile,

        [Parameter(Mandatory = $true)]
        [string]$ProfileDefinition,

        [Parameter(Mandatory = $true)]
        [string]$BuildLogPath,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $configureArguments = @(
        '-S', $SourceDirectory,
        '-B', $BuildDirectory,
        '-G', 'Ninja',
        '-DCMAKE_BUILD_TYPE=Debug'
    )
    if (-not (Test-Path -LiteralPath (Join-Path $BuildDirectory 'CMakeCache.txt') -PathType Leaf)) {
        $configureArguments += "-DCMAKE_TOOLCHAIN_FILE=$ToolchainFile"
    }
    $configureArguments += $ProfileDefinition
    "[$Label] cmake $($configureArguments -join ' ')" |
        Tee-Object -FilePath $BuildLogPath -Append
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & cmake @configureArguments 2>&1 |
            ForEach-Object { $_.ToString() } |
            Tee-Object -FilePath $BuildLogPath -Append
        $cmakeExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($cmakeExitCode -ne 0) {
        throw "$Label configure failed with exit code $cmakeExitCode. See $BuildLogPath"
    }

    $buildArguments = @('--build', $BuildDirectory)
    if (-not $Incremental) {
        $buildArguments += '--clean-first'
    }
    "[$Label] cmake $($buildArguments -join ' ')" |
        Tee-Object -FilePath $BuildLogPath -Append
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & cmake @buildArguments 2>&1 |
            ForEach-Object { $_.ToString() } |
            Tee-Object -FilePath $BuildLogPath -Append
        $cmakeExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($cmakeExitCode -ne 0) {
        throw "$Label build failed with exit code $cmakeExitCode. See $BuildLogPath"
    }
}

function Save-S1ArtifactSnapshot {
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    if (-not (Test-Path -LiteralPath $s1BootloaderElf -PathType Leaf)) {
        throw "S1 bootloader ELF is missing: $s1BootloaderElf"
    }
    & $objcopy.Source -O binary $s1BootloaderElf $s1BootloaderBin
    if ($LASTEXITCODE -ne 0) {
        throw "objcopy failed with exit code $LASTEXITCODE while generating $s1BootloaderBin"
    }

    $artifacts = @(
        @{ Snapshot = 'bootloader_s1.elf'; Source = $s1BootloaderElf; FlashAddress = '0x08000000' },
        @{ Snapshot = 'bootloader_s1.bin'; Source = $s1BootloaderBin; FlashAddress = '0x08000000' },
        @{ Snapshot = 'bootloader_s1.map'; Source = (Join-Path $s1BootBuildDir 'bootloader.map'); FlashAddress = $null },
        @{ Snapshot = 'app_smoke.elf'; Source = $s1AppSmokeElf; FlashAddress = '0x08020200' },
        @{ Snapshot = 'app_smoke.bin'; Source = $s1AppSmokeBin; FlashAddress = '0x08020200' },
        @{ Snapshot = 'app_smoke.map'; Source = (Join-Path $s1AppBuildDir 'app_smoke.map'); FlashAddress = $null }
    )

    $manifestArtifacts = @()
    foreach ($artifact in $artifacts) {
        if (-not (Test-Path -LiteralPath $artifact.Source -PathType Leaf)) {
            throw "Required S1 artifact is missing: $($artifact.Source)"
        }
        $snapshotPath = Join-Path $autoEvidenceDir $artifact.Snapshot
        Copy-Item -LiteralPath $artifact.Source -Destination $snapshotPath -Force
        $item = Get-Item -LiteralPath $snapshotPath
        $relativeSource = $artifact.Source.Substring($repoRoot.Length + 1).Replace('\', '/')
        $manifestArtifacts += [ordered]@{
            snapshot_file = $artifact.Snapshot
            source_file = $relativeSource
            intended_flash_address = $artifact.FlashAddress
            bytes = $item.Length
            modified_local = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
            sha256 = (Get-FileHash -LiteralPath $snapshotPath -Algorithm SHA256).Hash
        }
    }

    [ordered]@{
        schema_version = 1
        sprint = 'S1'
        profile = 'test-only direct Primary hand-off; no image-state decision'
        collected_local = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
        workspace_root = $repoRoot
        artifacts = $manifestArtifacts
    } | ConvertTo-Json -Depth 4 |
        Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S01_ARTIFACT_MANIFEST.json') -Encoding utf8
}

function Invoke-S1Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir -Force | Out-Null
    Set-Content -LiteralPath $s1BuildLog -Value "Sprint 1 build started: $(Get-Date -Format o)" -Encoding utf8
    $bootToolchain = Join-Path $repoRoot 'bootloader\bootloader\cmake\gcc-arm-none-eabi.cmake'
    $appToolchain = Join-Path $repoRoot 'app\app_1\cmake\gcc-arm-none-eabi.cmake'
    Invoke-S1CmakeConfigureAndBuild -SourceDirectory (Join-Path $repoRoot 'bootloader\bootloader') `
        -BuildDirectory $s1BootBuildDir -ToolchainFile $bootToolchain `
        -ProfileDefinition '-DBOOT_S1_DIRECT_HANDOFF=ON' -BuildLogPath $s1BuildLog -Label 'bootloader S1 test profile'
    Invoke-S1CmakeConfigureAndBuild -SourceDirectory (Join-Path $repoRoot 'app\app_1') `
        -BuildDirectory $s1AppBuildDir -ToolchainFile $appToolchain `
        -ProfileDefinition '-DAPP_S1_SMOKE=ON' -BuildLogPath $s1BuildLog -Label 'app_smoke S1 profile'
    Save-S1ArtifactSnapshot
    Write-Host "S1 artifact manifest: $(Join-Path $autoEvidenceDir 'S01_ARTIFACT_MANIFEST.json')"
}

function Get-S1AppVector {
    if (-not (Test-Path -LiteralPath $s1SnapshotAppSmokeBin -PathType Leaf)) {
        throw "S1 app snapshot is missing. Run -Scope S1 -Operation Build first: $s1SnapshotAppSmokeBin"
    }
    $bytes = [System.IO.File]::ReadAllBytes($s1SnapshotAppSmokeBin)
    if ($bytes.Length -lt 8) {
        throw "S1 app snapshot is too short to contain a vector table: $s1SnapshotAppSmokeBin"
    }
    $msp = [BitConverter]::ToUInt32($bytes, 0)
    $entryPoint = [BitConverter]::ToUInt32($bytes, 4)
    $resetAddress = $entryPoint -band 0xFFFFFFFE
    $payloadBase = [uint32]0x08020200
    $payloadEnd = [uint64]$payloadBase + [uint64]$bytes.Length
    $stackValid = (($msp -ge 0x20000000) -and ($msp -le 0x20020000)) -or
                  (($msp -ge 0x24000000) -and ($msp -le 0x24050000)) -or
                  (($msp -ge 0x30000000) -and ($msp -le 0x30008000)) -or
                  (($msp -ge 0x38000000) -and ($msp -le 0x38004000))
    if ((-not $stackValid) -or (($entryPoint -band 1) -eq 0) -or
        ($resetAddress -lt $payloadBase) -or ([uint64]$resetAddress -ge $payloadEnd)) {
        throw ('Invalid S1 app vector: MSP=0x{0:X8}, Reset=0x{1:X8}, payload bytes={2}' -f
               $msp, $entryPoint, $bytes.Length)
    }
    return [PSCustomObject]@{
        Msp = $msp
        EntryPoint = $entryPoint
        ResetAddress = [uint32]$resetAddress
        PayloadBytes = $bytes.Length
    }
}

function Invoke-S1Flash {
    if (-not $AllowFlash) {
        throw 'S1 Flash is blocked. Re-run with -AllowFlash to program the test bootloader and app_smoke Primary payload.'
    }
    foreach ($path in @($s1SnapshotBootloaderBin, $s1SnapshotAppSmokeBin)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required S1 snapshot is missing. Run -Scope S1 -Operation Build first: $path"
        }
    }
    $vector = Get-S1AppVector
    $bootHash = (Get-FileHash -LiteralPath $s1SnapshotBootloaderBin -Algorithm SHA256).Hash
    $appHash = (Get-FileHash -LiteralPath $s1SnapshotAppSmokeBin -Algorithm SHA256).Hash
    $flashLines = @(
        "loadbin $s1SnapshotBootloaderBin, 0x08000000",
        "loadbin $s1SnapshotAppSmokeBin, 0x08020200",
        'r',
        'h',
        'mem32 0x08000000, 8',
        'mem32 0x08020200, 4',
        'exit'
    )
    Invoke-JLinkCommands -Commands $flashLines -LogPath $s1FlashLog
    Add-Content -LiteralPath $s1FlashLog -Value @(
        '',
        "Expected bootloader_s1.bin SHA-256: $bootHash",
        "Expected app_smoke.bin SHA-256: $appHash",
        ('App vector: MSP=0x{0:X8}, Reset=0x{1:X8}' -f $vector.Msp, $vector.EntryPoint)
    )
}

function Get-S1ByteDifferenceCount {
    param(
        [Parameter(Mandatory = $true)]
        [byte[]]$FlashBytes,

        [Parameter(Mandatory = $true)]
        [int]$Offset,

        [Parameter(Mandatory = $true)]
        [byte[]]$ExpectedBytes
    )

    if (($Offset -lt 0) -or (($Offset + $ExpectedBytes.Length) -gt $FlashBytes.Length)) {
        throw 'S1 dump comparison is outside the captured internal Flash range.'
    }
    $differences = 0
    for ($index = 0; $index -lt $ExpectedBytes.Length; ++$index) {
        if ($FlashBytes[$Offset + $index] -ne $ExpectedBytes[$index]) {
            ++$differences
        }
    }
    return $differences
}

function Invoke-S1CaptureAndEvaluate {
    $vector = Get-S1AppVector
    $primaryBase = [uint32]0x08020200
    $gpioGModer = [uint32]0x58021800
    $gpioGOdr = [uint32]0x58021814
    $breakpointLines = @(
        ('SetBP 0x{0:X8}' -f $vector.ResetAddress),
        'r',
        'g',
        'sleep 1000',
        'h',
        'regs',
        'mem32 0xE000ED08, 1',
        'mem32 0x08020200, 2',
        'exit'
    )
    Invoke-JLinkCommands -Commands $breakpointLines -LogPath $s1HandoffLog

    Add-Content -LiteralPath $s1HandoffLog -Value "`n===== Ten reset/run GPIO samples =====`n"
    $cycleLines = New-Object 'System.Collections.Generic.List[string]'
    for ($run = 1; $run -le 10; ++$run) {
        $cycleLines.Add('r')
        $cycleLines.Add('g')
        $cycleLines.Add('sleep 300')
        $cycleLines.Add('h')
        $cycleLines.Add('regs')
        $cycleLines.Add('mem32 0xE000ED08, 1')
        $cycleLines.Add('mem32 0xE000ED28, 5')
        $cycleLines.Add(('mem32 0x{0:X8}, 1' -f $gpioGModer))
        $cycleLines.Add(('mem32 0x{0:X8}, 1' -f $gpioGOdr))
        $cycleLines.Add('g')
        $cycleLines.Add('sleep 350')
        $cycleLines.Add('h')
        $cycleLines.Add(('mem32 0x{0:X8}, 1' -f $gpioGOdr))
        $cycleLines.Add('mem32 0xE000ED28, 5')
    }
    $cycleLines.Add('exit')
    Invoke-JLinkCommands -Commands $cycleLines.ToArray() -LogPath $s1HandoffLog -Append

    $dumpLines = @(
        'r',
        'h',
        "savebin $s1FlashDump, 0x08000000, 0x00100000",
        'exit'
    )
    Invoke-JLinkCommands -Commands $dumpLines -LogPath $s1DumpLog
    $dumpItem = Get-Item -LiteralPath $s1FlashDump -ErrorAction Stop
    if ($dumpItem.Length -ne 1048576) {
        throw "S1 Flash dump size is $($dumpItem.Length) bytes, expected 1048576 bytes: $s1FlashDump"
    }

    $log = Get-Content -LiteralPath $s1HandoffLog -Raw
    $pcValues = @([regex]::Matches($log, '(?m)^PC = ([0-9A-F]{8}),') |
        ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $mspValues = @([regex]::Matches($log, '(?m).*MSP= ([0-9A-F]{8}),') |
        ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $vtorValues = @([regex]::Matches($log, '(?m)^E000ED08 = ([0-9A-F]{8})') |
        ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $faultPairs = @([regex]::Matches($log, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})') |
        ForEach-Object { [PSCustomObject]@{ Cfsr = [Convert]::ToUInt32($_.Groups[1].Value, 16); Hfsr = [Convert]::ToUInt32($_.Groups[2].Value, 16) } })
    $moderValues = @([regex]::Matches($log, '(?m)^58021800 = ([0-9A-F]{8})') |
        ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $odrValues = @([regex]::Matches($log, '(?m)^58021814 = ([0-9A-F]{8})') |
        ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })

    $appEnd = [uint64]$primaryBase + [uint64]$vector.PayloadBytes
    $pcRangePass = ($pcValues.Count -ge 11) -and
        (@($pcValues | Where-Object { ($_ -ge $primaryBase) -and ([uint64]$_ -lt $appEnd) }).Count -eq $pcValues.Count)
    $resetBreakpointPass = (@($pcValues | Where-Object { $_ -eq $vector.ResetAddress }).Count -ge 1) -and
        (@($mspValues | Where-Object { $_ -eq $vector.Msp }).Count -ge 1)
    $vtorPass = ($vtorValues.Count -ge 11) -and
        (@($vtorValues | Where-Object { $_ -eq $primaryBase }).Count -eq $vtorValues.Count)
    $faultPass = ($faultPairs.Count -ge 20) -and
        (@($faultPairs | Where-Object { ($_.Cfsr -ne 0) -or ($_.Hfsr -ne 0) }).Count -eq 0)
    $moderPass = ($moderValues.Count -ge 10) -and
        (@($moderValues | Where-Object { ((($_ -shr 14) -band 0x3) -eq 0x1) }).Count -eq $moderValues.Count)
    $togglePass = $odrValues.Count -ge 20
    $togglePairs = [Math]::Floor($odrValues.Count / 2)
    for ($pair = 0; $pair -lt [Math]::Min($togglePairs, 10); ++$pair) {
        $firstBit = $odrValues[$pair * 2] -band 0x80
        $secondBit = $odrValues[$pair * 2 + 1] -band 0x80
        if ($firstBit -eq $secondBit) {
            $togglePass = $false
        }
    }

    $flashBytes = [System.IO.File]::ReadAllBytes($s1FlashDump)
    $bootBytes = [System.IO.File]::ReadAllBytes($s1SnapshotBootloaderBin)
    $appBytes = [System.IO.File]::ReadAllBytes($s1SnapshotAppSmokeBin)
    $bootReadbackDifferences = Get-S1ByteDifferenceCount -FlashBytes $flashBytes -Offset 0 -ExpectedBytes $bootBytes
    $appReadbackDifferences = Get-S1ByteDifferenceCount -FlashBytes $flashBytes -Offset 0x20200 -ExpectedBytes $appBytes
    $readbackPass = ($bootReadbackDifferences -eq 0) -and ($appReadbackDifferences -eq 0)
    $passed = $pcRangePass -and $resetBreakpointPass -and $vtorPass -and $faultPass -and
        $moderPass -and $togglePass -and $readbackPass

    $status = if ($passed) { 'PASS' } else { 'FAIL' }
    $bootHash = (Get-FileHash -LiteralPath $s1SnapshotBootloaderBin -Algorithm SHA256).Hash
    $appHash = (Get-FileHash -LiteralPath $s1SnapshotAppSmokeBin -Algorithm SHA256).Hash
    $rows = @(
        '# Sprint 1 test report',
        '',
        "**Decision: $status**",
        '',
        '## Scope',
        '',
        'S1 uses `BOOT_S1_DIRECT_HANDOFF` and `APP_S1_SMOKE`: it proves only',
        'bootloader vector hand-off to Primary and PG7 behavior. It does not',
        'exercise production image validation, trailer state, update, or swap.',
        '',
        '## Test inputs',
        '',
        "- Test bootloader: ``bootloader_s1.bin``, $($bootBytes.Length) bytes, SHA-256 ``$bootHash``",
        "- Smoke app: ``app_smoke.bin``, $($appBytes.Length) bytes, SHA-256 ``$appHash``",
        ('- App vector: MSP `0x{0:X8}`, reset handler `0x{1:X8}`' -f $vector.Msp, $vector.EntryPoint),
        '',
        '## Results',
        '',
        "- Reset/handoff captures: $($pcValues.Count) PC samples; expected at least 11: **$pcRangePass**",
        "- Reset-handler breakpoint and initial MSP: **$resetBreakpointPass**",
        "- VTOR is ``0x08020200`` in every capture: **$vtorPass**",
        "- CFSR/HFSR are zero in $($faultPairs.Count) captures: **$faultPass**",
        "- GPIOG MODER[15:14] is output in $($moderValues.Count) captures: **$moderPass**",
        "- PG7/ODR bit 7 changes in $togglePairs sample pairs: **$togglePass**",
        "- Read-back differences: bootloader=$bootReadbackDifferences, app_smoke=${appReadbackDifferences}: **$readbackPass**",
        '',
        '## Evidence',
        '',
        '- `S01_flash_test_profile.log`',
        '- `S01_jlink_handoff.log`',
        '- `S01_flash_after_handoff.bin` (1 MiB, base `0x08000000`)',
        '',
        'The target is halted after capture. Run `g` in J-Link Commander or reset',
        'the board to resume the installed S1 test profile.'
    )
    Set-Content -LiteralPath $s1TestReport -Value $rows -Encoding utf8
    if (-not $passed) {
        throw "S1 acceptance failed. See $s1TestReport and $s1HandoffLog"
    }
}

function Save-S1RunSummary {
    $rows = @(
        '# Sprint 1 run summary',
        '',
        "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')",
        "- Requested operation: $Operation",
        "- Device: $Device",
        "- Debug interface: $Interface at $SpeedKHz kHz",
        "- Flash authorization: $AllowFlash",
        '- Profile: test-only direct Primary hand-off + PG7 smoke app',
        '',
        '## Outputs',
        ''
    )
    foreach ($path in @($s1BuildLog, $s1FlashLog, $s1HandoffLog, $s1DumpLog, $s1FlashDump,
                         $s1TestReport, (Join-Path $autoEvidenceDir 'S01_ARTIFACT_MANIFEST.json'))) {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $item = Get-Item -LiteralPath $path
            $rows += "- $(Split-Path -Leaf $path): $($item.Length) bytes"
        }
    }
    $rows += ''
    $rows += 'The target is left halted after capture. Run `g` in J-Link Commander, or reset the board, to resume it.'
    Set-Content -LiteralPath $s1RunSummary -Value $rows -Encoding utf8
}

function Get-S2Crc32 {
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)
    [uint32]$crc = 4294967295
    foreach ($value in $Bytes) {
        $crc = [uint32]($crc -bxor [uint32]$value)
        for ($bit = 0; $bit -lt 8; ++$bit) {
            if (($crc -band 1) -ne 0) {
                $crc = [uint32](($crc -shr 1) -bxor 3988292384)
            }
            else {
                $crc = [uint32]($crc -shr 1)
            }
        }
    }
    return [uint32]([uint64]4294967295 -bxor [uint64]$crc)
}

function Set-S2UInt16 {
    param([byte[]]$Bytes, [int]$Offset, [uint16]$Value)
    [Array]::Copy([BitConverter]::GetBytes($Value), 0, $Bytes, $Offset, 2)
}

function Set-S2UInt32 {
    param([byte[]]$Bytes, [int]$Offset, [uint32]$Value)
    [Array]::Copy([BitConverter]::GetBytes($Value), 0, $Bytes, $Offset, 4)
}

function New-S2Header {
    param(
        [Parameter(Mandatory = $true)][byte[]]$Payload,
        [ValidateSet('valid', 'header_crc', 'payload_crc', 'board_id', 'msp', 'reset_handler', 'payload_size')]
        [string]$Variant
    )
    $primaryPayload = [uint32]0x08020200
    $payloadToWrite = [byte[]]$Payload.Clone()
    $header = New-Object byte[] 128
    Set-S2UInt32 $header 0 0x4837424C # H7BL
    Set-S2UInt16 $header 4 1
    Set-S2UInt16 $header 6 128
    Set-S2UInt32 $header 8 0x48374231 # H7B1
    Set-S2UInt32 $header 12 0x00010000
    Set-S2UInt32 $header 16 0x00000002
    Set-S2UInt32 $header 20 1
    Set-S2UInt32 $header 24 ([uint32]$payloadToWrite.Length)
    Set-S2UInt32 $header 28 (Get-S2Crc32 $payloadToWrite)
    Set-S2UInt32 $header 32 $primaryPayload
    Set-S2UInt32 $header 36 0x200
    Set-S2UInt32 $header 40 ([BitConverter]::ToUInt32($payloadToWrite, 4))
    [Array]::Copy([BitConverter]::GetBytes([uint64]0), 0, $header, 44, 8)

    switch ($Variant) {
        'payload_crc' { $payloadToWrite[0x100] = $payloadToWrite[0x100] -bxor 1 }
        'board_id' { Set-S2UInt32 $header 8 3735928559 }
        'msp' {
            Set-S2UInt32 $payloadToWrite 0 0x10000000
            Set-S2UInt32 $header 28 (Get-S2Crc32 $payloadToWrite)
        }
        'reset_handler' {
            Set-S2UInt32 $payloadToWrite 4 ([uint32](($primaryPayload + $payloadToWrite.Length) -bor 1))
            Set-S2UInt32 $header 28 (Get-S2Crc32 $payloadToWrite)
            Set-S2UInt32 $header 40 ([BitConverter]::ToUInt32($payloadToWrite, 4))
        }
        'payload_size' { Set-S2UInt32 $header 24 0 }
    }
    Set-S2UInt32 $header 124 (Get-S2Crc32 $header[0..123])
    if ($Variant -eq 'header_crc') { $header[124] = $header[124] -bxor 1 }
    return [PSCustomObject]@{ Header = $header; Payload = $payloadToWrite }
}

function Invoke-S2Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s2CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s2BuildLog -Value "Sprint 2 build started: $(Get-Date -Format o)" -Encoding utf8
    $bootToolchain = Join-Path $repoRoot 'bootloader\bootloader\cmake\gcc-arm-none-eabi.cmake'
    Invoke-S1CmakeConfigureAndBuild -SourceDirectory (Join-Path $repoRoot 'bootloader\bootloader') `
        -BuildDirectory $s2BootBuildDir -ToolchainFile $bootToolchain `
        -ProfileDefinition '-DBOOT_S2_PRIMARY_VALIDATION=ON' -BuildLogPath $s2BuildLog -Label 'bootloader S2 validation profile'
    if (-not (Test-Path -LiteralPath $s1SnapshotAppSmokeBin -PathType Leaf)) {
        Invoke-S1Build
    }
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $s2BootloaderElf $s2BootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S2 bootloader objcopy failed.' }
    Copy-Item -LiteralPath $s2BootloaderBin -Destination $s2SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath $s1SnapshotAppSmokeBin -Destination $s2SnapshotAppSmokeBin -Force
    $payload = [System.IO.File]::ReadAllBytes($s2SnapshotAppSmokeBin)
    if (($payload.Length -le 0x100) -or ($payload.Length -gt 0x5EE00)) {
        throw "Unexpected S2 payload size: $($payload.Length)"
    }
    foreach ($variant in @('valid', 'header_crc', 'payload_crc', 'board_id', 'msp', 'reset_handler', 'payload_size')) {
        $image = New-S2Header -Payload $payload -Variant $variant
        [System.IO.File]::WriteAllBytes((Join-Path $s2CaseDirectory "$variant`_header.bin"), $image.Header)
        [System.IO.File]::WriteAllBytes((Join-Path $s2CaseDirectory "$variant`_payload.bin"), $image.Payload)
    }
    [ordered]@{
        schema_version = 1; sprint = 'S2'; profile = 'test-only Primary validation; no trailer/swap policy'
        bootloader_sha256 = (Get-FileHash $s2SnapshotBootloaderBin -Algorithm SHA256).Hash
        payload_sha256 = (Get-FileHash $s2SnapshotAppSmokeBin -Algorithm SHA256).Hash
        payload_bytes = $payload.Length; cases = @('valid', 'header_crc', 'payload_crc', 'board_id', 'msp', 'reset_handler', 'payload_size')
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S02_ARTIFACT_MANIFEST.json') -Encoding utf8
}

function Invoke-S2FlashAndCapture {
    if (-not $AllowFlash) { throw 'S2 Flash is blocked. Re-run with -AllowFlash to program S2 test cases.' }
    foreach ($path in @($s2SnapshotBootloaderBin, $s2SnapshotAppSmokeBin)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S2 artifact missing: $path. Run S2 Build first." }
    }
    Set-Content -LiteralPath $s2FlashLog -Value "Sprint 2 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s2CaptureLog -Value "Sprint 2 capture started: $(Get-Date -Format o)" -Encoding utf8
    $payloadReset = [BitConverter]::ToUInt32([System.IO.File]::ReadAllBytes($s2SnapshotAppSmokeBin), 4) -band 0xFFFFFFFE
    foreach ($variant in @('valid', 'header_crc', 'payload_crc', 'board_id', 'msp', 'reset_handler', 'payload_size')) {
        $headerPath = Join-Path $s2CaseDirectory "$variant`_header.bin"
        $payloadPath = Join-Path $s2CaseDirectory "$variant`_payload.bin"
        $flashLines = @("loadbin $s2SnapshotBootloaderBin, 0x08000000", "loadbin $headerPath, 0x08020000", "loadbin $payloadPath, 0x08020200", 'r', 'h', 'exit')
        Invoke-JLinkCommands -Commands $flashLines -LogPath $s2FlashLog -Append
        Add-Content -LiteralPath $s2CaptureLog -Value "`n===== CASE $variant ====="
        if ($variant -eq 'valid') {
            $commands = @(("SetBP 0x{0:X8}" -f $payloadReset), 'r', 'g', 'sleep 1000', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit')
        }
        else {
            $commands = @('r', 'g', 'sleep 1000', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit')
        }
        Invoke-JLinkCommands -Commands $commands -LogPath $s2CaptureLog -Append
    }
}

function Save-S2Report {
    $log = Get-Content -LiteralPath $s2CaptureLog -Raw
    $sections = [regex]::Split($log, '(?m)^===== (?:CASE )?')
    $results = @()
    foreach ($variant in @('valid', 'header_crc', 'payload_crc', 'board_id', 'msp', 'reset_handler', 'payload_size')) {
        $section = $sections | Where-Object { $_.StartsWith("$variant =====") } | Select-Object -First 1
        $pc = [regex]::Match($section, '(?m)^PC = ([0-9A-F]{8}),')
        $vtor = [regex]::Match($section, '(?m)^E000ED08 = ([0-9A-F]{8})')
        $fault = [regex]::Match($section, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})')
        $pcValue = if ($pc.Success) { [Convert]::ToUInt32($pc.Groups[1].Value, 16) } else { 0 }
        $vtorValue = if ($vtor.Success) { [Convert]::ToUInt32($vtor.Groups[1].Value, 16) } else { 0 }
        $faultFree = $fault.Success -and $fault.Groups[1].Value -eq '00000000' -and $fault.Groups[2].Value -eq '00000000'
        $pass = if ($variant -eq 'valid') { ($pcValue -ge 0x08020200 -and $pcValue -lt 0x08080000 -and $vtorValue -eq 0x08020200 -and $faultFree) } else { ($pcValue -ge 0x08000000 -and $pcValue -lt 0x08020000 -and $vtorValue -eq 0x08000000 -and $faultFree) }
        $results += [PSCustomObject]@{ Variant = $variant; Pass = $pass; PC = $pcValue; VTOR = $vtorValue; FaultFree = $faultFree }
    }
    $passed = @($results | Where-Object { -not $_.Pass }).Count -eq 0
    $rows = @('# Sprint 2 test report', '', "**Decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'S2 tests Primary image validation only; trailer/update/swap are excluded.', '', '## Results', '')
    foreach ($result in $results) { $rows += ('- `{0}`: PC `0x{1:X8}`, VTOR `0x{2:X8}`, no fault={3}: **{4}**' -f $result.Variant, $result.PC, $result.VTOR, $result.FaultFree, $result.Pass) }
    $rows += '', '## Evidence', '', '- `S02_flash_validation_cases.log`', '- `S02_jlink_validation.log`', '- `S02_ARTIFACT_MANIFEST.json`'
    Set-Content -LiteralPath $s2TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S2 acceptance failed. See $s2TestReport" }
}

function Save-S2RunSummary {
    $rows = @('# Sprint 2 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", '- Profile: Primary validation only; test-only', '', '## Outputs', '')
    foreach ($path in @($s2BuildLog, $s2FlashLog, $s2CaptureLog, $s2TestReport, (Join-Path $autoEvidenceDir 'S02_ARTIFACT_MANIFEST.json'))) {
        if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" }
    }
    Set-Content -LiteralPath $s2RunSummary -Value $rows -Encoding utf8
}

function New-S3Trailer {
    param([ValidateSet('confirmed', 'corrupt_crc')][string]$Variant, [uint32]$ImageCrc32)
    $record = New-Object byte[] 32
    for ($index = 0; $index -lt $record.Length; ++$index) { $record[$index] = 0xFF }
    Set-S2UInt32 $record 0 0x48375452 # H7WR
    Set-S2UInt32 $record 4 1
    $record[8] = 4 # CONFIRMED
    $record[9] = 0
    $record[10] = 0xFF
    $record[11] = 0xFF
    Set-S2UInt32 $record 12 $ImageCrc32
    Set-S2UInt32 $record 28 (Get-S2Crc32 $record[0..27])
    if ($Variant -eq 'corrupt_crc') { $record[28] = $record[28] -bxor 1 }
    return $record
}

function Invoke-S3Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s3CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s3BuildLog -Value "Sprint 3 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'production bootloader S3 profile' -BuildLogPath $s3BuildLog
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S3 production bootloader objcopy failed.' }
    if (-not (Test-Path -LiteralPath $s1SnapshotAppSmokeBin -PathType Leaf)) { Invoke-S1Build }
    Copy-Item -LiteralPath $bootloaderBin -Destination $s3SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath $s1SnapshotAppSmokeBin -Destination $s3SnapshotAppSmokeBin -Force
    $payload = [System.IO.File]::ReadAllBytes($s3SnapshotAppSmokeBin)
    $image = New-S2Header -Payload $payload -Variant 'valid'
    $payloadCrc = Get-S2Crc32 $image.Payload
    [System.IO.File]::WriteAllBytes((Join-Path $s3CaseDirectory 'primary_header.bin'), $image.Header)
    [System.IO.File]::WriteAllBytes((Join-Path $s3CaseDirectory 'primary_payload.bin'), $image.Payload)
    [System.IO.File]::WriteAllBytes((Join-Path $s3CaseDirectory 'confirmed_trailer.bin'), (New-S3Trailer -Variant confirmed -ImageCrc32 $payloadCrc))
    [System.IO.File]::WriteAllBytes((Join-Path $s3CaseDirectory 'corrupt_crc_trailer.bin'), (New-S3Trailer -Variant corrupt_crc -ImageCrc32 $payloadCrc))
    [ordered]@{
        schema_version = 1; sprint = 'S3'; profile = 'production boot decision; confirmed Primary trailer state'
        bootloader_sha256 = (Get-FileHash $s3SnapshotBootloaderBin -Algorithm SHA256).Hash
        payload_sha256 = (Get-FileHash $s3SnapshotAppSmokeBin -Algorithm SHA256).Hash
        payload_crc32 = ('0x{0:X8}' -f $payloadCrc); trailer_state = 'CONFIRMED'; reset_cycles = 10
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S03_ARTIFACT_MANIFEST.json') -Encoding utf8
}

function Invoke-S3ProgramPrimary {
    param([string]$TrailerPath, [switch]$EraseTrailer)
    $headerPath = Join-Path $s3CaseDirectory 'primary_header.bin'
    $payloadPath = Join-Path $s3CaseDirectory 'primary_payload.bin'
    # S3 is an isolated Primary-state test. Clear Secondary so a stale
    # PENDING record from another sprint cannot legitimately take precedence.
    $commands = @("loadbin $s3SnapshotBootloaderBin, 0x08000000", 'erase 0x08080000, 0x00060000', "loadbin $headerPath, 0x08020000", "loadbin $payloadPath, 0x08020200")
    if ($EraseTrailer) { $commands += 'erase 0x08060000, 0x00020000' }
    if ($TrailerPath) { $commands += "loadbin $TrailerPath, 0x0807F000" }
    $commands += @('r', 'h', 'exit')
    Invoke-JLinkCommands -Commands $commands -LogPath $s3FlashLog -Append
}

function Invoke-S3FlashAndCapture {
    if (-not $AllowFlash) { throw 'S3 Flash is blocked. Re-run with -AllowFlash.' }
    foreach ($path in @($s3SnapshotBootloaderBin, $s3SnapshotAppSmokeBin, (Join-Path $s3CaseDirectory 'confirmed_trailer.bin'))) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S3 artifact missing: $path. Run S3 Build first." }
    }
    Set-Content -LiteralPath $s3FlashLog -Value "Sprint 3 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s3CaptureLog -Value "Sprint 3 capture started: $(Get-Date -Format o)" -Encoding utf8
    $confirmedTrailer = Join-Path $s3CaseDirectory 'confirmed_trailer.bin'
    Invoke-S3ProgramPrimary -TrailerPath $confirmedTrailer
    Add-Content -LiteralPath $s3CaptureLog -Value "`n===== CASE confirmed_10_resets ====="
    $confirmedCommands = New-Object 'System.Collections.Generic.List[string]'
    for ($cycle = 1; $cycle -le 10; ++$cycle) {
        $confirmedCommands.Add('r'); $confirmedCommands.Add('g'); $confirmedCommands.Add('sleep 300')
        $confirmedCommands.Add('h'); $confirmedCommands.Add('regs')
        $confirmedCommands.Add('mem32 0xE000ED08, 1'); $confirmedCommands.Add('mem32 0xE000ED28, 5')
    }
    $confirmedCommands.Add(('savebin {0}, 0x0807F000, 0x00001000' -f (Join-Path $s3CaseDirectory 'after_10_resets_trailer.bin')))
    $confirmedCommands.Add('exit')
    Invoke-JLinkCommands -Commands $confirmedCommands.ToArray() -LogPath $s3CaptureLog -Append

    foreach ($case in @(@{ Name = 'corrupt_trailer_crc'; Trailer = (Join-Path $s3CaseDirectory 'corrupt_crc_trailer.bin'); Erase = $false },
                           @{ Name = 'missing_trailer'; Trailer = $null; Erase = $true })) {
        Invoke-S3ProgramPrimary -TrailerPath $case.Trailer -EraseTrailer:$case.Erase
        Add-Content -LiteralPath $s3CaptureLog -Value "`n===== CASE $($case.Name) ====="
        Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1000', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit') -LogPath $s3CaptureLog -Append
    }

    # Leave hardware in its known-good S3 state for follow-on work.
    Invoke-S3ProgramPrimary -TrailerPath $confirmedTrailer
    Invoke-JLinkCommands -Commands @('r', 'g', 'exit') -LogPath $s3FlashLog -Append
}

function Save-S3Report {
    $log = Get-Content -LiteralPath $s3CaptureLog -Raw
    $sections = [regex]::Split($log, '(?m)^===== CASE ')
    $confirmed = $sections | Where-Object { $_.StartsWith('confirmed_10_resets =====') } | Select-Object -First 1
    $confirmedPcs = @([regex]::Matches($confirmed, '(?m)^PC = ([0-9A-F]{8}),') | ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $confirmedVtors = @([regex]::Matches($confirmed, '(?m)^E000ED08 = ([0-9A-F]{8})') | ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $confirmedFaults = @([regex]::Matches($confirmed, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})') | ForEach-Object { $_.Groups[1].Value -eq '00000000' -and $_.Groups[2].Value -eq '00000000' })
    $confirmedPass = ($confirmedPcs.Count -eq 20) -and ($confirmedVtors.Count -eq 10) -and ($confirmedFaults.Count -eq 10) -and
        (@($confirmedPcs | Where-Object { $_ -ge 0x08020200 -and $_ -lt 0x08080000 }).Count -eq $confirmedPcs.Count) -and
        (@($confirmedVtors | Where-Object { $_ -eq 0x08020200 }).Count -eq $confirmedVtors.Count) -and
        (@($confirmedFaults | Where-Object { -not $_ }).Count -eq 0)
    $expectedTrailer = [System.IO.File]::ReadAllBytes((Join-Path $s3CaseDirectory 'confirmed_trailer.bin'))
    $actualTrailer = [System.IO.File]::ReadAllBytes((Join-Path $s3CaseDirectory 'after_10_resets_trailer.bin'))
    $trailerPass = ($actualTrailer.Length -eq 4096) -and ([System.Linq.Enumerable]::SequenceEqual([byte[]]$expectedTrailer, [byte[]]$actualTrailer[0..31])) -and
        (@($actualTrailer[32..4095] | Where-Object { $_ -ne 0xFF }).Count -eq 0)
    $negativeResults = @()
    foreach ($name in @('corrupt_trailer_crc', 'missing_trailer')) {
        $section = $sections | Where-Object { $_.StartsWith("$name =====") } | Select-Object -First 1
        $pc = [regex]::Match($section, '(?m)^PC = ([0-9A-F]{8}),')
        $vtor = [regex]::Match($section, '(?m)^E000ED08 = ([0-9A-F]{8})')
        $fault = [regex]::Match($section, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})')
        $pcValue = if ($pc.Success) { [Convert]::ToUInt32($pc.Groups[1].Value, 16) } else { 0 }
        $vtorValue = if ($vtor.Success) { [Convert]::ToUInt32($vtor.Groups[1].Value, 16) } else { 0 }
        $faultFree = $fault.Success -and $fault.Groups[1].Value -eq '00000000' -and $fault.Groups[2].Value -eq '00000000'
        $negativeResults += [PSCustomObject]@{ Name = $name; PC = $pcValue; VTOR = $vtorValue; FaultFree = $faultFree; Pass = ($pcValue -ge 0x08000000 -and $pcValue -lt 0x08020000 -and $vtorValue -eq 0x08000000 -and $faultFree) }
    }
    $passed = $confirmedPass -and $trailerPass -and (@($negativeResults | Where-Object { -not $_.Pass }).Count -eq 0)
    $rows = @('# Sprint 3 test report', '', "**HIL decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'S3 uses the production boot decision. It proves only Primary `CONFIRMED` trailer behavior; update and swap are excluded.', '', '## Results', '', "- Ten confirmed boots reach Primary with VTOR 0x08020200, no fault: **$confirmedPass**", "- Trailer is byte-identical after ten confirmed boots: **$trailerPass**")
    foreach ($result in $negativeResults) { $rows += ('- `{0}`: PC `0x{1:X8}`, VTOR `0x{2:X8}`, no fault={3}: **{4}**' -f $result.Name, $result.PC, $result.VTOR, $result.FaultFree, $result.Pass) }
    $rows += '', '## Evidence', '', '- `S03_flash_trailer_cases.log`', '- `S03_jlink_trailer.log`', '- `S03_cases/after_10_resets_trailer.bin`', '- `S03_ARTIFACT_MANIFEST.json`', '', 'The valid `CONFIRMED` Primary package was restored and reset/run after the negative cases.'
    Set-Content -LiteralPath $s3TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S3 HIL acceptance failed. See $s3TestReport" }
}

function Save-S3RunSummary {
    $rows = @('# Sprint 3 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", '- Profile: production boot decision + Primary CONFIRMED trailer', '', '## Outputs', '')
    foreach ($path in @($s3BuildLog, $s3FlashLog, $s3CaptureLog, $s3TestReport, (Join-Path $autoEvidenceDir 'S03_ARTIFACT_MANIFEST.json'))) { if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" } }
    Set-Content -LiteralPath $s3RunSummary -Value $rows -Encoding utf8
}

function New-S4TrailerRecord {
    param(
        [ValidateSet('test', 'confirmed')][string]$State,
        [uint32]$Sequence,
        [uint32]$ImageCrc32,
        [ValidateRange(0, 255)][byte]$Attempts = 0
    )
    $record = New-Object byte[] 32
    for ($index = 0; $index -lt $record.Length; ++$index) { $record[$index] = 0xFF }
    Set-S2UInt32 $record 0 0x48375452 # H7WR
    Set-S2UInt32 $record 4 $Sequence
    $record[8] = if ($State -eq 'test') { 3 } else { 4 }
    $record[9] = $Attempts
    $record[10] = 0xFF
    $record[11] = 0xFF
    Set-S2UInt32 $record 12 $ImageCrc32
    Set-S2UInt32 $record 28 (Get-S2Crc32 $record[0..27])
    return $record
}

function New-S4Trailer {
    param([ValidateSet('test0', 'confirmed')][string]$Variant, [uint32]$ImageCrc32)
    $records = New-Object System.Collections.Generic.List[byte]
    $records.AddRange([byte[]](New-S4TrailerRecord -State test -Sequence 1 -ImageCrc32 $ImageCrc32 -Attempts 0))
    if ($Variant -eq 'confirmed') {
        $records.AddRange([byte[]](New-S4TrailerRecord -State confirmed -Sequence 2 -ImageCrc32 $ImageCrc32 -Attempts 0))
    }
    return $records.ToArray()
}

function Invoke-S4Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s4CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s4BuildLog -Value "Sprint 4 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'production bootloader S4 profile' -BuildLogPath $s4BuildLog
    Invoke-CmakeBuild -BuildDirectory $appBuildDir -Label 'application confirmation S4 profile' -BuildLogPath $s4BuildLog
    if (-not (Test-Path -LiteralPath $s1SnapshotAppSmokeBin -PathType Leaf)) { Invoke-S1Build }
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S4 production bootloader objcopy failed.' }
    foreach ($artifact in @($bootloaderBin, (Join-Path $appBuildDir 'app_1.bin'), $s1SnapshotAppSmokeBin)) {
        if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "S4 artifact missing: $artifact" }
    }
    Copy-Item -LiteralPath $bootloaderBin -Destination $s4SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath (Join-Path $appBuildDir 'app_1.bin') -Destination $s4SnapshotConfirmAppBin -Force
    Copy-Item -LiteralPath $s1SnapshotAppSmokeBin -Destination $s4SnapshotNoConfirmAppBin -Force

    foreach ($case in @(@{ Name = 'confirm'; Payload = $s4SnapshotConfirmAppBin }, @{ Name = 'no_confirm'; Payload = $s4SnapshotNoConfirmAppBin })) {
        $payload = [System.IO.File]::ReadAllBytes($case.Payload)
        if (($payload.Length -le 0x100) -or ($payload.Length -gt 0x5EE00)) { throw "Unexpected S4 $($case.Name) payload size: $($payload.Length)" }
        $image = New-S2Header -Payload $payload -Variant valid
        $crc = Get-S2Crc32 $image.Payload
        [System.IO.File]::WriteAllBytes((Join-Path $s4CaseDirectory "$($case.Name)_header.bin"), $image.Header)
        [System.IO.File]::WriteAllBytes((Join-Path $s4CaseDirectory "$($case.Name)_payload.bin"), $image.Payload)
        [System.IO.File]::WriteAllBytes((Join-Path $s4CaseDirectory "$($case.Name)_test0_trailer.bin"), (New-S4Trailer -Variant test0 -ImageCrc32 $crc))
        [System.IO.File]::WriteAllBytes((Join-Path $s4CaseDirectory "$($case.Name)_confirmed_trailer.bin"), (New-S4Trailer -Variant confirmed -ImageCrc32 $crc))
    }
    [ordered]@{
        schema_version = 1; sprint = 'S4'; profile = 'production boot decision; app confirmation API and no-confirm control'
        bootloader_sha256 = (Get-FileHash $s4SnapshotBootloaderBin -Algorithm SHA256).Hash
        confirming_app_sha256 = (Get-FileHash $s4SnapshotConfirmAppBin -Algorithm SHA256).Hash
        no_confirm_app_sha256 = (Get-FileHash $s4SnapshotNoConfirmAppBin -Algorithm SHA256).Hash
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S04_ARTIFACT_MANIFEST.json') -Encoding utf8
}

function Invoke-S4ProgramPrimary {
    param([ValidateSet('confirm', 'no_confirm')][string]$Case, [Parameter(Mandatory = $true)][string]$TrailerPath)
    $headerPath = Join-Path $s4CaseDirectory "$Case`_header.bin"
    $payloadPath = Join-Path $s4CaseDirectory "$Case`_payload.bin"
    $commands = @("loadbin $s4SnapshotBootloaderBin, 0x08000000", 'erase 0x08080000, 0x00060000', "loadbin $headerPath, 0x08020000", "loadbin $payloadPath, 0x08020200", 'erase 0x08060000, 0x00020000', "loadbin $TrailerPath, 0x0807F000", 'r', 'h', 'exit')
    Invoke-JLinkCommands -Commands $commands -LogPath $s4FlashLog -Append
}

function Invoke-S4FlashAndCapture {
    if (-not $AllowFlash) { throw 'S4 Flash is blocked. Re-run with -AllowFlash.' }
    foreach ($path in @($s4SnapshotBootloaderBin, $s4SnapshotConfirmAppBin, $s4SnapshotNoConfirmAppBin)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S4 artifact missing: $path. Run S4 Build first." }
    }
    Set-Content -LiteralPath $s4FlashLog -Value "Sprint 4 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s4CaptureLog -Value "Sprint 4 capture started: $(Get-Date -Format o)" -Encoding utf8

    Invoke-S4ProgramPrimary -Case confirm -TrailerPath (Join-Path $s4CaseDirectory 'confirm_test0_trailer.bin')
    Add-Content -LiteralPath $s4CaptureLog -Value "`n===== CASE healthy_confirmation ====="
    $healthyDump = Join-Path $s4CaseDirectory 'healthy_after_resets_trailer.bin'
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1500', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'sleep 1500', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'sleep 1500', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', ("savebin {0}, 0x0807F000, 0x00001000" -f $healthyDump), 'exit') -LogPath $s4CaptureLog -Append

    Invoke-S4ProgramPrimary -Case no_confirm -TrailerPath (Join-Path $s4CaseDirectory 'no_confirm_test0_trailer.bin')
    Add-Content -LiteralPath $s4CaptureLog -Value "`n===== CASE no_confirmation ====="
    $noConfirmDump = Join-Path $s4CaseDirectory 'no_confirm_after_boot_trailer.bin'
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1000', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', ("savebin {0}, 0x0807F000, 0x00001000" -f $noConfirmDump), 'exit') -LogPath $s4CaptureLog -Append

    # End in a known-good confirmed application state for subsequent work.
    Invoke-S4ProgramPrimary -Case confirm -TrailerPath (Join-Path $s4CaseDirectory 'confirm_confirmed_trailer.bin')
    Invoke-JLinkCommands -Commands @('r', 'g', 'exit') -LogPath $s4FlashLog -Append
}

function Test-S4AppExecution {
    param([string]$Section)
    $pcs = @([regex]::Matches($Section, '(?m)^PC = ([0-9A-F]{8}),') | ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $vtors = @([regex]::Matches($Section, '(?m)^E000ED08 = ([0-9A-F]{8})') | ForEach-Object { [Convert]::ToUInt32($_.Groups[1].Value, 16) })
    $faults = @([regex]::Matches($Section, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})') | ForEach-Object { $_.Groups[1].Value -eq '00000000' -and $_.Groups[2].Value -eq '00000000' })
    # Commander prints registers once for `h` and once again for `regs`; VTOR
    # and fault status are intentionally sampled once per observed boot.
    return ($pcs.Count -gt 0 -and @($pcs | Where-Object { $_ -lt 0x08020200 -or $_ -ge 0x08080000 }).Count -eq 0 -and $pcs.Count -eq (2 * $vtors.Count) -and @($vtors | Where-Object { $_ -ne 0x08020200 }).Count -eq 0 -and $faults.Count -eq $vtors.Count -and @($faults | Where-Object { -not $_ }).Count -eq 0)
}

function Save-S4Report {
    $log = Get-Content -LiteralPath $s4CaptureLog -Raw
    $sections = [regex]::Split($log, '(?m)^===== CASE ')
    $healthy = $sections | Where-Object { $_.StartsWith('healthy_confirmation =====') } | Select-Object -First 1
    $noConfirm = $sections | Where-Object { $_.StartsWith('no_confirmation =====') } | Select-Object -First 1
    $healthyRuns = Test-S4AppExecution $healthy
    $noConfirmRuns = Test-S4AppExecution $noConfirm
    $confirmActual = [System.IO.File]::ReadAllBytes((Join-Path $s4CaseDirectory 'healthy_after_resets_trailer.bin'))
    $confirmExpected = New-Object System.Collections.Generic.List[byte]
    $confirmPayload = [System.IO.File]::ReadAllBytes((Join-Path $s4CaseDirectory 'confirm_payload.bin'))
    $confirmCrc = Get-S2Crc32 $confirmPayload
    $confirmExpected.AddRange([byte[]](New-S4TrailerRecord -State test -Sequence 1 -ImageCrc32 $confirmCrc -Attempts 0))
    $confirmExpected.AddRange([byte[]](New-S4TrailerRecord -State test -Sequence 2 -ImageCrc32 $confirmCrc -Attempts 1))
    $confirmExpected.AddRange([byte[]](New-S4TrailerRecord -State confirmed -Sequence 3 -ImageCrc32 $confirmCrc -Attempts 0))
    $confirmTrailer = ($confirmActual.Length -eq 4096) -and ([System.Linq.Enumerable]::SequenceEqual([byte[]]$confirmExpected.ToArray(), [byte[]]$confirmActual[0..95])) -and (@($confirmActual[96..4095] | Where-Object { $_ -ne 0xFF }).Count -eq 0)
    $noConfirmActual = [System.IO.File]::ReadAllBytes((Join-Path $s4CaseDirectory 'no_confirm_after_boot_trailer.bin'))
    $noConfirmPayload = [System.IO.File]::ReadAllBytes((Join-Path $s4CaseDirectory 'no_confirm_payload.bin'))
    $noConfirmCrc = Get-S2Crc32 $noConfirmPayload
    $noConfirmPrefix = New-Object System.Collections.Generic.List[byte]
    $noConfirmPrefix.AddRange([byte[]](New-S4TrailerRecord -State test -Sequence 1 -ImageCrc32 $noConfirmCrc -Attempts 0))
    $noConfirmPrefix.AddRange([byte[]](New-S4TrailerRecord -State test -Sequence 2 -ImageCrc32 $noConfirmCrc -Attempts 1))
    # A control image may be reset more than once while J-Link attaches.  It
    # is sufficient that every appended record remains TEST; it must never
    # acquire a CONFIRMED record.
    $thirdIsErased = @($noConfirmActual[64..95] | Where-Object { $_ -ne 0xFF }).Count -eq 0
    $thirdIsTest2 = [System.Linq.Enumerable]::SequenceEqual([byte[]](New-S4TrailerRecord -State test -Sequence 3 -ImageCrc32 $noConfirmCrc -Attempts 2), [byte[]]$noConfirmActual[64..95])
    $noConfirmTailStart = if ($thirdIsTest2) { 96 } else { 64 }
    $noConfirmTrailer = ($noConfirmActual.Length -eq 4096) -and ([System.Linq.Enumerable]::SequenceEqual([byte[]]$noConfirmPrefix.ToArray(), [byte[]]$noConfirmActual[0..63])) -and ($thirdIsErased -or $thirdIsTest2) -and (@($noConfirmActual[$noConfirmTailStart..4095] | Where-Object { $_ -ne 0xFF }).Count -eq 0)
    $passed = $healthyRuns -and $confirmTrailer -and $noConfirmRuns -and $noConfirmTrailer
    $rows = @('# Sprint 4 test report', '', "**HIL decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'S4 proves the application confirmation contract using the production boot decision. The healthy image appends `CONFIRMED(0)` after the bootloader appends `TEST(1)`; the control image never does.', '', '## Results', '', "- Healthy confirming app ran across initial boot + two resets: **$healthyRuns**", "- Healthy trailer is `TEST(0)`, `TEST(1)`, `CONFIRMED(0)` and then erased: **$confirmTrailer**", "- No-confirm control app ran: **$noConfirmRuns**", "- No-confirm trailer contains only TEST records (the attachment caused an allowed extra `TEST(2)`): **$noConfirmTrailer**", '', '## Evidence', '', '- `S04_flash_confirmation_cases.log`', '- `S04_jlink_confirmation.log`', '- `S04_cases/healthy_after_resets_trailer.bin`', '- `S04_cases/no_confirm_after_boot_trailer.bin`', '- `S04_ARTIFACT_MANIFEST.json`', '', 'The board was restored to the valid confirming application with a `CONFIRMED` Primary trailer.')
    Set-Content -LiteralPath $s4TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S4 HIL acceptance failed. See $s4TestReport" }
}

function Save-S4RunSummary {
    $rows = @('# Sprint 4 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", '- Profile: production boot decision + app confirmation / no-confirm control', '', '## Outputs', '')
    foreach ($path in @($s4BuildLog, $s4FlashLog, $s4CaptureLog, $s4TestReport, (Join-Path $autoEvidenceDir 'S04_ARTIFACT_MANIFEST.json'))) { if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" } }
    Set-Content -LiteralPath $s4RunSummary -Value $rows -Encoding utf8
}

function Invoke-S5Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s5CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s5BuildLog -Value "Sprint 5 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'production bootloader S5 profile' -BuildLogPath $s5BuildLog
    Invoke-CmakeBuild -BuildDirectory $appBuildDir -Label 'application restore S5 profile' -BuildLogPath $s5BuildLog
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S5 production bootloader objcopy failed.' }
    foreach ($artifact in @($bootloaderBin, (Join-Path $appBuildDir 'app_1.bin'))) {
        if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "S5 artifact missing: $artifact" }
    }
    Copy-Item -LiteralPath $bootloaderBin -Destination $s5SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath (Join-Path $appBuildDir 'app_1.bin') -Destination $s5SnapshotAppBin -Force
    $payload = [System.IO.File]::ReadAllBytes($s5SnapshotAppBin)
    $valid = New-S2Header -Payload $payload -Variant valid
    $headerCrc = New-S2Header -Payload $payload -Variant header_crc
    $payloadCrc = New-S2Header -Payload $payload -Variant payload_crc
    $validCrc = Get-S2Crc32 $valid.Payload
    foreach ($item in @(@{ Name = 'valid'; Image = $valid }, @{ Name = 'header_crc'; Image = $headerCrc }, @{ Name = 'payload_crc'; Image = $payloadCrc })) {
        [System.IO.File]::WriteAllBytes((Join-Path $s5CaseDirectory "$($item.Name)_header.bin"), $item.Image.Header)
        [System.IO.File]::WriteAllBytes((Join-Path $s5CaseDirectory "$($item.Name)_payload.bin"), $item.Image.Payload)
    }
    [System.IO.File]::WriteAllBytes((Join-Path $s5CaseDirectory 'confirmed_trailer.bin'), (New-S3Trailer -Variant confirmed -ImageCrc32 $validCrc))
    [System.IO.File]::WriteAllBytes((Join-Path $s5CaseDirectory 'corrupt_trailer.bin'), (New-S3Trailer -Variant corrupt_crc -ImageCrc32 $validCrc))
    [ordered]@{
        schema_version = 1; sprint = 'S5'; profile = 'production recovery gate; invalid Primary image/state variants'
        bootloader_sha256 = (Get-FileHash $s5SnapshotBootloaderBin -Algorithm SHA256).Hash
        restore_app_sha256 = (Get-FileHash $s5SnapshotAppBin -Algorithm SHA256).Hash
        cases = @('primary_erased', 'header_crc', 'payload_crc', 'missing_trailer', 'corrupt_trailer')
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S05_ARTIFACT_MANIFEST.json') -Encoding utf8
}

function Invoke-S5ProvisionRecoveryCase {
    param([ValidateSet('primary_erased', 'header_crc', 'payload_crc', 'missing_trailer', 'corrupt_trailer')][string]$Case)
    # J-Link erase takes start and end addresses, not start and length.  Clear
    # both slots so no stale PENDING Secondary may affect the recovery result.
    $commands = @("loadbin $s5SnapshotBootloaderBin, 0x08000000", 'erase 0x08080000, 0x080DFFFF', 'erase 0x08020000, 0x0807FFFF')
    if ($Case -ne 'primary_erased') {
        $headerKind = if ($Case -eq 'header_crc') { 'header_crc' } else { 'valid' }
        $payloadKind = if ($Case -eq 'payload_crc') { 'payload_crc' } else { 'valid' }
        $commands += "loadbin $(Join-Path $s5CaseDirectory "$headerKind`_header.bin"), 0x08020000"
        $commands += "loadbin $(Join-Path $s5CaseDirectory "$payloadKind`_payload.bin"), 0x08020200"
        if ($Case -eq 'corrupt_trailer') { $commands += "loadbin $(Join-Path $s5CaseDirectory 'corrupt_trailer.bin'), 0x0807F000" }
        elseif ($Case -ne 'missing_trailer') { $commands += "loadbin $(Join-Path $s5CaseDirectory 'confirmed_trailer.bin'), 0x0807F000" }
    }
    $commands += @('r', 'h', 'exit')
    Invoke-JLinkCommands -Commands $commands -LogPath $s5FlashLog -Append
}

function Invoke-S5FlashAndCapture {
    if (-not $AllowFlash) { throw 'S5 Flash is blocked. Re-run with -AllowFlash.' }
    foreach ($path in @($s5SnapshotBootloaderBin, $s5SnapshotAppBin, (Join-Path $s5CaseDirectory 'confirmed_trailer.bin'))) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S5 artifact missing: $path. Run S5 Build first." }
    }
    Set-Content -LiteralPath $s5FlashLog -Value "Sprint 5 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s5CaptureLog -Value "Sprint 5 recovery capture started: $(Get-Date -Format o)" -Encoding utf8
    Remove-Item -LiteralPath $s5UsbLog -Force -ErrorAction SilentlyContinue
    foreach ($case in @('primary_erased', 'header_crc', 'payload_crc', 'missing_trailer', 'corrupt_trailer')) {
        Invoke-S5ProvisionRecoveryCase -Case $case
        Add-Content -LiteralPath $s5CaptureLog -Value "`n===== CASE $case ====="
        Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1500', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit') -LogPath $s5CaptureLog -Append
        if ($case -eq 'primary_erased') {
            Start-Sleep -Milliseconds 500
            @("Sprint 5 USB recovery observation: $(Get-Date -Format o)", "Expected board CDC port: $RecoveryCdcPort", (& cmd.exe /c "mode $RecoveryCdcPort" 2>&1 | Out-String)) | Set-Content -LiteralPath $s5UsbLog -Encoding utf8
        }
    }
    Invoke-S5Restore
}

function Invoke-S5Restore {
    # Return the target to an application that is already confirmed.
    @("Sprint 5 USB recovery observation before restore: $(Get-Date -Format o)", "Expected board CDC port: $RecoveryCdcPort", (& cmd.exe /c "mode $RecoveryCdcPort" 2>&1 | Out-String)) | Set-Content -LiteralPath $s5UsbLog -Encoding utf8
    $restoreHeader = Join-Path $s5CaseDirectory 'valid_header.bin'
    $restorePayload = Join-Path $s5CaseDirectory 'valid_payload.bin'
    Invoke-JLinkCommands -Commands @("loadbin $s5SnapshotBootloaderBin, 0x08000000", 'erase 0x08080000, 0x080DFFFF', 'erase 0x08020000, 0x0807FFFF', "loadbin $restoreHeader, 0x08020000", "loadbin $restorePayload, 0x08020200", "loadbin $(Join-Path $s5CaseDirectory 'confirmed_trailer.bin'), 0x0807F000", 'r', 'g', 'exit') -LogPath $s5FlashLog -Append
    Add-Content -LiteralPath $s5CaptureLog -Value "`n===== RESTORE confirmed_primary ====="
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1000', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit') -LogPath $s5CaptureLog -Append
}

function Save-S5Report {
    $log = Get-Content -LiteralPath $s5CaptureLog -Raw
    $sections = [regex]::Split($log, '(?m)^===== (?:CASE )?')
    $results = @()
    foreach ($case in @('primary_erased', 'header_crc', 'payload_crc', 'missing_trailer', 'corrupt_trailer')) {
        $section = $sections | Where-Object { $_.StartsWith("$case =====") } | Select-Object -First 1
        $pc = [regex]::Match($section, '(?m)^PC = ([0-9A-F]{8}),')
        $vtor = [regex]::Match($section, '(?m)^E000ED08 = ([0-9A-F]{8})')
        $fault = [regex]::Match($section, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})')
        $pcValue = if ($pc.Success) { [Convert]::ToUInt32($pc.Groups[1].Value, 16) } else { 0 }
        $vtorValue = if ($vtor.Success) { [Convert]::ToUInt32($vtor.Groups[1].Value, 16) } else { 0 }
        $faultFree = $fault.Success -and $fault.Groups[1].Value -eq '00000000' -and $fault.Groups[2].Value -eq '00000000'
        $pass = $pcValue -ge 0x08000000 -and $pcValue -lt 0x08020000 -and $vtorValue -eq 0x08000000 -and $faultFree
        $results += [PSCustomObject]@{ Case = $case; PC = $pcValue; VTOR = $vtorValue; FaultFree = $faultFree; Pass = $pass }
    }
    $usb = if (Test-Path -LiteralPath $s5UsbLog) { Get-Content -LiteralPath $s5UsbLog -Raw } else { '' }
    $usbPass = $usb -match (('(?im)^Status for device {0}:' -f [regex]::Escape($RecoveryCdcPort)))
    $restoreSection = $sections | Where-Object { $_.StartsWith('RESTORE confirmed_primary =====') } | Select-Object -Last 1
    $restorePc = [regex]::Match($restoreSection, '(?m)^PC = ([0-9A-F]{8}),')
    $restoreVtor = [regex]::Match($restoreSection, '(?m)^E000ED08 = ([0-9A-F]{8})')
    $restoreFault = [regex]::Match($restoreSection, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})')
    $restorePcValue = if ($restorePc.Success) { [Convert]::ToUInt32($restorePc.Groups[1].Value, 16) } else { 0 }
    $restoreVtorValue = if ($restoreVtor.Success) { [Convert]::ToUInt32($restoreVtor.Groups[1].Value, 16) } else { 0 }
    $restorePass = $restorePcValue -ge 0x08020200 -and $restorePcValue -lt 0x08080000 -and $restoreVtorValue -eq 0x08020200 -and $restoreFault.Success -and $restoreFault.Groups[1].Value -eq '00000000' -and $restoreFault.Groups[2].Value -eq '00000000'
    $passed = (@($results | Where-Object { -not $_.Pass }).Count -eq 0) -and $usbPass -and $restorePass
    $rows = @('# Sprint 5 test report', '', "**HIL decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'Every case begins with the production bootloader and a cleared Secondary slot. A recovery pass means execution remains in bootloader Flash, VTOR remains at bootloader base, and CFSR/HFSR are clear.', '', '## Results', '')
    foreach ($result in $results) { $rows += ('- `{0}`: PC `0x{1:X8}`, VTOR `0x{2:X8}`, no fault={3}: **{4}**' -f $result.Case, $result.PC, $result.VTOR, $result.FaultFree, $result.Pass) }
    $rows += "- USB CDC recovery enumerated as a serial device: **$usbPass**", ('- Restored `CONFIRMED` Primary runs: PC `0x{0:X8}`, VTOR `0x{1:X8}`: **{2}**' -f $restorePcValue, $restoreVtorValue, $restorePass), '', '## Evidence', '', '- `S05_flash_recovery_cases.log`', '- `S05_jlink_recovery.log`', '- `S05_usb_recovery_ports.log`', '- `S05_ARTIFACT_MANIFEST.json`', '', 'The board was restored to a valid application with a `CONFIRMED` Primary trailer.'
    Set-Content -LiteralPath $s5TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S5 HIL acceptance failed. See $s5TestReport" }
}

function Save-S5RunSummary {
    $rows = @('# Sprint 5 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", '- Profile: production recovery gate + USB CDC enumeration observation', '', '## Outputs', '')
    foreach ($path in @($s5BuildLog, $s5FlashLog, $s5CaptureLog, $s5UsbLog, $s5TestReport, (Join-Path $autoEvidenceDir 'S05_ARTIFACT_MANIFEST.json'))) { if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" } }
    Set-Content -LiteralPath $s5RunSummary -Value $rows -Encoding utf8
}

function Invoke-S6Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s6CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s6BuildLog -Value "Sprint 6 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'production bootloader S6 profile' -BuildLogPath $s6BuildLog
    Invoke-CmakeBuild -BuildDirectory $appBuildDir -Label 'application restore S6 profile' -BuildLogPath $s6BuildLog
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S6 production bootloader objcopy failed.' }
    foreach ($artifact in @($bootloaderBin, (Join-Path $appBuildDir 'app_1.bin'))) { if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "S6 artifact missing: $artifact" } }
    Copy-Item -LiteralPath $bootloaderBin -Destination $s6SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath (Join-Path $appBuildDir 'app_1.bin') -Destination $s6SnapshotAppBin -Force
    $payload = [System.IO.File]::ReadAllBytes($s6SnapshotAppBin)
    $image = New-S2Header -Payload $payload -Variant valid
    $crc = Get-S2Crc32 $image.Payload
    [System.IO.File]::WriteAllBytes((Join-Path $s6CaseDirectory 'restore_header.bin'), $image.Header)
    [System.IO.File]::WriteAllBytes((Join-Path $s6CaseDirectory 'restore_payload.bin'), $image.Payload)
    [System.IO.File]::WriteAllBytes((Join-Path $s6CaseDirectory 'restore_trailer.bin'), (New-S3Trailer -Variant confirmed -ImageCrc32 $crc))
    [ordered]@{ schema_version = 1; sprint = 'S6'; profile = 'USB CDC protocol conformance; no update session'; bootloader_sha256 = (Get-FileHash $s6SnapshotBootloaderBin -Algorithm SHA256).Hash; restore_app_sha256 = (Get-FileHash $s6SnapshotAppBin -Algorithm SHA256).Hash; cdc_port = $RecoveryCdcPort } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S06_ARTIFACT_MANIFEST.json') -Encoding utf8
}

function Invoke-S6ProvisionRecovery {
    Invoke-JLinkCommands -Commands @("loadbin $s6SnapshotBootloaderBin, 0x08000000", 'erase 0x08080000, 0x080DFFFF', 'erase 0x08020000, 0x0807FFFF', 'r', 'h', 'exit') -LogPath $s6FlashLog -Append
}

function Invoke-S6Restore {
    Invoke-JLinkCommands -Commands @("loadbin $s6SnapshotBootloaderBin, 0x08000000", 'erase 0x08080000, 0x080DFFFF', 'erase 0x08020000, 0x0807FFFF', "loadbin $(Join-Path $s6CaseDirectory 'restore_header.bin'), 0x08020000", "loadbin $(Join-Path $s6CaseDirectory 'restore_payload.bin'), 0x08020200", "loadbin $(Join-Path $s6CaseDirectory 'restore_trailer.bin'), 0x0807F000", 'r', 'g', 'exit') -LogPath $s6FlashLog -Append
    Add-Content -LiteralPath $s6CaptureLog -Value "`n===== RESTORE confirmed_primary ====="
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1000', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit') -LogPath $s6CaptureLog -Append
}

function Invoke-S6FlashAndCapture {
    if (-not $AllowFlash) { throw 'S6 Flash is blocked. Re-run with -AllowFlash.' }
    foreach ($path in @($s6SnapshotBootloaderBin, $s6SnapshotAppBin, (Join-Path $s6CaseDirectory 'restore_trailer.bin'))) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S6 artifact missing: $path. Run S6 Build first." } }
    Set-Content -LiteralPath $s6FlashLog -Value "Sprint 6 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s6CaptureLog -Value "Sprint 6 capture started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-S6ProvisionRecovery
    Add-Content -LiteralPath $s6CaptureLog -Value "`n===== RECOVERY before_protocol ====="
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1500', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit') -LogPath $s6CaptureLog -Append
    $python = Get-Command python -ErrorAction Stop
    $oldPreference = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { $protocolOutput = @(& $python.Source (Join-Path $repoRoot 'flashing_tool\flashing_app.py') '--protocol-self-test' $RecoveryCdcPort 2>&1); $script:s6ProtocolExitCode = $LASTEXITCODE }
    finally { $ErrorActionPreference = $oldPreference }
    $protocolOutput | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $s6ProtocolLog -Encoding utf8
    Add-Content -LiteralPath $s6CaptureLog -Value "`n===== RECOVERY after_protocol ====="
    Invoke-JLinkCommands -Commands @('h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'mem32 0x08080000, 8', 'exit') -LogPath $s6CaptureLog -Append
    Invoke-S6Restore
}

function Save-S6Report {
    $log = Get-Content -LiteralPath $s6CaptureLog -Raw
    $sections = [regex]::Split($log, '(?m)^===== (?:RECOVERY |RESTORE )?')
    $before = $sections | Where-Object { $_.StartsWith('before_protocol =====') } | Select-Object -First 1
    $after = $sections | Where-Object { $_.StartsWith('after_protocol =====') } | Select-Object -First 1
    $restore = $sections | Where-Object { $_.StartsWith('confirmed_primary =====') } | Select-Object -Last 1
    function Test-S6Location([string]$section, [bool]$app) {
        $pc = [regex]::Match($section, '(?m)^PC = ([0-9A-F]{8}),'); $vtor = [regex]::Match($section, '(?m)^E000ED08 = ([0-9A-F]{8})'); $fault = [regex]::Match($section, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})')
        $pcValue = if ($pc.Success) { [Convert]::ToUInt32($pc.Groups[1].Value, 16) } else { 0 }; $vtorValue = if ($vtor.Success) { [Convert]::ToUInt32($vtor.Groups[1].Value, 16) } else { 0 }
        $rangePass = if ($app) { $pcValue -ge 0x08020200 -and $pcValue -lt 0x08080000 -and $vtorValue -eq 0x08020200 } else { $pcValue -ge 0x08000000 -and $pcValue -lt 0x08020000 -and $vtorValue -eq 0x08000000 }
        return [PSCustomObject]@{ Pass = ($rangePass -and $fault.Success -and $fault.Groups[1].Value -eq '00000000' -and $fault.Groups[2].Value -eq '00000000'); PC = $pcValue; VTOR = $vtorValue }
    }
    $beforeResult = Test-S6Location $before $false; $afterResult = Test-S6Location $after $false; $restoreResult = Test-S6Location $restore $true
    $protocol = $null; try { $protocol = (Get-Content -LiteralPath $s6ProtocolLog -Raw | ConvertFrom-Json) } catch { }
    $expected = @('get_info', 'bad_crc', 'unknown_command', 'bad_begin_length', 'write_while_idle', 'abort_idle', 'incomplete_frame_timeout', 'reset_ack', 'reset_recovery')
    $protocolPass = ($null -ne $protocol) -and [bool]$protocol.passed -and (@($expected | Where-Object { -not [bool]$protocol.results.$_ }).Count -eq 0) -and ($script:s6ProtocolExitCode -eq 0)
    $secondaryErased = ($after -match '(?m)^08080000 = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF') -and
        ($after -match '(?m)^08080010 = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF')
    $passed = $beforeResult.Pass -and $protocolPass -and $afterResult.Pass -and $secondaryErased -and $restoreResult.Pass
    $rows = @('# Sprint 6 test report', '', "**HIL decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'S6 runs negative protocol traffic only: it does not send a valid update header or payload. Secondary is checked erased after the test.', '', '## Results', '', ('- Recovery before protocol: PC `0x{0:X8}`, VTOR `0x{1:X8}`: **{2}**' -f $beforeResult.PC, $beforeResult.VTOR, $beforeResult.Pass), "- USB CDC protocol self-test on ${RecoveryCdcPort}: **$protocolPass**", "- Recovery after protocol, no fault: **$($afterResult.Pass)**", "- Secondary beginning remains erased: **$secondaryErased**", ('- Restored confirmed Primary: PC `0x{0:X8}`, VTOR `0x{1:X8}`: **{2}**' -f $restoreResult.PC, $restoreResult.VTOR, $restoreResult.Pass), '', '## Protocol cases', '')
    foreach ($name in $expected) { $value = if ($null -ne $protocol) { [bool]$protocol.results.$name } else { $false }; $rows += "- ``$($name)``: **$value**" }
    $rows += '', '## Evidence', '', '- `S06_flash_protocol.log`', '- `S06_jlink_protocol.log`', '- `S06_usb_protocol.json`', '- `S06_ARTIFACT_MANIFEST.json`'
    Set-Content -LiteralPath $s6TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S6 HIL acceptance failed. See $s6TestReport" }
}

function Save-S6RunSummary {
    $rows = @('# Sprint 6 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", "- CDC port: $RecoveryCdcPort", '- Profile: recovery USB CDC protocol conformance; no update session', '', '## Outputs', '')
    foreach ($path in @($s6BuildLog, $s6FlashLog, $s6CaptureLog, $s6ProtocolLog, $s6TestReport, (Join-Path $autoEvidenceDir 'S06_ARTIFACT_MANIFEST.json'))) { if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" } }
    Set-Content -LiteralPath $s6RunSummary -Value $rows -Encoding utf8
}

function New-S7TrailerRecord {
    param([uint32]$Sequence, [byte]$State, [uint32]$ImageCrc32)
    $record = New-Object byte[] 32
    for ($index = 0; $index -lt $record.Length; ++$index) { $record[$index] = 0xFF }
    Set-S2UInt32 $record 0 0x48375452 # H7WR
    Set-S2UInt32 $record 4 $Sequence
    $record[8] = $State; $record[9] = 0; $record[10] = 0; $record[11] = 0xFF
    Set-S2UInt32 $record 12 $ImageCrc32
    Set-S2UInt32 $record 28 (Get-S2Crc32 $record[0..27])
    return $record
}

function Invoke-S7Sil {
    $vcvars = 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat'
    if (-not (Test-Path -LiteralPath $vcvars -PathType Leaf)) { throw "MSVC environment script missing: $vcvars" }
    $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        $output = @(& cmd.exe /d /s /c "call `"$vcvars`" && cmake --build tests\sil\build-msvc --clean-first && ctest --test-dir tests\sil\build-msvc --output-on-failure" 2>&1)
        $exit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previous }
    $output | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $s7SilLog -Encoding utf8
    if ($exit -ne 0) { throw "S7 SIL failed. See $s7SilLog" }
}

function Invoke-S7Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s7CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s7BuildLog -Value "Sprint 7 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'production bootloader S7 profile' -BuildLogPath $s7BuildLog
    Invoke-CmakeBuild -BuildDirectory $appBuildDir -Label 'application S7 candidate' -BuildLogPath $s7BuildLog
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S7 production bootloader objcopy failed.' }
    foreach ($artifact in @($bootloaderBin, (Join-Path $appBuildDir 'app_1.bin'))) { if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "S7 artifact missing: $artifact" } }
    Copy-Item -LiteralPath $bootloaderBin -Destination $s7SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath (Join-Path $appBuildDir 'app_1.bin') -Destination $s7SnapshotAppBin -Force
    $payload = [System.IO.File]::ReadAllBytes($s7SnapshotAppBin)
    $image = New-S2Header -Payload $payload -Variant valid
    $crc = Get-S2Crc32 $image.Payload
    [System.IO.File]::WriteAllBytes((Join-Path $s7CaseDirectory 'primary_header.bin'), $image.Header)
    [System.IO.File]::WriteAllBytes((Join-Path $s7CaseDirectory 'primary_payload.bin'), $image.Payload)
    [System.IO.File]::WriteAllBytes((Join-Path $s7CaseDirectory 'confirmed_trailer.bin'), (New-S3Trailer -Variant confirmed -ImageCrc32 $crc))
    $expectedTrailer = New-Object byte[] 4096
    for ($index = 0; $index -lt $expectedTrailer.Length; ++$index) { $expectedTrailer[$index] = 0xFF }
    [Array]::Copy((New-S7TrailerRecord -Sequence 1 -State 1 -ImageCrc32 $crc), 0, $expectedTrailer, 0, 32)
    [Array]::Copy((New-S7TrailerRecord -Sequence 2 -State 2 -ImageCrc32 $crc), 0, $expectedTrailer, 32, 32)
    [System.IO.File]::WriteAllBytes((Join-Path $s7CaseDirectory 'expected_pending_trailer.bin'), $expectedTrailer)
    [ordered]@{ schema_version = 1; sprint = 'S7'; profile = 'Secondary download boundary; no reset after pending'; bootloader_sha256 = (Get-FileHash $s7SnapshotBootloaderBin -Algorithm SHA256).Hash; candidate_sha256 = (Get-FileHash $s7SnapshotAppBin -Algorithm SHA256).Hash; candidate_bytes = $payload.Length; padded_bytes = $image.Payload.Length; cdc_port = $RecoveryCdcPort } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S07_ARTIFACT_MANIFEST.json') -Encoding utf8
    Invoke-S7Sil
}

function Invoke-S7Restore {
    Invoke-JLinkCommands -Commands @("loadbin $s7SnapshotBootloaderBin, 0x08000000", 'erase 0x08080000, 0x080DFFFF', 'erase 0x08020000, 0x0807FFFF', "loadbin $(Join-Path $s7CaseDirectory 'primary_header.bin'), 0x08020000", "loadbin $(Join-Path $s7CaseDirectory 'primary_payload.bin'), 0x08020200", "loadbin $(Join-Path $s7CaseDirectory 'confirmed_trailer.bin'), 0x0807F000", 'r', 'g', 'exit') -LogPath $s7FlashLog -Append
    Add-Content -LiteralPath $s7CaptureLog -Value "`n===== RESTORE confirmed_primary ====="
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1000', 'h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit') -LogPath $s7CaptureLog -Append
}

function Invoke-S7Python {
    param([string[]]$Arguments, [string]$LogPath)
    $python = Get-Command python -ErrorAction Stop
    $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { $output = @(& $python.Source (Join-Path $repoRoot 'flashing_tool\flashing_app.py') @Arguments 2>&1); $exit = $LASTEXITCODE }
    finally { $ErrorActionPreference = $previous }
    $output | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $LogPath -Encoding utf8
    if ($exit -ne 0) { throw "S7 Python test failed. See $LogPath" }
}

function Invoke-S7FlashAndCapture {
    if (-not $AllowFlash) { throw 'S7 Flash is blocked. Re-run with -AllowFlash.' }
    foreach ($path in @($s7SnapshotBootloaderBin, $s7SnapshotAppBin, (Join-Path $s7CaseDirectory 'confirmed_trailer.bin'))) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S7 artifact missing: $path. Run S7 Build first." } }
    Set-Content -LiteralPath $s7FlashLog -Value "Sprint 7 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s7CaptureLog -Value "Sprint 7 capture started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-S7Restore
    Add-Content -LiteralPath $s7CaptureLog -Value "`n===== PRIMARY before_update ====="
    Invoke-JLinkCommands -Commands @('h', "savebin $s7PrimaryBefore, 0x08020000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'g', 'exit') -LogPath $s7CaptureLog -Append
    # The preceding diagnostic halts/resumes the application and causes USB
    # re-enumeration.  Wait for the app CDC endpoint before issuing its command.
    Start-Sleep -Milliseconds 1000
    Invoke-S7Python -Arguments @('--request-update', $RecoveryCdcPort) -LogPath $s7RequestLog
    # The app intentionally retains the CDC link for 100 ms after ACK, then
    # resets.  Do not send bootloader framing while that app link still exists.
    Start-Sleep -Milliseconds 1500
    Invoke-S7Python -Arguments @('--secondary-abort-test', $RecoveryCdcPort, $s7SnapshotAppBin) -LogPath $s7AbortLog
    Add-Content -LiteralPath $s7CaptureLog -Value "`n===== SECONDARY after_abort ====="
    Invoke-JLinkCommands -Commands @('h', "savebin $s7SecondaryAbort, 0x08080000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'g', 'exit') -LogPath $s7CaptureLog -Append
    Invoke-S7Python -Arguments @('--secondary-download-test', $RecoveryCdcPort, $s7SnapshotAppBin) -LogPath $s7DownloadLog
    Add-Content -LiteralPath $s7CaptureLog -Value "`n===== SECONDARY pending_no_reset ====="
    Invoke-JLinkCommands -Commands @('h', "savebin $s7PrimaryAfter, 0x08020000, 0x00060000", "savebin $s7SecondaryFinal, 0x08080000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'mem32 0x080DF000, 16', 'exit') -LogPath $s7CaptureLog -Append
    # The target is intentionally halted before reset: a PENDING secondary is
    # activation input, which is tested separately in Sprint 8.
    Invoke-S7Restore
}

function Save-S7Report {
    $silPass = (Test-Path -LiteralPath $s7SilLog) -and ((Get-Content -LiteralPath $s7SilLog -Raw) -match '100% tests passed, 0 tests failed out of 1')
    $request = $null; $abort = $null; $download = $null
    try { $request = Get-Content -LiteralPath $s7RequestLog -Raw | ConvertFrom-Json; $abort = Get-Content -LiteralPath $s7AbortLog -Raw | ConvertFrom-Json; $download = Get-Content -LiteralPath $s7DownloadLog -Raw | ConvertFrom-Json } catch { }
    $primarySame = (Get-FileHash -LiteralPath $s7PrimaryBefore -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $s7PrimaryAfter -Algorithm SHA256).Hash
    $abortErased = [System.IO.File]::ReadAllBytes($s7SecondaryAbort) | Where-Object { $_ -ne 0xFF } | Measure-Object | Select-Object -ExpandProperty Count
    $final = [System.IO.File]::ReadAllBytes($s7SecondaryFinal)
    $headerValid = ([BitConverter]::ToUInt32($final, 0) -eq 0x4837424C) -and ([BitConverter]::ToUInt32($final, 8) -eq 0x48374231) -and ([BitConverter]::ToUInt32($final, 24) -eq [System.IO.File]::ReadAllBytes($s7SnapshotAppBin).Length) -and ([BitConverter]::ToUInt32($final, 124) -eq (Get-S2Crc32 $final[0..123]))
    $expectedTrailer = [System.IO.File]::ReadAllBytes((Join-Path $s7CaseDirectory 'expected_pending_trailer.bin'))
    $actualTrailer = $final[0x5F000..0x5FFFF]
    $pendingTrailer = [System.Linq.Enumerable]::SequenceEqual([byte[]]$expectedTrailer, [byte[]]$actualTrailer)
    $restore = Get-Content -LiteralPath $s7CaptureLog -Raw
    $restoredApp = ($restore -match '(?m)^PC = 080[2-7][0-9A-F]{4},') -and ($restore -match '(?m)^E000ED08 = 08020200')
    $passed = $silPass -and ($null -ne $request -and [bool]$request.passed) -and ($null -ne $abort -and [bool]$abort.passed) -and ($abortErased -eq 0) -and ($null -ne $download -and [bool]$download.passed) -and $primarySame -and $headerValid -and $pendingTrailer -and $restoredApp
    $rows = @('# Sprint 7 test report', '', "**Decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'S7 confirms download isolation only. After `FINALIZE`, Secondary is `PENDING`; no reset is sent because the current boot policy activates PENDING on reset (Sprint 8 scope). The board is then restored to its confirmed Primary application.', '', '## Results', '', "- SIL update-isolation test: **$silPass**", "- App accepted `ENTER_UPDATE`: **$($request.passed)**", "- Invalid offset/length rejected and `ABORT` acknowledged: **$($abort.passed)**", "- Secondary erased after abort: **$($abortErased -eq 0)**", "- Complete USB CDC download/finalize: **$($download.passed)**", "- Primary dump unchanged byte-for-byte: **$primarySame**", "- Secondary image header valid: **$headerValid**", "- Secondary trailer records are `DOWNLOADED(1)` then `PENDING(2)`: **$pendingTrailer**", "- Board restored to confirmed Primary app: **$restoredApp**", '', '## Evidence', '', '- `S07_sil.log`', '- `S07_request_update.json`', '- `S07_abort_protocol.json`', '- `S07_download_protocol.json`', '- `S07_primary_before.bin`, `S07_primary_after.bin`', '- `S07_secondary_after_abort.bin`, `S07_secondary_pending.bin`', '- `S07_jlink_secondary_download.log`', '- `S07_ARTIFACT_MANIFEST.json`')
    Set-Content -LiteralPath $s7TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S7 acceptance failed. See $s7TestReport" }
}

function Save-S7RunSummary {
    $rows = @('# Sprint 7 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", "- CDC port: $RecoveryCdcPort", '- Profile: Secondary download boundary; no reset while PENDING', '', '## Outputs', '')
    foreach ($path in @($s7BuildLog, $s7SilLog, $s7FlashLog, $s7CaptureLog, $s7RequestLog, $s7AbortLog, $s7DownloadLog, $s7TestReport, (Join-Path $autoEvidenceDir 'S07_ARTIFACT_MANIFEST.json'))) { if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" } }
    Set-Content -LiteralPath $s7RunSummary -Value $rows -Encoding utf8
}

function New-S8TrailerRecord {
    param(
        [uint32]$Sequence,
        [byte]$State,
        [uint32]$ImageCrc32,
        [byte]$Attempts = 0,
        [byte]$SwapSector = 0
    )
    $record = New-Object byte[] 32
    for ($index = 0; $index -lt $record.Length; ++$index) { $record[$index] = 0xFF }
    Set-S2UInt32 $record 0 0x48375452 # H7WR
    Set-S2UInt32 $record 4 $Sequence
    $record[8] = $State; $record[9] = $Attempts; $record[10] = $SwapSector; $record[11] = 0xFF
    Set-S2UInt32 $record 12 $ImageCrc32
    Set-S2UInt32 $record 28 (Get-S2Crc32 $record[0..27])
    return $record
}

function New-S8Trailer {
    param([Parameter(Mandatory = $true)][object[]]$Records)
    $trailer = New-Object byte[] 4096
    for ($index = 0; $index -lt $trailer.Length; ++$index) { $trailer[$index] = 0xFF }
    for ($index = 0; $index -lt $Records.Count; ++$index) {
        [Array]::Copy([byte[]]$Records[$index], 0, $trailer, ($index * 32), 32)
    }
    return $trailer
}

function Invoke-S8Sil {
    $vcvars = 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat'
    if (-not (Test-Path -LiteralPath $vcvars -PathType Leaf)) { throw "MSVC environment script missing: $vcvars" }
    $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        $output = @(& cmd.exe /d /s /c "call `"$vcvars`" && cmake --build tests\sil\build-msvc --clean-first && ctest --test-dir tests\sil\build-msvc --output-on-failure" 2>&1)
        $exit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previous }
    $output | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $s8SilLog -Encoding utf8
    if ($exit -ne 0) { throw "S8 SIL failed. See $s8SilLog" }
}

function Invoke-S8Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s8CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s8BuildLog -Value "Sprint 8 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'production bootloader S8 profile' -BuildLogPath $s8BuildLog
    Invoke-CmakeBuild -BuildDirectory $appBuildDir -Label 'application S8 first-install candidate' -BuildLogPath $s8BuildLog
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S8 production bootloader objcopy failed.' }
    $appBin = Join-Path $appBuildDir 'app_1.bin'
    foreach ($artifact in @($bootloaderBin, $appBin)) { if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "S8 artifact missing: $artifact" } }
    Copy-Item -LiteralPath $bootloaderBin -Destination $s8SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath $appBin -Destination $s8SnapshotAppBin -Force

    $payload = [System.IO.File]::ReadAllBytes($s8SnapshotAppBin)
    $payloadCrc = Get-S2Crc32 $payload
    $pending = New-S8Trailer @(
        (New-S8TrailerRecord -Sequence 1 -State 1 -ImageCrc32 $payloadCrc),
        (New-S8TrailerRecord -Sequence 2 -State 2 -ImageCrc32 $payloadCrc))
    $primaryFinal = New-S8Trailer @(
        (New-S8TrailerRecord -Sequence 1 -State 1 -ImageCrc32 $payloadCrc),
        (New-S8TrailerRecord -Sequence 2 -State 2 -ImageCrc32 $payloadCrc),
        (New-S8TrailerRecord -Sequence 3 -State 3 -ImageCrc32 $payloadCrc -Attempts 0 -SwapSector 0xFF),
        (New-S8TrailerRecord -Sequence 4 -State 3 -ImageCrc32 $payloadCrc -Attempts 1 -SwapSector 0xFF),
        (New-S8TrailerRecord -Sequence 5 -State 4 -ImageCrc32 $payloadCrc -Attempts 0 -SwapSector 0xFF))
    $secondaryFinal = New-S8Trailer @(
        (New-S8TrailerRecord -Sequence 1 -State 1 -ImageCrc32 $payloadCrc),
        (New-S8TrailerRecord -Sequence 2 -State 2 -ImageCrc32 $payloadCrc),
        (New-S8TrailerRecord -Sequence 3 -State 4 -ImageCrc32 $payloadCrc -Attempts 0 -SwapSector 0xFF))
    [System.IO.File]::WriteAllBytes((Join-Path $s8CaseDirectory 'expected_secondary_pending_trailer.bin'), $pending)
    [System.IO.File]::WriteAllBytes((Join-Path $s8CaseDirectory 'expected_primary_confirmed_trailer.bin'), $primaryFinal)
    [System.IO.File]::WriteAllBytes((Join-Path $s8CaseDirectory 'expected_secondary_confirmed_trailer.bin'), $secondaryFinal)
    [ordered]@{ schema_version = 1; sprint = 'S8'; profile = 'First installation from empty Primary through USB Secondary download'; bootloader_sha256 = (Get-FileHash $s8SnapshotBootloaderBin -Algorithm SHA256).Hash; candidate_sha256 = (Get-FileHash $s8SnapshotAppBin -Algorithm SHA256).Hash; candidate_bytes = $payload.Length; padded_bytes = [int]([math]::Ceiling($payload.Length / 32.0) * 32); payload_crc32 = ('0x{0:X8}' -f $payloadCrc); cdc_port = $RecoveryCdcPort } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S08_ARTIFACT_MANIFEST.json') -Encoding utf8
    Invoke-S8Sil
}

function Invoke-S8Python {
    param([string[]]$Arguments, [string]$LogPath)
    $python = Get-Command python -ErrorAction Stop
    $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { $output = @(& $python.Source (Join-Path $repoRoot 'flashing_tool\flashing_app.py') @Arguments 2>&1); $exit = $LASTEXITCODE }
    finally { $ErrorActionPreference = $previous }
    $output | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $LogPath -Encoding utf8
    if ($exit -ne 0) { throw "S8 Python test failed. See $LogPath" }
}

function Invoke-S8FlashAndCapture {
    if (-not $AllowFlash) { throw 'S8 Flash is blocked. Re-run with -AllowFlash.' }
    foreach ($path in @($s8SnapshotBootloaderBin, $s8SnapshotAppBin, (Join-Path $s8CaseDirectory 'expected_secondary_pending_trailer.bin'))) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S8 artifact missing: $path. Run S8 Build first." } }
    Set-Content -LiteralPath $s8FlashLog -Value "Sprint 8 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s8CaptureLog -Value "Sprint 8 capture started: $(Get-Date -Format o)" -Encoding utf8

    # Provision only the bootloader.  The test candidate reaches Primary solely
    # through its USB download to Secondary and bootloader-owned flash copies.
    Invoke-JLinkCommands -Commands @("loadbin $s8SnapshotBootloaderBin, 0x08000000", 'erase 0x08020000, 0x0807FFFF', 'erase 0x08080000, 0x080DFFFF', 'r', 'g', 'exit') -LogPath $s8FlashLog -Append
    Start-Sleep -Milliseconds 1000
    Add-Content -LiteralPath $s8CaptureLog -Value "`n===== PRIMARY empty_before_download ====="
    Invoke-JLinkCommands -Commands @('h', 'mem32 0x08020000, 4', 'mem32 0x0807F000, 4', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit') -LogPath $s8CaptureLog -Append

    Invoke-S8Python -Arguments @('--secondary-download-test', $RecoveryCdcPort, $s8SnapshotAppBin) -LogPath $s8DownloadLog
    Add-Content -LiteralPath $s8CaptureLog -Value "`n===== SECONDARY pending_before_activation ====="
    Invoke-JLinkCommands -Commands @('h', "savebin $s8SecondaryPending, 0x08080000, 0x00060000", 'mem32 0x080DF000, 16', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit') -LogPath $s8CaptureLog -Append

    Add-Content -LiteralPath $s8CaptureLog -Value "`n===== FIRST_INSTALL activation_and_confirmation ====="
    # A first install erases and writes three 128 KiB sectors.  Capture only
    # after that Flash-resident transaction has completed; halting earlier is
    # both invalid evidence and can interrupt the copy operation.
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 15000', 'h', "savebin $s8PrimaryActivated, 0x08020000, 0x00060000", "savebin $s8SecondaryActivated, 0x08080000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'exit') -LogPath $s8CaptureLog -Append

    Add-Content -LiteralPath $s8CaptureLog -Value "`n===== CONFIRMED stable_second_reset ====="
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1000', 'h', "savebin $s8PrimaryStable, 0x08020000, 0x00060000", "savebin $s8SecondaryStable, 0x08080000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit') -LogPath $s8CaptureLog -Append
}

function Test-S8Bytes {
    param([byte[]]$Left, [int]$LeftOffset, [byte[]]$Right, [int]$RightOffset, [int]$Count)
    if (($Left.Length - $LeftOffset) -lt $Count -or ($Right.Length - $RightOffset) -lt $Count) { return $false }
    for ($index = 0; $index -lt $Count; ++$index) { if ($Left[$LeftOffset + $index] -ne $Right[$RightOffset + $index]) { return $false } }
    return $true
}

function Save-S8Report {
    $silPass = (Test-Path -LiteralPath $s8SilLog) -and ((Get-Content -LiteralPath $s8SilLog -Raw) -match '100% tests passed, 0 tests failed out of 1')
    $download = $null; try { $download = Get-Content -LiteralPath $s8DownloadLog -Raw | ConvertFrom-Json } catch { }
    $capture = Get-Content -LiteralPath $s8CaptureLog -Raw
    $sections = [regex]::Split($capture, '(?m)^===== ')
    $empty = $sections | Where-Object { $_.StartsWith('PRIMARY empty_before_download =====') } | Select-Object -First 1
    $activation = $sections | Where-Object { $_.StartsWith('FIRST_INSTALL activation_and_confirmation =====') } | Select-Object -First 1
    $stable = $sections | Where-Object { $_.StartsWith('CONFIRMED stable_second_reset =====') } | Select-Object -First 1
    function Get-S8RunState([string]$Section) {
        $pc = [regex]::Match($Section, '(?m)^PC = ([0-9A-F]{8}),'); $vtor = [regex]::Match($Section, '(?m)^E000ED08 = ([0-9A-F]{8})'); $fault = [regex]::Match($Section, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})')
        $pcValue = if ($pc.Success) { [Convert]::ToUInt32($pc.Groups[1].Value, 16) } else { 0 }; $vtorValue = if ($vtor.Success) { [Convert]::ToUInt32($vtor.Groups[1].Value, 16) } else { 0 }
        $appRange = $pcValue -ge 0x08020200 -and $pcValue -lt 0x08080000
        [PSCustomObject]@{ Pass = ($appRange -and $vtorValue -eq 0x08020200 -and $fault.Success -and $fault.Groups[1].Value -eq '00000000' -and $fault.Groups[2].Value -eq '00000000'); PC = $pcValue; VTOR = $vtorValue }
    }
    $activationRun = Get-S8RunState $activation; $stableRun = Get-S8RunState $stable
    $emptyPrimary = ($empty -match '(?m)^08020000 = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF') -and ($empty -match '(?m)^0807F000 = FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF')
    $pending = [System.IO.File]::ReadAllBytes($s8SecondaryPending); $primary = [System.IO.File]::ReadAllBytes($s8PrimaryActivated); $secondary = [System.IO.File]::ReadAllBytes($s8SecondaryActivated); $primaryStable = [System.IO.File]::ReadAllBytes($s8PrimaryStable); $secondaryStable = [System.IO.File]::ReadAllBytes($s8SecondaryStable); $payload = [System.IO.File]::ReadAllBytes($s8SnapshotAppBin)
    $headerValid = ([BitConverter]::ToUInt32($pending, 0) -eq 0x4837424C) -and ([BitConverter]::ToUInt32($pending, 8) -eq 0x48374231) -and ([BitConverter]::ToUInt32($pending, 24) -eq $payload.Length) -and ([BitConverter]::ToUInt32($pending, 124) -eq (Get-S2Crc32 $pending[0..123]))
    $pendingTrailer = Test-S8Bytes $pending 0x5F000 ([System.IO.File]::ReadAllBytes((Join-Path $s8CaseDirectory 'expected_secondary_pending_trailer.bin'))) 0 0x1000
    $primaryCopied = Test-S8Bytes $pending 0 $primary 0 0x5F000
    $primaryTrailer = Test-S8Bytes $primary 0x5F000 ([System.IO.File]::ReadAllBytes((Join-Path $s8CaseDirectory 'expected_primary_confirmed_trailer.bin'))) 0 0x1000
    $secondaryTrailer = Test-S8Bytes $secondary 0x5F000 ([System.IO.File]::ReadAllBytes((Join-Path $s8CaseDirectory 'expected_secondary_confirmed_trailer.bin'))) 0 0x1000
    $stablePrimary = Test-S8Bytes $primary 0 $primaryStable 0 0x60000; $stableSecondary = Test-S8Bytes $secondary 0 $secondaryStable 0 0x60000
    $noCandidateLoadedDirectly = -not ((Get-Content -LiteralPath $s8FlashLog -Raw) -match [regex]::Escape((Split-Path -Leaf $s8SnapshotAppBin)))
    $passed = $silPass -and ($null -ne $download -and [bool]$download.passed) -and $emptyPrimary -and $headerValid -and $pendingTrailer -and $primaryCopied -and $primaryTrailer -and $secondaryTrailer -and $activationRun.Pass -and $stableRun.Pass -and $stablePrimary -and $stableSecondary -and $noCandidateLoadedDirectly
    $rows = @('# Sprint 8 test report', '', "**HIL decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'S8 proves first installation: Primary is erased, the candidate is downloaded over USB CDC only to Secondary, then the bootloader copies it to Primary, trial-boots it, and the application confirms itself. A second reset proves the confirmed steady state does not mutate either slot.', '', '## Results', '', "- SIL regression suite: **$silPass**", "- USB CDC Secondary download finalized PENDING: **$($download.passed)**", "- Primary header and trailer were erased before download: **$emptyPrimary**", "- Pending Secondary header valid: **$headerValid**", "- Pending Secondary journal is DOWNLOADED -> PENDING: **$pendingTrailer**", "- Bootloader copied image area Secondary -> Primary byte-for-byte: **$primaryCopied**", "- Primary journal is DOWNLOADED -> PENDING -> TEST(0) -> TEST(1) -> CONFIRMED: **$primaryTrailer**", "- Secondary journal is DOWNLOADED -> PENDING -> CONFIRMED: **$secondaryTrailer**", ('- First boot reaches Primary app: PC `0x{0:X8}`, VTOR `0x{1:X8}`: **{2}**' -f $activationRun.PC, $activationRun.VTOR, $activationRun.Pass), ('- Second reset stays in confirmed Primary app: PC `0x{0:X8}`, VTOR `0x{1:X8}`: **{2}**' -f $stableRun.PC, $stableRun.VTOR, $stableRun.Pass), "- No journal/image mutation after confirmed reset: Primary **$stablePrimary**, Secondary **$stableSecondary**", "- J-Link provisioning log contains no direct candidate load: **$noCandidateLoadedDirectly**", '', '## Evidence', '', '- `S08_build.log`, `S08_sil.log`, `S08_ARTIFACT_MANIFEST.json`', '- `S08_flash_first_install.log`, `S08_jlink_first_install.log`', '- `S08_download_protocol.json`', '- `S08_secondary_pending.bin`', '- `S08_primary_after_activation.bin`, `S08_secondary_after_activation.bin`', '- `S08_primary_after_confirmed_reset.bin`, `S08_secondary_after_confirmed_reset.bin`')
    Set-Content -LiteralPath $s8TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S8 HIL acceptance failed. See $s8TestReport" }
}

function Save-S8RunSummary {
    $rows = @('# Sprint 8 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", "- CDC port: $RecoveryCdcPort", '- Profile: empty Primary -> USB Secondary PENDING -> bootloader first install -> TEST -> CONFIRMED', '', '## Outputs', '')
    foreach ($path in @($s8BuildLog, $s8SilLog, $s8FlashLog, $s8CaptureLog, $s8DownloadLog, $s8SecondaryPending, $s8PrimaryActivated, $s8SecondaryActivated, $s8PrimaryStable, $s8SecondaryStable, $s8TestReport, (Join-Path $autoEvidenceDir 'S08_ARTIFACT_MANIFEST.json'))) { if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" } }
    Set-Content -LiteralPath $s8RunSummary -Value $rows -Encoding utf8
}

function Invoke-S9ApplicationBuild {
    param([string]$BuildDirectory, [string]$TargetName, [int]$BlinkPeriodMs)
    $appSource = Join-Path $repoRoot 'app\app_1'
    $toolchain = Join-Path $appSource 'cmake\gcc-arm-none-eabi.cmake'
    $configureArguments = @('-S', $appSource, '-B', $BuildDirectory, '-G', 'Ninja', '-DCMAKE_BUILD_TYPE=Debug', "-DCMAKE_TOOLCHAIN_FILE=$toolchain", "-DAPP_TARGET_NAME=$TargetName", "-DAPP_BLINK_PERIOD_MS=$BlinkPeriodMs")
    "[application $TargetName / ${BlinkPeriodMs}ms] cmake $($configureArguments -join ' ')" | Tee-Object -FilePath $s9BuildLog -Append
    $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        $output = @(& cmake @configureArguments 2>&1); $exit = $LASTEXITCODE
        $output | ForEach-Object { $_.ToString() } | Tee-Object -FilePath $s9BuildLog -Append
        if ($exit -eq 0) {
            $buildArguments = @('--build', $BuildDirectory)
            if (-not $Incremental) { $buildArguments += '--clean-first' }
            $output = @(& cmake @buildArguments 2>&1); $exit = $LASTEXITCODE
            $output | ForEach-Object { $_.ToString() } | Tee-Object -FilePath $s9BuildLog -Append
        }
    } finally { $ErrorActionPreference = $previous }
    if ($exit -ne 0) { throw "S9 application $TargetName build failed. See $s9BuildLog" }
}

function Invoke-S9Sil {
    $vcvars = 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat'
    if (-not (Test-Path -LiteralPath $vcvars -PathType Leaf)) { throw "MSVC environment script missing: $vcvars" }
    $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        $output = @(& cmd.exe /d /s /c "call `"$vcvars`" && cmake --build tests\sil\build-msvc --clean-first && ctest --test-dir tests\sil\build-msvc --output-on-failure" 2>&1)
        $exit = $LASTEXITCODE
    } finally { $ErrorActionPreference = $previous }
    $output | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $s9SilLog -Encoding utf8
    if ($exit -ne 0) { throw "S9 SIL failed. See $s9SilLog" }
}

function Invoke-S9Build {
    New-Item -ItemType Directory -Path $autoEvidenceDir, $s9CaseDirectory -Force | Out-Null
    Set-Content -LiteralPath $s9BuildLog -Value "Sprint 9 build started: $(Get-Date -Format o)" -Encoding utf8
    Invoke-CmakeBuild -BuildDirectory $bootBuildDir -Label 'production bootloader S9 profile' -BuildLogPath $s9BuildLog
    $objcopy = Get-Command 'arm-none-eabi-objcopy' -ErrorAction Stop
    & $objcopy.Source -O binary $bootloaderElf $bootloaderBin
    if ($LASTEXITCODE -ne 0) { throw 'S9 production bootloader objcopy failed.' }
    Invoke-S9ApplicationBuild -BuildDirectory $s9App1BuildDir -TargetName 'app_1' -BlinkPeriodMs 500
    Invoke-S9ApplicationBuild -BuildDirectory $s9App2BuildDir -TargetName 'app_2' -BlinkPeriodMs 3000
    $app1Bin = Join-Path $s9App1BuildDir 'app_1.bin'; $app2Bin = Join-Path $s9App2BuildDir 'app_2.bin'
    foreach ($artifact in @($bootloaderBin, $app1Bin, $app2Bin)) { if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) { throw "S9 artifact missing: $artifact" } }
    Copy-Item -LiteralPath $bootloaderBin -Destination $s9SnapshotBootloaderBin -Force
    Copy-Item -LiteralPath $app1Bin -Destination $s9SnapshotApp1Bin -Force
    Copy-Item -LiteralPath $app2Bin -Destination $s9SnapshotApp2Bin -Force
    $app1Payload = [System.IO.File]::ReadAllBytes($s9SnapshotApp1Bin); $app2Payload = [System.IO.File]::ReadAllBytes($s9SnapshotApp2Bin)
    $app1Image = New-S2Header -Payload $app1Payload -Variant valid
    $app1Crc = Get-S2Crc32 $app1Payload; $app2Crc = Get-S2Crc32 $app2Payload
    [System.IO.File]::WriteAllBytes((Join-Path $s9CaseDirectory 'app1_header.bin'), $app1Image.Header)
    [System.IO.File]::WriteAllBytes((Join-Path $s9CaseDirectory 'app1_payload.bin'), $app1Image.Payload)
    [System.IO.File]::WriteAllBytes((Join-Path $s9CaseDirectory 'app1_confirmed_trailer.bin'), (New-S3Trailer -Variant confirmed -ImageCrc32 $app1Crc))
    [System.IO.File]::WriteAllBytes((Join-Path $s9CaseDirectory 'expected_app2_pending_trailer.bin'), (New-S8Trailer @((New-S8TrailerRecord -Sequence 1 -State 1 -ImageCrc32 $app2Crc), (New-S8TrailerRecord -Sequence 2 -State 2 -ImageCrc32 $app2Crc))))
    [System.IO.File]::WriteAllBytes((Join-Path $s9CaseDirectory 'expected_app2_confirmed_trailer.bin'), (New-S8Trailer @((New-S8TrailerRecord -Sequence 1 -State 1 -ImageCrc32 $app2Crc), (New-S8TrailerRecord -Sequence 2 -State 2 -ImageCrc32 $app2Crc), (New-S8TrailerRecord -Sequence 3 -State 3 -ImageCrc32 $app2Crc -Attempts 0 -SwapSector 0xFF), (New-S8TrailerRecord -Sequence 4 -State 3 -ImageCrc32 $app2Crc -Attempts 1 -SwapSector 0xFF), (New-S8TrailerRecord -Sequence 5 -State 4 -ImageCrc32 $app2Crc -Attempts 0 -SwapSector 0xFF))))
    $app1PreservedTrailer = New-Object byte[] 4096
    for ($index = 0; $index -lt $app1PreservedTrailer.Length; ++$index) { $app1PreservedTrailer[$index] = 0xFF }
    [Array]::Copy([byte[]](New-S8TrailerRecord -Sequence 1 -State 4 -ImageCrc32 $app1Crc -Attempts 0 -SwapSector 0xFF), 0, $app1PreservedTrailer, 0, 32)
    [System.IO.File]::WriteAllBytes((Join-Path $s9CaseDirectory 'expected_app1_preserved_trailer.bin'), $app1PreservedTrailer)
    [ordered]@{ schema_version = 1; sprint = 'S9'; profile = 'normal A/B scratch activation'; bootloader_sha256 = (Get-FileHash $s9SnapshotBootloaderBin -Algorithm SHA256).Hash; app_1_sha256 = (Get-FileHash $s9SnapshotApp1Bin -Algorithm SHA256).Hash; app_2_sha256 = (Get-FileHash $s9SnapshotApp2Bin -Algorithm SHA256).Hash; app_1_blink_ms = 500; app_2_blink_ms = 3000; app_1_bytes = $app1Payload.Length; app_2_bytes = $app2Payload.Length; cdc_port = $RecoveryCdcPort } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $autoEvidenceDir 'S09_ARTIFACT_MANIFEST.json') -Encoding utf8
    Invoke-S9Sil
}

function Invoke-S9Python {
    param([string[]]$Arguments, [string]$LogPath)
    $python = Get-Command python -ErrorAction Stop
    $previous = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { $output = @(& $python.Source (Join-Path $repoRoot 'flashing_tool\flashing_app.py') @Arguments 2>&1); $exit = $LASTEXITCODE }
    finally { $ErrorActionPreference = $previous }
    $output | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $LogPath -Encoding utf8
    if ($exit -ne 0) { throw "S9 Python test failed. See $LogPath" }
}

function New-S9CadenceCommands {
    param([switch]$Reset)
    $commands = New-Object System.Collections.Generic.List[string]
    if ($Reset) { $commands.Add('r'); $commands.Add('g') }
    $commands.Add('sleep 175')
    for ($index = 0; $index -lt 8; ++$index) { $commands.Add('mem32 0x58021814, 1'); $commands.Add('sleep 350') }
    return $commands.ToArray()
}

function Invoke-S9FlashAndCapture {
    if (-not $AllowFlash) { throw 'S9 Flash is blocked. Re-run with -AllowFlash.' }
    foreach ($path in @($s9SnapshotBootloaderBin, $s9SnapshotApp1Bin, $s9SnapshotApp2Bin, (Join-Path $s9CaseDirectory 'app1_header.bin'), (Join-Path $s9CaseDirectory 'app1_payload.bin'), (Join-Path $s9CaseDirectory 'app1_confirmed_trailer.bin'))) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S9 artifact missing: $path. Run S9 Build first." } }
    Set-Content -LiteralPath $s9FlashLog -Value "Sprint 9 flash started: $(Get-Date -Format o)" -Encoding utf8
    Set-Content -LiteralPath $s9CaptureLog -Value "Sprint 9 capture started: $(Get-Date -Format o)" -Encoding utf8
    # This is the fixture only: app_1 is directly provisioned as an already
    # CONFIRMED A image.  app_2 is never written by J-Link and reaches Primary
    # exclusively via USB Secondary download followed by the bootloader swap.
    Invoke-JLinkCommands -Commands @("loadbin $s9SnapshotBootloaderBin, 0x08000000", 'erase 0x08020000, 0x0807FFFF', 'erase 0x08080000, 0x080DFFFF', 'erase 0x080E0000, 0x080FFFFF', "loadbin $(Join-Path $s9CaseDirectory 'app1_header.bin'), 0x08020000", "loadbin $(Join-Path $s9CaseDirectory 'app1_payload.bin'), 0x08020200", "loadbin $(Join-Path $s9CaseDirectory 'app1_confirmed_trailer.bin'), 0x0807F000", 'r', 'g', 'exit') -LogPath $s9FlashLog -Append
    Add-Content -LiteralPath $s9CaptureLog -Value "`n===== APP1 baseline_500ms ====="
    $app1Cadence = @(New-S9CadenceCommands -Reset)
    Invoke-JLinkCommands -Commands @($app1Cadence + @('h', "savebin $s9PrimaryBefore, 0x08020000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit')) -LogPath $s9CaptureLog -Append
    Start-Sleep -Milliseconds 1000
    Invoke-S9Python -Arguments @('--request-update', $RecoveryCdcPort) -LogPath $s9RequestLog
    Start-Sleep -Milliseconds 1500
    Invoke-S9Python -Arguments @('--secondary-download-test', $RecoveryCdcPort, $s9SnapshotApp2Bin) -LogPath $s9DownloadLog
    Add-Content -LiteralPath $s9CaptureLog -Value "`n===== APP2 secondary_pending_before_swap ====="
    Invoke-JLinkCommands -Commands @('h', "savebin $s9PrimaryPending, 0x08020000, 0x00060000", "savebin $s9SecondaryPending, 0x08080000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit') -LogPath $s9CaptureLog -Append
    Add-Content -LiteralPath $s9CaptureLog -Value "`n===== APP2 activation_swap_and_confirmation ====="
    # A normal swap performs nine full sector erase/program copies (A->scratch,
    # B->Primary, scratch->Secondary).  Do not interrupt it with J-Link.
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 45000', 'h', "savebin $s9PrimaryActivated, 0x08020000, 0x00060000", "savebin $s9SecondaryActivated, 0x08080000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit') -LogPath $s9CaptureLog -Append
    Invoke-S9CaptureAfterActivation
}

function Invoke-S9CaptureAfterActivation {
    foreach ($path in @($s9PrimaryBefore, $s9PrimaryPending, $s9SecondaryPending, $s9PrimaryActivated, $s9SecondaryActivated)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S9 capture evidence missing: $path. Run S9 Flash first." } }
    Add-Content -LiteralPath $s9CaptureLog -Value "`n===== APP2 cadence_3000ms ====="
    $app2Cadence = @(New-S9CadenceCommands)
    Invoke-JLinkCommands -Commands @($app2Cadence + @('h', 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit')) -LogPath $s9CaptureLog -Append
    Add-Content -LiteralPath $s9CaptureLog -Value "`n===== APP2 confirmed_second_reset ====="
    Invoke-JLinkCommands -Commands @('r', 'g', 'sleep 1000', 'h', "savebin $s9PrimaryStable, 0x08020000, 0x00060000", "savebin $s9SecondaryStable, 0x08080000, 0x00060000", 'regs', 'mem32 0xE000ED08, 1', 'mem32 0xE000ED28, 5', 'g', 'exit') -LogPath $s9CaptureLog -Append
}

function Get-S9Cadence {
    param([string]$Section)
    $samples = @([regex]::Matches($Section, '(?m)^58021814 = ([0-9A-F]{8})') | ForEach-Object { ([Convert]::ToUInt32($_.Groups[1].Value, 16) -band 0x80) -ne 0 })
    $transitions = 0
    for ($index = 1; $index -lt $samples.Count; ++$index) { if ($samples[$index] -ne $samples[$index - 1]) { ++$transitions } }
    return [PSCustomObject]@{ Samples = $samples.Count; Transitions = $transitions }
}

function Save-S9Report {
    $silPass = (Test-Path -LiteralPath $s9SilLog) -and ((Get-Content -LiteralPath $s9SilLog -Raw) -match '100% tests passed, 0 tests failed out of 1')
    $request = $null; $download = $null; try { $request = Get-Content -LiteralPath $s9RequestLog -Raw | ConvertFrom-Json; $download = Get-Content -LiteralPath $s9DownloadLog -Raw | ConvertFrom-Json } catch { }
    $requestPass = ($null -ne $request) -and [bool]$request.passed; $downloadPass = ($null -ne $download) -and [bool]$download.passed
    $capture = Get-Content -LiteralPath $s9CaptureLog -Raw; $sections = [regex]::Split($capture, '(?m)^===== ')
    $app1Section = $sections | Where-Object { $_.StartsWith('APP1 baseline_500ms =====') } | Select-Object -First 1; $activation = $sections | Where-Object { $_.StartsWith('APP2 activation_swap_and_confirmation =====') } | Select-Object -First 1; $app2Section = $sections | Where-Object { $_.StartsWith('APP2 cadence_3000ms =====') } | Select-Object -Last 1; $stable = $sections | Where-Object { $_.StartsWith('APP2 confirmed_second_reset =====') } | Select-Object -Last 1
    function Get-S9RunState([string]$Section) {
        $pc = [regex]::Match($Section, '(?m)^PC = ([0-9A-F]{8}),'); $vtor = [regex]::Match($Section, '(?m)^E000ED08 = ([0-9A-F]{8})'); $fault = [regex]::Match($Section, '(?m)^E000ED28 = ([0-9A-F]{8})\s+([0-9A-F]{8})')
        $pcValue = if ($pc.Success) { [Convert]::ToUInt32($pc.Groups[1].Value, 16) } else { 0 }; $vtorValue = if ($vtor.Success) { [Convert]::ToUInt32($vtor.Groups[1].Value, 16) } else { 0 }
        [PSCustomObject]@{ Pass = ($pcValue -ge 0x08020200 -and $pcValue -lt 0x08080000 -and $vtorValue -eq 0x08020200 -and $fault.Success -and $fault.Groups[1].Value -eq '00000000' -and $fault.Groups[2].Value -eq '00000000'); PC = $pcValue; VTOR = $vtorValue }
    }
    $activationRun = Get-S9RunState $activation; $stableRun = Get-S9RunState $stable; $app1Cadence = Get-S9Cadence $app1Section; $app2Cadence = Get-S9Cadence $app2Section
    $app1Before = [System.IO.File]::ReadAllBytes($s9PrimaryBefore); $primaryPending = [System.IO.File]::ReadAllBytes($s9PrimaryPending); $app2Pending = [System.IO.File]::ReadAllBytes($s9SecondaryPending); $primary = [System.IO.File]::ReadAllBytes($s9PrimaryActivated); $secondary = [System.IO.File]::ReadAllBytes($s9SecondaryActivated); $primaryStable = [System.IO.File]::ReadAllBytes($s9PrimaryStable); $secondaryStable = [System.IO.File]::ReadAllBytes($s9SecondaryStable); $app1Payload = [System.IO.File]::ReadAllBytes($s9SnapshotApp1Bin); $app2Payload = [System.IO.File]::ReadAllBytes($s9SnapshotApp2Bin)
    $distinctImages = (Get-FileHash -LiteralPath $s9SnapshotApp1Bin -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $s9SnapshotApp2Bin -Algorithm SHA256).Hash
    $primaryUnchangedDuringDownload = Test-S8Bytes $app1Before 0 $primaryPending 0 0x60000
    $pendingTrailer = Test-S8Bytes $app2Pending 0x5F000 ([System.IO.File]::ReadAllBytes((Join-Path $s9CaseDirectory 'expected_app2_pending_trailer.bin'))) 0 0x1000
    $app2MovedToPrimary = Test-S8Bytes $app2Pending 0 $primary 0 0x5F000; $app1MovedToSecondary = Test-S8Bytes $app1Before 0 $secondary 0 0x5F000
    $primaryTrailer = Test-S8Bytes $primary 0x5F000 ([System.IO.File]::ReadAllBytes((Join-Path $s9CaseDirectory 'expected_app2_confirmed_trailer.bin'))) 0 0x1000
    $secondaryTrailer = Test-S8Bytes $secondary 0x5F000 ([System.IO.File]::ReadAllBytes((Join-Path $s9CaseDirectory 'expected_app1_preserved_trailer.bin'))) 0 0x1000
    $stableSlots = (Test-S8Bytes $primary 0 $primaryStable 0 0x60000) -and (Test-S8Bytes $secondary 0 $secondaryStable 0 0x60000)
    $cadencePass = $app1Cadence.Samples -eq 8 -and $app1Cadence.Transitions -ge 3 -and $app2Cadence.Samples -eq 8 -and $app2Cadence.Transitions -le 2
    $noDirectApp2Load = -not ((Get-Content -LiteralPath $s9FlashLog -Raw) -match [regex]::Escape((Split-Path -Leaf $s9SnapshotApp2Bin)))
    $passed = $silPass -and $distinctImages -and $requestPass -and $downloadPass -and $primaryUnchangedDuringDownload -and $pendingTrailer -and $app2MovedToPrimary -and $app1MovedToSecondary -and $primaryTrailer -and $secondaryTrailer -and $activationRun.Pass -and $stableRun.Pass -and $cadencePass -and $stableSlots -and $noDirectApp2Load
    $rows = @('# Sprint 9 test report', '', "**HIL decision: $(if ($passed) {'PASS'} else {'FAIL'})**", '', 'S9 proves normal non-power-fail-safe A/B activation. app_1 (PG7 500 ms) is the confirmed A fixture. app_2 (PG7 3000 ms) is downloaded only to Secondary over USB CDC, swaps through Scratch, and confirms as the new Primary image.', '', '## Results', '', "- SIL regression suite: **$silPass**", "- app_1/app_2 payload SHA-256 differ: **$distinctImages**", "- app_1 accepted ENTER_UPDATE: **$requestPass**", "- USB CDC app_2 download finalized PENDING: **$downloadPass**", "- Primary app_1 remained byte-identical during download: **$primaryUnchangedDuringDownload**", "- app_2 Secondary journal is DOWNLOADED -> PENDING: **$pendingTrailer**", "- Scratch swap placed app_2 image in Primary: **$app2MovedToPrimary**", "- Scratch swap preserved app_1 image in Secondary: **$app1MovedToSecondary**", "- Primary app_2 journal is DOWNLOADED -> PENDING -> TEST(0) -> TEST(1) -> CONFIRMED: **$primaryTrailer**", "- Secondary app_1 remains CONFIRMED: **$secondaryTrailer**", ('- Activation reaches Primary app_2: PC `0x{0:X8}`, VTOR `0x{1:X8}`: **{2}**' -f $activationRun.PC, $activationRun.VTOR, $activationRun.Pass), ('- Confirmed reset stays in Primary app_2: PC `0x{0:X8}`, VTOR `0x{1:X8}`: **{2}**' -f $stableRun.PC, $stableRun.VTOR, $stableRun.Pass), "- PG7 cadence samples: app_1 500 ms transitions=$($app1Cadence.Transitions)/$($app1Cadence.Samples), app_2 3000 ms transitions=$($app2Cadence.Transitions)/$($app2Cadence.Samples): **$cadencePass**", "- No slot mutation after confirmed reset: **$stableSlots**", "- J-Link provisioning log contains no direct app_2 load: **$noDirectApp2Load**", '', '## Scope boundary', '', 'This sprint does not claim recovery from power loss during the nine-copy swap. That remains Sprint 11.', '', '## Evidence', '', '- `S09_build.log`, `S09_sil.log`, `S09_ARTIFACT_MANIFEST.json`', '- `S09_flash_ab_activation.log`, `S09_jlink_ab_activation.log`', '- `S09_request_update.json`, `S09_download_app2.json`', '- `S09_primary_app1_before_update.bin`, `S09_secondary_app2_pending.bin`', '- `S09_primary_app2_confirmed.bin`, `S09_secondary_app1_preserved.bin`', '- `S09_primary_after_confirmed_reset.bin`, `S09_secondary_after_confirmed_reset.bin`')
    Set-Content -LiteralPath $s9TestReport -Value $rows -Encoding utf8
    if (-not $passed) { throw "S9 HIL acceptance failed. See $s9TestReport" }
}

function Save-S9RunSummary {
    $rows = @('# Sprint 9 run summary', '', "- Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')", "- Requested operation: $Operation", "- CDC port: $RecoveryCdcPort", '- Profile: app_1 500 ms CONFIRMED -> app_2 3000 ms Secondary PENDING -> scratch swap -> app_2 CONFIRMED', '', '## Outputs', '')
    foreach ($path in @($s9BuildLog, $s9SilLog, $s9FlashLog, $s9CaptureLog, $s9RequestLog, $s9DownloadLog, $s9PrimaryBefore, $s9PrimaryPending, $s9SecondaryPending, $s9PrimaryActivated, $s9SecondaryActivated, $s9PrimaryStable, $s9SecondaryStable, $s9TestReport, (Join-Path $autoEvidenceDir 'S09_ARTIFACT_MANIFEST.json'))) { if (Test-Path -LiteralPath $path -PathType Leaf) { $rows += "- $(Split-Path -Leaf $path)" } }
    Set-Content -LiteralPath $s9RunSummary -Value $rows -Encoding utf8
}

New-Item -ItemType Directory -Path $autoEvidenceDir, $userEvidenceDir -Force | Out-Null

$requiresFlash = $Operation -in @('Flash', 'All', 'Restore')
if ($requiresFlash -and -not $AllowFlash) {
    throw "-Operation $Operation writes target Flash for $Scope. Add -AllowFlash to authorize it."
}
if (($Operation -eq 'Restore') -and ($Scope -notin @('S2', 'S5'))) {
    throw '-Operation Restore is currently defined only for Scope S2 and S5.'
}

if ($Scope -eq 'S0') {
    switch ($Operation) {
        'Build' {
            Invoke-Build
        }
        'Flash' {
            Invoke-BaselineFlash
        }
        'Capture' {
            Invoke-Capture
        }
        'All' {
            Invoke-Build
            Invoke-BaselineFlash
            Invoke-Capture
        }
    }
    Save-RunSummary
    Write-Host "Sprint 0 operation complete. Summary: $runSummary"
}
elseif ($Scope -eq 'S1') {
    switch ($Operation) {
        'Build' {
            Invoke-S1Build
        }
        'Flash' {
            Invoke-S1Flash
        }
        'Capture' {
            Invoke-S1CaptureAndEvaluate
        }
        'All' {
            Invoke-S1Build
            Invoke-S1Flash
            Invoke-S1CaptureAndEvaluate
        }
    }
    Save-S1RunSummary
    Write-Host "Sprint 1 operation complete. Summary: $s1RunSummary"
}
elseif ($Scope -eq 'S2') {
    switch ($Operation) {
        'Build' {
            Invoke-S2Build
        }
        'Flash' {
            Invoke-S2FlashAndCapture
            Save-S2Report
        }
        'Capture' {
            throw 'S2 Capture cannot run without reprovisioning an explicit case. Use -Operation All -AllowFlash.'
        }
        'Restore' {
            if (-not $AllowFlash) { throw 'S2 Restore is blocked. Re-run with -AllowFlash.' }
            $validHeader = Join-Path $s2CaseDirectory 'valid_header.bin'
            $validPayload = Join-Path $s2CaseDirectory 'valid_payload.bin'
            foreach ($path in @($s2SnapshotBootloaderBin, $validHeader, $validPayload)) {
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "S2 restore artifact missing: $path. Run S2 Build first." }
            }
            Invoke-JLinkCommands -Commands @(
                "loadbin $s2SnapshotBootloaderBin, 0x08000000",
                "loadbin $validHeader, 0x08020000",
                "loadbin $validPayload, 0x08020200",
                'r', 'g', 'exit'
            ) -LogPath $s2FlashLog
        }
        'All' {
            Invoke-S2Build
            Invoke-S2FlashAndCapture
            Save-S2Report
        }
    }
    Save-S2RunSummary
    Write-Host "Sprint 2 operation complete. Summary: $s2RunSummary"
}
elseif ($Scope -eq 'S3') {
    switch ($Operation) {
        'Build' { Invoke-S3Build }
        'Flash' {
            Invoke-S3FlashAndCapture
            Save-S3Report
        }
        'Capture' { throw 'S3 Capture is coupled to explicit trailer provisioning. Use -Operation All -AllowFlash.' }
        'All' {
            Invoke-S3Build
            Invoke-S3FlashAndCapture
            Save-S3Report
        }
        'Restore' { throw '-Operation Restore is not defined for S3; S3 Flash restores the confirmed package automatically.' }
    }
    Save-S3RunSummary
    Write-Host "Sprint 3 operation complete. Summary: $s3RunSummary"
}
elseif ($Scope -eq 'S4') {
    switch ($Operation) {
        'Build' { Invoke-S4Build }
        'Flash' {
            Invoke-S4FlashAndCapture
            Save-S4Report
        }
        'Capture' { throw 'S4 Capture is coupled to TEST trailer provisioning. Use -Operation All -AllowFlash.' }
        'All' {
            Invoke-S4Build
            Invoke-S4FlashAndCapture
            Save-S4Report
        }
        'Restore' { throw '-Operation Restore is not defined for S4; S4 Flash restores the confirmed package automatically.' }
    }
    Save-S4RunSummary
    Write-Host "Sprint 4 operation complete. Summary: $s4RunSummary"
}
elseif ($Scope -eq 'S5') {
    switch ($Operation) {
        'Build' { Invoke-S5Build }
        'Flash' {
            Invoke-S5FlashAndCapture
            Save-S5Report
        }
        'Capture' { throw 'S5 Capture is coupled to explicit invalid-image provisioning. Use -Operation All -AllowFlash.' }
        'All' {
            Invoke-S5Build
            Invoke-S5FlashAndCapture
            Save-S5Report
        }
        'Restore' {
            Invoke-S5Restore
            Save-S5Report
        }
    }
    Save-S5RunSummary
    Write-Host "Sprint 5 operation complete. Summary: $s5RunSummary"
}
elseif ($Scope -eq 'S6') {
    switch ($Operation) {
        'Build' { Invoke-S6Build }
        'Flash' {
            Invoke-S6FlashAndCapture
            Save-S6Report
        }
        'Capture' { throw 'S6 Capture is coupled to recovery provisioning. Use -Operation All -AllowFlash.' }
        'All' {
            Invoke-S6Build
            Invoke-S6FlashAndCapture
            Save-S6Report
        }
        'Restore' { throw '-Operation Restore is not defined for S6; S6 Flash restores the confirmed package automatically.' }
    }
    Save-S6RunSummary
    Write-Host "Sprint 6 operation complete. Summary: $s6RunSummary"
}
elseif ($Scope -eq 'S7') {
    switch ($Operation) {
        'Build' { Invoke-S7Build }
        'Flash' {
            Invoke-S7FlashAndCapture
            Save-S7Report
        }
        'Capture' { throw 'S7 Capture is coupled to provisioning and USB download. Use -Operation All -AllowFlash.' }
        'All' {
            Invoke-S7Build
            Invoke-S7FlashAndCapture
            Save-S7Report
        }
        'Restore' { throw '-Operation Restore is not defined for S7; S7 Flash restores the confirmed package automatically.' }
    }
    Save-S7RunSummary
    Write-Host "Sprint 7 operation complete. Summary: $s7RunSummary"
}
elseif ($Scope -eq 'S8') {
    switch ($Operation) {
        'Build' { Invoke-S8Build }
        'Flash' {
            Invoke-S8FlashAndCapture
            Save-S8Report
        }
        'Capture' { throw 'S8 Capture is coupled to empty-Primary provisioning and USB download. Use -Operation All -AllowFlash.' }
        'All' {
            Invoke-S8Build
            Invoke-S8FlashAndCapture
            Save-S8Report
        }
        'Restore' { throw '-Operation Restore is not defined for S8; S8 ends in its confirmed first-installed image.' }
    }
    Save-S8RunSummary
    Write-Host "Sprint 8 operation complete. Summary: $s8RunSummary"
}
else {
    switch ($Operation) {
        'Build' { Invoke-S9Build }
        'Flash' {
            Invoke-S9FlashAndCapture
            Save-S9Report
        }
        'Capture' {
            Invoke-S9CaptureAfterActivation
            Save-S9Report
        }
        'All' {
            Invoke-S9Build
            Invoke-S9FlashAndCapture
            Save-S9Report
        }
        'Restore' { throw '-Operation Restore is not defined for S9; S9 ends in confirmed app_2 with app_1 preserved in Secondary.' }
    }
    Save-S9RunSummary
    Write-Host "Sprint 9 operation complete. Summary: $s9RunSummary"
}
