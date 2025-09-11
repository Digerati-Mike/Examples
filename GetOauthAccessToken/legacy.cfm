

<cfoutput>
    <!--- JWT.ms Top Button and Copy-to-Clipboard Script --->
    <script>
    function copyToken(tokenId) {
        var copyText = document.getElementById(tokenId);
        if (copyText) {
            navigator.clipboard.writeText(copyText.textContent || copyText.value);
            var btn = document.getElementById(tokenId + '-btn');
            if (btn) {
                var orig = btn.innerHTML;
                btn.innerHTML = 'Copied!';
                setTimeout(function(){ btn.innerHTML = orig; }, 1200);
            }
        }
    }
    </script>

    <div class="container mt-3 mb-2">
        <a href="https://jwt.ms/" target="_blank" class="btn btn-success">Go to jwt.ms</a>
    </div>


    <!--- Bootstrap 5 CSS --->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" >

    <!--- Load config --->
    <cfset msalConfig = DeserializeJSON(FileRead(ExpandPath('.\.env')))>
    <cfset creds = msalConfig.credentials>
    <cfset tenant = creds.providerConfig.tenant>
    <cfset clientId = creds.clientid>
    <cfset redirectUri = creds.redirecturi>
    <cfset scope = creds.scope>
    <cfset clientSecret = creds.secretKey>
    <cfset urlParams = creds.urlparams>


    <!--- UI: Start/Restart Authorization Code Flow Button --->
    <div class="container my-4">
    <h2>OAuth 2.0 Authorization Code Grant (Legacy Example)</h2>

    <!--- Step 1: If no code param, show button to start Microsoft login flow --->
    <cfif NOT structKeyExists(url, "code")>
        <cfset openIdConfigUrl = "https://login.microsoftonline.com/#tenant#/v2.0/.well-known/openid-configuration">
        <cfset openIdConfigUrl = replace(openIdConfigUrl, "#tenant#", tenant)>
        <cfhttp url="#openIdConfigUrl#" method="get" result="openidResponse" />
        <cfset openIdData = DeserializeJSON(openidResponse.fileContent)>
        <cfset authEndpoint = openIdData["authorization_endpoint"]>
        <cfset state = createUUID()>
        <cfset authUrl = authEndpoint & "?client_id=#clientId#&response_type=code&redirect_uri=#URLEncodedFormat(redirectUri)#&scope=#URLEncodedFormat(scope)#&state=#state#&#urlParams#">
        <div class="container my-4">
            <a href="#authUrl#" class="btn btn-success">Sign in with Microsoft</a>
        </div>
        <cfabort>
    </cfif>

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
            <div class="container">
                <div class="alert alert-success mt-4">
                    <h5>Token Data</h5>
                    <button id="accessToken-btn" class="btn btn-outline-primary btn-sm mb-2" onclick="copyToken('accessToken')">Copy Access Token</button>
                    <pre id="accessToken" style="white-space:pre-wrap;word-break:break-all;">#tokenData.access_token#</pre>
                    <pre style="white-space:pre-wrap;word-break:break-all;">#SerializeJSON(tokenData, true)#</pre>
                </div>
            </div>
            <!--- Step 3: Use the access token (example: call Graph API) --->
            <cfhttp url="https://graph.microsoft.com/v1.0/me" method="get" result="graphResponse">
                    <cfhttpparam type="header" name="Authorization" value="Bearer #accessToken#">
            </cfhttp>
            <div class="container">
                <div class="alert alert-info mt-2">
                    <h5>Graph API Response</h5>
                    <pre style="white-space:pre-wrap;word-break:break-all;">#SerializeJSON(DeserializeJSON(graphResponse.fileContent), true)#</pre>
                </div>
            </div>
            <cfif structKeyExists(tokenData, "id_token")>
                <div class="container">
                    <button id="idToken-btn" class="btn btn-outline-primary btn-sm mb-2" onclick="copyToken('idToken')">Copy ID Token</button>
                    <pre id="idToken" style="white-space:pre-wrap;word-break:break-all;">#tokenData.id_token#</pre>
                </div>
            </cfif>
        <cfelse>
            <div class="container">
                <div class="alert alert-danger mt-4">
                    <h5>Token Error</h5>
                    <pre style="white-space:pre-wrap;word-break:break-all;">#SerializeJSON(tokenData, true)#</pre>
                </div>
            </div>
        </cfif>
    </cfif>

    <!--- Exchange refresh_token for new access token --->
    <cfset refreshToken = "#tokenData.refresh_token#">
    <cfset tokenEndpoint = "https://login.microsoftonline.com/#tenant#/oauth2/v2.0/token">
    <cfset tokenEndpoint = replace(tokenEndpoint, "#tenant#", tenant)>
    <cfhttp url="#tokenEndpoint#" method="post" result="refreshResponse">
        <cfhttpparam type="formField" name="client_id" value="#clientId#">
        <cfhttpparam type="formField" name="scope" value="#scope#">
        <cfhttpparam type="formField" name="refresh_token" value="#refreshToken#">
        <cfhttpparam type="formField" name="grant_type" value="refresh_token">
        <cfhttpparam type="formField" name="client_secret" value="#clientSecret#">
    </cfhttp>
    <cfset refreshData = DeserializeJSON(refreshResponse.fileContent)>
    <div class="container">
        <div class="alert alert-secondary mt-4">
            <h5>Refresh Token Response</h5>
            <cfif structKeyExists(refreshData, "access_token")>
                <button id="refreshAccessToken-btn" class="btn btn-outline-primary btn-sm mb-2" onclick="copyToken('refreshAccessToken')">Copy Access Token</button>
                <pre id="refreshAccessToken" style="white-space:pre-wrap;word-break:break-all;">#refreshData.access_token#</pre>
            </cfif>
            <cfif structKeyExists(refreshData, "refresh_token")>
                <button id="refreshToken-btn" class="btn btn-outline-primary btn-sm mb-2" onclick="copyToken('refreshToken')">Copy Refresh Token</button>
                <pre id="refreshToken" style="white-space:pre-wrap;word-break:break-all;">#refreshData.refresh_token#</pre>
            </cfif>
            <pre style="white-space:pre-wrap;word-break:break-all;">#SerializeJSON(refreshData, true)#</pre>
        </div>
    </div>

    <!--- Client Credentials Grant --->
    <cfset tokenEndpoint = "https://login.microsoftonline.com/#tenant#/oauth2/v2.0/token">
    <cfset tokenEndpoint = replace(tokenEndpoint, "#tenant#", tenant)>
    <cfhttp url="#tokenEndpoint#" method="post" result="ccResponse">
        <cfhttpparam type="formField" name="client_id" value="#clientId#">
        <cfhttpparam type="formField" name="scope" value="#scope#">
        <cfhttpparam type="formField" name="grant_type" value="client_credentials">
        <cfhttpparam type="formField" name="client_secret" value="#clientSecret#">
    </cfhttp>
    <cfset ccData = DeserializeJSON(ccResponse.fileContent)>
    <div class="container">
        <div class="alert alert-secondary mt-4">
            <h5>Client Credentials Response</h5>
            <cfif structKeyExists(ccData, "access_token")>
                <button id="ccAccessToken-btn" class="btn btn-outline-primary btn-sm mb-2" onclick="copyToken('ccAccessToken')">Copy Access Token</button>
                <pre id="ccAccessToken" style="white-space:pre-wrap;word-break:break-all;">#ccData.access_token#</pre>
            </cfif>
            <pre style="white-space:pre-wrap;word-break:break-all;">#SerializeJSON(ccData, true)#</pre>
        </div>
    </div>
</cfoutput>
