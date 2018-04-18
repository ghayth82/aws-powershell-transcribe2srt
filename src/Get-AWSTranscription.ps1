Function Get-AWSTranscription {
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Specify the default parameters that will be used with AWS cmdlets')] [hashtable] $AWSDefaultParameters,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The S3 bucket to upload to')] [string] $Bucket,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The file to upload')] [string] $Path
    )
    
       
    Process {         

        #Set the S3 uri prefix and create a unique guid to be used as the job name
        $prefix = 'https://s3-eu-west-1.amazonaws.com'
        $jobname = [Guid]::NewGuid() | Select-Object -ExpandProperty Guid
        $resultsfile = './result.json'

        #Let's get the file item so we can use some of its properties
        $fileitem = Get-Item -Path $Path
        $s3uri = "$prefix/$Bucket/$($fileitem.name)" 

        #Upload it to S3
        Write-S3Object -BucketName $Bucket -File $Path @AWSDefaultParameters

        #We don't need to demux the audio stream from an MP4 file. Nice for most video downloads. :)
        $null = Start-TRSTranscriptionJob -Media_MediaFileUri $s3uri -TranscriptionJobName $jobname -MediaFormat mp4 -LanguageCode en-US @AWSDefaultParameters

        #Job processing will run async, so it's up to you how you deal with this.
        #For this one we'll take ten second naps in between checks of the status
        $results = Get-TRSTranscriptionJob -TranscriptionJobName $jobname @AWSDefaultParameters 

        While ($results.TranscriptionJobStatus -eq 'IN_PROGRESS') {
            Start-Sleep -Seconds 5
            $results = Get-TRSTranscriptionJob -TranscriptionJobName $jobname @AWSDefaultParameters 
        }

        If ($results.TranscriptionJobStatus -eq 'COMPLETED') {
            $transcripturi = $results.Transcript.TranscriptFileUri 
            Invoke-Webrequest -Uri $transcripturi -OutFile $resultsfile
            $output = Get-Content $resultsfile

            #Let's clear up the json file that was created
            Remove-Item -Path $resultsfile -Force
            
            #Output the results
            $output
        }
    }
}