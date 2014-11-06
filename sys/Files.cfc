<cfcomponent displayname="Files" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	<cfargument name="FileMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.FileMgr = arguments.FileMgr>
	
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfset variables.dirdelim = CreateObject("java", "java.io.File").separator>
	
	<cfreturn this>
</cffunction>

<cffunction name="getFile" access="public" returntype="query" output="no" hint="I get the requested file.">
	<cfargument name="FileID" type="numeric" required="yes">
	
	<cfset var qFile = 0>
	<cfset var FilePath = getFilePath(arguments.FileID)>
	<cfset var CurrentFileContents = "">
	<cfset var linedelim = CreateObject("java", "java.lang.System").getProperty("line.separator")>
	
	<!--- If the file exists, get the contents (otherwise leave them blank) --->
	<cfif FileExists(FilePath)>
		<cffile action="READ" file="#FilePath#" variable="CurrentFileContents">
	</cfif>
	
	<!--- Get the record for this file --->
	<cfquery name="qFile" datasource="#variables.datasource#">
	SELECT		FileID,FileName,FileContents,
				'#FilePath#' AS FilePath,
				'' AS CurrentFileContents,
				'0' AS #variables.DataMgr.escape("lines")#,
				chkReviews.ReviewID,Folder
	FROM		chkFiles
	INNER JOIN	chkReviews
		ON		chkFiles.ReviewID = chkReviews.ReviewID
	WHERE	FileID = <cfqueryparam value="#arguments.FileID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<!--- Set the value for the current contents (done here instead of in the query because it could be long and have any combination of quotes) --->
	<cfset QuerySetCell(qFile, "CurrentFileContents", CurrentFileContents)>
	<!--- Set the number of lines in the file (Done here because it is much easier than trying to do so in the query) --->
	<cfset QuerySetCell(qFile, "lines", ListLen(Trim(qFile.FileContents),linedelim))>
	
	<cfreturn qFile>
</cffunction>

<cffunction name="getFilePath" access="public" returntype="string" output="no" hint="I get system path to the requested file.">
	<cfargument name="FileID" type="numeric" required="yes">
	
	<cfset var qFile = 0>
	<cfset var result = "">
	
	<!--- Get the file name and folder for this file --->
	<cfquery name="qFile" datasource="#variables.datasource#">
	SELECT		FileID,FileName,Folder
	FROM		chkFiles
	INNER JOIN	chkReviews
		ON		chkFiles.ReviewID = chkReviews.ReviewID
	WHERE		FileID = <cfqueryparam value="#arguments.FileID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<!--- directory delimeter is stored as "/". Convert back to system directory delimeter --->
	<cfset result = ListChangeDelims(qFile.FileName,variables.dirdelim,"/")>
	<!--- Append the file path to the folder path (using a list function obviate the worry of the directory delim getting doubled-up) --->
	<cfset result = ListAppend(qFile.Folder,result,variables.dirdelim)>
	
	<cfreturn result>
</cffunction>

<cffunction name="getFiles" access="public" returntype="query" output="no" hint="I get all of the files for the given review.">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="RuleID" type="numeric" required="no">
	
	<cfset var qFile = 0>
	
	<cfquery name="qFile" datasource="#variables.datasource#">
	SELECT		chkFiles.FileID,FileName,FileContents,
				(
					SELECT	Count(*) AS IssueCount
					FROM	chkIssues
					WHERE	chkIssues.FileID = chkFiles.FileID
				) AS NumIssues
	FROM		chkFiles
	<cfif StructKeyExists(arguments,"RuleID")>
	INNER JOIN	chkIssues
		ON		chkFiles.FileID = chkIssues.FileID
	</cfif>
	WHERE		chkFiles.ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
	<cfif StructKeyExists(arguments,"RuleID")>
		AND		RuleID = <cfqueryparam value="#arguments.RuleID#" cfsqltype="CF_SQL_INTEGER">
	</cfif>
	<!--- ORDER BY	NumIssues DESC --->
	</cfquery>
	
	<cfreturn qFile>
</cffunction>

<cffunction name="getFileIssues" access="public" returntype="query" output="no" hint="I get all of the issues in the given file.">
	<cfargument name="FileID" type="numeric" required="yes">
	<cfargument name="type" type="string" default="public">
	
	<cfset var qFile = 0>
	
	<cfquery name="qFile" datasource="#variables.datasource#">
	SELECT		chkIssues.IssueID,chkIssues.ReviewID,pos,len,string,line,
				chkRules.RuleID,RuleName,Description,Regex,
				chkSeverities.SeverityID,SeverityName,rank,
				chkFiles.FileID,FileName
	FROM		chkIssues,chkRules,chkSeverities,chkFiles
	<!--- FROM		chkIssues
	INNER JOIN	chkRules
		ON		chkIssues.RuleID = chkRules.RuleID
	INNER JOIN	chkSeverities
		ON		chkRules.SeverityID = chkSeverities.SeverityID
	INNER JOIN	chkFiles
		ON		chkIssues.FileID = chkFiles.FileID --->
	WHERE		chkFiles.FileID = <cfqueryparam value="#arguments.FileID#" cfsqltype="CF_SQL_INTEGER">
	<!--- Replacing joins above for Access compatibility w/o tons of nested parens --->
		AND		chkIssues.RuleID = chkRules.RuleID
		AND		chkRules.SeverityID = chkSeverities.SeverityID
		AND		chkIssues.FileID = chkFiles.FileID
	<cfif arguments.type eq "parsecode">
	ORDER BY	pos
	<cfelse>
	ORDER BY	rank,pos,line
	</cfif>
	</cfquery>
	
	<cfreturn qFile>
</cffunction>

<cffunction name="saveFile" access="public" returntype="numeric" output="no" hint="I save a file.">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="FileContents" type="string" required="yes">
	
	<cfreturn variables.DataMgr.saveRecord("chkFiles",arguments)>
</cffunction>

</cfcomponent>