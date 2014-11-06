<cfcomponent displayname="MS Word" extends="layout">
<!--- This file is a quick example of an alternate layout component for WML phone --->
<cffunction name="head" access="public" output="yes"><cfargument name="title" type="string" required="yes">
<cfcontent reset="Yes"><cfset request.cftags.sebtags.xhtml = false>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>#xmlFormat(arguments.title)#</title>
	<link rel="stylesheet" type="text/css" href="all.css" />
	<link rel="stylesheet" type="text/css" href="pdf.css" />
	<base href="#CGI.HTTP_HOST##CGI.SCRIPT_NAME#" />
</cffunction>
<cffunction name="body" access="public" output="yes">
</head>
<body>
</cffunction>
<cffunction name="end" access="public" output="yes">
</body>
</html>
<cfset output = getPageContext().getOut().getString()><!--- Thanks to kola.oyedeji --->
<cfset output = ReplaceNoCase(output, 'class="right"',  'align="right"' , 'ALL')>
<cfset output = ReplaceNoCase(output, 'class="left"',  'align="left"' , 'ALL')>
<cfheader name="Content-Disposition" value="attachment;filename=#ReplaceNoCase(variables.FileName, ".cfm", ".pdf")#">
<cfcontent type="application/pdf" reset="Yes">
<cfdocument format="PDF" pagetype="letter"><!---  permissions="AllowPrinting, AllowCopy, AllowScreenReaders, AllowDegradedPrinting" --->
#output#
</cfdocument>
</cffunction>
<cffunction name="formatLink" access="public" returntype="void" output="yes"><cfargument name="formats" type="string" required="yes">
</cffunction>
<cffunction name="switchLayout" access="public" returntype="layout" output="no" hint="I prevent the layout to be switched once Word is chosen as the layout.">
	<cfargument name="layout" type="string" required="yes">
	<cfreturn this>
</cffunction>
</cfcomponent>
