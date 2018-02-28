Write-Host "Starting GitHub Create Release task"

Trace-VstsEnteringInvocation $MyInvocation

try {

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
    $ziptoupload = Get-VstsInput -Name ziptoupload


    #"Endpoint:"
    #$Endpoint | ConvertTo-Json -Depth 32
    $releaseNotes = $releasenote;
    $auth = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($token + ":x-oauth-basic"));

    if ($usecommitmessage -eq $true) {
        $commitParams = @{
            Uri         = "https://api.github.com/repos/$repositoryName/git/commits/$env:BUILD_SOURCEVERSION";
            Method      = 'GET';
            ContentType = 'application/json';
            Headers     = @{
                Authorization = $auth;
            }
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
   
    if (!((Get-Item $ziptoupload) -is [System.IO.DirectoryInfo])) {
        $extn = [IO.Path]::GetExtension($ziptoupload)
        if ($extn -eq ".zip" ) {
            $artifact = [IO.Path]::GetFileName($ziptoupload);
            $uploadUri = $res | Select-Object -ExpandProperty upload_url
            Write-Host $uploadUri
            $uploadUri = $uploadUri -creplace '\{\?name,label\}'  #, "?name=$artifact"
            $uploadUri = $uploadUri + "?name=$artifact"
            $uploadFile = $ziptoupload

            $uploadParams = @{
                Uri         = $uploadUri;
                Method      = 'POST';
                Headers     = @{
                    Authorization = $auth;
                }
                ContentType = 'application/zip';
                InFile      = $uploadFile
            }
            $result = Invoke-RestMethod @uploadParams
            Write-Host "The file $ziptoupload has uploaded to release"
        }else{
            Write-Error "You need to select Zip file";
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
