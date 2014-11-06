<cfparam name="URL.id" type="numeric" default="0">

<!--- Get data for use on this page --->
<cfset qFile = CodeCop.Files.getFile(URL.id)>

<cfset CompName = ListFirst(ListLast(qFile.FileName,"/"),".")>

<cfset TagFinder = CreateObject("component","sys.types.Tag").init(CodeCop.Files,CodeCop.Rules,CodeCop.Issues)>

<!--- Parse component information --->
<cfset components = TagFinder.getTags(qFile.FileContents,'cfcomponent')>
<cfloop index="compnum" from="1" to="#ArrayLen(components)#" step="1">
	<cfset components[compnum].functions = TagFinder.getTags(components[compnum].innerCFML,'cffunction')>
	<cfloop index="funcnum" from="1" to="#ArrayLen(components[compnum].functions)#" step="1">
		<cfset components[compnum].functions[funcnum].line = components[compnum].functions[funcnum].line + components[compnum].line - 1>
		<cfset components[compnum].functions[funcnum].arguments = TagFinder.getTags(components[compnum].functions[funcnum].innerCFML,'cfargument')>
	</cfloop>
</cfloop>

<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
	<link rel="stylesheet" type="text/css" href="cfcdoc.css" />
<cfoutput>#layout.body()#</cfoutput>

<cfoutput>
<cfloop index="compnum" from="1" to="#ArrayLen(components)#" step="1">
	<h1>Component #CompName# <cfif StructKeyExists(components[compnum]["attributes"],"displayname")>(#components[compnum]["attributes"].displayname#)</cfif></h1>
	<p><a href="file-view.cfm?id=#URL.id#">Return to file view</a></p>
	<cfset functions = components[compnum].functions>
	<cfif StructKeyExists(components[compnum].attributes,"hint")>
		<p>#components[compnum].attributes.hint#</p>
		<br>
	</cfif>
	<table class="cfcdoc">
	<tbody>
	<cfif StructKeyExists(components[compnum].attributes,"extends")>
	<tr>
		<td>extends:</td>
		<td>#components[compnum].attributes.extends#<br></td>
	</tr>
	</cfif>
	<!--- <tr>
		<td>properties:</td>
		<td></td>
	</tr> --->
	<cfif ArrayLen(functions)>
	<tr>
		<td>methods:</td>
		<td>
			<cfloop index="funcnum" from="1" to="#ArrayLen(functions)#" step="1">
				<a href="##method_#functions[funcnum].attributes.name#">#functions[funcnum].attributes.name#</a><cfif funcnum lt ArrayLen(functions)>,</cfif>
			</cfloop>
		</td>
	</tr>
	</cfif>
	</tbody>
	</table>
	<br>
	<table class="cfcdoc">
	<tbody>
	<cfloop index="funcnum" from="1" to="#ArrayLen(functions)#" step="1">
		<cfset function = Duplicate(functions[funcnum])>
		<cfset arguments = functions[funcnum].arguments>
	<tr>
		<th colspan="1" align="left"> <a id="method_#function.attributes.name#" href="file-view.cfm?id=#URL.id###line-#function.line#" title="View the code for this method.">#function.attributes.name#</a> </th>
	</tr>
	<tr>
		<td>
			<code>
				<cfif StructKeyExists(function.attributes,"access")><i>#function.attributes.access#</i></cfif>
				<cfif StructKeyExists(function.attributes,"returntype")><i>#function.attributes.returntype#</i></cfif>
				<b>#function.attributes.name#</b> (
				<cfloop index="argnum" from="1" to="#ArrayLen(arguments)#" step="1">
					<cfif argnum gt 1>,</cfif>
					<cfset argument = Duplicate(arguments[argnum])>
					<i>
						<cfif StructKeyExists(argument.attributes,"required") AND isBoolean(argument.attributes.required) AND argument.attributes.required>required</cfif>
						<cfif StructKeyExists(argument.attributes,"type")>#argument.attributes.type#</cfif>
					</i>
					<cfif StructKeyExists(argument.attributes,"name")>#argument.attributes.name#<cfelse>!!MISSING NAME!!</cfif><cfif StructKeyExists(argument.attributes,"default")>="#argument.attributes.default#"</cfif>
				</cfloop>
				)
			</code>
			<br>
			<br>
			<cfif StructKeyExists(function.attributes,"hint") AND Len(Trim(function.attributes.hint))>
				#function.attributes.hint#<br>
			<br>
			</cfif>
			<cfif StructKeyExists(function.attributes,"output") AND isBoolean(function.attributes.output)>
			Output: <cfif function.attributes.output>enabled<cfelse>suppressed</cfif><br>
			<br>
			</cfif>
			<cfif ArrayLen(function.arguments)>
				Parameters:<br>
				<cfloop index="argnum" from="1" to="#ArrayLen(arguments)#" step="1">
					<cfset argument = arguments[argnum]>
					&nbsp;&nbsp; <b><cfif StructKeyExists(argument.attributes,"name")><strong>#argument.attributes.name#</strong><cfelse>!!MISSING NAME!!</cfif>:</b>
					<cfif StructKeyExists(argument.attributes,"type")>#argument.attributes.type#,</cfif>
					<cfif StructKeyExists(argument.attributes,"required") AND isBoolean(argument.attributes.required) AND argument.attributes.required>required,<cfelse>optional,</cfif>
					<cfif StructKeyExists(argument.attributes,"name")>#argument.attributes.name#<cfelse>!!MISSING NAME!!</cfif>
					<cfif StructKeyExists(argument.attributes,"hint")> - #argument.attributes.hint#</cfif>
					<br>
				</cfloop>
			</cfif>
			<br>
		</td>
	</tr>
	</cfloop>
	</tbody>
	</table>
</cfloop>
</cfoutput>

<cfoutput>#layout.end()#</cfoutput>