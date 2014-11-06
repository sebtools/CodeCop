<cfcomponent displayname="Issues" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	<cfargument name="Rules" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.Rules = arguments.Rules>
	
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfreturn this>
</cffunction>

<cffunction name="getIssue" access="public" returntype="query" output="no" hint="I get the requested issue.">
	<cfargument name="IssueID" type="numeric" required="yes">
	
	<cfset var qIssue = 0>
	
	<cfquery name="qIssue" datasource="#variables.datasource#">
	SELECT	IssueID,ReviewID,FileID,RuleID,pos,len,string,line
	FROM	chkIssues
	WHERE	IssueID = <cfqueryparam value="#arguments.IssueID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfreturn qIssue>
</cffunction>

<cffunction name="getIssues" access="public" returntype="query" output="no" hint="I get all of the issues for the given review.">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="sorttype" type="string" default="default">
	
	<!---
	I have a debate about how to handle optionally sorting queries.
	Here I have chosen to pass in a sorttype and make my SQL internally based on that (my personal favorite).
	I have also seen people pass in SQL for sorting. More flexible, but requires outside code to know the database structure.
	I have also seen people use query of queries to sort the returned query. Most flexible, but seems like an extra step and feels ugly.
	Curious as to your thoughts.
	--->
	
	<cfset var qIssues = 0>
	
	<cfquery name="qIssues" datasource="#variables.datasource#">
	SELECT		chkIssues.IssueID,chkIssues.ReviewID,pos,len,string,line,
				chkRules.RuleID,RuleName,Description,Regex,
				chkSeverities.SeverityID,SeverityName,rank,
				chkCategories.CategoryID,CategoryName,
				chkFiles.FileID,FileName
	FROM		chkFiles,chkIssues,chkRules,chkSeverities,chkCategories
	<!--- FROM		chkFiles
	INNER JOIN	chkIssues
		ON		chkFiles.FileID = chkIssues.FileID
	INNER JOIN	chkRules
		ON		chkIssues.RuleID = chkRules.RuleID
	INNER JOIN	chkSeverities
		ON		chkRules.SeverityID = chkSeverities.SeverityID
	INNER JOIN	chkCategories
		ON		chkRules.CategoryID = chkCategories.CategoryID --->
	WHERE		chkIssues.ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
	<!--- Replacing joins above for Access compatibility w/o tons of nested parens --->
		AND		chkFiles.FileID = chkIssues.FileID
		AND		chkIssues.RuleID = chkRules.RuleID
		AND		chkRules.SeverityID = chkSeverities.SeverityID
		AND		chkRules.CategoryID = chkCategories.CategoryID
	<cfswitch expression="#arguments.sorttype#">
	<cfcase value="rule">
	ORDER BY	rank DESC, line, RuleName ASC, chkRules.RuleID ASC
	</cfcase>
	<cfcase value="file">
	ORDER BY	FileName ASC, rank DESC, line
	</cfcase>
	<cfcase value="category">
	ORDER BY	CategoryName, rank DESC, FileName ASC, line
	</cfcase>
	ORDER BY	rank DESC, RuleName
	</cfswitch>
	</cfquery>
	
	<cfreturn qIssues>
</cffunction>

<cffunction name="saveIssue" access="public" returntype="numeric" output="no">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="RuleID" type="numeric" required="yes">
	<cfargument name="FileInfo" type="struct" required="yes">
	<cfargument name="pos" type="numeric" required="yes">
	<cfargument name="len" type="numeric" required="yes">
	<cfargument name="info" type="struct" default="#StructNew()#">
	
<cfset var cr = "
">
	
	<cfset var linedelim = CreateObject("java", "java.lang.System").getProperty("line.separator")><!--- line separator for this OD --->
	<cfset var qRule = variables.Rules.getRule(RuleID)>
	<cfset var isIssue = true><!--- Assume it is a valid issue (we may run custom code to check that later though) --->
	<cfset var issue = StructNew()><!--- store information about this issue --->
	<cfset var IssueID = 0>
	
	<!--- Compile information about this issue --->
	<cfset issue["ReviewID"] = arguments.ReviewID>
	<cfset issue["RuleID"] = arguments.RuleID>
	<cfset issue["FileID"] = FileInfo.FileID>
	<cfset issue["pos"] = pos>
	<cfset issue["len"] = len>
	<cfset issue["string"] = Mid(FileInfo.Contents,pos,len)>
	<!---
	%%HACK:
	Have to try to get line number by Java line delim or manual carraige return.
	The higher result tends to be the right one.
	--->
	<cfset issue["line"] = Max( ListLen(Left(FileInfo.Contents,pos), linedelim) , ListLen(Left(FileInfo.Contents,pos), cr) )>
	<!---
	If we have some custom code for this rule, run it.
	If this rule exists, it will decide whether this is a valid issue.
	--->
	<cfif Len(qRule.CustomCode)>
		<cftry>
			<cfinvoke component="custom.#qRule.UUID#" method="runRuleCheck" returnvariable="isIssue">
				<cfinvokeargument name="Folder" value="#FileInfo.Folder#">
				<cfinvokeargument name="FileName" value="#FileInfo.FullName#">
				<cfinvokeargument name="string" value="#issue.string#">
				<cfinvokeargument name="info" value="#info#">
			</cfinvoke>
			<cfcatch>
				<!--- Since this error is type "CodeCop", it can be caught by any upstairs code looking for that type. --->
				<cfthrow message="Error in Rule ""#qRule.RuleName#"": #CFCATCH.Message#" type="CodeCop" detail="#CFCATCH.Detail#" errorcode="CustomRuleError">
			</cfcatch>
		</cftry>
	</cfif>
	<!--- If this is a valid issue, save it. --->
	<cfif isIssue>
		<cfset IssueID = variables.DataMgr.saveRecord("chkIssues",issue)>
	</cfif>
	
	<cfreturn IssueID>
</cffunction>

</cfcomponent>