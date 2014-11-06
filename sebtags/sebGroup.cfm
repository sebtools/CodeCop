<!---
1.0 RC2 (Build 111)
Last Updated: 2008-09-04
Created by Steve Bryant 2004-06-01
Information: sebtools.com
---><cfsilent>
<cfset TagName = "cf_sebGroup">
<cfset ValidTypes = "accordion,fieldset,ColumnsTable,Column">
<cfset ParentTag = "cf_sebForm"><cfset ParentTag2 = "cf_sebTable">
<cfparam name="attributes.type" type="string" default="fieldset">
<cfparam name="attributes.label" type="string" default="">
<cfparam name="attributes.link" type="string" default="">
<cfparam name="attributes.class" type="string" default="sebGroup">
<cfparam name="attributes.help" type="string" default="">
<cfset htmlatts = "id,style">

<cfset atts = "">
<cfloop list="#htmlatts#" index="att">
	<cfif StructKeyExists(attributes,att)>
		<cfset atts = "#atts# #att#=""#attributes[att]#""">
	</cfif>
</cfloop>

<cfif ListFindNoCase(GetBaseTagList(), ParentTag)>
	<cfset ParentAtts = request.cftags.cf_sebForm.attributes>
<cfelse>
	<cfset ParentAtts = StructNew()>
</cfif>

<cfif attributes.type NEQ "hr" AND NOT ThisTag.HasEndTag>
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
<cfif ThisTag.ExecutionMode eq "Start"><div class="accordion-header"#atts#><cfif Len(attributes.link)><a href="#attributes.link#">#attributes.label#</a><cfelse>#attributes.label#</cfif></div><div class="accordion-body"><cfelseif ThisTag.ExecutionMode eq "End"></div></cfif>
</cfcase>
<cfcase value="ColumnsTable">
<cfif ThisTag.ExecutionMode eq "Start"><div class="#attributes.class#"#atts#><table class="sebFormColumns"><tr><cfelseif ThisTag.ExecutionMode eq "End"></tr></table></div></cfif>
</cfcase>
<cfcase value="Column">
<cfif ThisTag.ExecutionMode eq "Start"><td class="#attributes.class#"#atts#><cfelseif ThisTag.ExecutionMode eq "End"></td></cfif>
</cfcase>
<cfcase value="fieldset">
<cfif ThisTag.ExecutionMode eq "Start"><fieldset class="#attributes.class#"#atts#><legend>#attributes.label#</legend><cfelseif ThisTag.ExecutionMode eq "End"></fieldset></cfif>
</cfcase>
<cfcase value="label">
<cfif ThisTag.ExecutionMode eq "Start"><div class="#attributes.class#"#atts#><div>#attributes.label#</div><cfelseif ThisTag.ExecutionMode eq "End"></div></cfif>
</cfcase>
<cfcase value="hr">
<cfif ThisTag.ExecutionMode eq "Start"><hr/></cfif>
</cfcase>
</cfswitch>
<cfif ThisTag.ExecutionMode eq "End" AND Len(Trim(attributes.help))><div class="sebHelp">#attributes.help#</div></cfif>
<cfif StructKeyExists(ParentAtts,"format") AND ParentAtts.format eq "table">
	<cfif ThisTag.ExecutionMode eq "Start"><table></cfif>
	<cfif ThisTag.ExecutionMode eq "End"></td></tr></cfif>
</cfif>
</cfoutput>