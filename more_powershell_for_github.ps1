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

#Add-GitHubCollaborator -Credential $c -Repository MorePowerShellForGithub -Collaborator dieter-ap

function Accept-GitHubRepositoryInvitations {
    param(
        $RepositoryName,$OwnerGroup,$MailDomains,$Credential
    )

    $invitations = Invoke-RestMethod -Method Get -Headers $Credential -Uri https://api.github.com/user/repository_invitations

    if ($RepositoryName -eq $null -and $OwnerGroup -eq $null -and $MailDomains -eq $null)
    {
        foreach ($invite in $invitations)
        {
            Write-Host $invite
            $fullURI = 'https://api.github.com/user/repository_invitations/'+ ($invite).id
            Invoke-RestMethod -Method Patch -Headers $Credential -Uri $fullURI
        }
    }

    if ($RepositoryName -ne $null -or $OwnerGroup -ne $null -or $MailDomains -ne $null)
    {
        if ($RepositoryName -ne $null)
        {
            foreach ($invite in $invitations)
            {
                $invitationRepository = $invite | Select-Object -Property repository

                if ($RepositoryName -eq ($invitationRepository.repository).name)
                {
                    $fullURI = 'https://api.github.com/user/repository_invitations/'+ ($invite).id
                    Invoke-RestMethod -Method Patch -Headers $Credential -Uri $fullURI
                }
            }
        }

        if ($OwnerGroup -ne $null)
        {
            foreach ($invite in $invitations)
            {
                $invitee_object = $invite | Select-Object -Property invitee
                $invitee = ($invitee_object.invitee).login
                Write-Host $invitee

                $bio_invitee = (Get-GitHubUser -UserName $invitee | Select-Object -Property bio).bio

                $inviter_object = $invite | Select-Object -Property inviter
                $inviter = ($inviter_object.inviter).login
                Write-Host $inviter

                $bio_inviter = (Get-GitHubUser -UserName $inviter | Select-Object -Property bio).bio

                if ($bio_invitee -eq $bio_inviter)
                {
                    $fullURI = 'https://api.github.com/user/repository_invitations/'+ ($invite).id
                    Invoke-RestMethod -Method Patch -Headers $Credential -Uri $fullURI                
                }
            }
        }
        if ($MailDomains -ne $null)
        {
        $MailDomains = '*'+$MailDomains
        Write-Host $MailDomains
            foreach ($invite in $invitations)
            {
                $inviter_object = $invite | Select-Object -Property inviter
                $inviter = ($inviter_object.inviter).login
                Write-Host $inviter

                $email_inviter = (Get-GitHubUser -UserName $inviter | Select-Object -Property email).email


                if ($email_inviter -like $MailDomains)
                {
                    $fullURI = 'https://api.github.com/user/repository_invitations/'+ ($invite).id
                    Invoke-RestMethod -Method Patch -Headers $Credential -Uri $fullURI                
                }
            }       
        }
    }

}


#Accept-GitHubRepositoryInvitations -Credential $c -MailDomains '@ap.be'
