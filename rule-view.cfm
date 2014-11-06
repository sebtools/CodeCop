<cfimport taglib="sebtags/" prefix="seb">

<cfparam name="URL.id" type="numeric" default="0">
<cfparam name="URL.issue" type="numeric" default="0">
<cfparam name="URL.review" type="numeric" default="0">

<!--- If an issue is passed in, but a rule isn't, get the rule fom the issue --->
<cfif URL.issue AND NOT URL.id>
	<cfset qIssue = CodeCop.Issues.getIssue(URL.issue)>
	<cfset URL.review = qIssue.ReviewID>
	<cfset URL.id = qIssue.RuleID>
</cfif>

<!--- If this rule is being viewed from a review, show files that have issues for this rule --->
<cfif URL.review>
	<cfset qFiles = CodeCop.Files.getFiles(ReviewID=URL.review,RuleID=URL.id)>
</cfif>

<!--- Get this rule and its links --->
<cfset qRule = CodeCop.Rules.getRule(URL.id)>
<cfset qLinks = CodeCop.Rules.getLinks(URL.id)>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
	<style type="text/css">strong {font-size:small;font-weight:bold;}</style>
<cfoutput>#layout.body()#</cfoutput>

<cfoutput query="qRule">
<h2>#RuleName#</h2>

<p><strong>Description</strong></p>
<p>#Description#</p>

<p><strong>Severity</strong></p>
<p>#SeverityName#</p>

<p><strong>Extensions</strong></p>
<p><cfif isBoolean(allExtensions) AND allExtensions>ALL<cfelse>#ExtensionNames#</cfif></p>

<cfif qLinks.RecordCount>
	<p><strong>Links</strong></p>
	<ul>
	<cfloop query="qLinks">
		<li><a href="#LinkURL#" target="_blank">#LinkText#</a></li>
	</cfloop>
	</ul>
</cfif>

</cfoutput>

<cfif isDefined("qFiles")>
	<seb:sebTable
		label=""
		isAddable="false"
		isEditable="false"
		isDeletable="false"
		pkfield="FileID"
		query="qFiles">
		<seb:sebColumn dbfield="FileName" label="File" link="file-view.cfm?rule=#URL.id#&id=">
	</seb:sebTable>
</cfif>

<cfoutput>#layout.end()#</cfoutput>