<!---
NOTE: THIS ONLY WORKS ON ColdFusion2025
--->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>GetOauthAccessToken Example</title>
    <!-- Bootstrap CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Clipboard.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/clipboard@2.0.11/dist/clipboard.min.js"></script>
    <style>
        .position-relative {
            position: relative;
        }
        pre {
            white-space: pre-wrap;
            word-break: break-all;
        }
    </style>
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-primary mb-4">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">GetOauthAccessToken Example</a>
    <div class="d-flex ms-auto">
      <button class="btn btn-outline-light me-2" onclick="copyResponse()">Copy Response</button>
      <button class="btn btn-outline-warning" onclick="restartFlow()">Restart Flow</button>
    </div>
  </div>
</nav>
<div class="container py-5">
    <cftry>
        <!--- Deserialize the JSON config into a struct --->
        <cfset variables.msalConfig = DeserializeJSON(FileRead(ExpandPath('.\.env')) ) />
        

        <!--- Check if the OAuth 'code' parameter exists in the URL (callback from provider) --->
        <cfif structKeyExists(url, "code")>
            <!--- Exchange the code for an access token --->
            <cfset variables.response = GetOauthAccessToken(variables.msalConfig.credentials) />
        <cfelse>
            <!--- Exchange the code for an access token --->
            <cfset variables.response = GetOauthAccessToken(variables.msalConfig.credentials) />
        </cfif>
                

        <!--- Display the response with a click-to-copy button --->
        <div class="card shadow">
            <div class="card-header bg-primary text-white p-3">
                OAuth Response
            </div>
            <div class="card-body">
                <cfloop collection="#variables.response#" item="key">
                    <cfoutput>

                        
                        <cfif isSimpleValue(variables.response[key])>
                            <div class=" row position-relative">
                                <label for="field_#key#" class="col-sm-2 col-form-label">
                                    #encodeForHtml(key)#
                                </label>
                                <div class="col-sm-10">

                                    <div class="input-group mb-3">
                                        <button 
                                            class="btn btn-outline-secondary copy-btn" 
                                            type="button" 
                                            data-clipboard-target="##field_#key#"
                                            title="Copy value"
                                        >
                                            Copy
                                        </button>
                                        <input 
                                            type="text" 
                                            class="form-control" 
                                            id="field_#key#" 
                                            name="#key#" 
                                            value="<cfoutput>#encodeForHtml(variables.response[key])#</cfoutput>" 
                                            readonly
                                        >
                                    </div>
                                </div>
                            </div>
                        </cfif>
                    </cfoutput>
                </cfloop>


                 <hr />

                <pre id="responseText"><cfoutput>#serializeJSON(variables.response, true)#</cfoutput></pre>
            </div>
        </div>

        <script>

    
            // Initialize Clipboard.js for all copy buttons
            document.addEventListener("DOMContentLoaded", function() {
                var clipboard = new ClipboardJS('.copy-btn');
                clipboard.on('success', function(e) {
                    showToast('Copied to clipboard!', 'success', 2000);
                });
            });
            // Prettify the JSON in the <pre> tag
            document.addEventListener("DOMContentLoaded", function() {
                var pre = document.getElementById('responseText');
                try {
                    var json = JSON.parse(pre.textContent);
                    pre.textContent = JSON.stringify(json, null, 2);
                } catch (e) {
                    // If not valid JSON, leave as is
                }
            });


            // Show a toast message (reusable)
            function showToast(message, type = 'success', delay = 2000) {
                let toastContainer = document.getElementById('toastContainer');
                if (!toastContainer) {
                    toastContainer = document.createElement('div');
                    toastContainer.id = 'toastContainer';
                    toastContainer.className = 'position-fixed bottom-0 end-0 p-3';
                    toastContainer.style.zIndex = 1080;
                    document.body.appendChild(toastContainer);
                }
                // Do NOT remove previous toasts; allow stacking
                // Create toast element
                const toast = document.createElement('div');
                toast.className = `toast align-items-center text-bg-${type} border-0 show mb-2`;
                toast.setAttribute('role', 'alert');
                toast.setAttribute('aria-live', 'assertive');
                toast.setAttribute('aria-atomic', 'true');
                toast.innerHTML = `
                    <div class="d-flex">
                        <div class="toast-body">
                            ${message}
                        </div>
                        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                    </div>
                `;
                toastContainer.appendChild(toast);
                // Initialize and show the toast using Bootstrap's JS API
                if (window.bootstrap && bootstrap.Toast) {
                    new bootstrap.Toast(toast, { delay: delay }).show();
                } else {
                    // Fallback: auto-hide after delay
                    setTimeout(() => toast.remove(), delay);
                }
                // Remove toast from DOM after it hides (for Bootstrap's JS API)
                toast.addEventListener('hidden.bs.toast', function() {
                    toast.remove();
                });
            }

            function copyResponse() {
                const text = document.getElementById('responseText').innerText;
                navigator.clipboard.writeText(text).then(function() {
                    showToast('Copied to clipboard!', 'success', 2000);
                });
            }


            
            function restartFlow() {
                // Remove code param and reload page
                const url = new URL(window.location.href);
                url.searchParams.delete('code');
                window.location.href = url.toString();
            }




            function removeQueryString() {
                const url = new URL(window.location.href);
                url.search = '';
                window.history.replaceState({}, document.title, url.toString());
            }
            
        </script>
        
        <!--- Catch and dump any errors that occur during processing --->
        <cfcatch>
            <div class="alert alert-danger mt-4">
                <strong>Error:</strong>
                <pre><cfoutput>#serializeJSON(cfcatch, true)#</cfoutput></pre>
            </div>
        </cfcatch>
    </cftry>
</div>
</body>
</html>
