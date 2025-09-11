

<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>OAuth 2.0 Authorization Code Grant (Legacy Example)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .token-preview { font-family:monospace; font-size:1rem; background:##f8f9fa; border-radius:4px; padding:0.25rem 0.5rem; }
        .token-actions { display:flex; gap:0.5rem; align-items:center; }
        .card { margin-bottom: 1.5rem; }
        .card-title { font-size: 1.1rem; }
        .copy-btn { min-width: 110px; }
    </style>
    <script>
        function copyToken(tokenValue, btnId) {
            navigator.clipboard.writeText(tokenValue);
            var btn = document.getElementById(btnId);
            if (btn) {
                var orig = btn.innerHTML;
                btn.innerHTML = 'Copied!';
                setTimeout(function(){ btn.innerHTML = orig; }, 1200);
            }
        }
    </script>
</head>
<body>
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="mb-0">OAuth 2.0 Authorization Code Grant (Legacy Example)</h2>
        <a href="https://jwt.ms/" target="_blank" class="btn btn-success">Go to jwt.ms</a>
    </div>

    <!--- Load config --->
    <cfset msalConfig = DeserializeJSON(FileRead(ExpandPath('.\.env')))> 
    <cfset creds = msalConfig.credentials>
    <cfset tenant = creds.providerConfig.tenant>
    <cfset clientId = creds.clientid>
    <cfset redirectUri = creds.redirecturi>
    <cfset scope = creds.scope>
    <cfset clientSecret = creds.secretKey>
    <cfset urlParams = creds.urlparams>

    <!--- Step 1: If no code param, show button to start Microsoft login flow --->

    <cfset openIdConfigUrl = "https://login.microsoftonline.com/#tenant#/v2.0/.well-known/openid-configuration">
    <cfset openIdConfigUrl = replace(openIdConfigUrl, "#tenant#", tenant)>
    <cfhttp url="#openIdConfigUrl#" method="get" result="openidResponse" />
    <cfset openIdData = DeserializeJSON(openidResponse.fileContent)>
    <cfset authEndpoint = openIdData["authorization_endpoint"]>
    <cfset state = createUUID()>
    <cfset authUrl = authEndpoint & "?client_id=#clientId#&response_type=code&redirect_uri=#URLEncodedFormat(redirectUri)#&scope=#URLEncodedFormat(scope)#&state=#state#&#urlParams#">
    <div class="d-flex justify-content-center my-5">
        <a href="#authUrl#" class="btn btn-primary btn-lg">Sign in with Microsoft</a>
    </div>


    <!--- Step 2: Handle redirect with code param, exchange for token --->
    <cfif structKeyExists(url, "code")>
        <cfset tokenEndpoint = "https://login.microsoftonline.com/#tenant#/oauth2/v2.0/token">
        <cfset tokenEndpoint = replace(tokenEndpoint, "#tenant#", tenant)>
        <cfhttp url="#tokenEndpoint#" method="post" result="tokenResponse">
            <cfhttpparam type="formField" name="client_id" value="#clientId#">
            <cfhttpparam type="formField" name="scope" value="#scope#">
            <cfhttpparam type="formField" name="code" value="#url.code#">
            <cfhttpparam type="formField" name="redirect_uri" value="#redirectUri#">
            <cfhttpparam type="formField" name="grant_type" value="authorization_code">
            <cfhttpparam type="formField" name="client_secret" value="#clientSecret#">
        </cfhttp>
        <cfset tokenData = DeserializeJSON(tokenResponse.fileContent)>
        <cfif structKeyExists(tokenData, "access_token")>
            <cfset accessToken = tokenData.access_token>
            <div class="card border-success">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div class="card-title mb-0">Access Token</div>
                        <div class="token-actions">
                            <span class="token-preview">#left(accessToken,4)#...#right(accessToken,4)#</span>
                            <button id="accessToken-btn" class="btn btn-outline-primary btn-sm copy-btn" onclick="copyToken('#accessToken#','accessToken-btn')">Copy</button>
                        </div>
                    </div>
                </div>
            </div>
            <cfif structKeyExists(tokenData, "id_token")>
                <cfset idToken = tokenData.id_token>
                <div class="card border-info">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="card-title mb-0">ID Token</div>
                            <div class="token-actions">
                                <span class="token-preview">#left(idToken,4)#...#right(idToken,4)#</span>
                                <button id="idToken-btn" class="btn btn-outline-primary btn-sm copy-btn" onclick="copyToken('#idToken#','idToken-btn')">Copy</button>
                            </div>
                        </div>
                    </div>
                </div>
            </cfif>
            <cfif structKeyExists(tokenData, "refresh_token")>
                <cfset refreshToken = tokenData.refresh_token>
                <div class="card border-secondary">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="card-title mb-0">Refresh Token</div>
                            <div class="token-actions">
                                <span class="token-preview">#left(refreshToken,4)#...#right(refreshToken,4)#</span>
                                <button id="refreshToken-btn" class="btn btn-outline-primary btn-sm copy-btn" onclick="copyToken('#refreshToken#','refreshToken-btn')">Copy</button>
                            </div>
                        </div>
                    </div>
                </div>
            </cfif>
            <!--- Step 3: Use the access token (example: call Graph API) --->
            <cfhttp url="https://graph.microsoft.com/v1.0/me" method="get" result="graphResponse">
                <cfhttpparam type="header" name="Authorization" value="Bearer #accessToken#">
            </cfhttp>
            <div class="card border-light">
                <div class="card-body">
                    <div class="card-title">Graph API Response</div>
                    <pre style="white-space:pre-wrap;word-break:break-all;">#SerializeJSON(DeserializeJSON(graphResponse.fileContent), true)#</pre>
                </div>
            </div>
        <cfelse>
            <div class="alert alert-danger mt-4">
                <h5>Token Error</h5>
                <pre style="white-space:pre-wrap;word-break:break-all;">#SerializeJSON(tokenData, true)#</pre>
            </div>
        </cfif>
    </cfif>

    <!--- Client Credentials Grant (for demo completeness) --->
    <cfset tokenEndpoint = "https://login.microsoftonline.com/#tenant#/oauth2/v2.0/token">
    <cfset tokenEndpoint = replace(tokenEndpoint, "#tenant#", tenant)>
    <cfhttp url="#tokenEndpoint#" method="post" result="ccResponse">
        <cfhttpparam type="formField" name="client_id" value="#clientId#">
        <cfhttpparam type="formField" name="scope" value=".default">
        <cfhttpparam type="formField" name="grant_type" value="client_credentials">
        <cfhttpparam type="formField" name="client_secret" value="#clientSecret#">
    </cfhttp>
    <cfset ccData = DeserializeJSON(ccResponse.fileContent)>
    <cfif structKeyExists(ccData, "access_token")>
        <cfset ccAccessToken = ccData.access_token>
        <div class="card border-secondary">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div class="card-title mb-0">Client Credentials Access Token</div>
                    <div class="token-actions">
                        <span class="token-preview">#left(ccAccessToken,4)#...#right(ccAccessToken,4)#</span>
                        <button id="ccAccessToken-btn" class="btn btn-outline-primary btn-sm copy-btn" onclick="copyToken('#ccAccessToken#','ccAccessToken-btn')">Copy</button>
                    </div>
                </div>
            </div>
        </div>
    </cfif>
</div>
</body>
</html>
</cfoutput>
