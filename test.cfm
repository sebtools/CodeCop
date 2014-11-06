<cfsetting showdebugoutput="YES">

<!--- This is just for testing. I don't want any layout on the page --->
<cfset layout = layout.switchLayout("Blank")>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<p>DataMgr Loaded.</p>
<cfloop collection="#Application.CodeCop#" item="itm">
	<cfoutput>#itm#: #isCFC(Application.CodeCop[item])#<br/></cfoutput>
</cfloop>

<cftry>
	<!--- <cfquery name="qResults" datasource="TestSQL2">SELECT * FROM chk2Rules</cfquery> --->
	<!--- <cfset qResults = DataMgr2.runSQL("SELECT * FROM chkRules")> --->
	<cfset qResults = Application["CodeCop"].DataMgr.getRecords("chkExtensions")>
<cfcatch>
	<cfdump var="#CFCATCH#">
</cfcatch>
</cftry>

<cfdump var="#qResults#">

<cfoutput>#layout.end()#</cfoutput>