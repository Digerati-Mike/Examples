<!--- Add Bootstrap 5 CSS --->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<cfscript>
  // Get container name from form or use default
  variables.selectedContainer = trim( form.newContainerName ?: "mycontainer" );
  variables.selectedContainer = "mycontainer"
  

  // Set the name of the Azure Blob Storage account
  variables.storageName = "{{storageAccount}}";

  // Get the cloud storage service object using the storage account name
  variables.storageService = getCloudService( variables.storageName, variables.storageName );

  // List all containers in the storage account
  variables.containers = variables.storageService.listAll();

  // Get a reference to the root object of the specified container
  variables.rootObj = storageService.root( variables.selectedContainer, "true" );

  // If a new container name is submitted, create it
  if ( structKeyExists(form, "newContainerName") && len(trim(form.newContainerName)) ) {


    // Get a reference to the root object of the specified container
    variables.rootObj = storageService.root( form.newContainerName, "true" );
    variables.tmpFile = ExpandPath('./README.md');

    FIleWrite( variables.tmpFile, "This is a README file for the new container: #trim(form.newContainerName)#.#Chr(10)# Created: #now()#" );
    
    // Upload the File
    uploadResponse = variables.rootObj.uploadFile( {
        "srcFile" : variables.tmpFile,
        "key": 'README.md'
    } ) 
    
    // Delete the TMP directory
    FileDelete( variables.tmpFile )
    
    // Refresh containers list after creation
    variables.containers = variables.storageService.listAll();
    // Optionally, set the new container as selected
    variables.selectedContainer = trim(form.newContainerName);
  }

  // Define the path to the test file to upload
  variables.testFile = ExpandPath('./text.txt');

  // If the test file does not exist, create it with sample content
  if( !FileExists(variables.testFile) ){
      FileWrite( variables.testFile, "This is a test file for the Cloud Storage Service.#Chr(10)# Created: #now()#" );
  }

  // Upload the test file to the Azure Blob Storage container as "test.txt"
  variables.uploadResponse = rootObj.uploadFile({
    "srcFile": variables.testFile,
    "key": "test.txt"
  } );
</cfscript>

<cfoutput>
  <div class="container mt-5">
    <h2>Azure Blob Storage Containers</h2>
    <!-- Form to select container -->
    <form method="post" class="mb-4">
      <div class="mb-3 mt-4">
        <label for="newContainerName" class="form-label">Add New Container</label>
        <input type="text" class="form-control" id="newContainerName" name="newContainerName" placeholder="Enter new container name">
      </div>
      <button type="submit" class="btn btn-success">Add Container</button>
    </form>

    <table class="table table-striped">
      <thead>
        <tr>
          <th>Container Name</th>
        </tr>
      </thead>
      <tbody>
        <cfloop array="#variables.containers#" index="container">
          <tr>
            <td>#container.name#</td>
          </tr>
        </cfloop>
      </tbody>
    </table>
    <div class="alert alert-success mt-3" role="alert">
      File uploaded successfully to <strong>#variables.selectedContainer#</strong>
    </div>
  </div>
</cfoutput>
