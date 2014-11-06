<cfcomponent displayname="Rule" output="no">

<cffunction name="init" returntype="any" access="public" output="no" hint="I initialize and return this component.">
	<cfargument name="DataMgr" type="any" required="yes">
	<cfargument name="FileMgr" type="any" required="yes">
	
	<cfset variables.DataMgr = arguments.DataMgr>
	<cfset variables.FileMgr = arguments.FileMgr>
	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	
	<cfset upgrade()>
	
	<cfreturn this>
</cffunction>

<cffunction name="getExtensions" returntype="query" access="public" output="no" hint="I return the extensions associated with the given rule.">
	<cfargument name="RuleID" type="numeric" required="yes">
	
	<cfset var qExtensions = 0>
	
	<!--- get extensions that are mapped (via the chkRules2Extensions table) to the given rule --->
	<cfquery name="qExtensions" datasource="#variables.datasource#">
	SELECT		chkExtensions.ExtensionID,Extension
	FROM		chkExtensions
	INNER JOIN	chkRules2Extensions
		ON		chkExtensions.ExtensionID = chkRules2Extensions.ExtensionID
	WHERE		RuleID = <cfqueryparam value="#arguments.RuleID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfreturn qExtensions>
</cffunction>

<cffunction name="getLink" returntype="query" access="public" output="no" hint="I return the requested link.">
	<cfargument name="LinkID" type="numeric" required="yes">
	
	<cfset var qLink = 0>
	
	<cfquery name="qLink" datasource="#variables.datasource#">
	SELECT	LinkID,RuleID,LinkText,LinkURL
	FROM	chkLinks
	WHERE	LinkID = <cfqueryparam value="#arguments.LinkID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfreturn qLink>
</cffunction>

<cffunction name="getLinks" returntype="query" access="public" output="no" hint="I return the links for the given rule.">
	<cfargument name="RuleID" type="numeric" required="yes">
	
	<cfset var qLinks = 0>
	
	<cfquery name="qLinks" datasource="#variables.datasource#">
	SELECT	LinkID,RuleID,LinkText,LinkURL
	FROM	chkLinks
	WHERE	RuleID = <cfqueryparam value="#arguments.RuleID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfreturn qLinks>
</cffunction>

<cffunction name="getPackages" returntype="query" access="public" output="no" hint="I return the packages associated with the given rule.">
	<cfargument name="RuleID" type="numeric" required="yes">
	
	<cfset var qPackages = 0>
	
	<cfquery name="qPackages" datasource="#variables.datasource#">
	SELECT	PackageID
	FROM	chkRules2Packages
	WHERE	RuleID = <cfqueryparam value="#arguments.RuleID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfreturn qPackages>
</cffunction>

<cffunction name="getRule" returntype="query" access="public" output="no" hint="I return the requested rule.">
	<cfargument name="RuleID" type="numeric" required="yes">
	
	<!--- <cfset var qPackages = getPackages(arguments.RuleID)>
	<cfset var qExtensions = getExtensions(arguments.RuleID)>
	<cfset var qRule = 0> --->
	
	<!---
	I get associated packages and extensions in separate queries
	because it is difficult to form such comma-delimited lists in a
	manner that will work on any database.
	--->
	
	<!--- return the details of the given rule --->
	<!--- <cfquery name="qRule" datasource="#variables.datasource#">
	SELECT		RuleID,RuleName,RuleType,TagName,Regex,Description,allExtensions,UUID,CustomCode,
				chkSeverities.SeverityID,SeverityName,<!--- rank, --->
				chkCategories.CategoryID,CategoryName,
				'#ValueList(qPackages.PackageID)#' AS Packages,
				'#ValueList(qExtensions.ExtensionID)#' AS Extensions,
				'#ValueList(qExtensions.Extension)#' AS ExtensionNames
	FROM		(chkRules
	INNER JOIN	chkSeverities
		ON		chkRules.SeverityID = chkSeverities.SeverityID)
	INNER JOIN	chkCategories
		ON		chkRules.CategoryID = chkCategories.CategoryID
	WHERE		RuleID = <cfqueryparam value="#arguments.RuleID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<cfreturn qRule> --->
	<cfreturn variables.DataMgr.getRecord("chkRules",arguments)>
</cffunction>

<cffunction name="getRules" returntype="query" access="public" output="no" hint="I return all of the rules.">
	<cfargument name="PackageID" type="numeric">
	
	<!--- <cfset var qRules = 0>
	<cfset var qExtensions = 0> --->
	<cfset var data = StructNew()>
	
	<!--- return all rules (optionally limiting by the given package) --->
	<!--- <cfquery name="qRules" datasource="#variables.datasource#">
	SELECT		chkRules.RuleID,chkRules.SeverityID,RuleName,RuleType,TagName,Regex,Description,allExtensions,UUID,CustomCode,
				SeverityName,SeverityName AS Severity,rank,
				chkCategories.CategoryID,CategoryName,
				'' AS ExtensionNames
	FROM		(chkRules
	INNER JOIN	chkSeverities
		ON		chkRules.SeverityID = chkSeverities.SeverityID)
	INNER JOIN	chkCategories
		ON		chkRules.CategoryID = chkCategories.CategoryID
	WHERE		1 = 1<!--- Naturally I don't need this portion, but I like to have a WHERE clause --->
	<cfif StructKeyExists(arguments,"PackageID")>
		AND		EXISTS (
					SELECT	RuleID
					FROM	chkRules2Packages
					WHERE	RuleID = chkRules.RuleID
						AND	PackageID = <cfqueryparam value="#arguments.PackageID#" cfsqltype="CF_SQL_INTEGER">
				)
	</cfif>
	ORDER BY	rank DESC, chkRules.RuleID ASC
	</cfquery> --->
	
	<!---
	I can't easily have a comma-delimited list in the resultset in a cross-database manner
	nor can I use the ValueList() from within the query as I did for one record,
	so I am stuck with looping through the query and setting the value.
	Incidentally, I generally recommend against looping over a query (many a bad performance problem)
	**Be nice if I could figure out a good cross-database method around this
	--->
	<!--- <cfloop query="qRules">
		<cfset qExtensions = getExtensions(RuleID)>
		<cfset QuerySetCell(qRules, "ExtensionNames", ValueList(qExtensions.Extension), CurrentRow)>
		<cfif NOT isBoolean(allExtensions)>
			<cfset QuerySetCell(qRules, "allExtensions", 1, CurrentRow)>
		</cfif>
	</cfloop> --->
	
	<!--- <cfreturn qRules> --->
	
	<cfif StructKeyExists(arguments,"PackageID")>
		<cfset data.Packages = arguments.PackageID>
	</cfif>
	
	<cfreturn variables.DataMgr.getRecords(tablename="chkRules",data=data,orderBy="chkRules.RuleID ASC")><!--- %%TODO: sort: rank DESC, chkRules.RuleID ASC --->
</cffunction>

<cffunction name="removeLink" returntype="void" access="public" output="no" hint="I delete the given link.">
	<cfargument name="LinkID" type="string" required="yes">
	
	<cfset variables.DataMgr.deleteRecord("chkLinks",arguments)>
	
</cffunction>

<cffunction name="removeRule" returntype="void" access="public" output="no" hint="I delete the given rule.">
	<cfargument name="RuleID" type="string" required="yes">
	
	<cfset qRule = getRule(arguments.RuleID)>
	
	<!--- First, delete all associations with packages and extensions --->
	<cfquery datasource="#variables.datasource#">
	DELETE
	FROM	chkRules2Packages
	WHERE	RuleID = <cfqueryparam value="#arguments.RuleID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	<cfquery datasource="#variables.datasource#">
	DELETE
	FROM	chkRules2Extensions
	WHERE	RuleID = <cfqueryparam value="#arguments.RuleID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>
	
	<!--- Then delete the rule record - could have just as easily used SQL. --->
	<cfset variables.DataMgr.deleteRecord("chkRules",arguments)>
	
	<!--- If the file had custom code, I will need to delete the CFC that holds that code. --->
	<cfif Len(qRule.CustomCode)>
		<cfset variables.FileMgr.deleteFile("#qRule.UUID#.cfc")>
	</cfif>
	
</cffunction>

<cffunction name="saveLink" returntype="numeric" access="public" output="no" hint="I save a link.">
	<cfargument name="RuleID" type="numeric" required="yes">
	<cfargument name="LinkID" type="string" required="no">
	<cfargument name="LinkText" type="string" required="no">
	<cfargument name="LinkURL" type="string" required="no">
	
	<cfreturn variables.DataMgr.saveRecord("chkLinks",arguments)>
</cffunction>

<cffunction name="saveRule" returntype="numeric" access="public" output="no" hint="I save a Rule.">
	<cfargument name="RuleID" type="string" required="no">
	<cfargument name="SeverityID" type="string" required="no">
	<cfargument name="RuleName" type="string" required="no">
	<cfargument name="RuleType" type="string" required="no">
	<cfargument name="TagName" type="string" required="no">
	<cfargument name="Regex" type="string" required="no">
	<cfargument name="Description" type="string" required="no">
	<cfargument name="allExtensions" type="string" required="no">
	<cfargument name="Packages" type="string" required="no">
	<cfargument name="Extensions" type="string" required="no">
	<cfargument name="CustomCode" type="string" required="no">
	<cfargument name="CategoryID" type="string" required="no">
	
	<cfset var result = 0>
	<cfset var qRule = 0>
	<cfset var qFindRule = 0>
	
	<!--- If an invalid UUID gets passed in, ditch it. --->
	<cfif StructKeyExists(arguments,"UUID") AND NOT Len(arguments.UUID) eq 35><cfset StructDelete(arguments,"UUID")></cfif>
	
	<!--- If this is a new rule that doesn't come with a UUID, give it one. --->
	<cfif NOT StructKeyExists(arguments,"UUID") AND NOT ( StructKeyExists(arguments,"RuleID") AND isNumeric(arguments.RuleID) AND arguments.RuleID gt 0 )>
		<cfset arguments.UUID = CreateUUID()>
	</cfif>
	
	<!--- Check to see if we are updating an existing rule (DataMgr takes care of this by RuleID, but I want to check by RuleName and UUID --->
	<cfif NOT StructKeyExists(arguments,"RuleID") AND ( StructKeyExists(arguments,"RuleName") OR StructKeyExists(arguments,"UUID") )>
		<cfquery name="qFindRule" datasource="#variables.datasource#">
		SELECT	RuleID
		FROM	chkRules
		WHERE	1 = 1
			<cfif StructKeyExists(arguments,"RuleName")>
			AND	RuleName = <cfqueryparam value="#arguments.RuleName#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<cfif StructKeyExists(arguments,"UUID")>
			AND	UUID = <cfqueryparam value="#arguments.UUID#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
		</cfquery>
		<cfif qFindRule.RecordCount eq 1>
			<cfset arguments.RuleID = qFindRule.RuleID>
		</cfif>
	</cfif>
	
	<!--- If this is an update, get the existing rule (need to know about some changes) --->
	<cfif StructKeyExists(arguments,"RuleID")>
		<cfset qRule = getRule(arguments.RuleID)>
	</cfif>
	
	<cftransaction>
		<!--- Save the rule record. --->
		<cfset result = variables.DataMgr.saveRecord("chkRules",arguments)>
		
		<!--- Save associations with packages (from a comma-delimited list of packages) --->
		<!--- <cfif StructKeyExists(arguments,"Packages")>
			<cfset variables.DataMgr.saveRelationList("chkRules2Packages","RuleID",result,"PackageID",arguments.Packages)>
		</cfif> --->
		
		<!--- Save associations with extensions (from a comma-delimited list of extensions) --->
		<!--- <cfif StructKeyExists(arguments,"Extensions")>
			<cfset variables.DataMgr.saveRelationList("chkRules2Extensions","RuleID",result,"ExtensionID",arguments.Extensions)>
		</cfif> --->
	</cftransaction>
	
	<!--- Handle custom code --->
	<cfif StructKeyExists(arguments,"CustomCode")>
		<cfif Len(arguments.CustomCode)>
			<!--- If we have custom code, save the file for it --->
			<cfset writeCustomCode(result)>
		<cfelseif isQuery(qRule) AND Len(qRule.CustomCode)>
			<!--- If custom code existed, but is removed, delete the file. --->
			<cfset variables.FileMgr.deleteFile("#qRule.UUID#.cfc")>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="writeCustomCode" access="public" returntype="void" output="no" hint="I write a component for the custom code of the given rule.">
	<cfargument name="RuleID" type="string" required="no">
	
	<cfset var qRule = getRule(arguments.RuleID)>
	<cfset var cfcCode = "">
	<cfset var Tag_Component = tag("cfcomponent")>
	<cfset var Tag_Function = tag("cffunction")>
	<cfset var Tag_Argument = tag("cfargument")>
	
	<cfif Len(qRule.CustomCode)>
		<!---
		Sure, this could have been done with way less code and less process-time.
		Sure, it would have been easier to read and edit.
		But I like the programmatic approach here and it ensures that the resulting code is nice and pretty.
		To see how I would recommend sane people tackle this problem, see the code commented out at the bottom of this file.
		--->
		<cfscript>
		Tag_Component.setAttribute("displayname","Custom Check for #qRule.RuleName#");
		Tag_Component.setAttribute("output","no");
		
		Tag_Function = tag("cffunction");
		Tag_Function.setAttribute("name","runRuleCheck");
		Tag_Function.setAttribute("access","public");
		Tag_Function.setAttribute("returntype","boolean");
		Tag_Function.setAttribute("output","no");
		Tag_Function.setAttribute("hint","I run the custom code check for this rule.");
		
		Tag_Argument = tag("cfargument");
		Tag_Argument.setAttribute("name","Folder");
		Tag_Argument.setAttribute("type","string");
		Tag_Argument.setAttribute("required","yes");
		
		Tag_Function.addTag(Tag_Argument);
		
		Tag_Argument = tag("cfargument");
		Tag_Argument.setAttribute("name","FileName");
		Tag_Argument.setAttribute("type","string");
		Tag_Argument.setAttribute("required","yes");
		
		Tag_Function.addTag(Tag_Argument);
		
		Tag_Argument = tag("cfargument");
		Tag_Argument.setAttribute("name","string");
		Tag_Argument.setAttribute("type","string");
		Tag_Argument.setAttribute("required","yes");
		
		Tag_Function.addTag(Tag_Argument);
		
		Tag_Argument = tag("cfargument");
		Tag_Argument.setAttribute("name","info");
		Tag_Argument.setAttribute("type","struct");
		Tag_Argument.setAttribute("default","##StructNew()##");
		
		Tag_Function.addTag(Tag_Argument);
		
		Tag_Function.addContents("");
		Tag_Function.addContents("<cfset var result = true>");
		Tag_Function.addContents("");
		Tag_Function.addContents(qRule.CustomCode);
		Tag_Function.addContents("");
		Tag_Function.addContents("<cfreturn result>");
		
		Tag_Component.addTag(Tag_Function);
		
		variables.FileMgr.writeFile("#qRule.UUID#.cfc",Tag_Component.write());
		</cfscript>
		
	</cfif>

</cffunction>

<cffunction name="tag" access="private" returntype="any" output="no" hint="I create and return a tag.">
	<cfargument name="name" type="string" required="yes">
	
	<cfreturn CreateObject("component","tags.#arguments.name#").init()>
</cffunction>

<cffunction name="upgrade" access="private" returntype="void" output="no" hint="I handle any tasks to upgrade this component to current version.">
	
	<cfset var qRules = 0>
	<cfset var UUID = "">
	
	<!--- Make sure that all rules have UUIDs (an eary iteration of this code didn't have a UUID field) --->
	
	<cfquery name="qRules" datasource="#variables.datasource#">
	SELECT		RuleID
	FROM		chkRules
	WHERE		UUID IS NULL
	</cfquery>
	
	<cfloop query="qRules">
		<cfset UUID = CreateUUID()>
		<cfquery datasource="#variables.datasource#">
		UPDATE	chkRules
			SET	UUID = '#UUID#'
		WHERE	RuleID = #Val(RuleID)#
		</cfquery>
	</cfloop>

</cffunction>

</cfcomponent>
<!--- The sane person's approach to creating code: --->
<!--- <cfsavecontent variable="cfcCode"><cfoutput>
#chr(60)#cfcomponent displayname="Custom Check for #qRule.RuleName#"#chr(62)#

#chr(60)#cffunction name="runRuleCheck" access="public" returntype="boolean" output="no"#chr(62)#
	#chr(60)#cfargument name="Folder" type="string" required="yes"#chr(62)#
	#chr(60)#cfargument name="FileName" type="string" required="yes"#chr(62)#
	#chr(60)#cfargument name="string" type="string" required="yes"#chr(62)#
	
	#chr(60)#cfset var result = true#chr(62)#
	
	#qRule.CustomCode#
	
	#chr(60)#cfreturn result#chr(62)#
#chr(60)#/cffunction#chr(62)#

#chr(60)#/cfcomponent#chr(62)#
</cfoutput></cfsavecontent>
<cfset variables.FileMgr.writeFile("#qRule.UUID#.cfc",cfcCode)> --->