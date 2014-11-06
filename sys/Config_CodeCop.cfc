<cfcomponent displayname="CodeCop Configuration" output="no">

<cffunction name="init" access="public" returntype="any" output="no" hint="I instantiate and return this component.">
	
	<!--- Set the build number for future upgrades --->
	<cfset variables.Build = 16>
	<cfset variables.Version = "1.0">
	
	<cfreturn this>
</cffunction>

<cffunction name="getBuild" access="public" returntype="numeric" output="no" hint="I return the build number of this version of CodeCop.">
	<!---
	The idea here is that code outside of this method can check
	the build number and optionally force a re-initialization
	for an upgrade so that the user doesn't have to worry about that.
	--->
	<cfreturn variables.Build>
</cffunction>

<cffunction name="getInstallSQL" access="public" returntype="string" output="no" hint="I return the SQL needed to install CodeCop (assuming CodeCop failed to do so).">
	<cfreturn variables.InstallSQL>
</cffunction>

<cffunction name="getVersion" access="public" returntype="string" output="no" hint="I return the version of CodeCop being used.">
	<cfreturn variables.Version>
</cffunction>

<cffunction name="getDbXml" returntype="string" access="public" output="no" hint="I return the XML for the tables needed for Categories to work.">
	
	<cfset var tableXML = "">
	
	<cfsavecontent variable="tableXML">
	<tables>
		<table name="chkCategories">
			<field ColumnName="CategoryID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="CategoryName" CF_DataType="CF_SQL_VARCHAR" Length="80" />
			<field ColumnName="Rules">
				<relation table="chkRules" type="list" field="RuleID" onDelete="Error"/>
			</field>
			<field ColumnName="NumRules">
				<relation table="chkRules" type="count" field="RuleID" join-field="CategoryID"/>
			</field>
<!--- 			<field ColumnName="MaxRuleID">
				<relation table="chkRules" type="max" field="RuleID" join-field="CategoryID"/>
			</field>
			<field ColumnName="MinRuleID">
				<relation table="chkRules" type="min" field="RuleID" join-field="CategoryID"/>
			</field>
			<field ColumnName="SumRuleID">
				<relation table="chkRules" type="sum" field="RuleID" join-field="CategoryID"/>
			</field> --->
		</table>
		<table name="chkExtensions">
			<field ColumnName="ExtensionID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="Extension" CF_DataType="CF_SQL_VARCHAR" Length="8" />
			<field ColumnName="Rules">
				<relation table="chkRules" type="list" field="RuleID" onDelete="Error"/>
			</field>
			<field ColumnName="NumRules">
				<relation table="chkRules" type="count" field="RuleID" join-field="ExtensionID"/>
			</field>
		</table>
		<table name="chkRules2Extensions">
			<field ColumnName="RuleID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" />
			<field ColumnName="ExtensionID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" />
		</table>
		<table name="chkFiles">
			<field ColumnName="FileID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="ReviewID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="FileName" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="FileContents" CF_DataType="CF_SQL_LONGVARCHAR" />
		</table>
		<table name="chkIssues">
			<field ColumnName="IssueID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="ReviewID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="FileID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="RuleID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="pos" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="len" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="string" CF_DataType="CF_SQL_LONGVARCHAR" />
			<field ColumnName="line" CF_DataType="CF_SQL_INTEGER" />
		</table>
		<table name="chkLinks">
			<field ColumnName="LinkID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="RuleID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="LinkText" CF_DataType="CF_SQL_VARCHAR" Length="100" />
			<field ColumnName="LinkURL" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="ordernum" CF_DataType="CF_SQL_INTEGER" Special="Sorter" />
		</table>
		<table name="chkPackages">
			<field ColumnName="PackageID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="PackageName" CF_DataType="CF_SQL_VARCHAR" Length="120" />
			<field ColumnName="Rules">
				<relation table="chkRules" type="list" field="RuleID" join-table="chkRules2Packages" onDelete="Cascade"/>
			</field>
		</table>
		<table name="chkReviews">
			<field ColumnName="ReviewID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="PackageID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="Folder" CF_DataType="CF_SQL_VARCHAR" Length="250" />
			<field ColumnName="ReviewDate" CF_DataType="CF_SQL_DATE" Special="CreationDate" />
		</table>
		<table name="chkRules">
			<field ColumnName="RuleID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="SeverityID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="RuleName" CF_DataType="CF_SQL_VARCHAR" Length="180" />
			<field ColumnName="RuleType" CF_DataType="CF_SQL_VARCHAR" Length="60" Default="Regex" />
			<field ColumnName="TagName" CF_DataType="CF_SQL_VARCHAR" Length="240" />
			<field ColumnName="Regex" CF_DataType="CF_SQL_VARCHAR" Length="250" />
			<field ColumnName="Description" CF_DataType="CF_SQL_LONGVARCHAR" />
			<field ColumnName="allExtensions" CF_DataType="CF_SQL_BIT" default="1" />
			<field ColumnName="UUID" CF_DataType="CF_SQL_VARCHAR" Length="40" />
			<field ColumnName="CustomCode" CF_DataType="CF_SQL_LONGVARCHAR" />
			<field ColumnName="CategoryID" CF_DataType="CF_SQL_INTEGER" />
			<field ColumnName="CategoryName">
				<relation table="chkCategories" type="label" field="CategoryName" join-field="CategoryID"/>
			</field>
			<field ColumnName="Severity">
				<relation table="chkSeverities" type="label" field="SeverityName" join-field="SeverityID"/>
			</field>
			<field ColumnName="SeverityName">
				<relation table="chkSeverities" type="label" field="SeverityName" join-field="SeverityID"/>
			</field>
			<field ColumnName="rank">
				<relation table="chkSeverities" type="label" field="rank" join-field="SeverityID"/>
			</field>
			<field ColumnName="Packages">
				<relation table="chkPackages" type="list" field="PackageID" join-table="chkRules2Packages"/>
			</field>
			<field ColumnName="Extensions">
				<relation table="chkExtensions" type="list" field="ExtensionID" join-table="chkRules2Extensions"/>
			</field>
			<field ColumnName="ExtensionNames">
				<relation table="chkExtensions" type="list" field="Extension" join-table="chkRules2Extensions" join-field="ExtensionID"/>
			</field>
			<!--- <field ColumnName="isGone" CF_DataType="CF_SQL_BIT" Special="DeletionMark" /> --->
		</table>
		<table name="chkRules2Packages">
			<field ColumnName="RuleID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" />
			<field ColumnName="PackageID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" />
		</table>
		<table name="chkSeverities">
			<field ColumnName="SeverityID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="SeverityName" CF_DataType="CF_SQL_VARCHAR" Length="60" />
			<field ColumnName="rank" CF_DataType="CF_SQL_INTEGER" />
		</table>
		<data table="chkCategories">
			<row CategoryName="Maintenance" />
			<row CategoryName="Performance" />
			<row CategoryName="Portability" />
			<row CategoryName="Security" />
		</data>
		<data table="chkSeverities">
			<row SeverityName="High" rank="3" />
			<row SeverityName="Medium" rank="2" />
			<row SeverityName="Low" rank="1" />
		</data>
	</tables>
	</cfsavecontent>
	
	<cfreturn tableXML>
</cffunction>

</cfcomponent>