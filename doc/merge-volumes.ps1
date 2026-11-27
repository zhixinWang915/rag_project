# 把 doc/设备手册汇总.zip.001 ~ .004 合并回完整的 zip
#
# Windows PowerShell:
#   pwsh -File doc/merge-volumes.ps1
#   或一行命令: cmd /c copy /b 设备手册汇总.zip.001+设备手册汇总.zip.002+设备手册汇总.zip.003+设备手册汇总.zip.004 设备手册汇总.zip
#
# Linux / macOS:
#   cd doc && cat 设备手册汇总.zip.00{1,2,3,4} > 设备手册汇总.zip
#
# 合并后完整文件 SHA256:
#   DC7D59DD957767CF5C7C46F08B6FFA9D6ED40A5EAFAF4C2E314DB619EAC7EC4E

param(
    [string]$Directory = $PSScriptRoot,
    [string]$BaseName  = '设备手册汇总.zip'
)

$output = Join-Path $Directory $BaseName
if (Test-Path -LiteralPath $output) {
    Write-Host "已存在 $output，先删除或改名后再运行。" -ForegroundColor Yellow
    exit 1
}

$parts = Get-ChildItem -LiteralPath $Directory -Filter "$BaseName.0*" | Sort-Object Name
if ($parts.Count -eq 0) {
    Write-Host "在 $Directory 下没找到 $BaseName.0xx 分卷。" -ForegroundColor Red
    exit 1
}

$stream = [System.IO.File]::Create($output)
try {
    foreach ($part in $parts) {
        $bytes = [System.IO.File]::ReadAllBytes($part.FullName)
        $stream.Write($bytes, 0, $bytes.Length)
        Write-Host ("+ {0} ({1:N2} MB)" -f $part.Name, ($bytes.Length / 1MB))
    }
}
finally {
    $stream.Dispose()
}

$hash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
Write-Host ("合并完成: {0}" -f $output) -ForegroundColor Green
Write-Host ("SHA256 : {0}" -f $hash)
