<cfimport taglib="sebtags/" prefix="seb">

<!--- Get available packages --->
<cfset qPackages = CodeCop.Packages.getPackages()>
<!--- Get available extensions --->
<cfset qExtensions = CodeCop.Extensions.getExtensions()>

<!--- choose a default package (so that user has one less step they must take) --->
<cfset DefaultPackageID = CodeCop.Packages.getDefaultPackageID()>


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
	<script language="JavaScript" src="index.js" type="text/javascript"></script>
<cfoutput>#layout.body()#</cfoutput>

<p>Choose the path that you want the CodeCop to review.</p>

<seb:sebForm
	formname="myform"
	forward="review-view.cfm?id={result}"
	CFC_Component="#CodeCop#"
	CFC_Method="runReview"
	CatchErrTypes="CodeCop"
	>
	<seb:sebField fieldname="Folder" required="true" Length="250" size="75">
	<!--- Only show browse server in cfadmin of CF7 (security and use of undocumented variable) --->
	<!--- As it requires JavaScript, it will only show if JS is running. --->
	<cfif isInAdmin AND CFVersionMajor GTE 7><seb:sebField type="custom1"><div id="browse-server"></div></seb:sebField></cfif>
	<seb:sebField fieldname="PackageID" label="Rules Package" type="select" subquery="qPackages" subvalues="PackageID" subdisplays="PackageName" defaultValue="#DefaultPackageID#" required="true">
	<seb:sebField fieldname="allExtensions" label="All Extensions?" type="yesno" defaultValue="true" /><!--- could have used: onclick="showExtensions();", but that is less unobstructive --->
	<seb:sebField fieldname="Extensions" type="checkbox" subquery="qExtensions" subvalues="ExtensionID" subdisplays="Extension" />
	<seb:sebField fieldname="MoreExtensions" label="more" />
	<seb:sebField type="custom1"><a href="extension-list.cfm">manage extensions</a></seb:sebField>
	<seb:sebField type="submit" label="Submit">
</seb:sebForm>
<!---
The above form provides the UI for the form.
It will call the indicated method with the form fields passed-in as named arguments,
catching and handling any errors of the indicated types (try passing in an invalid folder as an example)
Upon success, it will forward the user to the indicated page (replacing "{result}" with the result of the CFC_Method
--->

<cfoutput>#layout.end()#</cfoutput>