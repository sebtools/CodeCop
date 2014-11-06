<cfcomponent>

<cffunction name="init" access="public" returntype="layout" output="no">
	<cfargument name="ScriptName" type="string" required="yes">
	<cfargument name="Config" type="any" required="yes">
	
	<!--- <cfset variables.Factory = arguments.Loader> --->
	<cfset variables.ScriptName = arguments.ScriptName>
	
	<cfset variables.FileName = ListLast(arguments.ScriptName,"/")>
	<cfset variables.Config = arguments.Config>
	
	<cfset variables.Paths = variables.Config.getPaths()>
	
	<cfset variables.WebRoot = variables.Paths.Web.Root>
	
	<cfset variables.me = StructNew()>
	<cfset variables.me.section = "">
	
	<cfreturn this>
</cffunction>

<cffunction name="switchLayout" access="public" returntype="layout" output="no">
	<cfargument name="layout" type="string" required="yes">
	
	<cfset var result = CreateObject("component",layout)>
	
	<cfset result.init(variables.FileName,variables.Config)><!--- variables.Factory --->
	
	<cfset result.setMe(variables.me)>
	<cfset this = result>
	
	<cfreturn result>
</cffunction>

<cffunction name="setMe" access="package" returntype="void" output="no">
	<cfargument name="me" type="struct" required="yes">
	
	<cfset variables.me = me>

</cffunction>

</cfcomponent>
