<cfimport taglib="sebtags/" prefix="seb">


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h1>Import Package</h1>

<seb:sebForm
	pkfield="PackageID"
	forward="package-list.cfm"
	CFC_Component="#CodeCop.Transfer#"
	CFC_Method="importPackageFile"
	label="Package">
	<seb:sebField fieldname="PackageFile" label="Package File" type="file" destination="#UploadPath#" accept="text/xml" extensions="xml" required="true" />
	<seb:sebField type="Submit/Cancel/Delete" label="Submit,Cancel,Delete" />
</seb:sebForm>

<cfoutput>#layout.end()#</cfoutput>