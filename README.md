# aws-powershell-transcribe2srt - A Media File to SRT Converter
This projects demonstrates the use of the AWS Transcribe service and PowerShell to create an SRT (subtitle) file from a media file.

Makes use of:

* PowerShell Core
* AWS PowerShell Core Cmdlets
* AWS S3
* AWS Transcribe Service

## Installation

Prerequisites :

* An existing AWS account. You can sign up for a Free Tier account [here:](https://aws.amazon.com/free/)
* Credentials and configuration setup for use with AWS CLI/AWS PowerShell Core Cmdlets. See [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html) for information on how to do this.
* PowerShell Core (available cross [platform](https://github.com/PowerShell/PowerShell))
* An MP4 media file

## Usage
If not already done, clone this repo from either source or your own fork

Start a terminal session 

Launch PowerShell Core 

```
➜  ~  pwsh
```

Change to the *src* directory of the cloned repo

```
set-location ~/git/aws-transcribe2srt/src/                                                                                                                                                                                                                                
```

### Initialization
**NOTE: The following steps are covered in the *sample.ps1* file that is also in the *src* folder. **

The actions below only need to be carried out **once** per PowerShell session. It won't hurt if you do them more than once, but the only benefit will be a couple of extra seconds convincing your boss that you're busy with work.


Import the required modules and dotsource the functions

```
Import-Module AWSPowerShell.NetCore
. ./ConvertTo-Srt.ps1
. ./Get-AWSTranscription.ps1
```

### Define Variables for the Generation of the SRT File
If this is the first run during the current PowerShell session, execute all of the following commands

If not, then all you need to do is change the appropriate variable(s)

#### Define the Parameters for the AWS Cmdlets

```
$awsparams = @{
    profilename = 'development'
    region      = 'eu-west-1' 
}
```

#### Specify your S3 bucket

```
$bucket = 'tim-training-thing'
```

#### Specify the Location of the Video (mp4) File

```
$path = "~/Desktop/videoplayback.mp4"
```

#### Specify the Name of the SRT File to be Created

```
$destinationPath = '~/Desktop/videoplayback.srt'
```

### Transcribe the mp4 File
We just need to assign a variable to the result of the *Get-AWSTranscription* cmdlet

```
$transcription = Get-AWSTranscription -AWSDefaultParameters $awsparams -Bucket $bucket -Path $path
```

### Convert the Results to an SRT File
The results of the transcript are fed into the ConvertTo-Srt cmdlet, which handles the processing of the data and creating the SRT file from it.

```
ConvertTo-Srt -Transcription $transcription -DestinationPath $destinationPath
```
### Comments
You can find a sample script, *sample.ps1* which performs the above, in the *src* folder.

## Known Issues
The end time entry for the last sequence in the SRT file is always wrong.

## Contributing
Bug reports and pull requests are welcome on GitHub at <https://github.com/tim-pringle/aws-powershell-transcribe2srt>.

## History
18/04/2018 : Developed on OSX 10.13.3 with PowerShell v6.0.2 release
19/04/2018 : Renamed repository 

## License

Apache 2.0 (see [LICENSE])

[license]: https://github.com/tim-pringle/aws-transcribe2srt/blob/master/LICENSE
