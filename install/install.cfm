<cfimport taglib="../sebtags/" prefix="seb">

<!--- Get possible datasources --->
<cfset qDatasources = Application["CodeCop"].DatasourceMgr.getDatasources()>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<cfoutput>
<p>CodeCop wasn't able to install on your datasource ("#SettingsData.datasource#").</p>
<ul>
	<li>If the datasource is correct, run <a href="sql.cfm">this SQL code</a> on your database and <a href="../">continue</a>.</li>
	<li>You can also <a href="settings.cfm">change your datasource</a>.</li>
</ul>
</cfoutput>


<cfoutput>#layout.end()#</cfoutput>