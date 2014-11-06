<cfcomponent displayname="Datasource Manager">

<cffunction name="init" access="public" returntype="any" output="no" hint="I instantiate and return this component.">
	<cfargument name="Factory" type="any" required="no">
	
	<cfset variables.DataMgr = CreateObject("component","com.sebtools.DataMgr").init("")>
	
	<cfif StructKeyExists(arguments,"Factory")>
		<cfset variables.Factory = arguments.Factory>
	</cfif>
	
	<cfreturn this>
</cffunction>

<cffunction name="getDatabase" access="public" returntype="string" output="no" hint="I get the database engine of the given datasource.">
	<cfargument name="datasource" type="string" required="yes">
	
	<cfset var qDatasources = getDatasources()>
	<cfset var result = "">
	
	<cfquery name="qDatasources" dbtype="query">
	SELECT	name,type
	FROM	qDatasources
	WHERE	name = '#arguments.datasource#'
	</cfquery>
	<cfif qDatasources.RecordCount eq 1>
		<cfset result = qDatasources.type>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getDatabases" access="public" returntype="query" output="no" hint="I get the available databases.">
	<cfset var qDatabases = 0>
	
	<cfif StructKeyExists(variables,"databases")>
		<cfset qDatabases = variables.databases>
	<cfelse>
		<cfset qDatabases = variables.DataMgr.getSupportedDatabases()>
		<cfset variables.databases = qDatabases>
	</cfif>
	
	<cfreturn qDatabases>
</cffunction>

<cffunction name="getDatasources" access="public" returntype="query" output="no" hint="I get the available datasources.">
	
	<cfset var qDatasources = QueryNew("name,type,nameu")>
	
	<cfif StructKeyExists(variables,"Factory")>
		<cfset qDatasources = getDatasources_7()>
	<cfelse>
		<!--- Do a try/catch in case the undocumented service factory isn't available (resulting in no databasources in query) --->
		<cftry>
			<cfset qDatasources = getDatasources_6()>
			<cfcatch>
			</cfcatch>
		</cftry>
	</cfif>
	
	<cfreturn qDatasources>
</cffunction>

<cffunction name="getDatasources_6" access="private" returntype="query" output="no" hint="I get the available datasources on CFMX prior to CFMX7.">
	
	<cfset var dsService = CreateObject("java", "coldfusion.server.ServiceFactory").DataSourceService>
	<cfset var dsManager = dsService.getDman()>
	<cfset var nameArray = dsManager.getNames()>
	<cfset var i = 0>
	<cfset var name = "">
	<cfset var qDatasources = QueryNew("name,type,nameu")>
	<cfset var type = "">
	
	<cfloop from="1" to="#ArrayLen(nameArray)#" index="i">
		<cfset name = nameArray[i]>
		<cfset type = getJdbcUrlDatabase(dsManager.getJdbcUrl(name))>
		<cfif Len(type)>
			<cfset QueryAddRow(qDatasources)>
			<cfset QuerySetCell(qDatasources, "name", name)>
			<cfset QuerySetCell(qDatasources, "type", type)>
			<cfset QuerySetCell(qDatasources, "nameu", UCase(name))>
		</cfif>
	</cfloop>
	
	<cfreturn qDatasources>
</cffunction>

<cffunction name="getDatasources_7" access="private" returntype="query" output="no" hint="I get the available datasources on CFMX7 (and above).">
	
	<cfset var qDatasources = QueryNew("name,driver,type,nameu")>
	<cfset var Datasources = variables.Factory.DataSourceService.getDatasources()>
	<cfset var dsn = "">
	<cfset var type = "">
	
	<cfloop collection="#Datasources#" item="dsn">
		<cfset driver = Datasources[dsn].Driver>
		<cfset type = getDriverDatabase(driver)>
		<cfif Len(type)>
			<cfset QueryAddRow(qDatasources)>
			<cfset QuerySetCell(qDatasources,"name",dsn)>
			<cfset QuerySetCell(qDatasources,"driver",driver)>
			<cfset QuerySetCell(qDatasources,"type",type)>
			<cfset QuerySetCell(qDatasources,"nameu",UCase(dsn))>
		</cfif>
	</cfloop>
	
	<cfreturn qDatasources>
</cffunction>

<cffunction name="getDriverDatabase" access="private" returntype="string" output="no" hint="I get the database engine from the driver.">
	<cfargument name="driver" type="string" required="yes">
	
	<cfset var qDatabases = getDatabases()>
	<cfset var result = "">
	
	<cfloop query="qDatabases">
		<cfif arguments.driver CONTAINS ShortString>
			<cfset result = Database>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="getJdbcUrlDatabase" access="private" returntype="string" output="no" hint="I get the database engine from the JDBC URL.">
	<cfargument name="JdbcUrl" type="string" required="yes">
	
	<cfset var qDatabases = getDatabases()>
	<cfset var result = "">
	
	<cfloop query="qDatabases">
		<cfif arguments.driver CONTAINS ShortString>
			<cfset result = Database>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

</cfcomponent>