<cfsilent>
<cfif isDefined("ThisTag.ExecutionMode") AND ( (Not ThisTag.HasEndTag) OR ThisTag.ExecutionMode eq "End" )>
	<cfset TagName = "cf_sebMenuItem"><cfset ParentTag = "cf_sebMenu">
	<cfparam name="attributes.Label" default="Admin">
	<cfparam name="attributes.Link" default="admin_mgr.cfm">
	<cfparam name="attributes.target" default="">
	<cfparam name="attributes.pages" default="">
	<cfparam name="attributes.folder" default="">
	<cfif ListFindNoCase(GetBaseTagList(), ParentTag)>
		<cfassociate basetag="#ParentTag#" datacollection="items">
	<cfelse>
		<cfthrow message="&lt;#TagName#&gt; must be called as a custom tag between &lt;#ParentTag#&gt; and &lt;/#ParentTag#&gt;" type="cftag">
	</cfif>
	<cfif StructKeyExists(ThisTag, "items")><cfset attributes.items = ThisTag.items></cfif>
	
	<cfif Len(attributes.folder) AND NOT Right(attributes.folder,1) eq "/">
		<cfset attributes.folder = "#attributes.folder#/">
	</cfif>
	<cfif Right(attributes.Link,1) eq "/" AND NOT Len(attributes.folder)>
		<cfset attributes.folder = attributes.Link>
	</cfif>
	
</cfif>
</cfsilent>