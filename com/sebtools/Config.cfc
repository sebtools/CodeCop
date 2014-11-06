<cfcomponent displayname="Config" output="no" hint="Handles the configuration of the system.">

<cffunction name="init" access="public" returntype="any" output="no" hint="I initialize and return this component.">
	<cfargument name="CGI" type="struct" required="true" />
	<cfargument name="RootPath" type="string" required="true" />
	
	<cfset variables.CGI = arguments.CGI>
	<cfset variables.Paths = StructNew()>
	<cfset variables.Seperators = StructNew()>
	
	<cfset variables.Paths.Server = StructNew()>
	<cfset variables.Paths.Web = StructNew()>
	
	<cfset variables.Paths.Server.Root = arguments.RootPath>
	<cfset setWebRoot()><!--- <cfset variables.Paths.Web.Root = ""> --->
	<cfset variables.Paths.Server.Current = GetCurrentTemplatePath()>
	<cfset variables.Paths.Web.Current = variables.CGI.SCRIPT_NAME>
	
	<cfset variables.Seperators.Server = CreateObject("java", "java.io.File").separator>
	<cfset variables.Seperators.Web = "/">
	
	<cfreturn this>
</cffunction>

<cffunction name="getPaths" access="public" returntype="struct" output="no">
	<cfreturn variables.Paths>
</cffunction>

<cffunction name="setWebRoot" access="private" returntype="string" output="no">
	
	<cfset var WebRoot = "">
	
	<cfset RelPath = ReplaceNoCase(GetDirectoryFromPath(GetBaseTemplatePath()), variables.Paths.Server.Root, "")>
	
	<cfset RelPath = ReplaceNoCase(RelPath,"\","/","ALL")>
	<cfif Len(RelPath)>
		<cfset RelPath = ReplaceNoCase(variables.CGI.SCRIPT_NAME,RelPath,"","ALL")>
		<cfset RelPath = ReplaceNoCase(RelPath,ListLast(variables.CGI.SCRIPT_NAME,"/"),"","ALL")>
	<cfelse>
		<cfset RelPath = ReplaceNoCase(CGI.SCRIPT_NAME,ListLast(variables.CGI.SCRIPT_NAME,"/"),"","ALL")>
	</cfif>
	
	<cfset variables.Paths.Web.Root = RelPath>
	
</cffunction>

</cfcomponent>
