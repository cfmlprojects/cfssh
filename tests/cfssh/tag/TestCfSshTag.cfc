<cfcomponent displayname="TestCfSsh"  extends="mxunit.framework.TestCase">

	<cfimport taglib="/cfssh/tag/cfssh" prefix="sh" />

	<cffunction name="setUp" returntype="void" access="public">
		<cfset workdir = expandPath("/tests/cfssh") & "/work" />
		<cfset directoryExists(workdir) ? directoryDelete(workdir, true) : "" />
		<cfset directoryCreate(workdir) />
		<cf_sshd action="start" />
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<cf_sshd action="stop" />
	</cffunction>

	<cffunction name="testSshExecTag">
		<cffile action="write" file="#workdir#/testexec.txt" output="this is a test!" />
		<cfscript>
			var host="127.0.0.1";
			var port="2022";
			var timeout="8000";
			var username="testuser";
			var password="testuser";
		</cfscript>
		<sh:ssh action="exec"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#">ls</sh:ssh>
			<cfset assertEquals(1,arrayLen(ssh))/>
		<cfset debug(ssh[1]) />
<!---
		<sh:ssh action="exec"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#">ls -al
			ls -al
			ls -al</sh:ssh>
			<cfset assertEquals(3,arrayLen(ssh))/>
		<cfset debug(ssh) />
 --->
	</cffunction>

	<cffunction name="testSshShellTag">
		<cfscript>
			var host="127.0.0.1";
			var port="2022";
			var timeout="3";
			var username="testuser";
			var password="testuser";
		</cfscript>
		<sh:ssh action="shell"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#">ls -al
ls -al
ls -al
ls -al</sh:ssh>
			<cfset request.debug(ssh) />
			<cfset assertTrue(findNoCase("total",ssh))/>
	</cffunction>

	<cffunction name="testListDir">
		<cfscript>
			var host="127.0.0.1";
			var port="2022";
			var timeout="3";
			var username="testuser";
			var password="testuser";
		</cfscript>
		<sh:ssh action="listdir"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#" />
		<cfset debug(ssh) />
	</cffunction>

	<cffunction name="testPutFile">
		<cffile action="write" file="#workdir#/testput.txt" output="this is a test!" />
		<cfscript>
			var host="127.0.0.1";
			var port="2022";
			var timeout="3";
			var username="testuser";
			var password="testuser";
		</cfscript>
		<sh:ssh action="putFile" localFile="#workdir#/testput.txt"
			filename="putted.txt" remotedirectory="#workdir#"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#" />
		<cfset assertEquals(fileRead("#workdir#/testput.txt"),fileRead("#workdir#/putted.txt")) />
		<cfset debug(ssh) />
	</cffunction>

	<cffunction name="testGetFile">
		<cfscript>
			var host="127.0.0.1";
			var port="2022";
			var timeout="3";
			var username="testuser";
			var password="testuser";
			testPutFile();
		</cfscript>
		<sh:ssh action="getFile"
			remoteFile="#workdir#/testput.txt"
			localFile="#workdir#/getted.txt"
			username="#username#" password="#password#" host="#host#"
			port="#port#" timeout="#timeout#" />
		<cfset assertEquals(fileRead("#workdir#/testput.txt"),fileRead("#workdir#/getted.txt")) />
		<cfset debug(ssh) />
	</cffunction>

</cfcomponent>
