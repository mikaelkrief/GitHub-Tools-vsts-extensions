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
    $token = $endpoint.Auth.Parameters.accessToken
    $commit = $env:BUILD_SOURCEVERSION
	
    #"Endpoint:"
    #$Endpoint | ConvertTo-Json -Depth 32

    $releaseData = @{
        ref = "refs/tags/$tag" ;
        sha = "$commit";
    }

    $auth = 'token ' + $token;

    $releaseParams = @{
        Uri         = "https://api.github.com/repos/$repositoryName/git/refs";
        Method      = 'POST';
        Headers     = @{
            Authorization = $auth;
        }
        ContentType = 'application/json';
        Body        = (ConvertTo-Json $releaseData -Compress)
    }

    $res = Invoke-RestMethod @releaseParams
    Write-Verbose $res | ConvertTo-Json -Depth 32
    Write-Host "The source code commit $commit is taged $tag on repository $repositoryName"
}
catch [Exception] {    
    Write-Error ($_.Exception.Message)
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host "Ending GitHub Tag task"