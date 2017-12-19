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
    $releasenote = Get-VstsInput -Name releasenote -Require

    #"Endpoint:"
    #$Endpoint | ConvertTo-Json -Depth 32



    $commitParams = @{
        Uri         = "https://api.github.com/repos/$repositoryName/git/commits/$env:BUILD_SOURCEVERSION";
        Method      = 'GET';
        ContentType = 'application/json';
    }
    $rescommit = Invoke-RestMethod @commitParams

    $releaseData = @{
        tag_name         = $tag;
        target_commitish = $branch;
        name             = $releaseName;
        body             = $rescommit.message;
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
   

    $rescommit.message
    Write-Verbose $res | ConvertTo-Json -Depth 32
    Write-Host "The release is created"
}
catch [Exception] {    
    Write-Error ($_.Exception.Message)
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host "Ending GitHub Create Release task"