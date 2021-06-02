Get-Content .\secret.txt| 
ConvertTo-SecureString | Set-Variable ss_token
$Creds = New-Object pscredential 'user’, $ss_token
Set-GitHubAuthentication -SessionOnly -Credential $Creds



function Get-AuthHeader{
    param(
            $Creds
         )
    $auth= [System.Convert]::ToBase64String([char[]]$Creds.GetNetworkCredential().Password)
    $headers = @{Authorization="Basic $auth"}
    return $headers

}

$c = Get-AuthHeader -Creds $Creds

function Add-GitHubCollaborator{
    param(
            $Credential,$Repository,$Collaborator
         )

         $DefaultGitHubURL = 'https://api.github.com/repos/MarkAntRepo/'

         $fullURL = $DefaultGitHubURL+$Repository+'/collaborators/'+$Collaborator

         Invoke-RestMethod -Method Put -Headers $Credential -uri $fullURL

}

Add-GitHubCollaborator -Credential $c -Repository MorePowerShellForGithub -Collaborator dieter-ap
