<cfcomponent output="false">
<cffunction name="init" returntype="any">
	<cfargument name="adminPassword" hint="I am the admin password for ColdFusion" required="false">
	<cfargument name="ds" hint="I am the datasource service" required="false">
	
	<cfset var result = "">
	
	<cfif NOT ( StructKeyExists(arguments,"adminPassword") OR StructKeyExists(arguments,"ds") )>
		<cfthrow message="Either the adminPassword or the ds argument must be provided." type="derbyCFC" errorcode="MissingInitArg">
	</cfif>
	
	<cfif StructKeyExists(arguments,"adminPassword")>
		<cfset variables.admin = createObject("component","cfide.adminAPI.administrator")>
		<cfset result = variables.admin.login(adminPassword=adminPassword)>
		<cfset variables.ds = createObject("component","cfide.adminAPI.datasource")>
	<cfelse>
		<cfset variables.ds = arguments.ds>
		<cfset result = true>
	</cfif>
	
	<cfreturn this>
</cffunction>

<cffunction name="getDerbyDatasources">
	<cfargument name="format" default="query" hint="query | raw">
	<cfargument name="maxRecords" default="" hint="If provided I limit the max records returned to this number">
	<cfset var private = {}>
	<cfset private.records = 0>
	<cfset private.getDS = variables.ds.getDatasources()>
	<cfset private.getAll = duplicate(private.getDS)>
	
	<cfif arguments.format eq "query">
		<cfset private.columnsForQuery = "name,description,interval,alter,delete,disable_clob,revoke,select,driver,login_timeout,disable_blob,storedproc,class,isj2ee,create,validationquery,timeout,password,update,drop,pooling,url,username,grant,buffer,disable,insert,blob_buffer">
		<cfset private.qryDerby = queryNew(private.columnsForQuery)>
	</cfif>
	
	<cfloop collection="#private.getAll#" item="private.key">
		<cfif isNumeric(arguments.maxRecords) && arguments.maxRecords eq private.records>
			<cfset structDelete(private.getAll,private.key)>
		<cfelseif private.getAll[private.key]["driver"] contains "Derby">
			<cfset private.records++>
			<cfif arguments.format eq "query">
				<cfset queryAddRow(private.qryDerby)>
				<cfloop list="#private.columnsForQuery#" index="private.column">
					<cfset querySetCell(private.qryDerby,private.column,private.getAll[private.key][private.column])>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset structDelete(private.getAll,private.key)>
		</cfif>
	</cfloop>
	
	<cfif arguments.format eq "query">
		<cfset private.getAll = private.qryDerby>	
	</cfif>
	<cfreturn private.getAll>
</cffunction>

<cffunction name="createIfNotExists">
	<cfargument name="name" required="true" type="string" hint="I am the name of the datasource">
	<cfargument name="databaseName" type="string" default="#arguments.name#" hint="I am the folder the Derby database is created in.  Defaults to the name of the datasource">
	<cfargument name="databasePath" type="string" default="" hint="I am the path for storing the database.  Only needed to overwrite system settings.">
	<cfargument name="select" type="boolean" hint="select - Allow SQL SELECT statements.">
	<cfargument name="create" type="boolean" hint="create - Allow SQL CREATE statements.">
	<cfargument name="grant" type="boolean" hint="grant - Allow SQL GRANT statements.">
 	<cfargument name="insert" type="boolean" hint="insert - Allow SQL INSERT statements.">
	<cfargument name="drop" type="boolean" hint="drop - Allow SQL DROP statements.">
	<cfargument name="revoke" type="boolean" hint="revoke - Allow SQL REVOKE statements.">
	<cfargument name="update" type="boolean" hint="update - Allow SQL UPDATE statements.">
	<cfargument name="alter" type="boolean" hint="alter - Allow SQL ALTER statements.">
	<cfargument name="storedproc" type="boolean" hint="storedproc - Allow SQL stored procedure calls.">
	<cfargument name="delete" type="boolean" hint="delete - Allow SQL DELETE statements.">
	<cfset var private = {}>
	<cfset private.ds = getDerbyDatasources(format="raw")>
	<cfif structKeyExists(private.ds,arguments.name)>
		<cfreturn false>
	<cfelse>
		<cfset private.args = arguments>
		<cfset private.args.database = arguments.databasePath & arguments.databaseName>
		<cfset private.args.isnewdb=true>
		<cfset variables.ds.setDerbyEmbedded(argumentCollection=private.args)>
		<cfset variables.ds.verifyDsn(dsn=private.args.name)>
		<cfset private.args.isnewdb=false>
		<cfset variables.ds.setDerbyEmbedded(argumentCollection=private.args)>
		<cfreturn true>
	</cfif>
</cffunction>

<cffunction name="getDerbyPath" access="private">
	<cfset var private = {}>
	<cfset private.getDS = getDerbyDatasources(format="raw",maxrecords=1)>
	<cfset private.firstKey = StructKeyList(private.getDS)>
	<cfset private.path = private.getDS[private.firstKey]["urlmap"]["database"]>
	<cfset private.path =  replace(private.path,listLast(private.path,"//"),"")>
	<cfdump var="#private.path#">
</cffunction>
</cfcomponent>