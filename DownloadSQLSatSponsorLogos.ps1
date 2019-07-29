##########################################################################################
#- Author: John Morehouse
# Date: July 2019
# T: @SQLRUS
# E: john@jmorehouse.com
# B: http://sqlrus.com
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY 
# AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
# IN OTHER WORDS: USE AT YOUR OWN RISK.
#
# AUTHOR ASSUMES ZERO LIABILITY OR RESPONSIBILITY.
#
# You may alter this code for your own purposes.
# You may republish altered code as long as you give due credit.
##########################################################################################

#text format 
#Speaker [name] presents [title] [SessionURL} /cc [twitter handle] #sqlsat403

$eventNum = "883"
$outputfolder = "c:\temp\SponsorLogos"
$compress = $True

#let's get the XML from the SQL Saturday website
[xml] $xdoc = Invoke-WebRequest -Uri "http://www.sqlsaturday.com/eventxml.aspx?sat=$eventNum" -UseBasicParsing

#we only need a subset of each node of the XML, mainly the sponsors
$sponsors = $xdoc.guidebookxml.sponsors.sponsor | select name, label, imageURL

#let's make sure the folder exists
"Checking folder existence...."
if (-not (test-path $outputFolder)) {
    try {
        New-Item -Path $outputFolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$outputFolder'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$outputFolder'."
}else{
    "Folder already exists...moving on"
}

#give me all of the logos
foreach ($sponsor in $sponsors){
    $filename = $sponsor.imageURL | split-path -Leaf
    #get the file name and clean up spaces, commas, and the dot coms
    $sponsorname = $sponsor.name.replace(" ", "").replace(",","").replace(".com","")
    invoke-webrequest -uri $sponsor.imageURL -outfile $outputfolder\$($sponsorName)_$($sponsor.label.ToUpper())_$($fileName)
}

# zip things up if desired
If ($compress -eq $true){
    $filename = $outputfolder | split-path -Leaf
    compress-archive -path $outputFolder -DestinationPath $outputfolder\$($filename).zip
}

# show me the folder
explorer $outputfolder

