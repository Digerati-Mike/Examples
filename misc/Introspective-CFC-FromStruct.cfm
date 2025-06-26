<!--- Set the components to be cached --->
<cfset variables.Components = {
    "dynamicComponent" : "path-my-cfc"
}>

<!--- Set to application to avoid reinitializing --->
<cfset variables.Components.each( function( item ){
    Application['components'][ item ] = CreateObject( "Component", variables.Components[item] )
} ) >
