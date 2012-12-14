<cfcomponent displayname="TestInstall"  extends="mxunit.framework.TestCase">

  <cffunction name="setUp" returntype="void" access="public">
		<cfset ssh = createObject("component","cfssh.tag.cfssh.cfc.ssh") />
		<cftry>
			<cfset wee = createObject("java","com.jcraft.jsch.JSch").init() />
			<cfcatch>
				<cfif findNoCase("class",cfcatch.Type)>
					<cfset install = createObject("component","cfssh.tests.extension.TestInstall") />
					<cfset install.setUp() />
					<cfset install.testAddJars() />
					<cftry>
						<cfset install.testInstallDevCustomTag(false) />
					<cfcatch></cfcatch>
					</cftry>
					<cfset variables.ssh = createObject("component","cfssh.src.tag.cfssh.ssh") />
				</cfif>
			</cfcatch>
		</cftry>
		<cf_sshd action="start" />
  </cffunction>

  <cffunction name="tearDown" returntype="void" access="public">
		<cf_sshd action="stop" />
  </cffunction>

	<cffunction name="dumpvar" access="private">
		<cfargument name="var">
		<cfdump var="#var#">
		<cfabort/>
	</cffunction>

	<cffunction name="testExec">
		<cfscript>
		var attrs = {
			host="127.0.0.1",
			port="2022",
			timeout="3000",
			username="testuser",
			password="testuser",
			action="exec",
			userinput = "ls -al"
			};
		debug(ssh.runAction(attrs));
		</cfscript>
	</cffunction>

</cfcomponent>