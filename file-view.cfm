<cfimport taglib="sebtags/" prefix="seb">

<!---
In most systems, I would have some sort of try/catch,
but this will just be used by CF programmers and I figure they would prefer errors.
--->
<cfparam name="URL.id" type="numeric" default="0">
<cfparam name="URL.issue" type="numeric" default="0">
<cfparam name="URL.rule" type="numeric" default="0">

<!--- If an issue is passed in instead of a file, get the file from the issue --->
<cfif URL.issue AND NOT URL.id>
	<cfset qIssue = CodeCop.Issues.getIssue(URL.issue)>
	<cfset URL.id = qIssue.FileID>
</cfif>

<!--- Get data for use on this page --->
<cfset qFile = CodeCop.Files.getFile(URL.id)>
<cfset qIssues = CodeCop.Files.getFileIssues(URL.id)>

<!--- Get the formatted code for the file highlighting issues (drawing attention to ones that match incoming data) --->
<cfinvoke returnvariable="FormattedContents" component="#CodeCop.CodeViewer#" method="getFormattedFileCode">
	<cfinvokeargument name="FileID" value="#URL.id#">
	<cfif URL.issue><cfinvokeargument name="IssueID" value="#URL.issue#"></cfif>
	<cfif URL.rule><cfinvokeargument name="RuleID" value="#URL.rule#"></cfif>
</cfinvoke>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
	<script language="JavaScript" src="file-view.js" type="text/javascript"></script>
	<style type="text/css">
	#sebForm label {display:block;font-size:small;font-weight:bold;}
	</style>
<cfoutput>#layout.body()#</cfoutput>

<h1><cfoutput>#qFile.FileName#</cfoutput></h1>

<cfoutput><p><a href="review-view.cfm?id=#qFile.ReviewID#">Return to review</a></p></cfoutput>

<!--- Show a table of issues found in this file --->
<p><cfoutput>#qIssues.RecordCount# issues:</cfoutput></p>
<seb:sebTable
	label=""
	isAddable="false"
	isEditable="false"
	isDeletable="false"
	pkfield="IssueID"
	query="qIssues"
	width="600">
	<seb:sebColumn dbfield="RuleName" label="Rule" link="rule-view.cfm?issue=" title="Learn more about this rule.">
	<seb:sebColumn dbfield="line" label="Line" link="##line-[Line]" type="link">
	<seb:sebColumn dbfield="SeverityName" label="Severity" sortfield="rank" defaultSort="DESC">
</seb:sebTable>


<cfif ListLast(qFile.FileName,".") eq "cfc">
	<cfoutput><p><a href="file-introspect.cfm?id=#URL.id#">Introspect CFC</a></p></cfoutput>
</cfif>
<!--- Show the numbered, highlighted code --->
<div id="sysfile-view">
<cfoutput><pre class="file-view">#FormattedContents#</pre></cfoutput>
<p>(If only part of your file is showing, make sure "Enable long text retrieval" is checked for your datasource)</p>
</div>

<!--- If the file contents in memory match the actual contents of the file, allow it to be edited from here. --->
<cfif qFile.FileContents eq qFile.CurrentFileContents>
	<div id="sysfile-edit">
		<p>&nbsp;</p>
		
		<seb:sebForm
			pkfield="FileID"
			format="semantic"
			CFC_Component="#CodeCop.Files#"
			CFC_Method="writeFileContents"
			CFC_GetMethod="getFile"
			label="System File">
			<seb:sebField fieldname="FileContents" label="Code" type="textarea" required="true" cols="100" rows="#Min(50,Max(qFile.lines,3))#" setValue="#HTMLEditFormat(qFile.FileContents)#" />
			<seb:sebField type="Submit/Cancel" label="Submit,Cancel" />
		</seb:sebForm>
		
		<p class="warning">Remember! CodeCop will only let you edit a file from here if the content in the database exactly matches the content in the file, so you can only effectively use this feature once per file per review.</p>
	</div>
</cfif>


<cfoutput>#layout.end()#</cfoutput>