<cfcomponent displayname="Default Layout for ColdFusion MX" extends="layout">
<cffunction name="head" access="public" output="yes"><cfargument name="title" type="string" required="yes">
<cfcontent reset="yes"><html>
<head>
	<title>#arguments.title#</title><cfset variables.title = arguments.title>
	<link rel="stylesheet" type="text/css" href="#variables.WebRoot#all.css" />
	<link rel="STYLESHEET" type="text/css" href="/CFIDE/administrator/cfadmin.css">
	<link rel="SHORTCUT ICON" href="/CFIDE/administrator/favicon.ico">
	<meta name="Author" content="Copyright 1995-2006 Macromedia Corp. All rights reserved.">
	<script type="text/javascript" src="#variables.WebRoot#all.js"></script>
</cffunction>
<cffunction name="body" access="public" output="yes">
</head>

<body bgcolor="E2E9EF" topmargin="0" text="444444" link="003399" vlink="003399" alink="996600" topmargin="0" leftmargin="0" marginheight="0" marginwidth="0">

<table border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="White">
<tr bgcolor="eeeeee">
	<td height="40" nowrap background="/CFIDE/administrator/images/headerbgmx.jpg">&nbsp; &nbsp; &nbsp;</td>

	<td colspan="2" background="/CFIDE/administrator/images/headerbgmx.jpg">
		<b class="h3">#variables.title#</b>
	</td>
	<td width="1" nowrap rowspan="99" bgcolor="003366"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1"></td>
</tr>
<tr><td colspan="3" height="10" background="/CFIDE/administrator/images/homedivider.gif" bgcolor="88A2BF"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1"></td></tr>
<tr bgcolor="336699">
	<td width="7%" height="1"><p style="line-height:1px;"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1" border="0" hspace="2"></p></td>
	<td width="86%"><p style="line-height:1px;"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1" border="0" hspace="252"></p></td>
	<td width="7%"><p style="line-height:1px;"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1" border="0" hspace="2"></p></td>
</tr>
<tr><td height="10" colspan="3">&nbsp;</td></tr>
<tr>
	<td>&nbsp;</td>
	<td>
<!-- margin top -->
</cffunction>
<cffunction name="end" access="public" output="yes">
<br />
<p>
	<a href="index.cfm">home</a> |
	<a href="rule-list.cfm">rules</a> |
	<a href="package-list.cfm">packages</a> |
	<a href="review-list.cfm">past reviews</a> |
	<a href="about.cfm">about</a>
</p>
<br /><br />
<!-- margin bottom -->
	<br />
	</td>
	<td>&nbsp;</td>
</tr>
<tr><td colspan="3" height="10" bgcolor="88A2BF" background="/CFIDE/administrator/images/homedivider.gif"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1" border="0" hspace="2"></td></tr>
<tr><td height="1" colspan="3" bgcolor="6688aa"><p style="line-height:1px;"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1"></p></td></tr>
<tr bgcolor="BDC7D2">
	<td height="40" colspan="3" background="/CFIDE/administrator/images/footerbg2000.gif">&nbsp;</td>
</tr>
<tr><td height="1" colspan="3" bgcolor="003366"><p style="line-height:1px;"><img src="/CFIDE/administrator/images/clear.gif" alt=" " height="1" width="1"></p></td></tr>
</table>
</body>
</html>
</cffunction>
</cfcomponent>