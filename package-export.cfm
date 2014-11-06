<cfparam name="url.id" type="numeric" default="0">
<cfheader name="Content-Disposition" value="attachment;filename=#CreateUUID()#.xml"><!--- Just make up a file-name for the export --->
<cfcontent type="text/xml" reset="yes"><cfoutput>#CodeCop.Transfer.exportPackage(url.id)#</cfoutput>