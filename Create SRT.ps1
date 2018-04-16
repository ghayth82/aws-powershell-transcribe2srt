$transcription = Get-Content '~/Downloads/Amazon Transcribe Example.json' | ConvertFrom-Json
$transcription = $transcription[0].results.items


$index = 0
$sequenceno = 0
$srtinfo = ""

While ($index -lt $transcription.count) {
    $strlen = 0
    $sttime = $transcription[$index].start_time
    $sttime = [timespan]::FromSeconds($sttime)
    $starttime = "{0:hh}:{0:mm}:{0:ss},{0:fff}" -f $sttime
    $subtitle = ""
    $sequenceno += 1


    While (($strlen -le 32) -and ($index -le $transcription.count)){
        $type = $transcription[$index].type
        $text = $transcription[$index].alternatives.content
        $strlen += $text.length
        Switch ($type) {
        "pronunciation"  {$subtitle += " $text"}
        "punctuation"  {$subtitle += $text}
       
    }
    $entime = $transcription[$index].end_time
    $entime = [timespan]::FromSeconds($entime)
    $endtime = "{0:hh}:{0:mm}:{0:ss},{0:fff}" -f $entime  
    $index += 1
   
        }
    $subtitle = $subtitle.trim()
    $subdetail = "
    $sequenceno
    $starttime --> $endtime
    $subtitle
    "
    
    $srtinfo += $subdetail
    
    }
    
$srtinfo | Set-Content ~/Downloads/subs.srt -Force



