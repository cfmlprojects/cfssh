<cfcomponent displayname="TestCfSsh"  extends="mxunit.framework.TestCase">

	<cfimport taglib="/cfssh/tag/cfssh" prefix="sh" />

	<cffunction name="setUp" returntype="void" access="public">
		<!--- creds.txt : user@hostname=password --->
		<cffile action="read" file="#expandpath('/tests')#/cfssh/creds.txt" variable="userpass" />
		<cfset variables.username = listFirst(userpass,"=") />
		<cfset variables.password = listLast(userpass,"=") />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public"></cffunction>

	<cffunction name="dumpvar" access="private"><cfargument name="var" />
		<cfdump var="#var#" />
		<cfabort /></cffunction>

	<cffunction name="testSshExecTag">
		<cfscript>
			var host=listLast(variables.username,"@");
			var port="22";
			var timeout="3";
			var username=listFirst(variables.username,"@");
			var password=variables.password;
		</cfscript>
		<sh:ssh action="exec"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#">ls -al</sh:ssh>
			<cfset request.debug(ssh) />
			<cfset assertEquals(1,arrayLen(ssh))/>
		<cfset debug(ssh) />
		<sh:ssh action="exec"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#">ls -al
			ls -al
			ls -al</sh:ssh>
			<cfset assertEquals(3,arrayLen(ssh))/>
		<cfset debug(ssh) />
	</cffunction>

	<cffunction name="testListDir">
		<cfscript>
			var host=listLast(variables.username,"@");
			var port="22";
			var timeout="3";
			var username=listFirst(variables.username,"@");
			var password=variables.password;
		</cfscript>
		<sh:ssh action="listdir"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#" />
		<cfset debug(ssh) />
	</cffunction>

	<cffunction name="testPutFile">
		<cfscript>
			var host=listLast(variables.username,"@");
			var port="22";
			var timeout="3";
			var username=listFirst(variables.username,"@");
			var password=variables.password;
		</cfscript>
		<sh:ssh action="putFile" localFile="#expandPath("/tests")#/run.cfm"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#" />
		<cfset debug(ssh) />
	</cffunction>

	<cffunction name="testGetFile">
		<cfscript>
			var host=listLast(variables.username,"@");
			var port="22";
			var timeout="3";
			var username=listFirst(variables.username,"@");
			var password=variables.password;
		</cfscript>
		<sh:ssh action="getFile"
			remoteFile="run.cfm"
			localFile="#expandPath("/tests")#/data/got.txt"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#" />
		<cfset debug(ssh) />
	</cffunction>

</cfcomponent>
