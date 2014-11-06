<cfset passkey = Variables.ROLEHASH>
<cfset passkey = ReplaceNoCase(passkey,"CFAdmin","")>

<cfset qExtensions = CodeCop.Extensions.getExtensions()>
<cfset ExtensionsList = ValueList(qExtensions.Extension)>
<cfset Extensions = "">
<cfloop index="ext" list="#ExtensionsList#">
	<cfset Extensions = ListAppend(Extensions,".#ext#")>
</cfloop>

<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<script language="JavaScript">
function GetSelectedPath() {
   document.FileDialogForm.Folder.value = document.TreeControl.currentPath("\\");
   document.FileDialogForm.submit();
}
</script>
<cfoutput>#layout.body()#</cfoutput>


<cfoutput>
<applet archive="../classes/cfadmin.jar" code="allaire.cfide.CFNavigationApplet" width=325 height=275 name="TreeControl">
	<param name="ApplicationClass" value="allaire.cfide.CFNavigation">
	<param name="ShowFiles" value="Yes">
	<param name="Extensions" value="#Extensions#">
	<param name="DefaultPath" value="">
	<param name="ServerCaption" value="Select File on the Server">
	<param name="Border" value="Yes">
	<param name="VScroll" value="Yes">
	<param name="passkey" value="#passkey#">
	<param name="OS" value="#Server.OS.Name#">
	This applet displays a file-tree of the server to enable the user to browse its contents.
	Your browser is not configured correctly to use java applets.  Please install the Java Runtime Environment (JRE) and be sure to install the browser plugins.
</applet>
</cfoutput>

<form name="FileDialogForm" action="index.cfm" method="POST" onsubmit="return _CF_checkFileDialogForm(this)">
<table border="0" cellpadding="5" cellspacing="0">
<tr>
	<td>
		<input type="hidden" name="Folder" value="C:\CFusionMX7\db\bugs.mdb">
		<input type="button" name="TreeSubmitApply" value="Submit" onclick="GetSelectedPath();">
	</td>
	<td>
		<input type="submit" name="cancelbrowse" value="Cancel">
	</td>
</tr>
</table>
</form>

<cfoutput>#layout.end()#</cfoutput>
