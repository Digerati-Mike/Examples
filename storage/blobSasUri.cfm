<cfscript>
    // Get Storage Service
    storageService = getCloudService('{{alias}}', '{{alias}}')
 
    // Set the container
    Documents = storageService.container( "{{cient_container}}" , true)
 
    // Set the repo Contents
    DocumentList = Documents.ListAll({
        "prefix" : "{{client_folder}}/other_folder",
        "listingDetails" : [
            "METADATA"
        ]
    }).response
   
    // Set the Start and End Date
    StartDate = DateTimeFormat( Now(), "m/dd/yyyy" )
    EndDate = DateTimeFormat( DateAdd( "d", 1, StartDate ), "m/dd/yyyy" )
   
    // Get the shared access signature
    sharedAccessSignature = Documents.generateSas( {
    "blobName" :  "#DocumentList[1].blobName#",
    "policy" : {
            "permissions" : ["READ"],
            "sharedAccessExpiryTime" : "#EndDate#",
            "sharedAccessStartTime" : "#StartDate#"
        }
    } );

    location( url = "https://storageAccountName.blob.core.windows.net/path-to-the-blob-endpoint?#sharedAccessSignature.sas#", addtoken=false )
</cfscript>
