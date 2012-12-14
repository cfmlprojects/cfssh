<cffunction name="ssh">
	<cfscript>
		var jm = createObject("WEB-INF.railo.customtags.cfssh.cfc.ssh");
		var results = jm.runAction(arguments);
		return results;
	</cfscript>
</cffunction>