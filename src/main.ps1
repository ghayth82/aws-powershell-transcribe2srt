Import-Module AWSPowerShell.NetCore
. ./ConvertTo-Srt.ps1
. ./Get-AWSTranscription.ps1

#Lets set default parameter values for the aws cmdlets
$awsparams = @{
    profilename = 'development'
    region      = 'eu-west-1' 
}

$bucket = 'tim-training-thing'
$path = "$PSScriptRoot/videoplayback.mp4"

$transcription = Get-AWSTranscription -AWSDefaultParameters $awsparams -Bucket $bucket -Path $path
ConvertTo-Srt -Transcription $transcription -DestinationPath ~/Desktop/output.srt