<cfcomponent displayname="Default Layout" extends="layout">
<!--- This is a layout using HTML for the CF Admin as well as CodeCop --->
<cffunction name="head" access="public" output="yes"><cfargument name="title" type="string" required="yes">
<cfcontent reset="yes"><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>#arguments.title#</title>
	<link rel="stylesheet" type="text/css" href="#variables.WebRoot#all.css" />
	<link rel="stylesheet" type="text/css" href="#variables.WebRoot#cfadmin.css" />
	<link rel="SHORTCUT ICON" href="/CFIDE/administrator/favicon.ico">
	<script type="text/javascript" src="/CFIDE/scripts/cfform.js"></script>
	<script type="text/javascript" src="/CFIDE/scripts/masks.js"></script>
	<script type="text/javascript" src="#variables.WebRoot#all.js"></script>
</cffunction>
<cffunction name="body" access="public" output="yes">
</head>

<body>

<table width="92%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td colspan="3"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" height="1" width="540" alt=""></td>
</tr>
<tr>
	<td width="10"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" width="10" height="10" alt=""></td>
	<td>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_top_left.gif" width="12" height="11" alt=""></td>
			<td bgcolor="##FFFFFF"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" width="10" height="10" alt=""></td>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_top_right.gif" width="12" height="11" alt=""></td>
		</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="10" bgcolor="##FFFFFF"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" width="10" height="10" alt=""></td>
			<td bgcolor="##FFFFFF">
				<table width="100%"  border="0" cellspacing="0" cellpadding="5">
				<tr>
					<td>&nbsp;</td>
					<td>

<span class="pageHeader">Custom Extensions &gt; CodeCop</span>
<br><br>

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
		</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_bottom_left.gif" width="12" height="11" alt=""></td>
			<td bgcolor="##FFFFFF"><img src="/CFIDE/administrator/images/spacer_10_x_10.gif" width="10" height="10" alt=""></td>
			<td width="12"><img src="/CFIDE/administrator/images/cap_content_white_main_bottom_right.gif" width="12" height="11" alt=""></td>
		</tr>
		</table>
	</td>
</tr>
</table>
		
<div align="center">
	<br>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td class="copyright">
			<admin:l10n id="copyrightinforhp">
				Copyright &copy; 1995-2005 Macromedia, Inc. and its licensors.  All rights reserved. U.S. Patents Pending.
				<hr noshade="true" size="1" />
				Notices, terms and conditions pertaining to third party software are located at <a href="http://www.macromedia.com/go/thirdparty" target="extwebsite" class="copyrightLink">http://www.macromedia.com/go/thirdparty/</a> and incorporated by reference herein.
			</admin:l10n>
			<br>
			<br>
		</td>
	</tr>
	</table>
</div>

</body>

</html>
</cffunction>

</cfcomponent>
