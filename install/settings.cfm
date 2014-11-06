<cfimport taglib="../sebtags/" prefix="seb">

<!--- Get possible datasources --->
<cfset qDatasources = Application["CodeCop"].DatasourceMgr.getDatasources()>
<cfif NOT qDatasources.RecordCount>
	<cfset qDatabases = Application["CodeCop"].DatasourceMgr.getDatabases()>
</cfif>

<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<p>You must choose a datasource for CodeCop to use:</p>

<seb:sebForm
	CFC_Component="#Application.CodeCop.SettingsMgr#"
	CFC_Method="saveSettings"
	forward="../index.cfm?reinit=1"
	CatchErrTypes="CodeCop">
	<!--- If we were able to get a selection of datasources, use that as a selection, otherwise let the user type them in. --->
	<cfif qDatasources.RecordCount>
		<seb:sebField name="datasource" type="select" subquery="qDatasources" subvalues="name" required="true" defaultValue="CodeCop">
	<cfelse>
		<seb:sebField name="datasource" type="text" Length="50" size="30" required="true">
		<seb:sebField name="database" type="select" subquery="qDatabases" subvalues="Database" subdisplays="DatabaseName" required="true">
	</cfif>
	<seb:sebField type="submit" label="Submit">
</seb:sebForm>

<cfoutput>#layout.end()#</cfoutput>