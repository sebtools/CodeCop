<cfimport taglib="sebtags/" prefix="seb">

<cfparam name="url.id" type="numeric" default="0">

<!--- Get files and issues for this code review --->
<cfset qFiles = CodeCop.Files.getFiles(ReviewID=url.id)>
<cfset qIssues = CodeCop.Issues.getIssues(ReviewID=url.id)>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h2>Issues</h2>

<seb:sebTable
	label=""
	isAddable="false"
	isEditable="false"
	isDeletable="false"
	pkfield="FileID"
	query="qFiles">
	<seb:sebColumn dbfield="FileName" label="File" link="file-view.cfm?id=">
	<seb:sebColumn dbfield="NumIssues" label="Issues">
</seb:sebTable>

<br />
<hr />
<cfoutput query="qFiles">
	<p><br/><a class="strong" href="file-view.cfm?id=#FileID#">#FileName#</a></p>
	<seb:sebTable
		label=""
		isAddable="false"
		isEditable="false"
		isDeletable="false"
		pkfield="IssueID"
		filter="FileID=#FileID#"
		query="qIssues"><!--- Passing in a query here with a filter means that I am running QofQ each iteration, but not calling back to the DB --->
		<seb:sebColumn dbfield="RuleName" label="Rule" link="rule-view.cfm?issue=" width="300" title="Learn more about this rule.">
		<seb:sebColumn dbfield="line" label="Line" type="link" link="file-view.cfm?issue=[IssueID]##line-[Line]" width="100">
		<seb:sebColumn dbfield="SeverityName" label="Severity" width="100" sortfield="rank" defaultSort="DESC">
	</seb:sebTable>
</cfoutput>

<cfif url.format eq "HTML" AND CFVersionMajor gte 7>
	<cfoutput>
	<p><a href="#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#&format=PDF">Download PDF</a></p>
	</cfoutput>
</cfif>

<cfoutput>#layout.end()#</cfoutput>