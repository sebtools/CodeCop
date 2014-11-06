<cfimport taglib="sebtags/" prefix="seb">

<!--- This structure will be passed in to the getLinks() function to filter the links that show --->
<cfset GetLinks = StructNew()>

<!--- Make page title --->
<cfset Title = "Rule">
<cfif isDefined("url.id") AND isNumeric(url.id) AND url.id gt 0>
	<cfset GetLinks["RuleID"] = url.id><!--- Effectively passing in an argument named "RuleID" to getLinks() via sebTable --->
	<cfset Title = "Edit #Title#">
<cfelse>
	<cfset Title = "Add #Title#">
</cfif>

<!--- Get options for drop-downs --->
<cfset qSeverities = CodeCop.Severities.getSeverities()>
<cfset qPackages = CodeCop.Packages.getPackages()>
<cfset qExtensions = CodeCop.Extensions.getExtensions()>
<cfset qCategories = CodeCop.Categories.getCategories()>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
	<script language="JavaScript" src="rule-edit.js" type="text/javascript"></script>
<cfoutput>#layout.body()#</cfoutput>

<cfoutput><h1>#Title#</h1></cfoutput>

<seb:sebForm
	pkfield="RuleID"
	forward="rule-list.cfm"
	CFC_Component="#CodeCop.Rules#"
	CFC_Method="saveRule"
	CFC_GetMethod="getRule"
	CFC_DeleteMethod="removeRule"
	label="Rule">
	<seb:sebField fieldname="RuleName" label="Rule" required="true" size="50" Length="180" />
	<seb:sebField fieldname="SeverityID" label="Severity" type="select" subquery="qSeverities" subvalues="SeverityID" subdisplays="SeverityName" required="true" />
	<seb:sebField fieldname="CategoryID" label="Category" type="select" subquery="qCategories" subvalues="CategoryID" subdisplays="CategoryName" required="true" />
	<seb:sebField fieldname="RuleType" label="Rule Type" required="true" type="select" Length="250" rows="2" subvalues="Regex,Tag" />
	<seb:sebField fieldname="TagName" label="Tag Name" required="false" size="50" Length="240" help="example: &quot;cfquery&quot;" />
	<seb:sebField fieldname="Regex" label="Regex" required="false" type="textarea" Length="250" rows="2" />
	<seb:sebField type="custom1"><a href="http://www.houseoffusion.com/groups/regex/" id="regex-help" target="_blank">get regex help</a></seb:sebField>
	<seb:sebField fieldname="Description" label="Description" type="textarea" rows="4" />
	<seb:sebField fieldname="Packages" type="checkbox" subquery="qPackages" subvalues="PackageID" subdisplays="PackageName" required="true" />
	<seb:sebField type="custom1"><a href="package-list.cfm">manage packages</a></seb:sebField>
	<seb:sebField fieldname="allExtensions" label="All Extensions?" type="yesno" defaultValue="true" /><!--- could have used: onclick="showExtensions();", but that is less unobstructive --->
	<seb:sebField fieldname="Extensions" type="checkbox" subquery="qExtensions" subvalues="ExtensionID" subdisplays="Extension" />
	<seb:sebField type="custom1"><a href="extension-list.cfm">manage extensions</a></seb:sebField>
	<seb:sebField fieldname="CustomCode" label="CustomCode" type="textarea" rows="6" />
	<seb:sebField type="custom1"><a href="rule-how-customcode.cfm">How to write custom code for a rule</a></seb:sebField>
	<seb:sebField type="Submit/Cancel/Delete" label="Submit,Cancel,Delete" />
</seb:sebForm>

<!--- Only show links when editing a rule (just to confusing to try to add links to a rule that doesn't exist. --->
<cfif StructKeyExists(GetLinks,"RuleID")>
	<seb:sebTable
		pkfield="LinkID"
		label="Link"
		editpage="link-edit.cfm?rule=#url.id#"
		isDeletable="true"
		CFC_Component="#CodeCop.Rules#"
		CFC_GetMethod="getLinks"
		CFC_GetArgs="#GetLinks#"
		CFC_DeleteMethod="removeLink">
		<seb:sebColumn dbfield="LinkText" label="Link Text">
		<seb:sebColumn dbfield="LinkURL" label="Link URL">
	</seb:sebTable>
</cfif>

<cfoutput>#layout.end()#</cfoutput>