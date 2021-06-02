Get-Content .\secret.txt| 
ConvertTo-SecureString | Set-Variable ss_token
$creds = New-Object pscredential 'user’, $ss_token
Set-GitHubAuthentication -SessionOnly -Credential $creds

