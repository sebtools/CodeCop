<cfimport taglib="sebtags/" prefix="seb">


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h1>Extensions</h1>

<seb:sebTable
	pkfield="ExtensionID"
	label="Extension"
	editpage="extension-edit.cfm"
	isEditable="false"
	CFC_Component="#CodeCop.Extensions#"
	CFC_GetMethod="getExtensions"
	CFC_DeleteMethod="removeExtension">
	<seb:sebColumn dbfield="Extension" label="Extension">
	<seb:sebColumn link="extension-edit.cfm?id=" label="Extension">
	<seb:sebColumn type="delete" show="!NumRules">
</seb:sebTable>

<cfoutput>#layout.end()#</cfoutput>