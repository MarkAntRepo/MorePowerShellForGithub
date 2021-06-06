function Set-MoreGitHubAuthentication {
    Get-Content .\secret.txt|
    ConvertTo-SecureString | Set-Variable ss_token
    $Creds = New-Object pscredential 'user’, $ss_token
    Set-GitHubAuthentication -SessionOnly -Credential $Creds

    return $Creds
}

Export-ModuleMember -Function Set-MoreGitHubAuthentication


function Get-AuthHeader{
    param(
            $Creds
         )
    $auth= [System.Convert]::ToBase64String([char[]]$Creds.GetNetworkCredential().Password)
    $headers = @{Authorization="Basic $auth"}
    return $headers

}

Export-ModuleMember -Function Get-AuthHeader


function Add-GitHubCollaborator{
    [CmdletBinding()]
    param(
            $header,
            [Parameter(Mandatory=$false,Position=1,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)][Alias('name')][string[]]$RepositoryName,
            $Collaborator
         )

         begin{

         }

         process{
            $DefaultGitHubURL = 'https://api.github.com/repos/MarkAntRepo/'

            $fullURL = $DefaultGitHubURL+$RepositoryName+'/collaborators/'+$Collaborator

            Invoke-RestMethod -Method Put -Headers $header -uri $fullURL         
         }

         end{
            Write-Host $Collaborator' has been added to repository '$RepositoryName
         }
         
}

Export-ModuleMember -Function Add-GitHubCollaborator


function Accept-GitHubRepositoryInvitations {
    param(
        $RepositoryName,$OwnerGroup,$MailDomains,$header
    )

    $invitations = Invoke-RestMethod -Method Get -Headers $header -Uri https://api.github.com/user/repository_invitations

    if ($RepositoryName -eq $null -and $OwnerGroup -eq $null -and $MailDomains -eq $null)
    {
        foreach ($invite in $invitations)
        {
            Write-Host $invite
            $fullURI = 'https://api.github.com/user/repository_invitations/'+ ($invite).id
            Invoke-RestMethod -Method Patch -Headers $header -Uri $fullURI
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
                    Invoke-RestMethod -Method Patch -Headers $header -Uri $fullURI
                }
            }
        }
        
        if ($OwnerGroup -ne $null)
        {
            foreach ($invite in $invitations)
            {
                $invitee_object = $invite | Select-Object -Property invitee
                $invitee = ($invitee_object.invitee).login
                

                $bio_invitee = (Get-GitHubUser -UserName $invitee | Select-Object -Property bio).bio

                $inviter_object = $invite | Select-Object -Property inviter
                $inviter = ($inviter_object.inviter).login
                

                $bio_inviter = (Get-GitHubUser -UserName $inviter | Select-Object -Property bio).bio

                if ($bio_invitee -eq $bio_inviter)
                {
                    $fullURI = 'https://api.github.com/user/repository_invitations/'+ ($invite).id
                    Invoke-RestMethod -Method Patch -Headers $header -Uri $fullURI                
                }
            }
        }
        if ($MailDomains -ne $null)
        {
        $MailDomains = '*'+$MailDomains
        
            foreach ($invite in $invitations)
            {
                $inviter_object = $invite | Select-Object -Property inviter
                $inviter = ($inviter_object.inviter).login
                

                $email_inviter = (Get-GitHubUser -UserName $inviter | Select-Object -Property email).email


                if ($email_inviter -like $MailDomains)
                {
                    $fullURI = 'https://api.github.com/user/repository_invitations/'+ ($invite).id
                    Invoke-RestMethod -Method Patch -Headers $header -Uri $fullURI                
                }
            }       
        }
    }

}

Export-ModuleMember -Function Accept-GitHubRepositoryInvitations