<cfcomponent displayname="Categories" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfreturn this>
</cffunction>

<cffunction name="getCategory" returntype="query" access="public" output="no" hint="I return the requested category.">
	<cfargument name="CategoryID" type="string" required="yes">
	
	<!--- <cfset var qCategory = 0>
	<cfset var qRules = getRules(arguments.CategoryID)> --->
	
	<!--- Return the record for this category with a list of the rules under it --->
	<!--- I use value list because it keeps me from having to use some convoluted SQL approach --->
	<!--- <cfquery name="qCategory" datasource="#variables.datasource#">
	SELECT	CategoryID,CategoryName,'#ValueList(qRules.RuleID)#' AS Rules, #qRules.RecordCount# AS NumRules
	FROM	chkCategories
	WHERE	CategoryID = <cfqueryparam value="#arguments.CategoryID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery> --->
	
	<!--- <cfreturn qCategory> --->
	<cfreturn variables.Datamgr.getRecords(tablename="chkCategories",data=arguments)>
</cffunction>

<cffunction name="getCategories" returntype="query" access="public" output="no" hint="I return all of the categories.">
	
	<!--- <cfset var qCategories = 0>
	<cfset var qRules = 0>
	
	<cfquery name="qCategories" datasource="#variables.datasource#">
	SELECT		CategoryID,CategoryName,'' AS Rules, 0 AS NumRules
	FROM		chkCategories
	ORDER BY	CategoryName
	</cfquery> --->
	
	<!--- I can't include the ValueList in the query itself, so I add it back in (can't find a database-agnostic way to do this in SQL) --->
	<!--- <cfloop query="qCategories">
		<cfset qRules = getRules(CategoryID)>
		<cfset QuerySetCell(qCategories, "Rules", ValueList(qRules.RuleID), CurrentRow)>
		<cfset QuerySetCell(qCategories, "NumRules", qRules.RecordCount, CurrentRow)>
	</cfloop> --->
	
	<!--- <cfreturn qCategories> --->
	<cfreturn variables.Datamgr.getRecords(tablename="chkCategories",orderBy="CategoryName")>
</cffunction>

<cffunction name="getRules" returntype="query" access="public" output="no" hint="I return all of the rules for the given category.">
	<cfargument name="CategoryID" type="string" required="yes">
	
	<cfreturn variables.DataMgr.getRecords("chkRules",arguments)>
</cffunction>

<cffunction name="removeCategory" returntype="void" access="public" output="no" hint="I delete the given category.">
	<cfargument name="CategoryID" type="string" required="yes">
	
	<cfset var qRules = getRules(arguments.CategoryID)>
	
	<cfif qRules.RecordCount>
		<cfthrow message="You cannot delete a category that is associated with one or more rules." type="CodeCop" errorcode="CategoryHasRules">
	</cfif>
	
	<cfset variables.DataMgr.deleteRecord("chkCategories",arguments)>
	
</cffunction>

<cffunction name="saveCategory" returntype="string" access="public" output="no" hint="I save a category.">
	<cfargument name="CategoryID" type="string" required="no">
	<cfargument name="CategoryName" type="string" required="no">
	
	<cfreturn variables.DataMgr.saveRecord("chkCategories",arguments)>
</cffunction>

</cfcomponent>