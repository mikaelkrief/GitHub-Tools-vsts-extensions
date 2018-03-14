Write-Host "Starting GitHub Create Release task"

Trace-VstsEnteringInvocation $MyInvocation
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {

    # Import the helpers.
    . $PSScriptRoot\Get-MimeType.ps1

    $serviceName = Get-VstsInput -Name githubEndpoint
    $endpoint = Get-VstsEndpoint -Name $serviceName -Require
   
    Write-Host $serviceName
    if (!$serviceName) {
        Get-VstsInput -Name $serviceNameInput -Require
    }

    $tag = Get-VstsInput -Name tag -Require
    $repositoryName = Get-VstsInput -Name repositoryName -Require
    $branch = Get-VstsInput -Name branch -Require
    $token = $endpoint.Auth.Parameters.accessToken
    $releaseName = Get-VstsInput -Name releaseName -Require
    $isdraft = Get-VstsInput -Name isdraft -Require -AsBool
    $isprerelease = Get-VstsInput -Name isprerelease -Require -AsBool
    $usecommitmessage = Get-VstsInput -Name usecommitmessage -Require -AsBool
    $releasenote = Get-VstsInput -Name releasenote
    $filetoupload = Get-VstsInput -Name ziptoupload


    #"Endpoint:"
    #$Endpoint | ConvertTo-Json -Depth 32
    $releaseNotes = $releasenote;

    if ($usecommitmessage -eq $true) {
        $commitParams = @{
            Uri         = "https://api.github.com/repos/$repositoryName/git/commits/$env:BUILD_SOURCEVERSION";
            Method      = 'GET';
            ContentType = 'application/json';
        }
        $rescommit = Invoke-RestMethod @commitParams
        $releaseNotes = $rescommit.message;
    }

    $releaseData = @{
        tag_name         = $tag;
        target_commitish = $branch;
        name             = $releaseName;
        body             = $releaseNotes;
        draft            = $isdraft;
        prerelease       = $isprerelease;
    }

    $auth = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($token + ":x-oauth-basic"));


    $releaseParams = @{
        Uri         = "https://api.github.com/repos/$repositoryName/releases";
        Method      = 'POST';
        Headers     = @{
            Authorization = $auth;
        }
        ContentType = 'application/json';
        Body        = (ConvertTo-Json $releaseData -Compress)
    }

    $res = Invoke-RestMethod @releaseParams
   
    if (!((Get-Item $filetoupload) -is [System.IO.DirectoryInfo])) {
        $mimetype = Get-MimeType -CheckFile $filetoupload | Out-String
        if ($mimetype) { # need to validate the $mimetype
            $artifact = [IO.Path]::GetFileName($filetoupload);
            $uploadUri = $res | Select-Object -ExpandProperty upload_url
            Write-Host $uploadUri
            $uploadUri = $uploadUri -creplace '\{\?name,label\}'  #, "?name=$artifact"
            $uploadUri = $uploadUri + "?name=$artifact"
            $uploadFile = $filetoupload

            $uploadParams = @{
                Uri         = $uploadUri;
                Method      = 'POST';
                Headers     = @{
                    Authorization = $auth;
                }
                ContentType = $mimetype;
                InFile      = $uploadFile
            }
            $result = Invoke-RestMethod @uploadParams
            Write-Host "The file $filetoupload has uploaded to release"
        }else{
            Write-Error "You need to select an acceptable file: https://www.iana.org/assignments/media-types/media-types.xhtml";
        }
    }
    #$rescommit.message
    #Write-Verbose $res | ConvertTo-Json -Depth 32
    Write-Host "The release is created"
}
catch [Exception] {    
    Write-Error ($_.Exception.Message)
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host "Ending GitHub Create Release task"
