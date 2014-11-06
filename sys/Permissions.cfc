<cfcomponent displayname="Permission" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	<cfset variables.DataMgr.loadXML(getDbXml(),true,true)><!--- Make sure needed tables/columns exist --->
	
	<cfreturn this>
</cffunction>

<cffunction name="getPermission" returntype="query" access="public" output="no" hint="I return the requested permission.">
	<cfargument name="PermissionID" type="string" required="yes">
	
	<cfreturn variables.DataMgr.getRecord("secPermissions",arguments)>
</cffunction>

<cffunction name="getPermissions" returntype="query" access="public" output="no" hint="I return all of the permissions.">
	
	<cfreturn variables.DataMgr.getRecords("secPermissions",arguments)>
</cffunction>

<cffunction name="removePermission" returntype="void" access="public" output="no" hint="I delete the given Permission.">
	<cfargument name="PermissionID" type="string" required="yes">
	
	<cfset variables.DataMgr.deleteRecord("secPermissions",arguments)>
	
</cffunction>

<cffunction name="savePermission" returntype="string" access="public" output="no" hint="I save a Permission.">
	<cfargument name="PermissionID" type="string" required="no">
	<cfargument name="PermissionName" type="string" required="no">
	
	<cfreturn variables.DataMgr.saveRecord("secPermissions",arguments)>
</cffunction>

<cffunction name="getDbXml" returntype="string" access="public" output="no" hint="I return the XML for the tables needed for Permissions to work.">
	
	<cfset var tableXML = "">
	
	<cfsavecontent variable="tableXML">
	<tables>
		<table name="secPermissions">
			<field ColumnName="PermissionID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="PermissionName" CF_DataType="CF_SQL_VARCHAR" Length="255" />
		</table>
		<data table="secPermissions">
			<row GroupName="Administrators" />
			<row GroupName="Members" />
			<row GroupName="Presenters" />
		</data>
	</tables>
	</cfsavecontent>
	
	<cfreturn tableXML>
</cffunction>

</cfcomponent>