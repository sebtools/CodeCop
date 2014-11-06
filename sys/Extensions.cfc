<cfcomponent displayname="Extensions" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<!--- Make sure .cfm and .cfc extensions exist. --->
	<cfset saveExtensionList("cfm,cfc")>
	
	<cfreturn this>
</cffunction>

<cffunction name="getExtension" returntype="query" access="public" output="no" hint="I return the requested extension.">
	<cfargument name="ExtensionID" type="string" required="yes">
	
	<!--- <cfset var qExtension = 0>
	<cfset var qRules = getRules(arguments.ExtensionID)>
	
	<cfquery name="qExtension" datasource="#variables.datasource#">
	SELECT	ExtensionID,Extension,'#ValueList(qRules.RuleID)#' AS Rules, #qRules.RecordCount# AS NumRules
	FROM	chkExtensions
	WHERE	ExtensionID = <cfqueryparam value="#arguments.ExtensionID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfreturn qExtension> --->
	<cfreturn variables.Datamgr.getRecord(tablename="chkExtensions",data=arguments)>
</cffunction>

<cffunction name="getExtensions" returntype="query" access="public" output="no" hint="I return all of the extensions.">
	<cfargument name="ids" type="string" required="no" hint="Limits the returned extensions to those whose primary key values are in this list.">
	
	<cfset var qExtensions = 0>
	<cfset var qRules = 0>
	
	<cfquery name="qExtensions" datasource="#variables.datasource#">
	SELECT	ExtensionID,Extension,'' AS Rules, 0 AS NumRules
	FROM	chkExtensions
	<cfif StructKeyExists(arguments,"ids") AND Len(arguments.ids)>
	WHERE	ExtensionID IN (<cfqueryparam value="#arguments.ids#" cfsqltype="CF_SQL_INTEGER" list="Yes">)
	</cfif>
	</cfquery>
	
	<cfloop query="qExtensions">
		<cfset qRules = getRules(ExtensionID)>
		<cfset QuerySetCell(qExtensions, "Rules", ValueList(qRules.RuleID), CurrentRow)>
		<cfset QuerySetCell(qExtensions, "NumRules", qRules.RecordCount, CurrentRow)>
		<cfset QuerySetCell(qExtensions, "Extension", Trim(Extension), CurrentRow)>
	</cfloop>
	
	<cfreturn qExtensions>
</cffunction>

<cffunction name="getRules" returntype="query" access="public" output="no" hint="I return all of the rules for the given extension.">
	<cfargument name="ExtensionID" type="string" required="yes">
	
	<cfreturn variables.DataMgr.getRecords("chkRules2Extensions",arguments)>
</cffunction>

<cffunction name="removeExtension" returntype="void" access="public" output="no" hint="I delete the given extension.">
	<cfargument name="ExtensionID" type="string" required="yes">
	
	<!--- <cfset var qRules = getRules(arguments.ExtensionID)>
	
	<cfif qRules.RecordCount>
		<cfthrow message="You cannot delete an extension that is associated with one or more rules." type="CodeCop" errorcode="ExtensionHasRules">
	</cfif> --->
	
	<cfset variables.DataMgr.deleteRecord("chkExtensions",arguments)>
	
</cffunction>

<cffunction name="saveExtension" returntype="string" access="public" output="no" hint="I save an extension.">
	<cfargument name="ExtensionID" type="string" required="no">
	<cfargument name="Extension" type="string" required="no">
	
	<!--- The extension won't include the dot (so just get everything after it - this will allow a whole file name to be passed in) --->
	<cfif StructKeyExists(arguments,"Extension")>
		<cfset arguments.Extension = Trim(ListLast(arguments.Extension,"."))>
	</cfif>
	
	<cfreturn variables.DataMgr.saveRecord("chkExtensions",arguments)>
</cffunction>

<cffunction name="saveExtensionList" returntype="string" access="public" output="no" hint="I save a list of extensions.">
	<cfargument name="Extensions" type="string" required="yes">
	
	<cfset var extension = "">
	<cfset var ExtensionID = 0>
	<cfset var result = "">
	
	<!--- People may use ";" as a delimiter, so allow that. --->
	<cfset arguments.Extensions = ReplaceNoCase(arguments.Extensions, ";", ",", "ALL")>
	
	<cftransaction>
		<!--- Loop through extensions and make sure each one is in the system --->
		<cfloop index="extension" list="#arguments.Extensions#">
			<cfset ExtensionID = saveExtension(Extension=extension)>
			<cfset result = ListAppend(result,ExtensionID)>
		</cfloop>
	</cftransaction>
	
	<cfreturn result>
</cffunction>

</cfcomponent>