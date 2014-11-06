<cfheader name="Content-Disposition" value="attachment;filename=CodeCop.sql">
<cfcontent type="text/sql" reset="yes"><cfoutput>#Application["CodeCop"].InstallSQL#</cfoutput>