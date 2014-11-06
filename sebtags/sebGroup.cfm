<cfsilent>
<cfset TagName = "cf_sebGroup">
<cfset ValidTypes = "accordion,fieldset,ColumnsTable,Column">
<cfset ParentTag = "cf_sebForm"><cfset ParentTag2 = "cf_sebTable">
<cfparam name="attributes.type" type="string" default="fieldset">
<cfparam name="attributes.label" type="string" default="">
<cfparam name="attributes.link" type="string" default="">

<cfif ListFindNoCase(GetBaseTagList(), ParentTag)>
	<cfset ParentAtts = request.cftags.cf_sebForm.attributes>
<cfelse>
	<cfset ParentAtts = StructNew()>
</cfif>

<cfif NOT ThisTag.HasEndTag>
	<cfthrow message="#TagName# must have an end tag." type="ctag">
</cfif>
</cfsilent>
<cfoutput>
<cfif StructKeyExists(ParentAtts,"format") AND ParentAtts.format eq "table">
	<cfif ThisTag.ExecutionMode eq "End"></table></cfif>
	<cfif ThisTag.ExecutionMode eq "Start"><tr><td colspan="2"></cfif>
</cfif>
<cfswitch expression="#attributes.type#">
<cfcase value="accordion">
<cfif ThisTag.ExecutionMode eq "Start"><div class="accordion-header"><cfif Len(attributes.link)><a href="#attributes.link#">#attributes.label#</a><cfelse>#attributes.label#</cfif></div><div class="accordion-body"><cfelseif ThisTag.ExecutionMode eq "End"></div></cfif>
</cfcase>
<cfcase value="ColumnsTable">
<cfif ThisTag.ExecutionMode eq "Start"><div><table class="sebFormColumns"><tr><cfelseif ThisTag.ExecutionMode eq "End"></tr></table></div></cfif>
</cfcase>
<cfcase value="Column">
<cfif ThisTag.ExecutionMode eq "Start"><td><cfelseif ThisTag.ExecutionMode eq "End"></td></cfif>
</cfcase>
<cfcase value="fieldset">
<cfif ThisTag.ExecutionMode eq "Start"><fieldset><legend>#attributes.label#</legend><cfelseif ThisTag.ExecutionMode eq "End"></fieldset></cfif>
</cfcase>
</cfswitch>
<cfif StructKeyExists(ParentAtts,"format") AND ParentAtts.format eq "table">
	<cfif ThisTag.ExecutionMode eq "Start"><table></cfif>
	<cfif ThisTag.ExecutionMode eq "End"></td></tr></cfif>
</cfif>
</cfoutput>