


$dir = "C:\users\john\Desktop\Temp\"

$files = Get-ChildItem $dir -Recurse -Include "*.log"

foreach ($file in $files){
    $out = "ERR_" + $file.BaseName + ".txt"
    select-string -path $file.FullName -Pattern " ERR " -AllMatches | out-file "$dir\$out"
}