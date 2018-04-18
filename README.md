# aws-transcribe2srt - A Media File to SRT Converter
This projects demonstrates the use of the AWS Transcribe service to create an SRT (subtitle) file from a media file.

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

### Initialization
The following steps only need to be carried out **once** per PowerShell session


Change to the *src* directory of the cloned repo

```
set-location ~/git/aws-transcribe2srt/src/                                                                                                                                                                                                                                 
```

Import the required modules and dotsource the functions

```
Import-Module AWSPowerShell.NetCore
. ./ConvertTo-Srt.ps1
. ./Get-AWSTranscription.ps1
```

### Define Variables for the Generation of the SRT File
If this is the first run during the current PowerShell session, execute all of the following commands

If not, then all you need to do is change the appropriate variable(s)

####Define the Parameters for the AWS Cmdlets

```
$awsparams = @{
    profilename = 'development'
    region      = 'eu-west-1' 
}
```

####Specify your S3 bucket

```
$bucket = 'tim-training-thing'
```

####Specify the location of the video (mpp4) file

```
$path = "~/Desktop/videoplayback.mp4"
```

### Transcribe the MP4 File
We just need to assign a variable to the result of the *Get-AWSTranscription* cmdlet

```
$transcription = Get-AWSTranscription -AWSDefaultParameters $awsparams -Bucket $bucket -Path $path
```

### Convert the Results to an SRT File
The results of the transcript are fed into the ConvertTo-Srt cmdlet, which handles the processing of the data and creating the SRT file from it.

```
ConvertTo-Srt -Transcription $transcription -DestinationPath '~/Desktop/videoplayback.srt'
```

## Known Issues
The end time entry for the last sequence in the SRT file is always wrong.

## Contributing
Bug reports and pull requests are welcome on GitHub at <https://github.com/tim-pringle/aws-transcribe2srt>.
##Additional Information
18/04/2018 : Developed on OSX 10.13.3 with PowerShell v6.0.2 release


## License

Apache 2.0 (see [LICENSE])

[license]: https://github.com/tim-pringle/aws-transcribe2srt/blob/master/LICENSE
