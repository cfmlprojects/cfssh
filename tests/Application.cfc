<cfcomponent output="false"><cfscript>
	/* Application settings */
	this.name = hash(getCurrenttemplatepath());
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,2,0,0);
</cfscript></cfcomponent>