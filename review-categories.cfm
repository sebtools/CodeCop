<cfimport taglib="sebtags/" prefix="seb">

<cfparam name="url.id" type="numeric" default="0">

<!--- Get rules and issues for this review --->
<cfset qCategories = CodeCop.Reviews.getCategories(ReviewID=url.id)>
<cfset qCategories = CodeCop.Reviews.getStats(url.id,"Category")>
<cfset qIssues = CodeCop.Issues.getIssues(ReviewID=url.id,sorttype="rule")>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h2>Issues</h2>

<seb:sebTable
	label=""
	isAddable="false"
	isEditable="false"
	isDeletable="false"
	pkfield="CategoryID"
	query="qCategories">
	<seb:sebColumn dbfield="CategoryName" label="CategoryName">
	<seb:sebColumn dbfield="NumIssues" label="Issues">
</seb:sebTable>

<br />
<hr />
<cfoutput query="qCategories">
	<p><br/><span class="strong">#CategoryName#</span></p><!--- <a class="strong" href="rule-view.cfm?review=#url.id#&id=#RuleID#">#RuleName#</a> --->
	<!---
	Normally I use CFC_Component and CFC_GetMethod to get data.
	Since I am in a loop, querying a query with a filter is more effecient.
	--->
	<seb:sebTable
		label=""
		isAddable="false"
		isEditable="false"
		isDeletable="false"
		pkfield="IssueID"
		filter="CategoryID=#CategoryID#"
		query="qIssues"><!--- Passing in a query here with a filter means that I am running QofQ each iteration, but not calling back to the DB --->
		<seb:sebColumn dbfield="RuleName" label="Rule" link="rule-view.cfm?issue=" width="250" defaultSort="ASC">
		<seb:sebColumn dbfield="FileName" label="File" link="file-view.cfm?issue=" width="150">
		<seb:sebColumn dbfield="line" label="Line" link="file-view.cfm?issue=[IssueID]##line-[Line]" type="link" width="50">
		<seb:sebColumn dbfield="SeverityName" label="Severity" sortfield="rank" width="50">
	</seb:sebTable>
</cfoutput>

<cfif url.format eq "HTML" AND CFVersionMajor gte 7>
	<cfoutput>
	<p><a href="#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#&format=PDF">Download PDF</a></p>
	</cfoutput>
</cfif>

<cfoutput>#layout.end()#</cfoutput>