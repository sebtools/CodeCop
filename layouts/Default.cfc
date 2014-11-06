<cfcomponent displayname="Default Layout" extends="layout"><cfimport taglib="../sebtags/" prefix="seb">
<!--- This is a layout using HTML for the CF Admin as well as the CodeCop --->
<cffunction name="head" access="public" output="yes"><cfargument name="title" type="string" required="yes">
<cfcontent reset="yes"><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>#arguments.title#</title>
	<link rel="stylesheet" type="text/css" href="all.css" />
	<script type="text/javascript" src="all.js"></script>
</cffunction>
<cffunction name="body" access="public" output="yes">
</head>
<body>

<h1><img src="#variables.WebRoot#i/shield3.gif" width="49" height="49" alt=""> CodeCop</h1>

<seb:sebMenu LogoutLink="">
	<seb:sebMenuItem label="Home" link="#variables.WebRoot#index.cfm">
	<seb:sebMenuItem label="Rules" link="#variables.WebRoot#rule-list.cfm">
	<seb:sebMenuItem label="Packages" link="#variables.WebRoot#package-list.cfm">
	<seb:sebMenuItem label="Past Reviews" link="#variables.WebRoot#review-list.cfm">
	<seb:sebMenuItem label="About" link="#variables.WebRoot#about.cfm">
</seb:sebMenu>

</cffunction>
<cffunction name="end" access="public" output="yes">
<seb:sebMenu action="end">

</body>
</html>
</cffunction>
</cfcomponent>
