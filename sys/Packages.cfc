<cfcomponent displayname="Package" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfreturn this>
</cffunction>

<cffunction name="getDefaultPackageID" access="public" returntype="numeric" output="no" hint="I return the id of the package that seems to be the default.">
	
	<cfset var qDefaults = 0>
	<cfset var result = 0>
	
	<!--- To avoid a settings table and confusion as to how that would effect sharing packages, guess at the default --->
	<!--- I expect that the first package that uses the name "default" will be the default package. --->
	<cfquery name="qDefaults" datasource="#variables.datasource#">
	SELECT		PackageID
	FROM		chkPackages
	WHERE		PackageName LIKE '%Default%'
	ORDER BY	PackageID
	</cfquery>
	
	<cfif isNumeric(qDefaults.PackageID)>
		<cfset result = qDefaults.PackageID>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getPackage" returntype="query" access="public" output="no" hint="I return the requested package.">
	<cfargument name="PackageID" type="numeric" required="yes">
	
	<!--- <cfset var qRules = 0>
	<cfset var qPackage = 0> --->
	
	<!--- I need a comma-delimited list of associated rules, but hard to do so in a cross-database manner, so an extra query. --->
	<!--- <cfquery name="qRules" datasource="#variables.datasource#">
	SELECT	RuleID
	FROM	chkRules2Packages
	WHERE	PackageID = <cfqueryparam value="#arguments.PackageID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfquery name="qPackage" datasource="#variables.datasource#">
	SELECT	PackageID,PackageName,'#ValueList(qRules.RuleID)#' AS Rules
	FROM	chkPackages
	WHERE	PackageID = <cfqueryparam value="#arguments.PackageID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery> --->
	
	<!--- <cfreturn qPackage> --->
	<cfreturn variables.DataMgr.getRecord("chkPackages",arguments)>
</cffunction>

<cffunction name="getPackageID" returntype="numeric" access="public" output="no" hint="I return the requested package.">
	<cfargument name="PackageName" type="string" required="yes">
	
	<cfset var qPackage = 0>
	<cfset var result = 0>
	
	<cfquery name="qPackage" datasource="#variables.datasource#">
	SELECT	PackageID
	FROM	chkPackages
	WHERE	PackageName = <cfqueryparam value="#arguments.PackageName#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif qPackage.RecordCount>
		<cfset result = qPackage.PackageID>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getPackages" returntype="query" access="public" output="no" hint="I return all of the packages.">
	
	<cfreturn variables.DataMgr.getRecords("chkPackages",arguments)>
</cffunction>

<cffunction name="removePackage" returntype="void" access="public" output="no" hint="I delete the given Package.">
	<cfargument name="PackageID" type="string" required="yes">
	
	<cfset variables.DataMgr.deleteRecord("chkPackages",arguments)>
	
</cffunction>

<cffunction name="savePackage" returntype="string" access="public" output="no" hint="I save a Package.">
	<cfargument name="PackageID" type="string" required="no">
	<cfargument name="PackageName" type="string" required="no">
	<cfargument name="Rules" type="string" required="no">
	
	<cfset var result = 0>
	
	<cftransaction>
		<!--- Save the package record --->
		<cfset result = variables.DataMgr.saveRecord("chkPackages",arguments)>
		
		<!--- Save records for associated rules (and ditch those no longer associated) --->
		<!--- <cfif StructKeyExists(arguments,"Rules")>
			<cfset variables.DataMgr.saveRelationList("chkRules2Packages","PackageID",result,"RuleID",arguments.Rules)>
		</cfif> --->
	</cftransaction>
	
	<cfreturn result>
</cffunction>

</cfcomponent>