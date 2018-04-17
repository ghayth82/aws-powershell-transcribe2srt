Import-Module AWSPowerShell.NetCore

#Lets set default parameter values for the aws cmdlets
$awsparams = @{
    profilename = 'development'
    region      = 'eu-west-1' 
}

$prefix = 'https://s3-eu-west-1.amazonaws.com'
$bucketname = 'tim-training-thing'
$file = 'videoplayback.mp4'
$s3uri = "$prefix/$bucketname/$file" 
$jobname = "newjob"

Write-S3Object -BucketName $bucketname -File $file @awsparams

#We don't need to demux the audio stream from an MP4 file. Nice for most video downloads. :)
Start-TRSTranscriptionJob -Media_MediaFileUri $s3uri -TranscriptionJobName $jobname -MediaFormat mp4 -LanguageCode en-US @awsparams 

<#
CompletionTime         : 04/17/2018 09:35:40
CreationTime           : 04/17/2018 09:29:33
FailureReason          : 
LanguageCode           : en-US
TranscriptionJobName   : subtitle-adamz
TranscriptionJobStatus : COMPLETED
#>

#Job processing will run async, so it's up to you how you deal with this.
$results = Get-TRSTranscriptionJob -TranscriptionJobName subtitle-adamz @awsparams 

While ($results.TranscriptionJobStatus -eq 'IN_PROGRESS') {
    Start-Sleep -Seconds 10
    $results = Get-TRSTranscriptionJob -TranscriptionJobName subtitle-adamz @awsparams 
}

If ($results.TranscriptionJobStatus -eq 'FAILED') {[Environment]::Exit(1)}
$transcripturi = $results.Transcript.TranscriptFileUri 
Invoke-Webrequest -Uri $transcripturi -OutFile result.json 
$transcription = Get-Content result.json | ConvertFrom-Json
$transcription = $transcription[0].results.items

#Now for some horrible code to make the SRT that i really need to tidy up later!

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
    $firstrow = $true
    
    #Repeat this until we have either reached the last item in results
    #or the length of the lines we are reading is greater than 64 characters
    While (($strlen -le 64) -and ($index -le $transcription.count)) {
        $type = $transcription[$index].type
        $text = $transcription[$index].alternatives.content
        $strlen += $text.length

        Switch ($type) {
            "pronunciation" {$subtitle += "$text "}
            "punctuation" {
                If ($subtitle.Length -gt 0) {
                    $subtitle = $subtitle.substring(0, $subtitle.length - 1) + $text
                }
                Else {
                    $subtitle += $text
                }
            }
        }
        #If the length of the current string is greater than 32 and this
        #is the first line of the sequence, then add a return character to it
        If (($strlen -gt 32) -and ($firstrow)) {
            $subtitle += "`n"
            $firstrow = $false
        }

        #If the last character is a '.', then we need to set
        #the end time attribute to the previous indexes one
        #since punctuation characters to not have a time stamp
        If ($type -eq "punctuation") {
            $entime = $transcription[$index - 1].end_time
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
$srtinfo | Set-Content '~/Downloads/subs.srt' -Force