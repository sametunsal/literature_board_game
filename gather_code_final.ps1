$target = "C:\Users\samet\.gemini\antigravity\brain\0e123fb7-7efc-484d-8b45-90be15ff1338\project_codebase.md"
$tick = [char]96
$codeFence = "$tick$tick$tick" + "dart"
$endFence = "$tick$tick$tick"

$files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart"
foreach ($file in $files) {
    $relativePath = $file.FullName.Substring((Get-Location).Path.Length + 1)
    Add-Content -Path $target -Value ""
    Add-Content -Path $target -Value "## $relativePath"
    Add-Content -Path $target -Value $codeFence
    Get-Content $file.FullName | Add-Content -Path $target
    Add-Content -Path $target -Value $endFence
}
Write-Host "Success"
