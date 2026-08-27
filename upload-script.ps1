<#
    upload-script.ps1

    Uploads a local file to a remote endpoint using HTTP Basic Authentication.
    Sends the request as multipart/form-data with a "file" field and a "path" field,
    then reports the HTTP status code returned by the server.
#>

# --- Credentials -----------------------------------------------------------
# Username and password used for HTTP Basic Authentication.
$user = ''
$pass = ''

# Combine username and password into "user:pass" format required by Basic Auth
$pair = "$($user):$($pass)"

# Base64-encode "user:pass" string as required by Basic Auth scheme
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

# Build value for Authorization header (e.g. "Basic dXNlcjpwYXNz")
$basicAuthValue = "Basic $encodedCreds"

# Assemble headers hashtable to send with request
$Headers = @{ Authorization = $basicAuthValue }

# --- Upload request ----------------------------------------------------------
# Send POST request with file and destination path as multipart/form-data.
# -SkipCertificateCheck bypasses self-signed SSL certificate validation.
# -MaximumRedirection 0 stops PowerShell from automatically following HTTP redirects.
try {
    $response = Invoke-WebRequest -Uri "https://ip-address:port/upload" `
        -Method Post `
        -Headers $Headers `
        -SkipCertificateCheck `
        -Form @{
            file = Get-Item -Path "C:\path\to\file" # File to upload
            path = "/tmp" # Destination path on server
        } `
        -MaximumRedirection 0
}
catch {
    # If request fails (including non-2xx responses treated as errors),
    # extract and display HTTP status code from exception's response object
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Upload sent. Server returned: $statusCode"
}
