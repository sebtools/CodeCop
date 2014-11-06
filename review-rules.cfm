<cfimport taglib="sebtags/" prefix="seb">

<cfparam name="url.id" type="numeric" default="0">

<!--- Get rules and issues for this review --->
<cfset qRules = CodeCop.Reviews.getRules(ReviewID=url.id)>
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
	pkfield="RuleID"
	query="qRules">
	<seb:sebColumn dbfield="RuleName" label="Rule" link="rule-view.cfm?review=#url.id#&id=">
	<seb:sebColumn dbfield="NumIssues" label="Issues">
	<seb:sebColumn dbfield="SeverityName" label="Severity">
</seb:sebTable>

<br />
<hr />
<cfoutput query="qRules">
	<p><br/><a class="strong" href="rule-view.cfm?review=#url.id#&id=#RuleID#">#RuleName#</a></p>
	<seb:sebTable
		label=""
		isAddable="false"
		isEditable="false"
		isDeletable="false"
		pkfield="IssueID"
		filter="RuleID=#RuleID#"
		query="qIssues"><!--- Passing in a query here with a filter means that I am running QofQ each iteration, but not calling back to the DB --->
		<seb:sebColumn dbfield="FileName" label="File" link="file-view.cfm?issue=" width="300" defaultSort="ASC">
		<seb:sebColumn dbfield="line" label="Line" width="100" link="file-view.cfm?issue=[IssueID]##line-[Line]" type="link">
		<seb:sebColumn dbfield="SeverityName" label="Severity" width="100" sortfield="rank">
	</seb:sebTable>
</cfoutput>

<cfif url.format eq "HTML" AND CFVersionMajor gte 7>
	<cfoutput>
	<p><a href="#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#&format=PDF">Download PDF</a></p>
	</cfoutput>
</cfif>

<cfoutput>#layout.end()#</cfoutput>