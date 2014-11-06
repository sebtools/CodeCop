<cfcomponent displayname="Base Rule Type">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="Files" type="any" required="yes">
	<cfargument name="Rules" type="any" required="yes">
	<cfargument name="Issues" type="any" required="yes">
	
	<cfset variables.Files = arguments.Files>
	<cfset variables.Rules = arguments.Rules>
	<cfset variables.Issues = arguments.Issues>
	
	<cfreturn this>
</cffunction>

<cffunction name="getLineNum" access="public" returntype="numeric" output="no">
	<cfargument name="contents" type="string" required="yes">
	<cfargument name="pos" type="numeric" required="yes">
	<cfset var cr = "
">
	<cfset var linedelim = CreateObject("java", "java.lang.System").getProperty("line.separator")><!--- line separator for this OD --->
	<cfset var result = Max( ListLen(Left(arguments.Contents,arguments.pos), linedelim) , ListLen(Left(arguments.Contents,arguments.pos), cr) )>
	
	<cfreturn result>
</cffunction>

<cffunction name="saveIssue" access="private" returntype="numeric" output="no">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="RuleID" type="numeric" required="yes">
	<cfargument name="FileInfo" type="struct" required="yes">
	<cfargument name="pos" type="numeric" required="yes">
	<cfargument name="len" type="numeric" required="yes">
	<cfargument name="info" type="struct" default="#StructNew()#">
	
	<cfreturn variables.Issues.saveIssue(ReviewID,RuleID,FileInfo,pos,len,info)>
</cffunction>

</cfcomponent>
