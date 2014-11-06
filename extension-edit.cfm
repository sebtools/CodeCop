<cfimport taglib="sebtags/" prefix="seb">

<!--- Make page title --->
<cfset Title = "Extension">
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
	pkfield="ExtensionID"
	forward="extension-list.cfm"
	CFC_Component="#CodeCop.Extensions#"
	CFC_Method="saveExtension"
	CFC_GetMethod="getExtension"
	CFC_DeleteMethod="removeExtension"
	isDeletable="!NumRules"
	label="Extension">
	<seb:sebField fieldname="Extension" label="Extension" required="true" />
	<seb:sebField type="Submit/Cancel/Delete" label="Submit,Cancel,Delete" />
</seb:sebForm>

<cfoutput>#layout.end()#</cfoutput>