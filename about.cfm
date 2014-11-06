<cfset AboutDataMgr = CreateObject("component","com.sebtools.DataMgr").init("")>
<cfset qDatabases = AboutDataMgr.getSupportedDatabases()><!--- Find the databases supported by this installation --->

<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
<cfoutput>#layout.body()#</cfoutput>

<cfoutput><h1>About #request.ProductName#</h1></cfoutput>

<div class="infobox">
	<p><a href="test.cfm">test</a></p>
	<!--- Component will exist unless code is being reinitialized on this page. --->
	<cfif StructKeyExists(Application,"CodeCop")>
		<cfoutput><h2>Version #Application["CodeCop"].ConfigApp.getVersion()# (build #Application["CodeCop"].ConfigApp.getBuild()#)</h2></cfoutput>
	</cfif>
	
	<h3>General Information</h3>
	<p>Find out <a href="rule-how-customcode.cfm">how to create custom code for a rule</a></p>
	<p>
		CodeCop was written with <a href="http://en.wikipedia.org/wiki/Progressive_enhancement">progressive enhancement</a> in mind.
		Therefore some features will only be available in environments that support them.
		CodeCop has maximum functionality running in the administrator on CFMX7 with JavaScript enabled.
	</p>

	<h3>Supported Databases</h3>
	<ul>
	<cfoutput query="qDatabases">
		<li>#DatabaseName#</li>
	</cfoutput>
	</ul>
	
	<h3>Architecture Notes</h3>
	<p>Initially developed for <a href="http://ray.camdenfamily.com/index.cfm/2006/6/11/Advanced-ColdFusion-Contest-Announced" target="_blank">Ray Camden's ColdFusion Coding Contest</a></p>
	<p>This is a pretty major case of eating my own dog food. This project takes advantage of several pre-existing ColdFusion tools, all of which I wrote (although I am sure that I didn't write every line in each of them).</p>
	<p>These tools include:</p>
	<ul>
		<li><a href="http://www.bryantwebconsulting.com/cftags/cf_sebForm.htm" target="_blank">cf_sebForm</a></li>
		<li><a href="http://www.bryantwebconsulting.com/cftags/cf_sebTable.htm" target="_blank">cf_sebTable</a></li>
		<li><a href="http://www.bryantwebconsulting.com/presentations.cfm" target="_blank">DataMgr</a></li>
		<li>FileMgr.cfc (as yet undocumented)</li>
		<li><a href="http://coldfusion.sys-con.com/read/154231.htm">Layout Components</a></li>
	</ul>
	<p>These tools, in turn, take advantage of JavaScript code written by others, including <a href="http://www.pengoworks.com/index.cfm?action=get:qforms">qForms</a>.</p>
	<p>I used my (still very young) <a href="http://steve.coldfusionjournal.com/preview_of_new_code_creator.htm" target="_blank">Code Generator</a> to kick-start development.</p>
	
	<h3>Credits</h3>
	<p>Designed, built and maintained by <a href="http://www.bryantwebconsulting.com/">Steve Bryant</a></p>
	<p>Testing by Ryan Hartwich, Drew Harris, and Will Spurgeon.</p>
</div>

<cfoutput>#layout.end()#</cfoutput>