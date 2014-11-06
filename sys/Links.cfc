<cfcomponent displayname="Link" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfreturn this>
</cffunction>

<cffunction name="getLink" returntype="query" access="public" output="no" hint="I return the requested link.">
	<cfargument name="LinkID" type="string" required="yes">
	
	<cfreturn variables.DataMgr.getRecord("chkLinks",arguments)>
</cffunction>

<cffunction name="getLinks" returntype="query" access="public" output="no" hint="I return all of the links.">
	
	<!--- Rare that a getRecords() method stays intact, but no reason to change yet --->
	<cfreturn variables.DataMgr.getRecords("chkLinks",arguments)>
</cffunction>

<cffunction name="removeLink" returntype="void" access="public" output="no" hint="I delete the given Link.">
	<cfargument name="LinkID" type="string" required="yes">
	
	<cfset variables.DataMgr.deleteRecord("chkLinks",arguments)>
	
</cffunction>

<cffunction name="saveLink" returntype="string" access="public" output="no" hint="I save a Link.">
	<cfargument name="LinkID" type="string" required="no">
	<cfargument name="RuleID" type="string" required="no">
	<cfargument name="LinkText" type="string" required="no">
	<cfargument name="LinkURL" type="string" required="no">
	
	<cfreturn variables.DataMgr.saveRecord("chkLinks",arguments)>
</cffunction>

</cfcomponent>