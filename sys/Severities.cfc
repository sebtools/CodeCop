<cfcomponent displayname="Severity" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfreturn this>
</cffunction>

<cffunction name="getDefaultSeverityID" access="public" returntype="numeric" output="no" hint="I get (my best guess of) a default severity.">
	
	<cfset var qSeverities = 0>
	<cfset var result = 0>
	
	<!---
	OK. So why do I guess at a default severity instead of allowing it to be set.
	1) In most situations, it doesn't matter. No one will mess with severities.
	2) In those other sitations (where people do mess with severities), it being set will mess with the ability to pass around rules.
		The problem is that people may expect their settings on this default to pass around or they may not.
		So, I avoid that confusion by not allowing it to be set.
	--->
	
	<cfquery name="qSeverities" datasource="#variables.datasource#">
	SELECT		SeverityID
	FROM		chkSeverities
	ORDER BY	rank
	</cfquery>
	
	<cfset result = qSeverities.SeverityID[Round(qSeverities.RecordCount/2)]>
	
	<cfreturn result>
</cffunction>

<cffunction name="getSeverityID" returntype="numeric" access="public" output="no" hint="I return the requested severity.">
	<cfargument name="SeverityName" type="string" required="yes">
	
	<cfset var qSeverity = 0>
	<cfset var result = 0>
	
	<cfquery name="qSeverity" datasource="#variables.datasource#">
	SELECT	SeverityID
	FROM	chkSeverities
	WHERE	SeverityName = <cfqueryparam value="#arguments.SeverityName#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif qSeverity.RecordCount eq 1>
		<cfset result = qSeverity.SeverityID>
	<cfelse>
		<cfset result = getDefaultSeverityID()>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getSeverity" returntype="query" access="public" output="no" hint="I return the requested severity.">
	<cfargument name="SeverityID" type="string" required="yes">
	
	<cfreturn variables.DataMgr.getRecord("chkSeverities",arguments)>
</cffunction>

<cffunction name="getSeverities" returntype="query" access="public" output="no" hint="I return all of the severities.">
	
	<cfset var qSeverities = 0>
	
	<cfquery name="qSeverities" datasource="#variables.datasource#">
	SELECT		SeverityID,SeverityName
	FROM		chkSeverities
	ORDER BY	rank DESC
	</cfquery>
	
	<cfreturn qSeverities>
</cffunction>

<cffunction name="removeSeverity" returntype="void" access="public" output="no" hint="I delete the given Severity.">
	<cfargument name="SeverityID" type="string" required="yes">
	
	<cfset variables.DataMgr.deleteRecord("chkSeverities",arguments)>
	
</cffunction>

<cffunction name="saveSeverity" returntype="string" access="public" output="no" hint="I save a Severity.">
	<cfargument name="SeverityID" type="string" required="no">
	<cfargument name="SeverityName" type="string" required="no">
	
	<cfreturn variables.DataMgr.saveRecord("chkSeverities",arguments)>
</cffunction>

</cfcomponent>