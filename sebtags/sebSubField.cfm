<!---
cf_sebSubField build 006
Steve Bryant	2004-05-01
Documentation:
http://www.bryantwebconsulting.com/cftags/cf_sebSubField.htm
---><cfset TagName = "cf_sebSubField"><cfset ParentTag = "cf_sebField"><cfif Not isDefined("ThisTag.ExecutionMode") OR NOT ListFindNoCase(GetBaseTagList(), ParentTag)><cfthrow message="&lt;#TagName#&gt; must be called as a custom tag between &lt;#ParentTag#&gt; and &lt;/#ParentTag#&gt;" type="cftag"></cfif><cfif ThisTag.ExecutionMode eq "Start"><cfassociate basetag="#ParentTag#" datacollection="qsubfields"><cfparam name="attributes.display" default=""><cfparam name="attributes.value" default=""><cfparam name="attributes.checked" default="false" type="boolean"></cfif>