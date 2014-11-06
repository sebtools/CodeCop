<cfimport taglib="sebtags/" prefix="seb">


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h1>Packages</h1>

<seb:sebTable
	pkfield="PackageID"
	label="Package"
	editpage="package-edit.cfm"
	isDeletable="true"
	CFC_Component="#CodeCop.Packages#"
	CFC_GetMethod="getPackages"
	CFC_DeleteMethod="removePackage">
	<seb:sebColumn dbfield="PackageName" label="Package">
</seb:sebTable>

<p><a href="package-import.cfm">Import Package</a></p>

<cfoutput>#layout.end()#</cfoutput>