component {
	this.ApplicationManagement 	= 	true
	this.ApplicationTimeOut 	= 	CreateTimeSpan( 1, 0, 0, 0 )
	
	this.SessionManagement		= 	true
	this.SessionTimeout 		= 	CreateTimeSpan( 0, 1, 0, 0 )
	
	this.LoginStorage 			= 	"Session"
	this.clientManagement 		= 	true
	this.protectScript			=	"all"
	this.requestTimeOut			=	72000
    this.name					=	"SMTP Demo v1.0.0" 
    
	

    /* REST SPECIFIC */
    this.restsettings.autoregister = true;
    this.restsettings.skipCFCWithError = false;
    this.restSettings.isDefault = false;


	public boolean function OnApplicationStart() {
		

		Application.Env = DeserializeJSON( FileRead( expandPath('\.env') ) );

		
		return true;
	}

	public void function OnSessionStart() { 
		// Fires when the session is first created.

		Session.LoggedIn = false;


		return;
	};
	
	
	
	
    public void function onRequestStart( string targetPage ) {
       

		variables.requestData = getHTTPRequestData()

		variables.remote_addr = structKeyExists( variables.requestData.headers, "x-forwarded-for" ) && len( variables.requestData.headers["x-forwarded-for"] )
			? variables.requestData.headers["x-forwarded-for"]
			: CGI.REMOTE_ADDR;


		null = ""
    }
    
    public function OnRequest( required string TargetPage ) {
        // Fire when the page is requested. This is where any routes will take place.
		

        include targetpage
    }

    public void function onRequestEnd() {
        // Run any code you need to run at the end of each request
		
		
    }

    public void function onSessionEnd(struct sessionScope, struct applicationScope) {
        // Run any code you need to run at the end of the session
		
				

    }

    public void function onApplicationEnd( struct applicationScope ) {
        // Run any code you need to run at the end of the application
    }
	
    
	
	public void function OnMissingTemplate( required string targetPage = CGI.SCRIPT_NAME ){
		// Runs when a template is missing and being called from within ColdFusion.
		
		//include "./app/errors/404.cfm"
	};
	


	public void function OnAbort( required string targetPage ) {
		// Triggers when a cfabort or abort function is used from within coldfusion
	}
	
    
	public void function OnError( 
		required any Exception, 
		string EventName=""
	){
		writeDump( var = exception, top = 5 );
		
		
		return;
	}
}
