<cfimport taglib="sebtags/" prefix="seb">


<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<h1>Reviews</h1>

<seb:sebTable
	pkfield="ReviewID"
	label=""
	isAddable="false"
	isEditable="false"
	isDeletable="true"
	editpage="review-edit.cfm"
	CFC_Component="#CodeCop.Reviews#"
	CFC_GetMethod="getReviews"
	CFC_DeleteMethod="removeReview">
	<seb:sebColumn dbfield="Folder" label="Folder">
	<seb:sebColumn dbfield="PackageName" label="Package">
	<seb:sebColumn dbfield="ReviewDate" label="Date" datatype="date" defaultSort="DESC">
	<seb:sebColumn dbfield="NumIssues" label="Issues">
	<seb:sebColumn link="review-view.cfm?id=" label="view">
</seb:sebTable>

<cfoutput>#layout.end()#</cfoutput>