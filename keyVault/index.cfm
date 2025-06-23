<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Index Template</title>
    <!-- CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.3.1/styles/default.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.1.0-beta.1/css/select2.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" integrity="sha384-wvfXpqpZZVQGK6TAh5PVlGOfQNHSoD2xbE+QkPxCAFlNEevoEH3Sl0sibVcOQVnN" crossorigin="anonymous">
</head>
<body>
    <div class="container">
        <h1 class="text-primary text-center">IMS / Key Vault Example</h1>
        <hr />
        
        <!-- Initialize IMS object -->
        <cfset variables.ims = new ims()>
        
        <!-- Set the Key Vault name -->
        <cfset variables.keyVaultName = "[VAULT-NAME]">

        <!-- Authenticate and retrieve token -->
        <cfset variables.token = variables.ims.Auth()>

        <!-- Initialize KeyVault object with vault name and authentication token -->
        <cfset variables.keyVault = new KeyVault({
            "vaultName" = variables.keyVaultName,
            "auth" : variables.token
        })>

        <!-- Retrieve secrets from the Key Vault -->
        <cfset variables.keyVaultSecrets = variables.keyVault.getSecrets()>

        <!-- Display the retrieved secrets -->
        <cfdump var="#variables.keyVaultSecrets#">
    </div>
    <!-- JavaScript -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
