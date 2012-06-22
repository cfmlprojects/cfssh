<cfcomponent>

	<cfset this.metadata.attributetype="mixed">
	<cfset this.metadata.attributes={
		action:			{required:true,type:"string",default:"sshToHtml"},
		name:	{required:false,type:"string",default:"ssh"}
		}/>
	<cfset _log = [] />

	<cffunction name="onStartTag" output="yes" returntype="boolean">
		<cfargument name="attributes" type="struct">
		<cfargument name="caller" type="struct">
		<cfif structKeyExists(attributes,"argumentCollection")>
			<cfset attributes = attributes.argumentCollection />
		</cfif>
		<cfif not variables.hasEndTag>
			<cfset onEndTag(attributes,caller,"") />
		</cfif>
		<cfreturn variables.hasEndTag>
	</cffunction>

	<cffunction name="onEndTag" output="yes" returntype="boolean">
		<cfargument name="attributes" type="struct">
		<cfargument name="caller" type="struct">
		<cfargument name="generatedContent" type="string">
		<cfscript>
			if(len(trim(generatedContent))) {
				attributes.content = generatedContent;
			}
			caller[attributes.name] = runAction(attributes);
		</cfscript>
		<cfreturn false/>
	</cffunction>

	<cffunction name="runAction" output="false" hint="for calling from function, etc.">
		<cfargument name="attributes" required="true" />
		<cfscript>
			var processor = new jsch();
			if(structKeyExists(attributes,"content")) {
				attributes.userinput = attributes.content;
			}
			return processor[attributes.action](argumentCollection=attributes);
		</cfscript>
	</cffunction>

	<cffunction name="init" output="no" returntype="void" hint="invoked after tag is constructed">
		<cfargument name="hasEndTag" type="boolean" required="yes" />
		<cfargument name="parent" type="component" required="no" hint="the parent cfc custom tag, if there is one" />
		<cfset variables.hasEndTag = arguments.hasEndTag />
	</cffunction>

</cfcomponent>
