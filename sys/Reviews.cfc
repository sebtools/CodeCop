<cfcomponent displayname="Reviews" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	<cfargument name="FileMgr" type="any" required="yes">
	<cfargument name="Extensions" type="any" required="yes">
	<cfargument name="Rules" type="any" required="yes">
	<cfargument name="Files" type="any" required="yes">
	<cfargument name="Issues" type="any" required="yes">
	
	<cfset var dirdelim = CreateObject("java", "java.io.File").separator><!--- directory delimeter for this OS --->
	<cfset var TypesPath = "#GetDirectoryFromPath(GetCurrentTemplatePath())#types">
	<cfset var qRuleTypes = 0>
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.FileMgr = arguments.FileMgr>
	<cfset variables.Extensions = arguments.Extensions>
	<cfset variables.Rules = arguments.Rules>
	<cfset variables.Files = arguments.Files>
	<cfset variables.Issues = arguments.Issues>
	
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfset variables.RuleTypes = StructNew()>
	
	<cfdirectory action="LIST" directory="#TypesPath#" name="qRuleTypes" filter="*.cfc">
	<cfloop query="qRuleTypes">
		<cfif name neq "base.cfc">
			<cfset variables.RuleTypes[ListFirst(name,".")] = CreateObject("component","types.#ListFirst(name,'.')#").init(variables.Files,variables.Rules,variables.Issues)>
		</cfif>
	</cfloop>
	
	<cfreturn this>
</cffunction>

<cffunction name="getCategories" access="public" returntype="query" output="no" hint="I get the categories for which issues are found in the given review.">
	<cfargument name="ReviewID" type="numeric" required="yes">
	
	<cfset var qCategories = 0>
	
	<cfquery name="qCategories" datasource="#variables.datasource#">
	SELECT		DISTINCT chkRules.RuleID,RuleName,
				chkSeverities.SeverityID,chkSeverities.SeverityName,rank,
				chkCategories.CategoryID,chkCategories.CategoryName,
				(
					SELECT	Count(*)
					FROM	chkIssues
					WHERE	chkIssues.RuleID = chkRules.RuleID
						AND	chkIssues.ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
				) AS NumIssues
	FROM		chkRules,chkIssues,chkSeverities,chkCategories
<!--- 	INNER JOIN	chkIssues
		ON		chkRules.RuleID = chkIssues.RuleID
	INNER JOIN	chkSeverities
		ON		chkRules.SeverityID = chkSeverities.SeverityID
	INNER JOIN	chkCategories
		ON		chkRules.CategoryID = chkCategories.CategoryID --->
	WHERE		chkIssues.ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
		AND		chkRules.RuleID = chkIssues.RuleID
		AND		chkRules.SeverityID = chkSeverities.SeverityID
		AND		chkRules.CategoryID = chkCategories.CategoryID
	ORDER BY	chkCategories.CategoryName ASC
	</cfquery>
	
	<cfreturn qCategories>
</cffunction>

<cffunction name="getReviews" access="public" returntype="query" output="no" hint="I get all of the reviews stored in the system.">
	<cfargument name="Folder" type="string" required="no">
		
	<cfset var qReviews = 0>
	
	<!--- This start off using getRecords() but changed to need the needs of this method. --->
	<cfquery name="qReviews" datasource="#variables.datasource#">
	SELECT		chkReviews.ReviewID,Folder,ReviewDate,
				chkPackages.PackageID,PackageName,
				(
					SELECT	Count(*)
					FROM	chkIssues
					WHERE	ReviewID = chkReviews.ReviewID
				) AS NumIssues
	FROM		chkReviews
	INNER JOIN	chkPackages
		ON		chkReviews.PackageID = chkPackages.PackageID
	<cfif StructKeyExists(arguments,"Folder")>
	WHERE		Folder = <cfqueryparam value="#arguments.Folder#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	ORDER BY	ReviewDate DESC, ReviewID DESC
	</cfquery>
	
	<cfreturn qReviews>
</cffunction>

<cffunction name="getRules" access="public" returntype="query" output="no" hint="I get the rules for which issues are found in the given review.">
	<cfargument name="ReviewID" type="numeric" required="yes">
	
	<cfset var qRules = 0>
	
	<cfquery name="qRules" datasource="#variables.datasource#">
	SELECT		DISTINCT chkRules.RuleID,RuleName,
				chkSeverities.SeverityID,chkSeverities.SeverityName,rank,
				(
					SELECT	Count(*)
					FROM	chkIssues
					WHERE	chkIssues.RuleID = chkRules.RuleID
						AND	chkIssues.ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
				) AS NumIssues
	FROM		(chkRules
	INNER JOIN	chkIssues
		ON		chkRules.RuleID = chkIssues.RuleID)
	INNER JOIN	chkSeverities
		ON		chkRules.SeverityID = chkSeverities.SeverityID
	WHERE		chkIssues.ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
	ORDER BY	chkSeverities.rank DESC
	</cfquery>
	
	<cfreturn qRules>
</cffunction>

<cffunction name="getStats" access="public" returntype="query" output="no">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="by" type="string" default="Severity">
	
	<cfset var qStats = 0>
	
	<cfquery name="qStats" datasource="#variables.datasource#">
	SELECT		Count(chkIssues.IssueID) AS NumIssues
				<cfswitch expression="#arguments.by#">
				<cfcase value="Severity">
				,chkSeverities.SeverityName
				</cfcase>
				<cfcase value="Category">
				,chkCategories.CategoryID,chkCategories.CategoryName
				</cfcase>
				</cfswitch>
	FROM		chkRules,chkIssues,chkSeverities,chkCategories
	<!--- FROM		chkRules
	INNER JOIN	chkIssues
		ON		chkRules.RuleID = chkIssues.RuleID
	INNER JOIN	chkSeverities
		ON		chkRules.SeverityID = chkSeverities.SeverityID
	INNER JOIN	chkCategories
		ON		chkRules.CategoryID = chkCategories.CategoryID --->
	WHERE		chkIssues.ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
	<!--- Replacing joins above for Access compatibility w/o tons of nested parens --->
		AND		chkRules.RuleID = chkIssues.RuleID
		AND		chkRules.SeverityID = chkSeverities.SeverityID
		AND		chkRules.CategoryID = chkCategories.CategoryID
	<cfswitch expression="#arguments.by#">
	<cfcase value="Severity">
	GROUP BY	chkSeverities.SeverityID,chkSeverities.SeverityName,chkSeverities.rank
	ORDER BY	chkSeverities.rank DESC
	</cfcase>
	<cfcase value="Category">
	GROUP BY	chkCategories.CategoryID,chkCategories.CategoryName
	ORDER BY	chkCategories.CategoryName ASC
	</cfcase>
	</cfswitch>
	</cfquery>
	
	<cfreturn qStats>
</cffunction>

<cffunction name="removeReview" access="public" returntype="void" output="no" hint="I remove a review.">
	<cfargument name="ReviewID" type="numeric" required="yes">
	
	<cfquery datasource="#variables.datasource#">
	DELETE
	FROM	chkIssues
	WHERE	ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfquery datasource="#variables.datasource#">
	DELETE
	FROM	chkFiles
	WHERE	ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfquery datasource="#variables.datasource#">
	DELETE
	FROM	chkReviews
	WHERE	ReviewID = <cfqueryparam value="#arguments.ReviewID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
</cffunction>

<!--- Ah! The heart of the thing! --->
<cffunction name="runReview" access="public" returntype="numeric" output="no" hint="I perform a review and store the result, returning the id of the review.">
	<cfargument name="Folder" type="string" required="yes">
	<cfargument name="PackageID" type="numeric" required="yes">
	<cfargument name="Extensions" type="string" default="">
	
	<cfset var ReviewID = 0>
	<cfset var qFiles = 0><!--- This will hold a query of files in the given folder --->
	<cfset var FileInfo = StructNew()><!--- To store information about a file --->
	<cfset var qRules = variables.Rules.getRules(arguments.PackageID)><!--- Get the rules for the chosen package --->
	
	<!--- Save this review record (I'll save the results later, right now I need the id of this review) --->
	<cfset ReviewID = saveReview(arguments.PackageID,arguments.Folder)>
	
	<!--- Save a record for each file being reviewed --->
	<cfset saveFiles(ReviewID,arguments.Folder,arguments.Extensions)>
	
	<!--- Get all of the files being reviewed --->
	<cfset qFiles = variables.Files.getFiles(ReviewID)>
	
	<!--- Look in each file --->
	<cfloop query="qFiles">
		<!--- Save the file information in a structure - makes for handy reference and easy to look at the information inner loops --->
		<cfset FileInfo = StructNew()>
		<cfset FileInfo.FileID = FileID>
		<cfset FileInfo.FullName = FileName>
		<cfset FileInfo.Folder = arguments.Folder>
		<cfset FileInfo.Contents = FileContents>
		<!--- Run each rule against this file --->
		<cfloop query="qRules">
			<!--- If this is a file that should be checked for this rule --->
			<cfif allExtensions OR ListFindNoCase(ExtensionNames,ListLast(ListLast(FileInfo.FullName,"/"),"."))>
				<!--- Run check for this rule type --->
				<cfset variables.RuleTypes[RuleType].checkRule(ReviewID,RuleID,FileInfo)>
			</cfif>
		</cfloop>
	</cfloop>
	
	<cfreturn ReviewID>
</cffunction>

<cffunction name="saveFiles" access="public" returntype="any" output="no">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="Folder" type="string" required="yes">
	<cfargument name="Extensions" type="string" default="">
	
	<cfset var dirdelim = CreateObject("java", "java.io.File").separator><!--- directory delimeter for this OS --->
	<cfset var qFiles = 0><!--- This will hold a query of files in the given folder --->
	<cfset var FileInfo = StructNew()><!--- To store information about a file --->
	<cfset var qExtensions = 0>
	<cfset var ReviewExtensionsList = "">
	<cfset var RootFolder = "">
	
	<!--- Use extensions that are passed in or all extensions in system if none are passed in --->
	<cfinvoke returnvariable="qExtensions" component="#variables.Extensions#" method="getExtensions">
		<cfinvokeargument name="ids" value="#arguments.Extensions#">
	</cfinvoke>
	<cfset ReviewExtensionsList = ValueList(qExtensions.Extension)><!--- comma delimited list of extensions --->
	
	<!--- See if this is a file --->
	<cfif FileExists(arguments.Folder)>
		<cfset RootFolder = GetDirectoryFromPath(arguments.Folder)>
		
		<cfdirectory action="LIST" directory="#RootFolder#" name="qFiles" filter="#GetFileFromPath(arguments.Folder)#">
	<cfelse>
		<cfset RootFolder = arguments.Folder>
		
		<!--- Make sure given folder exists. --->
		<cfif NOT DirectoryExists(RootFolder)>
			<cfthrow message="Requested Folder does not exists." type="CodeCop" errorcode="NoSuchFolder">
		</cfif>
		
		<!--- Get all of the files in the requested folder --->
		<cfset qFiles = variables.FileMgr.directoryList(directory=RootFolder,recurse=true)>
	</cfif>
	
	<cftransaction>
		<!--- Look in each file --->
		<cfloop query="qFiles">
			<!--- Save the file information in a structure - makes for handy reference and easy to look at the information inner loops --->
			<cfset FileInfo = StructNew()>
			<cfset FileInfo.FullName = ReplaceNoCase(Directory, RootFolder, "")>
			<cfset FileInfo.FilePath = "#Directory##dirdelim##name#">
			<cfset FileInfo.FullName = "#FileInfo.FullName#/#name#">
			<!--- Make sure that folder entries use "/", but lone file searches are identified by system file path --->
			<cfif arguments.Folder eq RootFolder>
				<cfset FileInfo.FullName = ReplaceNoCase(FileInfo.FullName, "\", "/", "ALL")>
			<cfelse>
				<cfset FileInfo.FullName = ReplaceNoCase(FileInfo.FullName, "/", dirdelim, "ALL")>
			</cfif>
			<cfset FileInfo.Contents = "">
			<!--- If this is a file with an extension that we are checking, then take a look at it --->
			<cfif type eq "File" AND ListFindNoCase(ReviewExtensionsList,ListLast(name,"."))>
				<!--- Get the contents of the file --->
				<cffile action="READ" file="#FileInfo.FilePath#" variable="FileInfo.Contents">
				<!--- Save a record for this file (even if no issues, actually) - after all we could later use this to retrieve an old copy of a file --->
				<cfset FileInfo.FileID = variables.Files.saveFile(ReviewID,FileInfo.FullName,FileInfo.Contents)>
			</cfif>
		</cfloop>
	</cftransaction>
	
	<cfreturn ReviewID>
</cffunction>

<cffunction name="saveReview" access="public" returntype="numeric" output="no" hint="I save a review.">
	<cfargument name="PackageID" type="numeric" required="yes">
	<cfargument name="Folder" type="string" required="yes">
	
	<cfreturn variables.DataMgr.saveRecord("chkReviews",arguments)>
</cffunction>

</cfcomponent>