Write-Host "Starting GitHub Release task"

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
    $commit = Get-VstsInput -Name commmit -Require
    $token = $endpoint.Auth.Parameters.accessToken
    $releaseName = Get-VstsInput -Name releaseName -Require
    $isdraft = Get-VstsInput -Name isdraft -Require -AsBool
    $isprerelease = Get-VstsInput -Name isprerelease -Require -AsBool
    $releasenote = Get-VstsInput -Name releasenote -Require
    
    #"Endpoint:"
    #$Endpoint | ConvertTo-Json -Depth 32


    $releaseData = @{
        tag_name         = $tag;
        target_commitish = $commit;
        name             = $releaseName;
        body             = $releasenote;
        draft            = $isdraft;
        prerelease       = $isprerelease;
    }

    #$auth = 'token ' + $token;
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
    Write-Verbose $res | ConvertTo-Json -Depth 32
    Write-Host "The release is created"
}
catch [Exception] {    
    Write-Error ($_.Exception.Message)
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host "Ending GitHubRelease task"