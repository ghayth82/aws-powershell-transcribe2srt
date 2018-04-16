#Takes as input a file generated from AWS Transcribe

$transcription = Get-Content './sample.json' | ConvertFrom-Json
$transcription = $transcription[0].results.items

#Set initial variables
$index = 0
$sequenceno = 0
$srtinfo = ""

#Repeat this process until we have reached the end of the results
While ($index -lt $transcription.count) {
    $strlen = 0
    #Grab the start time of the item we are reading and covert it SRT time format
    $sttime = $transcription[$index].start_time
    $sttime = [timespan]::FromSeconds($sttime)
    $starttime = "{0:hh}:{0:mm}:{0:ss},{0:fff}" -f $sttime
    $subtitle = ""
    $sequenceno += 1

    #Repeat this until we have either reached the last item in results
    #or the length of the line we are reading is greater than 32 characters
    While (($strlen -le 32) -and ($index -le $transcription.count)){
        $type = $transcription[$index].type
        $text = $transcription[$index].alternatives.content
        $strlen += $text.length

        Switch ($type) {
        "pronunciation"  {$subtitle += "$text "}
        "punctuation"  {$subtitle += $text}
       
    }
   
    $entime = $transcription[$index].end_time
    $entime = [timespan]::FromSeconds($entime)
    $endtime = "{0:hh}:{0:mm}:{0:ss},{0:fff}" -f $entime  
    $index += 1
}

#We're wanting two lines on the page though, so we repeat the 
#process
$subtitle += "`n"
$strlen = 0

While (($strlen -le 32) -and ($index -le $transcription.count)){
    $type = $transcription[$index].type
    $text = $transcription[$index].alternatives.content
    $strlen += $text.length

    Switch ($type) {
    "pronunciation"  {$subtitle += "$text "}
    "punctuation"  {$subtitle += $text}
}

#If the last character is a '.', then we need to set
#the end time attribute to the previous indexes one
#since punctuation characters to not have a time stamp
If ($type -eq "punctuation") {
    $entime = $transcription[$index-1].end_time
    }
Else {
$entime = $transcription[$index].end_time
}
$entime = [timespan]::FromSeconds($entime)
$endtime = "{0:hh}:{0:mm}:{0:ss},{0:fff}" -f $entime  
$index += 1
}

#Setup the string that is refers to these two
#lines in SRT format
$subdetail = "
$sequenceno
$starttime --> $endtime
$subtitle
"

#Append this to the existing string
    $srtinfo += $subdetail
    
    }
    
#Now output the results to our .srt file
$srtinfo | Set-Content ~/Downloads/subs.srt -Force