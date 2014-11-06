<cfimport taglib="sebtags/" prefix="seb">

<!--- Get rules that might be used in this package --->
<cfset qRules = CodeCop.Rules.getRules()>

<!--- Make page title --->
<cfset Title = "Package">
<cfif isDefined("url.id") AND isNumeric(url.id) AND url.id gt 0>
	<cfset Title = "Edit #Title#">
<cfelse>
	<cfset Title = "Add #Title#">
</cfif>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<cfoutput><h1>#Title#</h1></cfoutput>

<seb:sebForm
	pkfield="PackageID"
	forward="package-list.cfm"
	CFC_Component="#CodeCop.Packages#"
	CFC_Method="savePackage"
	CFC_GetMethod="getPackage"
	CFC_DeleteMethod="removePackage"
	label="Package">
	<seb:sebField fieldname="PackageName" label="Package" required="true" size="50" Length="120" />
	<seb:sebField fieldname="Rules" type="checkbox" subquery="qRules" subvalues="RuleID" subdisplays="RuleName" required="true" />
	<seb:sebField type="custom1"><a href="rule-list.cfm">manage rules</a></seb:sebField>
	<seb:sebField type="Submit/Cancel/Delete" label="Submit,Cancel,Delete" />
</seb:sebForm>

<!--- If editing a package, provide link to export package --->
<cfif StructKeyExists(URL,"id") AND isNumeric(url.id) AND url.id gt 0>
	<cfoutput><p><a href="package-export.cfm?id=#url.id#">Export Package</a></p></cfoutput>
</cfif>

<cfoutput>#layout.end()#</cfoutput>