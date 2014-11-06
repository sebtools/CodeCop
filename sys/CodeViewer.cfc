<cfcomponent displayname="Code Viewer">

<cffunction name="init" access="public" returntype="any" output="no" hint="I initialize and return this function.">
	<cfargument name="Files" type="any" required="yes">
	
	<cfset variables.Files = arguments.Files>
	
	<cfreturn this>
</cffunction>

<cffunction name="getFormattedFileCode" access="public" returntype="string" output="no" hint="I return the formatted code from the given file.">
	<cfargument name="FileID" type="numeric" required="yes">
	<cfargument name="IssueID" type="numeric" required="no">
	<cfargument name="RuleID" type="numeric" required="no">
	
	<cfset var qFile = variables.Files.getFile(arguments.FileID)>
	<cfset var FormattedContents = qFile.FileContents><!--- Start with the contents of the file --->
	
	<!--- Highlight issues --->
	<cfinvoke returnvariable="FormattedContents" method="highlightIssues">
		<cfinvokeargument name="FileID" value="#arguments.FileID#">
		<cfinvokeargument name="Contents" value="#FormattedContents#">
		<cfif StructKeyExists(arguments,"IssueID")>
			<cfinvokeargument name="IssueID" value="#arguments.IssueID#">
		</cfif>
		<cfif StructKeyExists(arguments,"RuleID")>
			<cfinvokeargument name="RuleID" value="#arguments.RuleID#">
		</cfif>
	</cfinvoke>
	
	<!--- Color the code (thanks Ray!) --->
	<cfset FormattedContents = colorCode(FormattedContents)>
	
	<!--- Convert the code to the appropriate HTML --->
	<cfset FormattedContents = reformatCode(FormattedContents)>
	
	<!--- Add line numbers --->
	<cfset FormattedContents = numberLines(FormattedContents)>
	
	<cfreturn FormattedContents>
</cffunction>

<!--- 
Copyright for coloredCode function. Also note that Jeff Coughlin made some mods to this as well.
=============================================================
	Utility:	ColdFusion ColoredCode v3.2
	Author:		Dain Anderson
	Email:		webmaster@cfcomet.com
	Revised:	June 7, 2001
	Download:	http://www.cfcomet.com/cfcomet/utilities/
============================================================= 
---><!--- I renamed the function basically because I can't help myself. It was so close to verbNoun format that I had to get it into that format. --->
<cffunction name="colorCode" access="private" returntype="string" output="false" hint="Colors code">
	<cfargument name="dataString" type="string" required="true">
	<!--- <cfargument name="class" type="string" required="true"> --->

	<cfset var data = trim(arguments.dataString) />
	<cfset var eof = 0>
	<cfset var bof = 1>
	<cfset var match = "">
	<cfset var orig = "">
	<cfset var chunk = "">

	<cfscript>
	/* Convert special characters so they do not get interpreted literally; italicize and boldface */
	data = REReplaceNoCase(data, '&([[:alpha:]]{2,});', '«strong»«em»&amp;\1;«/em»«/strong»', 'ALL');

	/* Convert many standalone (not within quotes) numbers to blue, ie. myValue = 0 */
	data = REReplaceNoCase(data, "(gt|lt|eq|is|,|\(|\))([[:space:]]?[0-9]{1,})", "\1«span style='color: ##0000ff'»\2«/span»", "ALL");

	/* Convert normal tags to navy blue */
	data = REReplaceNoCase(data, "<(/?)((!d|b|c(e|i|od|om)|d|e|f(r|o)|h|i|k|l|m|n|o|p|q|r|s|t(e|i|t)|u|v|w|x)[^>]*)>", "«span style='color: ##000080'»<\1\2>«/span»", "ALL");

	/* Convert all table-related tags to teal */
	data = REReplaceNoCase(data, "<(/?)(t(a|r|d|b|f|h)([^>]*)|c(ap|ol)([^>]*))>", "«span style='color: ##008080'»<\1\2>«/span»", "ALL");

	/* Convert all form-related tags to orange */
	data = REReplaceNoCase(data, "<(/?)((bu|f(i|or)|i(n|s)|l(a|e)|se|op|te)([^>]*))>", "«span style='color: ##ff8000'»<\1\2>«/span»", "ALL");

	/* Convert all tags starting with 'a' to green, since the others aren't used much and we get a speed gain */
	data = REReplaceNoCase(data, "<(/?)(a[^>]*)>", "«span style='color: ##008000'»<\1\2>«/span»", "ALL");

	/* Convert all image and style tags to purple */
	data = REReplaceNoCase(data, "<(/?)((im[^>]*)|(sty[^>]*))>", "«span style='color: ##800080'»<\1\2>«/span»", "ALL");

	/* Convert all ColdFusion, SCRIPT and WDDX tags to maroon */
	data = REReplaceNoCase(data, "<(/?)((cf[^>]*)|(sc[^>]*)|(wddx[^>]*))>", "«span style='color: ##800000'»<\1\2>«/span»", "ALL");

	/* Convert all inline "//" comments to gray (revised) */
	data = REReplaceNoCase(data, "([^:/]\/{2,2})([^[:cntrl:]]+)($|[[:cntrl:]])", "«span style='color: ##808080'»«em»\1\2«/em»«/span»", "ALL");

	/* Convert all multi-line script comments to gray */
	data = REReplaceNoCase(data, "(\/\*[^\*]*\*\/)", "«span style='color: ##808080'»«em»\1«/em»«/span»", "ALL");

	/* Convert all HTML and ColdFusion comments to gray */	
	/* The next 10 lines of code can be replaced with the commented-out line following them, if you do care whether HTML and CFML 
	   comments contain colored markup. */

	while(NOT EOF) {
		Match = REFindNoCase("<!--" & "-?([^-]*)-?-->", data, BOF, True);
		if (Match.pos[1]) {
			Orig = Mid(data, Match.pos[1], Match.len[1]);
			Chunk = REReplaceNoCase(Orig, "«(/?[^»]*)»", "", "ALL");
			BOF = ((Match.pos[1] + Len(Chunk)) + 38); // 38 is the length of the SPAN tags in the next line
			data = Replace(data, Orig, "«span style='color: ##808080'»«em»#Chunk#«/em»«/span»");
		} else EOF = 1;
	}


	/* Convert all quoted values to blue */
	data = REReplaceNoCase(data, """([^""]*)""", "«span style='color: ##0000ff'»""\1""«/span»", "all");

	/* Convert left containers to their ASCII equivalent */
	//data = REReplaceNoCase(data, "<", "&lt;", "ALL");

	/* Convert right containers to their ASCII equivalent */
	//data = REReplaceNoCase(data, ">", "&gt;", "ALL");

	/* Revert all pseudo-containers back to their real values to be interpreted literally (revised) */
	//data = REReplaceNoCase(data, "«([^»]*)»", "<\1>", "ALL");

	/* ***New Feature*** Convert all FILE and UNC paths to active links (i.e, file:///, \\server\, c:\myfile.cfm) */
	data = REReplaceNoCase(data, "(((file:///)|([a-z]:\\)|(\\\\[[:alpha:]]))+(\.?[[:alnum:]\/=^@*|:~`+$%?_##& -])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");

	/* Convert all URLs to active links (revised) */
	data = REReplaceNoCase(data, "([[:alnum:]]*://[[:alnum:]\@-]*(\.[[:alnum:]][[:alnum:]-]*[[:alnum:]]\.)?[[:alnum:]]{2,}(\.?[[:alnum:]\/=^@*|:~`+$%?_##&-])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");

	/* Convert all email addresses to active mailto's (revised) */
	data = REReplaceNoCase(data, "(([[:alnum:]][[:alnum:]_.-]*)?[[:alnum:]]@[[:alnum:]][[:alnum:].-]*\.[[:alpha:]]{2,})", "<a href=""mailto:\1"">\1</a>", "ALL");
	</cfscript>

	<!--- mod by ray --->
	<!--- change line breaks at end to <br /> --->
	<!--- <cfset data = replace(data,chr(13),"<br />","all") /> --->
	<!--- replace tab with 3 spaces --->
	<!--- <cfset data = replace(data,chr(9),"&nbsp;&nbsp;&nbsp;","all") /> --->
	<!--- <cfset data = "<div class=""#arguments.class#"">" & data &  "</div>" /> --->
	
	<cfreturn data>
</cffunction>

<cffunction name="highlightIssues" access="private" returntype="string" output="no" hint="I highlight the issues in the given file.">
	<cfargument name="FileID" type="numeric" required="yes">
	<cfargument name="Contents" type="string" required="yes">
	<cfargument name="IssueID" type="numeric" required="no">
	<cfargument name="RuleID" type="numeric" required="no">
	
	<cfset var FormattedContents = arguments.Contents>
	<cfset var qIssues = variables.Files.getFileIssues(arguments.FileID,"parsecode")>
	<cfset var issue = StructNew()>
	<cfset var start = 1>
	<cfset var aContents = ArrayNew(1)>
	<cfset var i = 0>
	<cfset var temp = "">
	
	<cfset var result = "">
	
	<!--- Load up array with code and issues --->
	
	<cfloop query="qIssues">
		<!--- Store data about this issue --->
		<cfset issue = StructNew()>
		<cfset issue.IssueID = qIssues.IssueID[CurrentRow]>
		<cfset issue.RuleID = qIssues.RuleID[CurrentRow]>
		<cfset issue.RuleName = RuleName>
		<cfset issue.string = string>
		<cfif (pos-start) gt 1>
			<!--- Add the code (a string) the comes before the issues --->
			<cfset ArrayAppend(aContents,Mid(FormattedContents, start, pos-start))>
			<!--- Add the issue (a structure) --->
			<cfset ArrayAppend(aContents,issue)>
			<!--- Change the start position to start after current content --->
			<cfset start = pos + len>
		<cfelse>
			<cfbreak>
		</cfif>
	</cfloop>
	<!--- Add the remaining code (again, a string) --->
	<cfif Len(FormattedContents) gt start>
		<cfset ArrayAppend(aContents,Right(FormattedContents, Len(FormattedContents)-start+1))>
	</cfif>
	
	<!--- Highlight issues --->
	
	<!--- Loop through the array and build the contents --->
	<cfloop index="i" from="1" to="#ArrayLen(aContents)#" step="1">
		<cfif isSimpleValue(aContents[i])>
			<!--- If this array item is a string, it isn't an issue so just add it to the contents as-is --->
			<cfset result = result & aContents[i]>
		<cfelse>
			<!--- If this array item is a structure, it is an issue --->
			<cfinvoke method="highlight" returnvariable="temp">
				<cfinvokeargument name="issue" value="#Duplicate(aContents[i])#">
				<cfif StructKeyExists(arguments,"IssueID")>
					<cfinvokeargument name="IssueID" value="#arguments.IssueID#">
				</cfif>
				<cfif StructKeyExists(arguments,"RuleID")>
					<cfinvokeargument name="RuleID" value="#arguments.RuleID#">
				</cfif>
			</cfinvoke>
			<cfset result = result & temp>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="numberLines" access="private" returntype="string" output="no" hint="I number the lines of the given code.">
	<cfargument name="Contents" type="string" required="yes">

<cfset var cr = "
">
	<cfset var linedelim = CreateObject("java", "java.lang.System").getProperty("line.separator")>
	<!--- Pull contents into an array by line --->
	<cfset var aLines = arguments.Contents.split(linedelim)><!--- Creates an entry even for empty items --->
	<cfset var i = 0>
	<cfset var result = "">
	
	<!--- %%HACK: Using linedelim may not work right, so try manual carraige return --->
	<cfif ArrayLen(aLines) eq 1>
		<cfset aLines = arguments.Contents.split(cr)>
	</cfif>
	
	<!--- Loop through each line and add a line number --->
	<cfloop index="i" from="1" to="#ArrayLen(aLines)#" step="1">
		<cfset result = result & "#lineNum(i,ArrayLen(aLines))##aLines[i]#" & linedelim>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="reformatCode" access="private" returntype="string" output="no" hint="I turn the specially formatted code into the correctly formatted html.">
	<cfargument name="code" type="string" required="yes">
	
	<cfset var result = arguments.code>
	
	<cfset result = HTMLEditFormat(result)>
	<cfset result = ReplaceNoCase(result, "«", "<", "ALL")>
	<cfset result = ReplaceNoCase(result, "»", ">", "ALL")>
	<cfset result = ReplaceNoCase(result, chr(147), chr(34), "ALL")>
	
	<cfreturn result>
</cffunction>

<cffunction name="highlight" access="private" returntype="string" output="no" hint="I highlight an issue.">
	<cfargument name="issue" type="struct" required="yes">
	<cfargument name="IssueID" type="numeric" required="no">
	<cfargument name="RuleID" type="numeric" required="no">
	
	<cfset var className = "highlighted">
	<cfset var qout = chr(147)>
	
	<cfif StructKeyExists(arguments,"IssueID") AND arguments.IssueID gt 0 AND issue.IssueID eq arguments.IssueID>
		<cfset className = "urgent">
	<cfelseif StructKeyExists(arguments,"RuleID") AND arguments.RuleID gt 0 AND issue.RuleID eq arguments.RuleID>
		<cfset className = "urgent">
	</cfif>
	
	<cfreturn "«a href=#qout#rule-view.cfm?issue=#issue.IssueID##qout# id=#qout#issue-#issue.IssueID##qout# class=#qout##className##qout# title=#qout##issue.RuleName##qout#»#issue.string#«/a»">
</cffunction>

<cffunction name="lineNum" access="private" returntype="string" output="no" hint="I add space before a line numer to keep the line number right-aligned relative to each other.">
	<cfargument name="num" type="numeric" required="yes">
	<cfargument name="max" type="numeric" required="yes">
	
	<cfset var result = padd(num,max)>
	
	<cfset result = "<span id=""line-#num#"" class=""line-num"">#result#: </span>"><!---  style=""color:black;"" --->
	
	<cfreturn result>
</cffunction>

<cffunction name="padd" access="private" returntype="string" output="no" hint="I add space before a line numer to keep the line number right-aligned relative to each other.">
	<cfargument name="num" type="numeric" required="yes">
	<cfargument name="max" type="numeric" required="yes">
	
	<cfloop condition="#Len(num)# lt #Len(max)#">
		<cfset num = " #num#">
	</cfloop>
	
	<cfreturn num>
</cffunction>

</cfcomponent>