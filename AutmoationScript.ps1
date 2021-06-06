

Import-Module .\MorePowerShellForGithub\more_powershell_for_github.psm1

$Cred = Set-MoreGitHubAuthentication

$header = Get-AuthHeader -Creds $Cred

New-GitHubRepository -RepositoryName testRep -Private -AutoInit | Add-GitHubCollaborator -header $header -Collaborator 'MarkovicAntonio' | Set-Variable invitation

$RepositoryName = ($invitation.repository).name
$Login = ($invitation.inviter).login

$FullUri = 'https://api.github.com/repos/'+ $Login +'/'+ $RepositoryName + '/zipball/master'
    

Write-Host $FullUri

Invoke-RestMethod -Method Get -Headers $header -Uri $FullUri


Expand-Archive .\($invitation.repository).name
