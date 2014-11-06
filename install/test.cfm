<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<!--- <cfset AppFilePath = ReplaceNoCase(GetDirectoryFromPath(GetBaseTemplatePath()), GetDirectoryFromPath(GetBaseTemplatePath()), "")> --->

<!--- <cfdump var="#CGI#"> --->
<br>

<cfset CreateObject("component","cfide.administrator.CodeCop.com.sebtools.AppLoader").init(XmlFilePath=ExpandPath("../sys/xml.cfm"),Storage=Application.CodeCop)>

<cfdump var="#Application.CodeCop#">

<cfloop collection="#Application.CodeCop#" item="itm">
	<cfoutput>#itm#: #IsObject(Application.CodeCop[itm])#<br/></cfoutput>
</cfloop>
<cfdump var="#request.Paths#">

<cfoutput>
#GetDirectoryFromPath(GetCurrentTemplatePath())#<br>
#GetDirectoryFromPath(GetBaseTemplatePath())#
</cfoutput>

<cfoutput>#layout.end()#</cfoutput>