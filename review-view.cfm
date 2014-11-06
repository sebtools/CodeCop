<cfimport taglib="sebtags/" prefix="seb">

<cfparam name="url.id" type="numeric" default="0">

<!--- Get issues for this code review --->
<cfset qIssues = CodeCop.Issues.getIssues(url.id)>
<cfset qSeverityStats = CodeCop.Reviews.getStats(url.id,"Severity")>
<cfset qCategoryStats = CodeCop.Reviews.getStats(url.id,"Category")>

<cfif url.format eq "HTML">
	<cfset ChartFormat = "flash">
<cfelse>
	<cfset ChartFormat = "jpg">
</cfif>

<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h2>Issues</h2>

<cfif qIssues.RecordCount>
	<cfif url.format eq "HTML">
		<cfoutput>
		<p>
			<a href="review-categories.cfm?id=#url.id#">By Categories</a><br/>
			<a href="review-files.cfm?id=#url.id#">By Files</a><br/>
			<a href="review-rules.cfm?id=#url.id#">By Rules</a>
		</p>
		</cfoutput>
	</cfif>
	
	<cfchart format="#ChartFormat#" chartheight="200" chartwidth="300" seriesplacement="default" labelformat="number" tipstyle="mouseOver" pieslicestyle="sliced">
		<cfchartseries type="pie" query="qCategoryStats" itemcolumn="CategoryName" valuecolumn="NumIssues"></cfchartseries>
	</cfchart>
	<cfchart format="#ChartFormat#" chartheight="200" chartwidth="300" seriesplacement="default" labelformat="number" tipstyle="mouseOver" pieslicestyle="sliced">
		<cfchartseries type="pie" query="qSeverityStats" itemcolumn="SeverityName" valuecolumn="NumIssues" colorlist="FF0000,BBBB00,00DDDD"></cfchartseries>
	</cfchart>
	
	<!--- <cfdump var="#CodeCop.Reviews.getStats(url.id)#"> --->
	
	<seb:sebTable
		label="Issue"
		isAddable="false"
		isEditable="false"
		isDeletable="false"
		pkfield="IssueID"
		query="qIssues"
		width="600">
		<seb:sebColumn dbfield="FileName" label="File" link="file-view.cfm?issue=" width="150">
		<seb:sebColumn dbfield="RuleName" label="Rule" link="rule-view.cfm?issue=" width="350">
		<seb:sebColumn dbfield="line" label="Line" link="file-view.cfm?issue=[IssueID]##line-[Line]" type="link" width="50">
		<seb:sebColumn dbfield="SeverityName" label="Severity" sortfield="rank" defaultSort="DESC" width="50">
	</seb:sebTable>
	
	<cfif url.format eq "HTML" AND CFVersionMajor gte 7>
		<cfoutput>
		<p><a href="#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#&format=PDF">Download PDF</a></p>
		</cfoutput>
	</cfif>
<cfelse>
	<h2>Congratulations!</h2>
	<p>No issues were found with this code.</p>
</cfif>

<cfoutput>#layout.end()#</cfoutput>