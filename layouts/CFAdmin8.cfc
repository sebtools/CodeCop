<cfcomponent displayname="Default Layout" extends="layout">
<!--- This is a layout using HTML for the CF Admin as well as CodeCop --->
<cffunction name="head" access="public" output="yes"><cfargument name="title" type="string" required="yes">
<cfcontent reset="yes"><html>
<head>
	<script type="text/javascript" src="/CFIDE/scripts/cfform.js"></script>
	<script type="text/javascript" src="/CFIDE/scripts/masks.js"></script>
	<title>#arguments.title#</title>
	<link rel="stylesheet" type="text/css" href="#variables.WebRoot#cfadmin8.css" />
	<link rel="SHORTCUT ICON" href="/CFIDE/administrator/favicon.ico">
	<meta name="Author" content="Copyright (c) 1995-2006 Adobe Software LLC. All rights reserved.">
	<script type="text/javascript">
	if (window.ColdFusion) ColdFusion.required['cachePath']=true;
	if ( window.top.location.href != 'http://' + window.location.hostname + '/CFIDE/administrator/index.cfm' ) {
		window.location.replace('/CFIDE/administrator/index.cfm');
	}
	<cfif isDefined("request.CodeCop_LoadAdminMenu")>
	window.top.frame_nav.location.reload();
	</cfif>
	</script>
	<script type="text/javascript" src="#variables.WebRoot#all.js"></script>
</cffunction>
<cffunction name="body" access="public" output="yes">
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td><img src="/CFIDE/administrator/images/contentframetopleft.png" alt="" height="23" width="16"></td><td background="/CFIDE/administrator/images/contentframetopbackground.png"><img src="/CFIDE/administrator/images/spacer.gif" alt="" height="23" width="540"></td><td><img src="/CFIDE/administrator/images/contentframetopright.png" alt="" height="23" width="16"></td>
</tr>
<tr>
	<td width="16" style="background:url('/CFIDE/administrator/images/contentframeleftbackground.png') repeat-y;"><img src="/CFIDE/administrator/images/spacer.gif" alt="" width="16" height="1"></td>
	<td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_top_left.gif" alt="" width="12" height="11"></td>
			<td bgcolor="##FFFFFF"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" width="10" alt="" height="10"></td>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_top_right.gif" width="12" alt="" height="11"></td>
		</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="10" bgcolor="##FFFFFF"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" alt="" width="10" height="10"></td>
			<td bgcolor="##FFFFFF">
				<table width="100%" border="0" cellspacing="0" cellpadding="5">
				<tr valign="top">
					<td valign="top">
</cffunction>
<cffunction name="end" access="public" output="yes">
<p>
	<a href="#variables.WebRoot#index.cfm">home</a> |
	<a href="#variables.WebRoot#rule-list.cfm">rules</a> |
	<a href="#variables.WebRoot#package-list.cfm">packages</a> |
	<a href="#variables.WebRoot#review-list.cfm">past reviews</a> |
	<a href="#variables.WebRoot#about.cfm">about</a>
</p>

<br><br>
					</td>
				</tr>
				</table>
			</td>
			<td width="10" bgcolor="##FFFFFF"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" alt="" width="10" height="10"></td>
		</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_bottom_left.gif" alt="" width="12" height="11"></td>
			<td bgcolor="##FFFFFF"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" alt="" width="10" height="10"></td>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_bottom_right.gif" alt="" width="12" height="11"></td>
		</tr>
		</table>
	<td width="10" style="background:url('/CFIDE/administrator/images/contentframerightbackground.png') repeat-y;"><img src="/CFIDE/administrator/images/spacer.gif" alt="" width="16" height="1"></td>
	</td>
</tr>
<tr>
	<td><img src="/CFIDE/administrator/images/contentframebottomleft.png" height="23" alt="" width="16"></td><td background="/CFIDE/administrator/images/contentframebottombackground.png"><img src="/CFIDE/administrator/images/spacer.gif" alt="" height="23" width="540"></td><td><img src="/CFIDE/administrator/images/contentframebottomright.png" alt="" height="23" width="16"></td>
</tr>
</table>
<div align="center">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20"></td>
		<td class="copyright">
<admin:l10n id="copyrightinforhp">
Copyright &copy; 1995-2007 Adobe Systems, Inc. All rights reserved. U.S. Patents Pending.

<hr noshade="true" size="1" />
Notices, terms and conditions pertaining to third party software are located at <a href="http://www.adobe.com/go/thirdparty/##golocale" style="color:##C35617" target="extwebsite" class="copyrightLink">http://www.adobe.com/go/thirdparty/</a> and incorporated by reference herein.
</admin:l10n>
<br>
<br>
		</td>
		<td width="20"></td>
	</tr>
	</table>
</div>
</body>
</html>
</cffunction>
</cfcomponent>