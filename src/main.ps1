Import-Module AWSPowerShell.NetCore
. ./ConvertTo-Srt.ps1
. ./Get-AWSTranscription.ps1

#Lets set default parameter values for the aws cmdlets
$awsparams = @{
    profilename = 'development'
    region      = 'eu-west-1' 
}

$bucket = 'tim-training-thing'
$path = "~/Desktop/videoplayback.mp4"

#Initialise a variable that will be used to store the transcription results.
#Use a reference variable so we don't need to worry about any spurious output within the function
$transcription = Get-AWSTranscription -AWSDefaultParameters $awsparams -Bucket $bucket -Path $path
ConvertTo-Srt -Transcription $transcription -DestinationPath '~/Desktop/videoplayback.srt'