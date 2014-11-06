<cfimport taglib="sebtags/" prefix="seb">


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h1>Rules</h1>

<seb:sebTable
	pkfield="RuleID"
	label="Rule"
	editpage="rule-edit.cfm"
	isDeletable="true"
	CFC_Component="#CodeCop.Rules#"
	CFC_GetMethod="getRules"
	CFC_DeleteMethod="removeRule">
	<seb:sebColumn dbfield="RuleName" label="Rule">
	<seb:sebColumn dbfield="CategoryName" label="Category">
	<seb:sebColumn dbfield="Severity" label="Severity" sortfield="rank" defaultSort="DESC">
</seb:sebTable>

<cfoutput>#layout.end()#</cfoutput>