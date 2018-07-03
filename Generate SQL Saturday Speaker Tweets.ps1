##########################################################################################
#- Author: John Morehouse
# Date: August 2015
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

$eventNum = "729"
$OAuthToken =  "[Bit.Ly token goes here]"
$outputfile = "c:\temp\sqlsat$($eventnum)_tweets.csv"
$outtofile =  1     #1 = output the results to a file, 0 = putput the results to the screen

# used to shorten the session URL for a better character count for Twitter
# internals borrowed from http://powershellnotebook.com/2014/10/29/powershell-shorten-links-with-the-bit-ly-api/
# function wrapper was written by John Morehouse

function Get-ShortURL{
    Param([string]$longURL, 
            [string]$OAuthToken)

  # Make the call
  $URL=Invoke-WebRequest `
    -Uri https://api-ssl.bitly.com/v3/shorten `
    -Body @{access_token=$OAuthToken;longURL=$LongURL} `
    -Method Get
    
  #Get the elements from the returned JSON 
  $URLjson = $URL.Content | ConvertFrom-JSON
   
  # Print out the shortened URL 
  write-output $URLjson.data.url 
}   

#let's get the XML from the SQL Saturday website
[xml] $xdoc = Invoke-WebRequest -Uri "http://www.sqlsaturday.com/eventxml.aspx?sat=$eventNum" -UseBasicParsing

#we only need a subset of each node of the XML, mainly the speakers and the sessions
$speakers = $xdoc.GuidebookXML.speakers.speaker | select importid, name, twitter
$sessions = $xdoc.GuidebookXML.events.event | select importID, title

#declare our array to hold our tweets
$tweets = @()

foreach ($speaker in $speakers){
  $session = $sessions | where-object {$_.importid -eq $speaker.importID}
  
  #santize the data some
  #if the twitter value is less than 2, just set it to a blank value
  IF ($speaker.twitter.Length -le 2){
    $twitter = ""
        }
  #if the twitter value is larger than 1 and begins with https, replace it with an @
  ELSEIF (($speaker.twitter.Length -gt 1 ) -and ($speaker.twitter.substring(0,5) -eq "https")){
    $twitter = "/cc " + $speaker.twitter.Replace("https://twitter.com/","@")
        }
  #if the twitter value is larger than 1 and begins with http, replace it with an @
  ELSEIF (($speaker.twitter.Length -gt 1 ) -and ($speaker.twitter.substring(0,4) -eq "http")){
    $twitter = "/cc " + $speaker.twitter.Replace("http://twitter.com/","@")
        }
  #if the first character is NOT an @, add one
  ELSEIF ($speaker.twitter.substring(0,1) -ne "@"){
    $twitter = "/cc @" + $speaker.twitter
        }
  #else build in the /cc string
  ELSE {$twitter = "/cc " + $speaker.twitter}

  #clean up the title if there are any ASCII encoded characters
  $title = $session.title.TrimEnd().replace("#39;","'").replace("amp;","&")

  #get the short URL
  $longurl = "http://sqlsaturday.com/$eventNum/Sessions/Details.aspx?sid=" +$session.importID
  $shortURL = Get-ShortURL -longURL $longURL -OAuthToken $OAuthToken

  #bring it all together and put it in the array
  $tweets += "Speaker " + $speaker.name + " presents `"" + $title + "`" " + $shortURL + " " + $twitter + " " + $xdoc.GuidebookXML.guide.twitterHashtag
}

$format = @{Label="Length";Expression={$_.Length}}, @{Expression={$_};Label = "Tweet"}

If ($outtofile -eq 1){
    $tweets | select-object -Property $format  | export-csv $outputfile
  } else {
    $tweets | select-object -Property $format | format-table -AutoSize
  }