<cfcomponent displayname="Group" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	<cfset variables.DataMgr.loadXML(getDbXml(),true,true)><!--- Make sure needed tables/columns exist --->
	
	<cfreturn this>
</cffunction>

<cffunction name="getGroup" returntype="query" access="public" output="no" hint="I return the requested group.">
	<cfargument name="GroupID" type="string" required="yes">
	
	<cfreturn variables.DataMgr.getRecord("secGroups",arguments)>
</cffunction>

<cffunction name="getGroups" returntype="query" access="public" output="no" hint="I return all of the groups.">
	
	<cfreturn variables.DataMgr.getRecords("secGroups",arguments)>
</cffunction>

<cffunction name="removeGroup" returntype="void" access="public" output="no" hint="I delete the given Group.">
	<cfargument name="GroupID" type="string" required="yes">
	
	<cfset variables.DataMgr.deleteRecord("secGroups",arguments)>
	
</cffunction>

<cffunction name="saveGroup" returntype="string" access="public" output="no" hint="I save a Group.">
	<cfargument name="GroupID" type="string" required="no">
	<cfargument name="GroupName" type="string" required="no">
	<cfargument name="Permissions" type="string" required="no">
	
	<cfreturn variables.DataMgr.saveRecord("secGroups",arguments)>
</cffunction>

<cffunction name="getDbXml" returntype="string" access="public" output="no" hint="I return the XML for the tables needed for Groups to work.">
	
	<cfset var tableXML = "">
	
	<cfsavecontent variable="tableXML">
	<tables>
		<table name="secGroups">
			<field ColumnName="GroupID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="GroupName" CF_DataType="CF_SQL_VARCHAR" Length="255" />
			<field ColumnName="Permissions">
				<relation table="secPermissions" type="list" field="PermissionID" join-table="secGroups2Permissions" onDelete="Cascade"/>
			</field>
		</table>
		<data table="secGroups">
			<row GroupName="Administrators" />
			<row GroupName="Members" />
			<row GroupName="Presenters" />
		</data>
	</tables>
	</cfsavecontent>
	
	<cfreturn tableXML>
</cffunction>

</cfcomponent>