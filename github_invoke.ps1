$auth= [System.Convert]::ToBase64String([char[]]$creds.GetNetworkCredential().Password)
$headers = @{Authorization="Basic $auth"}
Invoke-RestMethod -Headers $headers https://api.github.com/user