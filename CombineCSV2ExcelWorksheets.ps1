# Define the directory containing the CSV files
$csvFolder = "/Users/folder1/folder2/folder3/"

# Import the ImportExcel module (if not already imported)
Import-Module ImportExcel

# Get all the CSV files from the source folder, select the name, fullname, basename, and then add an order column and sort by it
$csvFiles = get-childitem $csvFolder -Filter "*blah-blah*.csv" | select-object name, fullname, basename, @{l='order';e={[int]$_.name.split('-')[4]}} | sort-object order 

# Define exportexcel parameters. Note- MoveToEnd switch & others will affect outcome ie: could produce an error. 
$ExportExcelParams = @{
    Path =  '/Users/folder1/folder2/folder3/SomeFileNameHere.xlsx' 
    AutoFilter =  $true
    #MoveToEnd =  $true
    FreezeTopRow = $true
}

# Loop through each CSV file and add it as a worksheet
foreach ($csvFile in $csvFiles) {
    # Import the CSV data
    $csvData = Import-Csv -Path $csvFile.FullName

    # Generate the worksheet name based on the elements in the file name
    $sheetName = ($csvFile.BaseName -split "-")[4,5] -join "-"  # Use the file name (without extension) as the sheet name
    
    # Send the CSV data to export-excel and create the new worksheet.  Also, worksheet names longer than 31 characters could throw an error
    $csvData | Export-Excel @ExportExcelParams -WorksheetName $sheetname 
    
    # slow the machine down
    start-sleep -seconds 1
}

# Write out the message
Write-Host "CSV files have been successfully merged into: $outputPath"
