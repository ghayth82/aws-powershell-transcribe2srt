Import-Module AWSPowerShell.NetCore

#Change this location as required for the location of the
#src folder of the repo

Set-Location -Path "~/git/aws-powershell-transcribe2srt/src"

#Dot source the two functions
. ./ConvertTo-Srt.ps1
. ./Get-AWSTranscription.ps1

#Lets set default parameter values for the aws cmdlets
$awsparams = @{
    profilename = 'development'
    region      = 'eu-west-1' 
}

#Set parameters as required
$bucket = 'tim-training-thing'
$path = "~/Desktop/videoplayback.mp4"
$destinationPath = '~/Desktop/videoplayback.srt'

#Initialise a variable that will be used to store the transcription results.
#Use a reference variable so we don't need to worry about any spurious output within the function
$transcription = Get-AWSTranscription -AWSDefaultParameters $awsparams -Bucket $bucket -Path $path
ConvertTo-Srt -Transcription $transcription -DestinationPath $destinationPath