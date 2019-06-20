



#sum of most recent full backup files
$srvs = @("server1","server2","server3")
foreach ($srv in $srvs){
    $path = "D:\backups\$($srv)"
    $x = gci -path $path -Recurse | where-object {($_.extension -eq ".bak") -and ($_.lastWriteTime -gt (get-date).AddDays(-1))}
    [long]$amt +=($x | measure-object -sum length).sum | out-string
}

$amt