[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$config = Get-Content "app_config.json" -Encoding UTF8 | ConvertFrom-Json

$appName = $config.APP_NAME
$appIcon = $config.APP_ICON
$apkName = $config.APK_NAME

Write-Host "========================================"
Write-Host "  App Name: $appName"
Write-Host "  Icon: $appIcon"
Write-Host "  APK Name: $apkName"
Write-Host "========================================"

if (Test-Path $appIcon) {
    Write-Host "Updating icons..."
    $resDir = "android/app/src/main/res"
    $dirs = @(
        "$resDir/mipmap-mdpi",
        "$resDir/mipmap-hdpi",
        "$resDir/mipmap-xhdpi",
        "$resDir/mipmap-xxhdpi",
        "$resDir/mipmap-xxxhdpi"
    )
    foreach ($d in $dirs) {
        Copy-Item $appIcon (Join-Path $d "ic_launcher.png") -Force
    }
    Write-Host "Icons updated."
}
else {
    Write-Host "WARNING: Icon file $appIcon not found, skipping."
}

$manifestPath = "android/app/src/main/AndroidManifest.xml"
$content = [System.IO.File]::ReadAllText((Resolve-Path $manifestPath))
$dq = [char]34
$pattern = 'android:label=' + $dq + '[^' + $dq + ']*' + $dq
$replacement = 'android:label=' + $dq + $appName + $dq
$content = [regex]::Replace($content, $pattern, $replacement)
[System.IO.File]::WriteAllText((Resolve-Path $manifestPath), $content)
Write-Host "Manifest label updated: $appName"

$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"

Write-Host "Building APK (split-per-abi)..."
fvm flutter build apk --debug --split-per-abi --dart-define="APP_NAME=$appName"

$outputDir = "build/app/outputs/flutter-apk"
$abiMap = @{
    "arm64-v8a" = "app-arm64-v8a-debug.apk"
    "armeabi-v7a" = "app-armeabi-v7a-debug.apk"
    "x86_64" = "app-x86_64-debug.apk"
}

$found = $false
foreach ($abi in $abiMap.Keys) {
    $apkPath = Join-Path $outputDir $abiMap[$abi]
    if (Test-Path $apkPath) {
        $finalApk = Join-Path $outputDir "$apkName-$abi.apk"
        Copy-Item $apkPath $finalApk -Force
        $size = [math]::Round((Get-Item $finalApk).Length / 1MB, 1)
        Write-Host "  $abi : $finalApk (${size}MB)"
        $found = $true
    }
}

if ($found) {
    Write-Host "========================================"
    Write-Host "  Build SUCCESS"
    Write-Host "  APK dir: $outputDir"
    Write-Host "  Huawei tablet -> $apkName-arm64-v8a.apk"
    Write-Host "========================================"
}
else {
    Write-Host "Build FAILED"
}
