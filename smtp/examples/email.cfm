<cfscript>
    // Set the Microsoft Graph API endpoint for sending email
    variables.endpoint = "https://graph.microsoft.com/v1.0/me/sendmail";

    // Prepare HTTP headers with authorization and content type
    variables.headers = {
        "authorization" : "bearer " & session.token.access_token,
        "content-type" : "application/json"
    }

    // Build the email payload with subject, body, and recipient
    variables.payload = {
        "message" : {
            "subject" : form.subject,
            "body" : {
                "contenttype" : "text",
                "content" : form.content
            },
            "torecipients" : [
                {
                    "emailaddress" : {
                        "address" : form.recipientemail
                    }
                }
            ]
        }
    };


    

    // Send the email using cfhttp to the Microsoft Graph API
    cfhttp( url = variables.endpoint, method = "post", result = "httpresponse" ) {
        cfhttpparam( type = "header", name = "authorization", value = variables.headers["authorization"] );
        cfhttpparam( type = "header", name = "content-type", value = variables.headers["content-type"] );
        cfhttpparam( type = "body", value = serializejson( variables.payload ) );
    }

    // Output confirmation message
    writeoutput( "email sent!" );

    // Dump the HTTP response for debugging
    writedump( var = httpresponse, top = 5 );
</cfscript>
