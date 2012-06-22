<cfcomponent displayname="TestInstall"  extends="mxunit.framework.TestCase">

  <cffunction name="setUp" returntype="void" access="public">
		<cfset ssh = createObject("component","cfssh.src.tag.cfssh.ssh") />
		<!--- creds.txt : user@hostname=password --->
		<cffile action="read" file="#expandpath('/cfssh')#/tests/tag/cfssh/creds.txt" variable="userpass" />
		<cfset variables.userhost = listFirst(userpass,"=") />
		<cfset variables.password = listLast(userpass,"=") />
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
  </cffunction>

  <cffunction name="tearDown" returntype="void" access="public">
  </cffunction>

	<cffunction name="dumpvar" access="private">
		<cfargument name="var">
		<cfdump var="#var#">
		<cfabort/>
	</cffunction>

	<cffunction name="testExec">
		<cfscript>
		var host=listLast(variables.userhost,"@");
		var port="22";
		var timeout="3";
		var username=listFirst(variables.userhost,"@");
		var password=variables.password;
		var userinput = "ls -al";
		var connected = ssh._init(username,password,host,port,timeout);
		assertTrue(connected);
		debug(ssh.exec(username=username,password=password,host=host,userinput=userinput));
		</cfscript>
	</cffunction>

</cfcomponent>