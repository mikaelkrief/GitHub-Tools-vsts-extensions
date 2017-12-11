Write-Host "Starting GitHub Tag task"

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
	$isdraft = Get-VstsInput -Name isdraft -Require
	#"Endpoint:"
	#$Endpoint | ConvertTo-Json -Depth 32


    $releaseData = @{
        tag_name = $tag;
        target_commitish = $commit;
        name = [string]::Format("v{0}", $versionNumber);
        body = $releaseNotes;
        draft = $draft;
        prerelease = $preRelease;
     }

    $auth = 'token ' + $token;

    $releaseParams = @{
        Uri = "https://api.github.com/repos/$repositoryName/releases";
        Method = 'POST';
        Headers = @{
        Authorization = $auth;
        }
        ContentType = 'application/json';
        Body = (ConvertTo-Json $releaseData -Compress)
    }

    $res = Invoke-RestMethod @releaseParams
    Write-Verbose $res | ConvertTo-Json -Depth 32
    Write-Host "The release is created"
}
catch [Exception] 
{    
    Write-Error ($_.Exception.Message)
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host "Ending GitHubTag task"