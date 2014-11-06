<!--- Get ColdFusion version --->
<cfset CFVersionFull = SERVER.ColdFusion.ProductVersion>
<cfset CFVersionMajor = ListFirst(CFVersionFull)>

<!--- Determine if this is being run in the CF Admin --->
<cfif CGI.SCRIPT_NAME CONTAINS "/cfide/administrator/">
	<cfset isInAdmin = true>
<cfelse>
	<cfset isInAdmin = false>
</cfif>

<cfset request.ProductName = "CodeCop">