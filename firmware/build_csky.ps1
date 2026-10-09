param([string]$ToolchainRoot = '', [switch]$IncludeIntegrationCandidate, [switch]$IncludeScanCandidate, [switch]$IncludePickerEntryFix, [switch]$IncludeScanZoneTest, [switch]$IncludeScanZonePolish, [switch]$IncludeScanSourceFix, [switch]$IncludeScanTickFix)
$ErrorActionPreference = 'Stop'
$buildDirectory = Join-Path $PSScriptRoot 'build'
if ($IncludeScanTickFix) { $IncludeScanSourceFix = $true }
if ($IncludeScanSourceFix) { $IncludeScanZonePolish = $true }
if ($IncludeScanZonePolish) { $IncludeScanZoneTest = $true }
if ($IncludeScanZoneTest) { $IncludeScanCandidate = $true }
if ($IncludePickerEntryFix) {
    if ($IncludeScanCandidate) { throw 'Picker entry fix must be built separately from scanner.' }
    $IncludeIntegrationCandidate = $true
    $buildDirectory = Join-Path $buildDirectory 'picker_entry_fix'
} elseif ($IncludeScanCandidate) {
    $IncludeIntegrationCandidate = $true
    $buildDirectory = Join-Path $buildDirectory $(if ($IncludeScanTickFix) {'scan_tick_fix'} elseif ($IncludeScanSourceFix) {'scan_source_fix'} elseif ($IncludeScanZonePolish) {'scan_zone_polish'} elseif ($IncludeScanZoneTest) {'scan_zone_test'} else {'scan_candidate'})
} elseif ($IncludeIntegrationCandidate) { $buildDirectory = Join-Path $buildDirectory 'integration_candidate' }
New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null
$logPath = Join-Path $buildDirectory ('build_'+[DateTime]::UtcNow.ToString('yyyyMMdd_HHmmss')+'_UTC.log.txt')
Start-Transcript -LiteralPath $logPath | Out-Null
try {
if (!$ToolchainRoot -and $env:DM32_CSKY_TOOLCHAIN) { $ToolchainRoot = $env:DM32_CSKY_TOOLCHAIN }
if (!$ToolchainRoot) {
    $localCandidate = Join-Path $PSScriptRoot 'tools\csky-elfabiv2-tools-mingw-minilibc-20210423'
    if (Test-Path -LiteralPath $localCandidate) { $ToolchainRoot = $localCandidate }
    else { throw 'Set DM32_CSKY_TOOLCHAIN or pass -ToolchainRoot to the installed T-HEAD C-SKY tools.' }
}
$ToolchainRoot = (Resolve-Path -LiteralPath $ToolchainRoot).Path
$compiler = Join-Path $ToolchainRoot 'bin\csky-elfabiv2-gcc.exe'
$objdump = Join-Path $ToolchainRoot 'bin\csky-elfabiv2-objdump.exe'
$linker = Join-Path $ToolchainRoot 'bin\csky-elfabiv2-ld.exe'
$objcopy = Join-Path $ToolchainRoot 'bin\csky-elfabiv2-objcopy.exe'
# Only standalone objects are produced. There are no firmware hooks or output .bin here.
& $compiler --version
if ($LASTEXITCODE -ne 0) { throw 'C-SKY compiler is unavailable' }
$objects=@()
$modules=@('mod_core','codeplug_reader','firmware_zone_bridge')
if ($IncludeIntegrationCandidate) { $modules += @('runtime_state','menu_tables','menu_filter','zone_picker','zone_picker_ui','zone_picker_routing') }
if ($IncludeScanCandidate) { $modules += @('scan_prepare','scan_start_bridge','scan_step_bridge','scan_start_tail') }
foreach ($module in $modules) {
    $inputFile = Join-Path $PSScriptRoot "source\$module.c"
    if ($module -eq 'scan_start_tail') { $inputFile = Join-Path $PSScriptRoot 'source\scan_start_tail.S' }
    $objectFile = Join-Path $buildDirectory "$module.o"
    $moduleDefines=@()
    if ($IncludeScanCandidate) { $moduleDefines += '-DDM32_SCANNER_INTEGRATION' }
    & $compiler '-mcpu=ck803' '-Os' '-ffreestanding' '-fno-builtin' '-fno-stack-protector' '-ffunction-sections' '-fdata-sections' '-Wall' '-Wextra' '-Werror' @moduleDefines '-c' $inputFile '-o' $objectFile
    if ($LASTEXITCODE -ne 0) { throw "Compilation failed: $module" }
    & $objdump '-dr' $objectFile | Set-Content -LiteralPath (Join-Path $buildDirectory "$module.asm")
    if ($LASTEXITCODE -ne 0) { throw "Disassembly failed: $module" }
    & $objdump '-f' $objectFile | Set-Content -LiteralPath (Join-Path $buildDirectory "$module.elf-info.txt")
    if ($LASTEXITCODE -ne 0) { throw "ELF inspection failed: $module" }
    $objects+=$objectFile
}
$linkerScript=Join-Path $PSScriptRoot 'source\staging_module.ld'
$elf=Join-Path $buildDirectory 'staging_module.elf'
$map=Join-Path $buildDirectory 'staging_module.map'
& $linker '-T' $linkerScript '-Map' $map '--no-undefined' '-o' $elf @objects
if($LASTEXITCODE -ne 0) { throw 'Module linking failed' }
& $objcopy '-O' 'binary' $elf (Join-Path $buildDirectory 'staging_module.raw')
if($LASTEXITCODE -ne 0) { throw 'Module extraction failed' }
& $objdump '-dr' $elf | Set-Content -LiteralPath (Join-Path $buildDirectory 'staging_module.asm')
if($LASTEXITCODE -ne 0) { throw 'Linked module inspection failed' }
Write-Host 'BUILD COMPLETE. Objects and assembly are in the build folder.'
Write-Host 'A standalone staging_module.raw was generated. It is NOT a complete radio firmware.'
Write-Host 'No original firmware was changed and no radio connection was opened.'
if ($IncludeIntegrationCandidate) { Write-Host 'Runtime and menu candidates included; stock heap reservation, boot hook and menu hooks are NOT applied.' }
if ($IncludeScanCandidate) { Write-Host 'Experimental scan start/step drafts included; no scanner hooks or firmware changes are applied.' }
} catch {
    Write-Host ('BUILD FAILED: '+$_.Exception.Message)
    throw
} finally {
    Stop-Transcript | Out-Null
    Write-Host "Build log: $logPath"
}


