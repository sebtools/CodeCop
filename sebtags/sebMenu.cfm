<cfsilent>
<cfset TagName = "cf_sebMenu">
<!---
Code by Steve Bryant
Tim Jackson provided the original tags as well as the inpiration and brilliant implementation of consistency for admin sections.
--->
<cfscript>
//Default attributes from request.cftags.sebtags structure
if ( StructKeyExists(request, "cftags") AND StructKeyExists(request.cftags, "sebtags") ) {
	StructAppend(attributes, request.cftags["sebtags"], "no");
}
//Default attributes from request.cftags.cf_sebMenu (overrides sebtags defaults)
if ( StructKeyExists(request, "cftags") AND StructKeyExists(request.cftags, TagName) ) {
	StructAppend(attributes, request.cftags[TagName], "no");
}
</cfscript>
<cfparam name="attributes.action" default="StartPage"><!--- options: StartPage,EndPage --->
<cfparam name="attributes.menutype" default=""><!--- options: bar,drop-down,roundtab,squaretab --->
<cfparam name="attributes.width" default="770" type="numeric">
<cfparam name="attributes.Label" default="Admin Menu:">
<cfparam name="attributes.HasLeftPanel" default="true" type="boolean">
<cfparam name="attributes.LeftLabelWidth" default="135" type="numeric">
<cfparam name="attributes.MainLink" default="">
<cfparam name="attributes.skin" default="">
<cfparam name="attributes.librarypath" default="lib/">
<cfparam name="attributes.imagepath" default="#attributes.librarypath#">

<cfparam name="attributes.MainLinkLabel" default="">
<cfparam name="attributes.LogoutLink" default="/logout.cfm">

<!--- %% !! TEMPORARY !! --->
<!--- <cfparam name="attributes.shape" default="bar"> --->

<cfparam name="attributes.align" default=""><!--- not required --->
<cfparam name="attributes.TextRight" default="">

<cfparam name="url.sebTab" default=""><!--- indicator of chosen tab --->

<cfinclude template="sebtools.cfm">

</cfsilent>
<cfif isDefined("ThisTag.ExecutionMode") AND ThisTag.ExecutionMode eq "End"><cfsilent>
<cfif Not isDefined("ThisTag.items") OR ArrayLen(ThisTag.items) eq 0><cfthrow message="&lt;#TagName#&gt; must include at least one &lt;cf_Tab&gt;" type="cftag"></cfif>

<cfscript>
//Set menu-type based on skins/browser/defaults
if (attributes.menutype eq "drop-down") {
	isSFBrowser = false;
	sfBrowsers = "Gecko,MSIE 5.5,MSIE 6,Opera 7";
	for (sf=1; sf lt ListLen(sfBrowsers); sf=sf+1) {
		if ( CGI.USER_AGENT CONTAINS ListGetAt(sfBrowsers,sf) ) {
			isSFBrowser = true;
		}
	}
	if ( Not isSFBrowser ) {
		attributes.menutype = "bar";
	}
}
if ( NOT Len(attributes.menutype) ) {
	if ( StructKeyExists(sebtools.skins, attributes.skin) ) {
		attributes.menutype = sebtools.skins[attributes.skin].menutype;
	} else {
		attributes.menutype = "round";
	}
}

//Get the current file
CurrPage = CGI.SCRIPT_NAME;
CurrFile = ListLast(CurrPage,"/");
CurrPath = ReplaceNoCase(CurrPage,CurrFile,"");
CurrTab = 0;

//Just a simple rename of items to tabs for readability
ThisTag.tabs = ThisTag.items;
//Adjust links, set currTab from url var
for (i=1; i lte ArrayLen(ThisTag.tabs); i=i+1) {
	if ( Len(url.sebTab) ) {
		if ( url.sebTab eq ThisTag.tabs[i].Label ) {
			CurrTab = i;
		}
	} else {
		if ( ThisTag.tabs[i].Link eq CurrPage ) {
			CurrTab = i;
		}
	}
	//Make sure can have query_string var appended directly to it
	if ( ThisTag.tabs[i].Link CONTAINS "?" ) {
		ThisTag.tabs[i].LinkURL = ThisTag.tabs[i].Link & "&amp;";
	} else {
		ThisTag.tabs[i].LinkURL = ThisTag.tabs[i].Link & "?";
	}
	//Add sebTab to link URL
	ThisTag.tabs[i].LinkURL = ThisTag.tabs[i].LinkURL & "sebTab=#URLEncodedFormat(ThisTag.tabs[i].Label)#";
}

//If we don't know currTab yet, check by children/pages
if ( NOT CurrTab ) {
	//  Look in each tab
	for (i=1; i lte ArrayLen(ThisTag.tabs); i=i+1) {
		if ( Len(ThisTag.tabs[i].pages) ) {
			//Look for page in pages list
			if ( ListFindNoCase(ThisTag.tabs[i].pages, CurrPage) ) {
				CurrTab = i;
				break;
			}
		}
		//Look for page in sub-items
		if ( StructKeyExists(ThisTag.tabs[i],"items") AND ArrayLen(ThisTag.tabs[i].items) ) {
			//  Look in each sub-item
			for ( j=i; j lte ArrayLen(ThisTag.tabs[i].items); j=j+1 ) {
				if ( CurrPage eq ThisTag.tabs[i].items[j].Link ) {
					CurrTab = i;
					break;
				}
				if ( Len(ThisTag.tabs[i].items[j].pages) ) {
					if ( ListFindNoCase(ThisTag.tabs[i].items[j].pages, CurrPage) ) {
						CurrTab = i;
						break;
					}
				}
			}
			// /Look in each sub-item
		}
		
		if ( CurrTab ) {
			break;
		}
	}
	// /Look in each tab
}
//If we *still* don't know what tab to use, check by directory
tCurrPath = CurrPath;
if ( NOT CurrTab ) {
	for ( j=ListLen(CurrPath,"/"); j gte 1; j=j-1 ) {
		for (i=1; i lte ArrayLen(ThisTag.tabs); i=i+1) {
			if ( Len(ThisTag.tabs[i].folder) ) {
				if ( tCurrPath eq ThisTag.tabs[i].folder ) {
					CurrTab = i;
				}
			}
		}
		if ( CurrTab ) {
			break;
		} else {
			if ( ListLen(tCurrPath,"/") ) {
				tCurrPath = ListDeleteAt(tCurrPath,ListLen(tCurrPath,"/"),"/");
				if ( Right(tCurrPath,1) neq "/" ) {
					tCurrPath = "#tCurrPath#/";
				}
			} else {
				break;
			}
		}
	}
}

//Set widths based on menu type
if ( attributes.menutype eq "squaretab" ) {
	LeftSideWidth = attributes.LeftLabelWidth;
} else {
	LeftSideWidth = attributes.LeftLabelWidth;// + 9
}
LeftHRWidth = LeftSideWidth - 5;
RightSideWidth = attributes.Width - LeftSideWidth;

//Base ItemScope (for site menu items) on whether currTab is indicated
if ( CurrTab ) {
	ItemScope = ThisTag.tabs[CurrTab];
} else {
	ItemScope = ThisTag;
}
</cfscript>

</cfsilent><!--- START OUTPUT ---><cfoutput><!-- CurrTab:#CurrTab# -->
<cfif attributes.menutype eq "drop-down"><cfsavecontent variable="head1"><script language="JavaScript" src="#attributes.librarypath#nav.js" type="text/javascript"></script><style type="text/css">@import url(#attributes.librarypath#nav.css);</style></cfsavecontent><cfhtmlhead text="#head1#"></cfif>
<cfif Len(attributes.skin)><cfsavecontent variable="styletag"><style type="text/css">@import url(#attributes.librarypath#skins/#attributes.skin#.css);</style></cfsavecontent><cfhtmlhead text="#styletag#"></cfif>
<cfif attributes.menutype eq "drop-down">
<!--- Drop-Down --->
<div id="sebTab">
<div id="nav" style="width:#attributes.width#px;" class="sfMenu">
	<ul><cfloop index="i" from="1" to="#ArrayLen(ThisTag.tabs)#" step="1"><li><a href="#ThisTag.tabs[i].LinkURL#"<cfif CurrTab eq i> class="CurrTab"</cfif>>#ThisTag.tabs[i].Label#</a><cfif StructKeyExists(ThisTag.tabs[i], "items")><ul><cfloop index="j" from="1" to="#ArrayLen(ThisTag.tabs[i].items)#" step="1"><li><a href="#ThisTag.tabs[i].items[j].Link#">#ThisTag.tabs[i].items[j].Label#</a></cfloop></ul></cfif></li></cfloop></ul>
</div>
<br/></div>
<cfelse>
<div id="sebMenu" style="width:#attributes.width#px;">
<table width="#attributes.width#"<cfif Len(attributes.align)> align="#attributes.align#"</cfif> border="0" cellspacing="0" cellpadding="0" id="sebTab">
<tr><cfif attributes.HasLeftPanel>
	<cfif attributes.menutype eq "roundtab"><td width="9"><img src="#attributes.imagepath#tab_round_topleft.gif" width="9" height="22" border="0" alt=""/></td><cfset LeftTabWidth = attributes.LeftLabelWidth - 15>
	<cfelse><cfset LeftTabWidth = attributes.LeftLabelWidth></cfif>
	<td align="center" nowrap width="#LeftTabWidth#"><b id="sebMenuLabel">#attributes.Label#</b></td></cfif>
<cfloop index="i" from="1" to="#ArrayLen(ThisTag.tabs)#" step="1">
	<cfif attributes.menutype eq "squaretab"><td width="1" style="width:1px;background-color:white;"><div style="width:2px;"></div></td>
	<cfelseif attributes.menutype eq "roundtab"><td width="17"><img src="#attributes.imagepath#tab_round_separator.gif" width="17" height="22" border="0" alt=""/></td></cfif>
	<td nowrap class="tab<cfif CurrTab eq i> curr</cfif>"><a href="#ThisTag.tabs[i].LinkURL#"<cfif CurrTab eq i> class="CurrTab"</cfif>>#ThisTag.tabs[i].Label#</a></td>
</cfloop>
	<cfif attributes.menutype eq "roundtab"><td width="9"><img src="#attributes.imagepath#tab_round_topright.gif" width="9" height="22" border="0" alt=""/></td></cfif>
	<td width="100%" class="clear" align="right">#attributes.TextRight#&nbsp;</td>
</tr>
</table>
<table width="#attributes.width#" border="0" cellspacing="0" cellpadding="0" style="width:#attributes.width#px;border:1px solid ##BDBDBD;" id="sebMenuMain">
<tr><cfif attributes.HasLeftPanel>
	<td width="#LeftSideWidth#" bgcolor="##EFEFEF" id="sebTabMenu" valign="top">
	<cfif Len(attributes.MainLink)><ul><li><a href="#attributes.MainLink#" id="sebMenuMainLink"><cfif Len(attributes.MainLinkLabel)>#attributes.MainLinkLabel#<cfelse>Home</cfif></a></li></ul></cfif>
	<hr width="#LeftHRWidth#" size="1"/>
	<cfif CurrTab AND StructKeyExists(ItemScope, "items")>
	<ul>
		<cfloop index="j" from="1" to="#ArrayLen(ItemScope.items)#" step="1">
		<li><a href="#ItemScope.items[j].Link#">#ItemScope.items[j].Label#</a></li></cfloop>
	</ul>
	</cfif>
	<hr width="#LeftHRWidth#" size="1"/>
	<cfif Len(attributes.LogoutLink)><ul><li><a href="#attributes.LogoutLink#" id="sebMenuLogoutLink">Logout</a></li></ul></cfif>
	</td></cfif>
	<td width="#RightSideWidth#" style="padding:8px;" valign="top" id="sebMenuBody">
</cfif>

</cfoutput><cfset ThisTag.GeneratedContent = "">
</cfif>
<cfif isDefined("ThisTag.ExecutionMode") AND ThisTag.ExecutionMode eq "Start" AND ListFindNoCase("end,EndPage", attributes.action)>
	</td>
</tr>
</table>
</div>
</cfif>