<cfimport taglib="sebtags/" prefix="seb">

<cfparam name="url.rule" type="numeric" default="0">

<!--- Make page title --->
<cfset Title = "Link">
<cfif isDefined("url.id") AND isNumeric(url.id) AND url.id gt 0>
	<cfset Title = "Edit #Title#">
<cfelse>
	<cfset Title = "Add #Title#">
</cfif>

<!--- Show which rule this link is for --->
<cfif url.rule gt 0>
	<cfset qRule = CodeCop.Rules.getRule(url.rule)>
	<cfset Title = "#Title# for ""#qRule.RuleName#""">
</cfif>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<cfoutput><h1>#Title#</h1></cfoutput>

<seb:sebForm
	pkfield="LinkID"
	forward="rule-edit.cfm?id=#url.rule#"
	CFC_Component="#CodeCop.Rules#"
	CFC_Method="saveLink"
	CFC_GetMethod="getLink"
	CFC_DeleteMethod="removeLink"
	label="Link">
	<seb:sebField fieldname="RuleID" type="hidden" setValue="#url.rule#" />
	<seb:sebField fieldname="LinkText" label="Link Text" required="true" size="50" Length="240" />
	<seb:sebField fieldname="LinkURL" label="Link URL" required="true" size="50" Length="180" />
	<seb:sebField type="Submit/Cancel/Delete" label="Submit,Cancel,Delete" />
</seb:sebForm>

<cfoutput>#layout.end()#</cfoutput>