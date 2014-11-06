<!--- 0.1 Development1 Build 2 --->
<!--- Last Updated: 006-09-20 --->
<!--- Created by Steve Bryant 2006-09-18 --->
<cfcomponent displayname="Data Synchronizer">

<cffunction name="init" access="public" returntype="any" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	
	<!--- To hold any DataMgr receivers --->
	<cfset variables.aReceivers = ArrayNew(1)>
	
	<cfreturn this>
</cffunction>

<cffunction name="addDataMgr" access="public" returntype="void" output="no" hint="I add a DataMgr to be synchronized.">
	<cfargument name="DataMgr" type="any" required="yes">
	
	<cfset ArrayAppend(variables.aReceivers,arguments.DataMgr)>
	
</cffunction>

<cffunction name="getXml" access="public" returntype="string" output="no" hint="I get the XML for the given tables.">
	<cfargument name="tables" type="string" default="">
	<cfargument name="withdata" type="boolean" default="true">
	
	<cfset var TableData = variables.DataMgr.getTableData()>
	<cfset var i = 0>
	<cfset var table = "">
	<cfset var column = 0>
	<cfset var qRecords = 0>
	<cfset var col = "">
	<cfset var fdata = StructNew()>
	<cfset var fcol = StructNew()>
	
	<!--- If no tables are indicated, get them all. --->
	<cfif NOT Len(arguments.tables)>
		<cfset arguments.tables = StructKeyList(TableData)>
	</cfif>
	
	<!--- Make sure all requested tables are loaded in DataMgr --->
	<cfloop index="table" list="#arguments.tables#">
		<cfif NOT StructKeyExists(TableData,table)>
			<cfset variables.DataMgr.loadTable(table)>
			<cfset TableData = variables.DataMgr.getTableData()>
		</cfif>
	</cfloop>
	
	<!--- Look for foreign keys --->
	<cfloop index="table" list="#arguments.tables#">
		<cfloop index="i" from="1" to="#ArrayLen(TableData[table])#" step="1"><cfset column = TableData[table][i]>
			<cfif StructKeyExists(column,"CF_DataType")><cfset col = column.ColumnName>
				<cfset rtable = getRelatedTable(arguments.tables,table,column)>
				<cfif Len(rtable)>
					<cfset TableData[table][i]["rtable"] = rtable>
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>
	
<cfsavecontent variable="result"><cfoutput>
<tables>
<cfloop index="table" list="#arguments.tables#">
	<!--- Verifying the table exists (shouldn't really be needed since we made sure to check for it above --->
	<cfif StructKeyExists(TableData,table)>
		<table name="#table#">
		<!--- Indicate all of the fields --->
		<cfloop index="i" from="1" to="#ArrayLen(TableData[table])#" step="1"><cfset column = TableData[table][i]>
			<cfif StructKeyExists(column,"CF_DataType")>
				<field ColumnName="#column.ColumnName#" CF_DataType="#column.CF_DataType#"<cfif StructKeyExists(column,"PrimaryKey") AND isBoolean(column.PrimaryKey) AND column.PrimaryKey> PrimaryKey="true"</cfif><cfif StructKeyExists(column,"Increment") AND isBoolean(column.Increment) AND column.Increment> Increment="true"</cfif><cfif StructKeyExists(column,"Length") AND isNumeric(column.Length) AND column.Length gt 0> Length="#Int(column.Length)#"</cfif><cfif StructKeyExists(column,"Default") AND Len(column.Default)> Default="#column.Default#"</cfif><cfif StructKeyExists(column,"Precision") AND isNumeric(column["Precision"])> Precision="#column["Precision"]#"</cfif><cfif StructKeyExists(column,"Scale") AND isNumeric(column["Scale"])> Scale="#column["Scale"]#"</cfif><cfif StructKeyExists(column,"Special") AND Len(column["Special"])> Special="#column["Special"]#"</cfif> />
			</cfif>
		</cfloop>
		</table>
		<!--- Now let's get all of the data (assuming we are asked to do so) --->
		<cfif arguments.withdata>
			<cfset qRecords = variables.DataMgr.getRecords(table)>
			<cfif qRecords.RecordCount>
				<data table="#table#" permanentRows="true"><!--- permanentRows tells DataMgr to insert the record even if the table already exists --->
					<!--- Output each row of data --->
					<cfloop query="qRecords">
						<row>
							<!--- Output each column --->
							<cfloop index="i" from="1" to="#ArrayLen(TableData[table])#" step="1"><cfset column = TableData[table][i]>
								<!--- Only output a column if it has a datatype (all column should, but one never knows what the future holds... --->
								<cfif StructKeyExists(column,"CF_DataType")><cfset col = column.ColumnName>
									<!--- If we show a related table, put in reference to that instead of value --->
									<cfif StructKeyExists(column,"rtable")>
										<!--- Get the data for the related record --->
										<cfset fdata = getRelatedData(column["rtable"],column,qRecords[col][CurrentRow])>
										<cfif StructCount(fdata)>
											<field name="#col#" reltable="#column.rtable#">
												<cfloop collection="#fdata#" item="fcol">
													<relfield name="#fcol#" value="#XmlFormat(fdata[fcol])#" />
												</cfloop>
											</field>
										</cfif>
									<cfelse>
										<field name="#col#" value="#XmlFormat(qRecords[col][CurrentRow])#" />
									</cfif>
								</cfif>
							</cfloop>
						</row>
					</cfloop>
				</data>
			</cfif>
		</cfif>
	</cfif>
</cfloop>
</tables>
</cfoutput></cfsavecontent>

	<cfreturn XmlHumanReadable(result)>
</cffunction>

<cffunction name="synchTables" access="public" returntype="void" output="no" hint="I synchronize the given tables.">
	<cfargument name="tables" type="string" default="">
	<cfargument name="withdata" type="boolean" default="true">
	
	<cfset var i = 0>
	<cfset var dbxml = getXml(arguments.tables,arguments.withdata)>
	
	<cfloop index="i" from="1" to="#ArrayLen(variables.aReceivers)#" step="1">
		<cfset variables.aReceivers[i].loadXml(dbxml,true,true)>
	</cfloop>
	
</cffunction>

<cffunction name="synchXML" access="public" returntype="void" output="no" hint="I synchronize the given XML structure/data.">
	<cfargument name="dbxml" type="string" required="yes">
	
	<cfset var i = 0>
	
	<cfloop index="i" from="1" to="#ArrayLen(variables.aReceivers)#" step="1">
		<cfset variables.aReceivers[i].loadXml(dbxml,true,true)>
	</cfloop>
	
</cffunction>

<cffunction name="getRelatedTable" access="private" returntype="string" output="no">
	<cfargument name="tables" type="string" default="">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="Field" type="struct" required="yes">
	
	<cfset var result = "">
	<cfset var TableData = variables.DataMgr.getTableData()>
	<cfset var table = "">
	<cfset var pkfields = 0>
	
	<cfif NOT Len(arguments.tables)>
		<cfset arguments.tables = StructKeyList(TableData)>
	</cfif>
	
	<!--- Make sure the fields is a real field (has a datatype) --->
	<cfif StructKeyExists(Field,"CF_DataType")>
		<!--- Look through all tables for a matching primary key --->
		<cfloop index="table" list="#arguments.tables#">
			<!--- Only look at loaded tables that aren't the one our field is in. --->
			<cfif StructKeyExists(TableData,table) AND table NEQ arguments.tablename>
				<cfset pkfields = variables.DataMgr.getPKFields(table)>
				<!--- Only look at tables with simple primary keys --->
				<cfif ArrayLen(pkfields) eq 1>
					<!--- If the column name matches, this is our table --->
					<cfif pkfields[1].ColumnName eq Field["ColumnName"]>
						<cfset result = table>
						<cfbreak>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getRelatedData" access="private" returntype="struct" output="no">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="field" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	
	<cfset var data = StructNew()>
	<cfset var colname = Field["ColumnName"]>
	<cfset var table = arguments.tablename>
	<cfset var result = StructNew()>
	
	<!--- Make sure variables["RelatedData"] exists --->
	<cfif NOT StructKeyExists(variables,"RelatedData")>
		<cfset variables["RelatedData"] = StructNew()>
	</cfif>
	
	<!--- Make sure variables["RelatedData"] has a key for this table --->
	<cfif NOT StructKeyExists(variables["RelatedData"],table)>
		<cfset variables["RelatedData"][table] = StructNew()>
	</cfif>
	
	<!--- Get the structure --->
	<cfif StructKeyExists(variables["RelatedData"][table],arguments.value)>
		<!--- If the data has already been retrieved for this key use it --->
		<cfset result = variables["RelatedData"][table][arguments.value]>
	<cfelse>
		<!--- Get the record and load up he struct --->
		<cfset data[colname] = arguments.value>
		<cftry>
			<cfset qRecord = variables.DataMgr.getRecord(tablename=table,data=data,fieldlist=getFieldList(table))>
			<!--- Convert the record to a struct --->
			<cfset result = QueryToStruct(qRecord)>
			<!--- The struct shouldn't include the primary key field (defeats the purpose of by reference) --->
			<cfset StructDelete(result,colname)>
			<cfset variables["RelatedData"][table][arguments.value] = result>
		<cfcatch>
		</cfcatch>
		</cftry>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getFieldList" access="private" returntype="string" output="no" hint="I get the list of primary key fields.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var aFields = variables.DataMgr.getUpdateableFields(arguments.tablename)>
	<cfset var result = "">
	<cfset var i = 0>
	
	<cfloop index="i" from="1" to="#ArrayLen(aFields)#" step="1">
		<cfset result = ListAppend(result,aFields[i].ColumnName)>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="QueryToStruct" access="private" returntype="struct" output="no" hint="I convert a row of a query to a struct.">
	<cfargument name="query" type="query" required="yes">
	<cfargument name="rownum" type="numeric" default="1">
	
	<cfset var result = StructNew()>
	
	<cfloop index="col" list="#query.ColumnList#">
		<cfset result[col] = query[col][rownum]>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cfscript>
/**
 * Formats an XML document for readability.
 * update by Fabio Serra to CR code
 * 
 * @param XmlDoc 	 XML document. (Required)
 * @return Returns a string. 
 * @author Steve Bryant (steve@bryantwebconsulting.com) 
 * @version 2, March 20, 2006 
 */
function XmlHumanReadable(XmlDoc) {
	var elem = "";
	var result = "";
	var tab = "	";
	var att = "";
	var i = 0;
	var temp = "";
	var cr = createObject("java","java.lang.System").getProperty("line.separator");
	
	if ( isXmlDoc(XmlDoc) ) {
		elem = XmlDoc.XmlRoot;//If this is an XML Document, use the root element
	} else if ( IsXmlElem(XmlDoc) ) {
		elem = XmlDoc;//If this is an XML Document, use it as-as
	} else if ( NOT isXmlDoc(XmlDoc) ) {
		XmlDoc = XmlParse(XmlDoc);//Otherwise, try to parse it as an XML string
		elem = XmlDoc.XmlRoot;//Then use the root of the resulting document
	}
	//Now we are just working with an XML element
	result = "<#elem.XmlName#";//start with the element name
	if ( StructKeyExists(elem,"XmlAttributes") ) {//Add any attributes
		for ( att in elem.XmlAttributes ) {
			result = '#result# #att#="#XmlFormat(elem.XmlAttributes[att])#"';
		}
	}
	if ( Len(elem.XmlText) OR (StructKeyExists(elem,"XmlChildren") AND ArrayLen(elem.XmlChildren)) ) {
		result = "#result#>#cr#";//Add a carriage return for text/nested elements
		if ( Len(Trim(elem.XmlText)) ) {//Add any text in this element
			result = "#result##tab##XmlFormat(Trim(elem.XmlText))##cr#";
		}
		if ( StructKeyExists(elem,"XmlChildren") AND ArrayLen(elem.XmlChildren) ) {
			for ( i=1; i lte ArrayLen(elem.XmlChildren); i=i+1 ) {
				temp = Trim(XmlHumanReadable(elem.XmlChildren[i]));
				temp = "#tab##ReplaceNoCase(trim(temp), cr, "#cr##tab#", "ALL")#";//indent
				result = "#result##temp##cr#";
			}//Add each nested-element (indented) by using recursive call
		}
		result = "#result#</#elem.XmlName#>";//Close element
	} else {
		result = "#result# />";//self-close if the element doesn't contain anything
	}
	
	return result;
}
</cfscript>

</cfcomponent>