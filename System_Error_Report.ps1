$StartTime = (Get-Date).AddDays(-1)
$EndTime = Get-Date

$Events = Get-WinEvent -FilterHashtable @{Logname='System'; Level=2; StartTime=$StartTime; EndTime=$EndTime} -ErrorAction SilentlyContinue

$ErrorCounts = @{}
$SystemCounts = @{}

foreach ($Event in $Events) {
    $Message = $Event.Message
    $ErrorCounts[$Message] += 1
    $ComputerName = $Event.MachineName
    $SystemCounts[$Message][$ComputerName] = $true
}

$SortedErrors = $ErrorCounts.GetEnumerator() | Sort-Object -Property Value -Descending
$SortedSystems = $SystemCounts.GetEnumerator() | Sort-Object -Property { $_.Value.Count } -Descending

$Report = "Most Common Errors:`n`n"

foreach ($Error in $SortedErrors) {
    $Report += "$($Error.Value) occurrences - $($Error.Name)`n"
}

$Report += "`nErrors Occurring on Most Systems:`n`n"

foreach ($System in $SortedSystems) {
    $Error = $System.Name
    $Count = $System.Value.Count
    $Report += "$Count systems - $Error`n"
}

Write-Output $Report
