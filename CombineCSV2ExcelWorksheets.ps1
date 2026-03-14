# Define the directory containing the CSV files
$csvFolder = "/Users/john/Library/CloudStorage/OneDrive-DennyCherry&AssociatesConsulting/Hexagon/DiagnosticQueries/DiagnosticQueries-empty/DiagnosticQueries/"

# Import the ImportExcel module (if not already imported)
Import-Module ImportExcel

# Get all the CSV files from the source folder, select the name, fullname, basename, and then add an order column and sort by it
$csvFiles = get-childitem $csvFolder -Filter "*.csv" | select-object name, fullname, basename, @{l='order';e={[int]$_.name.split('-')[4]}} | sort-object order 

# Define exportexcel parameters. Note- MoveToEnd switch & others will affect outcome ie: could produce an error. 
$ExportExcelParams = @{
    Path =  '/Users/john/Desktop/Hexagon/empty.xlsx' 
    AutoFilter =  $true
    #MoveToEnd =  $true
    FreezeTopRow = $true
}

# Loop through each CSV file and add it as a worksheet
foreach ($csvFile in $csvFiles) {
    # Import the CSV data
    $csvData = Import-Csv -Path $csvFile.FullName

    # Generate the worksheet name based on the elements in the file name
    $sheetName = ($csvFile.BaseName -split "-") #[16,17] -join "-"  # Use the file name (without extension) as the sheet name
    $indexofDQ = $sheetName.IndexOf("DQ")
    $sheetName = $sheetName[$indexofDQ+1], $sheetName[$indexofDQ+2] -join "-"
    write-host  $sheetName

    # write host name
    Write-Host "Processing file: $($csvFile.Name) with sheet name: $sheetName"
    # Ensure the worksheet name is not longer than 31 characters
    if ($sheetName.Length -gt 30) {
        $sheetName = $sheetName.Substring(0, 30)
    }
    # Send the CSV data to export-excel and create the new worksheet.  Also, worksheet names longer than 31 characters could throw an error
    $csvData | Export-Excel @ExportExcelParams -WorksheetName $sheetname 
    
    # slow the machine down
    start-sleep -seconds 1
}

# Write out the message
Write-Host "CSV files have been successfully merged into: $outputPath"