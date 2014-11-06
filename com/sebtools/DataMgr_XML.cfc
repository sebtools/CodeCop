<!--- 2.0 Beta 1 Build 63 --->
<!--- Last Updated: 2006-10-13 --->
<!--- Created by Steve Bryant 2004-12-08 --->
<cfcomponent extends="DataMgr" displayname="Data Manager for Simulated Database" hint="I manage simulated data interactions with a database.">

<cffunction name="addColumn" access="public" returntype="any" output="no" hint="I add a column to the given table">
	<cfargument name="tablename" type="string" required="yes" hint="The name of the table to which a column will be added.">
	<cfargument name="columnname" type="string" required="yes" hint="The name of the column to add.">
	<cfargument name="CF_Datatype" type="string" required="yes" hint="The ColdFusion SQL Datatype of the column.">
	<cfargument name="Length" type="numeric" default="50" hint="The ColdFusion SQL Datatype of the column.">
	<cfargument name="Default" type="string" required="no" hint="The default value for the column.">
	
	<!--- <cfset var type = getDBDataType(arguments.CF_Datatype)>
	
	<cfif arguments.Length eq 0>
		<cfset arguments.Length = 50>
	</cfif> --->
	
</cffunction>

<cffunction name="createTable" access="public" returntype="string" output="no" hint="I take a table for which the structure has been loaded, and create the table in the database.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var CreateSQL = getCreateSQL(arguments.tablename)>
	
	<cfreturn CreateSQL>
</cffunction>

<cffunction name="CreateTables" access="public" returntype="void" output="no" hint="I create any tables that I know should exist in the database but don't.">
	<cfargument name="tables" type="string" default="#variables.tables#" hint="I am a list of tables to create. If I am not provided createTables will try to create any table that has been loaded into it but does not exist in the database.">

</cffunction>

<cffunction name="deleteRecord" access="public" returntype="void" output="no" hint="I delete the record with the given Primary Key(s).">
	<cfargument name="tablename" type="string" required="yes" hint="The name of the table from which to delete a record.">
	<cfargument name="data" type="struct" required="yes" hint="A structure indicating the record to delete. A key indicates a field. The structure should have a key for each primary key in the table.">
	
</cffunction>

<cffunction name="getCreateSQL" access="public" returntype="string" output="no" hint="I return the SQL to create the given table.">
	<cfargument name="tablename" type="string" required="yes" hint="The name of the table to create.">
	
	<cfset var CreateSQL = ""><!--- holds sql used for creation, allows us to return it in an error --->
	
	<cfreturn CreateSQL>
</cffunction>

<cffunction name="getDatabase" access="public" returntype="string" output="no" hint="I return the database platform being used (Access,MS SQL,MySQL etc).">
	<cfreturn "XML">
</cffunction>

<cffunction name="getDatabaseShortString" access="public" returntype="string" output="no" hint="I return the string that can be found in the driver or JDBC URL for the database platform being used.">
	<cfreturn "XML Database">
</cffunction>

<cffunction name="getDatabaseTables" access="public" returntype="string" output="yes" hint="I get a list of all tables in the current database.">

	<cfreturn StructKeyList(variables.tables)>
</cffunction>

<cffunction name="getDatasource" access="public" returntype="string" output="no" hint="I return the datasource used by this Data Manager.">
	<cfreturn variables.datasource>
</cffunction>

<cffunction name="getDBFieldList" access="public" returntype="string" output="no" hint="I return a list of fields in the database for the given table.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfreturn getFieldList(arguments.tablename)>
</cffunction>

<cffunction name="getDBTableStruct" access="public" returntype="array" output="no" hint="I return the structure of the given table in the database.">
	<cfargument name="tablename" type="string" required="yes">

	<cfreturn variables.tables[arguments.tablename]>
</cffunction>

<cffunction name="getNewSortNum" access="public" returntype="numeric" output="no">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="sortfield" type="string" required="yes" hint="The field holding the sort order.">
	
	<cfreturn (variables.rows + 1)>
</cffunction>

<cffunction name="getPKFromData" access="public" returntype="string" output="no" hint="I get the primary key of the record matching the given data.">
	<cfargument name="tablename" type="string" required="yes" hint="The table from which to return a primary key.">
	<cfargument name="fielddata" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	
	<cfreturn RandRange(1,variables.rows)>
</cffunction>

<cffunction name="getRecord" access="public" returntype="query" output="no" hint="I get a recordset based on the primary key value(s) given.">
	<cfargument name="tablename" type="string" required="yes" hint="The table from which to return a record.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key. Every primary key field should be included.">
	
	<cfset var qRecord = getRecords(tablename=arguments.tablename,data=arguments.data,maxrows=1)><!--- The record to return --->
	
	<cfreturn qRecord>
</cffunction>

<cffunction name="getRecords" access="public" returntype="query" output="no" hint="I get a recordset based on the data given.">
	<cfargument name="tablename" type="string" required="yes" hint="The table from which to return a record.">
	<cfargument name="data" type="struct" required="no" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	<cfargument name="orderBy" type="string" default="">
	<cfargument name="maxrows" type="numeric" default="#variables.rows#">
	
	<cfset var qRecords = 0><!--- The recordset to return --->
	<cfset var fields = getUpdateableFields(arguments.tablename)><!--- non primary-key fields in table --->
	<cfset var pkfields = getPKFields(arguments.tablename)><!--- primary key fields in table --->
	<cfset var i = 0><!--- Generic counter --->
	<cfset var fieldlist = "">
	<cfset var row = 0><!--- Generic counter --->
	
	<!--- Create data --->
	<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		<cfset fieldlist = ListAppend(fieldlist,pkfields[i]["ColumnName"])>
	</cfloop>
	<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1">
		<cfset fieldlist = ListAppend(fieldlist,fields[i]["ColumnName"])>
	</cfloop>
	<cfif Len(arguments.orderby)>
		<cfset fieldlist = ListAppend(fieldlist,"DataMgrOrderField")>
	</cfif>
	
	<cfset qRecords = QueryNew(fieldlist)>
	
	<cfloop index="row" from="1" to="#Min(arguments.maxrows,variables.rows)#" step="1">
		<cfset QueryAddRow(qRecords)>
		<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
			<cfset QuerySetCell(qRecords, pkfields[i]["ColumnName"], getRecordValue(pkfields[i]))>
		</cfloop>
		<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1">
			<cfset QuerySetCell(qRecords, fields[i]["ColumnName"], getRecordValue(fields[i]))>
		</cfloop>
		<cfif Len(arguments.orderby)>
			<cfset QuerySetCell(qRecords, "DataMgrOrderField", UCase(qRecords[arguments.orderby][row]))>
		</cfif>
	</cfloop>
	
	<cfif Len(arguments.orderby)>
		<cfquery name="qRecords" dbtype="query">
		SELECT		#ListDeleteAt(fieldlist,ListLen(fieldlist))#
		FROM		qRecords
		ORDER BY	DataMgrOrderField
		</cfquery>
	</cfif>
	
	<cfreturn qRecords>
</cffunction>

<cffunction name="getRecordValue" access="private" returntype="string" output="no">
	<cfargument name="field" type="struct" required="yes">
	
	<cfset var result = "">
	<cfset var mylength = Min(field.Length,RandRange(10,field.Length))>
	
	<cfswitch expression="#arguments.field.CF_DataType#">
	<cfcase value="CF_SQL_BIGINT">
		<cfset result = RandRange(1,1024)>
	</cfcase>
	<cfcase value="CF_SQL_BIT">
		<cfset result = RandRange(0,1)>
	</cfcase>
	<cfcase value="CF_SQL_CHAR">
		<cfset result = "char">
	</cfcase>
	<cfcase value="CF_SQL_DATE">
		<cfset result = DateAdd("d",RandRange(1,730),DateAdd("yyyy",-1,now()))>
	</cfcase>
	<cfcase value="CF_SQL_DECIMAL">
		<cfset result = (RandRange(100,102400)/100)>
	</cfcase>
	<cfcase value="CF_SQL_FLOAT">
		<cfset result = (RandRange(100,102400)/100)>
	</cfcase>
	<cfcase value="CF_SQL_IDSTAMP">
		<cfset result = CreateUUID()>
	</cfcase>
	<cfcase value="CF_SQL_INTEGER">
		<cfset result = RandRange(1,variables.rows)>
	</cfcase>
	<cfcase value="CF_SQL_CLOB,CF_SQL_LONGVARCHAR">
		<cfset result = Left(variables.greek,RandRange(500,5000))>
	</cfcase>
	<cfcase value="CF_SQL_MONEY">
		<cfset result = (RandRange(100,102400)/100)>
	</cfcase>
	<cfcase value="CF_SQL_MONEY4">
		<cfset result = (RandRange(100,102400)/100)>
	</cfcase>
	<cfcase value="CF_SQL_NUMERIC">
		<cfset result = RandRange(1,512)>
	</cfcase>
	<cfcase value="CF_SQL_REAL">
	<cfset result = "real">
		<cfset result = RandRange(1,1048576)>
	</cfcase>
	<cfcase value="CF_SQL_SMALLINT">
	<cfset result = "smallint">
		<cfset result = RandRange(1,64)>
	</cfcase>
	<cfcase value="CF_SQL_TINYINT">
		<cfset result = RandRange(1,8)>
	</cfcase>
	<cfcase value="CF_SQL_VARCHAR">
		<cfset result = ProperCase(Mid(variables.greek,RandRange(1,(Len(variables.greek)-mylength)),mylength))>
	</cfcase>
	<cfdefaultcase><cfthrow message="DataMgr object cannot handle this data type." type="DataMgr" detail="DataMgr cannot handle data type '#arguments.CF_Datatype#'" errorcode="InvalidDataType"></cfdefaultcase>
	</cfswitch>
	
	<cfreturn result>
</cffunction>

<cffunction name="getStringTypes" access="public" returntype="string" output="no" hint="I return a list of datypes that hold strings / character values."><cfreturn ""></cffunction>

<cffunction name="insertRecord" access="public" returntype="string" output="no" hint="I insert a record into the given table with the provided data and do my best to return the primary key of the inserted record.">
	<cfargument name="tablename" type="string" required="yes" hint="The table in which to insert data.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	<cfargument name="OnExists" type="string" default="insert" hint="The action to take if a record with the given values exists. Possible values: insert (inserts another record), error (throws an error), update (updates the matching record), skip (performs no action).">
	
	<cfreturn variables.rows + 1>	
</cffunction>

<cffunction name="isStringType" access="private" returntype="boolean" output="no" hint="I indicate if the given datatype is valid for string data.">
	<cfargument name="type" type="string">

	<cfset var strtypes = "CF_SQL_CHAR,CF_SQL_VARCHAR">
	<cfset var result = false>
	<cfif ListFindNoCase(strtypes,arguments.type)>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="saveRecord" access="public" returntype="string" output="no" hint="I insert or update a record in the given table (update if a matching record is found) with the provided data and return the primary key of the updated record.">
	<cfargument name="tablename" type="string" required="yes" hint="The table on which to update data.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	
	<cfreturn insertRecord(arguments.tablename,arguments.data,"update")>
</cffunction>

<cffunction name="saveRelationList" access="public" returntype="void" output="no" hint="">
	<cfargument name="tablename" type="string" required="yes" hint="The table holding the many-to-many relationships.">
	<cfargument name="keyfield" type="string" required="yes" hint="The field holding our key value for relationships.">
	<cfargument name="keyvalue" type="string" required="yes" hint="The value of out primary field.">
	<cfargument name="multifield" type="string" required="yes" hint="The field holding our many relationships for the given key.">
	<cfargument name="multilist" type="string" required="yes" hint="The list of related values for our key.">
	
</cffunction>

<cffunction name="saveSortOrder" access="public" returntype="void" output="no">
	<cfargument name="tablename" type="string" required="yes" hint="The table on which to update data.">
	<cfargument name="sortfield" type="string" required="yes" hint="The field holding the sort order.">
	<cfargument name="sortlist" type="string" required="yes" hint="The list of primary key field values in sort order.">
	<cfargument name="PrecedingRecords" type="numeric" default="0" hint="The number of records preceding those being sorted.">
	
</cffunction>

<cffunction name="updateRecord" access="public" returntype="string" output="no" hint="I update a record in the given table with the provided data and return the primary key of the updated record.">
	<cfargument name="tablename" type="string" required="yes" hint="The table on which to update data.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	
	<cfreturn Random(1,variables.rows)>
</cffunction>

<cffunction name="getCFDataType" access="public" returntype="string" output="no" hint="I return the cfqueryparam datatype from the database datatype.">
	<cfargument name="type" type="string" required="yes" hint="The database data type.">
	
	<cfreturn arguments.type>
</cffunction>

<cffunction name="getDBDataType" access="public" returntype="string" output="no" hint="I return the database datatype from the cfqueryparam datatype.">
	<cfargument name="CF_Datatype" type="string" required="yes">
	
	<cfreturn arguments.CF_Datatype>
</cffunction>

<cffunction name="getInsertedIdentity" access="private" returntype="numeric" output="no" hint="I get the value of the identity field that was just inserted into the given table.">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="identfield" type="string" required="yes">
	
	<cfreturn RandRange(1,variables.rows)>
</cffunction>

<cffunction name="ProperCase" access="private" returntype="string" output="no">
	<cfargument name="string" type="string" required="yes">
	
	<cfset var result = "">
	<cfset var word = "">
	<cfset var myword = "">
	
	<cfloop index="word" list="#arguments.string#" delimiters=" ">
		<cfset myword = UCase(Left(word,1)) & LCase(Mid(word,2,Len(word)))>
		<cfset result = ListAppend(result,myword," ")>
	</cfloop>
	
	<cfreturn result>
</cffunction>

</cfcomponent>