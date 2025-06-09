component accessors = "true" {

    /**
    * Example of a secure init method checking each key/value in a dynamic object. 
    * - I have not tested with complex objects (struct of structs or arrays in the object
    */
      
    /**
    * @hint Initialize Component Properties
    * @returnType any
    */
    function init( any dynamicProperties = {} ){

        // Set Initialized Properties securely
        for (var key in dynamicProperties) {
            if (isSafeHtml(dynamicProperties[key]) && IsSafeHtml( key )) {
                variables[ Trim( key ) ] = getSafeHtml( dynamicProperties[ GetSafeHtml( key ) ] );
            }
        }
        
        return this;
    };

}
