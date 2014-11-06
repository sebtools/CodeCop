<cfcomponent extends="base">

<cffunction name="checkRule" access="public" returntype="any" output="no">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="RuleID" type="numeric" required="yes">
	<cfargument name="FileInfo" type="struct" required="yes">
	
	<cfset var qRule = variables.Rules.getRule(arguments.RuleID)>
	<cfset var i = 0>
	<cfset var tag = "">
	
	<cfset var tagsRaw = 0>
	<cfset var tagsProcessed = 0>
	
	<!--- A tag could actually be a comma-delimeted list of tags --->
	<cfloop index="tag" list="#qRule.TagName#">
		<cfset tagsRaw = getTagsRaw(FileInfo.Contents,qRule.TagName)>
		<cfset tagsProcessed = getTagsData(FileInfo.Contents,tagsRaw)>
		<!--- Loop over found tags and save as issues --->
		<cfloop index="i" from="1" to="#ArrayLen(tagsProcessed)#" step="1">
			<cfset saveIssue(arguments.ReviewID,arguments.RuleID,FileInfo,tagsProcessed[i].pos,tagsProcessed[i].len,tagsProcessed[i])>
		</cfloop>
	
	</cfloop>
	
</cffunction>

<cffunction name="getTags" access="public" returntype="array">
	<cfargument name="string" type="string" required="yes">
	<cfargument name="TagName" type="string" required="yes">
	
	<cfset var tagsRaw = getTagsRaw(arguments.string,arguments.TagName)>
	<cfset var tagsProcessed = getTagsData(arguments.string,tagsRaw)>
	
	<cfreturn tagsProcessed>
</cffunction>

<cffunction name="getAttributes" access="private" returntype="any" output="no">
	<cfargument name="tag" type="struct" required="yes">
	
	<cfset var string = tag.string>
	<cfset var XmlData = 0>
	
	<cfif Len(tag.innerCFML) AND Len(tag.outerCFML) AND tag.innerCFML neq tag.outerCFML>
		<cfset string = ReplaceNoCase(tag.outerCFML,tag.innerCFML,"")>
	</cfif>
	<cfif NOT Len(tag.innerCFML) AND NOT Len(tag.outerCFML) AND NOT FindNoCase("</",string) AND NOT FindNoCase("/>",string)>
		<cfset string = ReplaceNoCase(string,">","/>")>
	</cfif>
	
	<cfif Len(Trim(string))>
		<cfset XmlData = XmlParser(string)>
	</cfif>
	
	<cfreturn XmlData[tag.tagName].XmlAttributes>
</cffunction>

<cffunction name="getTagsData" access="private" returntype="array" output="no">
	<cfargument name="string" type="string" required="yes">
	<cfargument name="foundtags" type="array" required="yes">
	
	<cfscript>
	var aResult = ArrayNew(1);
	var aRawTagsData = Duplicate(foundtags);
	var loopCount = ArrayLen(aRawTagsData);
	var i = 0;
	var j = 0;
	var thisTag = StructNew();
	var closingTag = StructNew();
	</cfscript>
	
	<cfloop condition="ArrayLen(aRawTagsData)">
		<!--- This is a destructive loop, so always get the first item. --->
		<cfset thisTag = Duplicate(aRawTagsData[1])>
		<cfscript>
		thisTag["innerCFML"] = "";
		thisTag["outerCFML"] = "";
		thisTag["attributes"] = StructNew();
		thisTag["contents"] = "";
		thisTag["line"] = getLineNum(string,thisTag.pos);
		</cfscript>
		<cfif thisTag["type"] eq "open">
			<cfset thisTag["attributes"] = getAttributes(thisTag)>
			<!--- Look for closing tag in remaining tags --->
			<cfloop index="j" from="2" to="#ArrayLen(aRawTagsData)#" step="1">
				<cfif aRawTagsData[j].type eq "close" AND aRawTagsData[j].level eq thisTag.level>
					<cfset thisTag["innerCFML"] = Mid(string,(thisTag.pos+thisTag.len),(aRawTagsData[j].pos-thisTag.pos-thisTag.len))>
					<cfset thisTag["outerCFML"] = Mid(string,(thisTag.pos),(aRawTagsData[j].pos+aRawTagsData[j].len-thisTag.pos))>
					<cfset thisTag["contents"] = thisTag["innerCFML"]>
					<cfset thisTag["type"] = "set">
					<!--- <cfset thisTag["attributes"] = getAttributes(thisTag)> --->
					<cfset ArrayDeleteAt(aRawTagsData,j)>
					<cfbreak>
				<!--- <cfelse>
					<cfset thisTag["attributes"] = getAttributes(thisTag)>
					<cfset ArrayDeleteAt(aRawTagsData,j)>
					<cfbreak> --->
				</cfif>
			</cfloop>
		</cfif>
		<cfset ArrayAppend(aResult,thisTag)>
		<cfset ArrayDeleteAt(aRawTagsData,1)>
	</cfloop>
	
	<cfreturn aResult>
</cffunction>

<cffunction name="getTagsRaw" access="private" returntype="array" output="no">
	<cfargument name="string" type="string" required="yes">
	<cfargument name="tagName" type="string" required="yes">
	
	<cfscript>
	var qt = chr(34);
	
	var regexBase = "(<[\d\w]* [\d\w]*=#qt#[^#qt#]*#qt# */?>)|(<([^>]*)>)";
	var regexStart = "(<#tagName# [\d\w]*=#qt#[^#qt#]*#qt# */?>)|(<#tagName# ([^>]*)>)";
	var regexEnd = "</#tagName#>";
	
	var result = StructNew();
	var openers = ArrayNew(1);
	var closers = ArrayNew(1);
	var alltags = ArrayNew(1);
	
	var i = 0;
	var posStartTag = 1;
	var posEndTag = 1;
	var pos = 1;
	var resultStartTag = 0;
	var resultEndTag = 0;
	var start = 1;
	var temp = StructNew();
	var level = 1;
	</cfscript>
	
	<!--- Find opening tags --->
	<cfloop condition="pos neq 0 AND i lte 1000">
		<cfset resultStartTag = REFindNoCase(regexStart, string, start, true)>
		<cfset resultEndTag = REFindNoCase(regexEnd, string, start, true)>
		<cfset posStartTag = resultStartTag.pos[1]>
		<cfset posEndTag = resultEndTag.pos[1]>
		
		<!--- Only take action if a start or end tag is found --->
		<cfif posStartTag OR posEndTag>
			<cfset temp = StructNew()>
			<cfset temp["tagName"] = tagName>
			<!--- If a start and end tag are found, use the first one --->
			<cfif posStartTag AND posEndTag>
				<cfif posStartTag gt posEndTag>
					<cfset result = resultEndTag>
					<cfset temp["type"] = "close">
				<cfelse>
					<cfset result = resultStartTag>
					<cfset temp["type"] = "open">
				</cfif>
			<!--- If only one is found, use the one that is found --->
			<cfelse>
				<cfif posStartTag>
					<cfset result = resultStartTag>
					<cfset temp["type"] = "open">
				<cfelse>
					<cfset result = resultEndTag>
					<cfset temp["type"] = "close">
				</cfif>
			</cfif>
			<cfset temp["pos"] = result.pos[1]>
			<cfset temp["len"] = result.len[1]>
			<cfset temp["string"] = Mid(string,result.pos[1],result.len[1])>
			<!--- If tag string ends with closing, indicate this tag as closed --->
			<cfset temp["closed"] = (Right(temp["string"],2) eq "/>")>
			
			<cfif temp["type"] eq "close">
				<cfset level = level - 1>
			</cfif>
			
			<cfset temp["level"] = level>
			
			<cfif temp["type"] eq "open">
				<cfset level = level + 1>
			</cfif>
			
			<cfset ArrayAppend(alltags,temp)>
			
			<cfif temp["type"] eq "open">
				<cfset ArrayAppend(openers,temp)>
			<cfelse>
				<cfset ArrayAppend(closers,temp)>
			</cfif>
			
			<cfset pos = temp["pos"]>
			<cfset start = pos + 1>
		<cfelse>
			<cfset pos = 0>
		</cfif>
		
		<cfset i = i + 1>
	</cfloop>
	<cfset result = StructNew()>
	<cfset result["alltags"] = alltags>
	
	<cfreturn alltags>
</cffunction>

<cffunction name="XmlParser" access="private" returntype="any" otuput="no">
	<cfargument name="string" type="string" value="string">
	
	<cfset var result = 0>
	
	<cfset arguments.string = ReplaceNoCase(arguments.string,"&amp;","&","ALL")>
	<cfset arguments.string = ReplaceNoCase(arguments.string,"&","&amp;","ALL")>
	
	<cftry>
		<cfset result = XmlParse(arguments.string)>
		<cfcatch>
			<cfset arguments.string = Xmlify(arguments.string)>
			<cftry>
				<cfset result = XmlParse(arguments.string)>
				<cfcatch>
					<cfthrow message="Unable to parse: [#HTMLEditFormat(arguments.string)#]" type="CodeCop" detail="#CFCATCH.Message#" errorcode="NoXmlParse">
				</cfcatch>
			</cftry>
		</cfcatch>
	</cftry>
	
	<cfreturn result>
</cffunction>

<cffunction name="Xmlify" access="private" returntype="string" output="no">
	<cfargument name="string" type="string" required="yes">
	
	<cfset var result = 0>
	<cfset var pos = 1>
	<cfset var start = 1>
	<cfset var i = 1>
	<cfset var substring = "">
	
	<cfset string = ReplaceNoCase(string," = ","=","ALL")>
	
	<!--- Quote any unquoted attributes --->
	<cfloop condition="pos neq 0 AND i lte 20">
		<cfset result = ReFindNoCase(" [\d\w]+=[\d\w]+",string,1,true)>
		<cfset pos = result.pos[1]>
		<cfif pos>
			<cfset substring = Mid(string,result.pos[1],result.len[1])>
			<cfset substring = " #XmlFormat(ListFirst(substring,"="))#=""#XmlFormat(ListLast(substring,"="))#""">
			<cfset string = Left(string,result.pos[1]-1) & substring & Right(string,Len(string)-result.pos[1]-result.len[1]+1)>
		</cfif>
		<cfset i = i + 1>
		<cfset start = pos + 1>
	</cfloop>
	
	<cfset pos = 1>
	<cfset start = 1>
	<cfset i = 1>
	<cfset substring = "">
	
	<!--- make att w/o value pair have value of att name --->
	<cfloop condition="pos neq 0 AND i lte 20">
		<cfset result = ReFindNoCase(" [\d\w]+ ",string,1,true)>
		<cfset pos = result.pos[1]>
		<cfif pos>
			<cfset substring = Mid(string,result.pos[1],result.len[1])>
			<cfset substring = " #Trim(substring)#=""#Trim(substring)#"" ">
			<cfset string = Left(string,result.pos[1]-1) & substring & Right(string,Len(string)-result.pos[1]-result.len[1]+1)>
		</cfif>
		<cfset i = i + 1>
		<cfset start = pos + 1>
	</cfloop>
	
	<!--- Close unclosed tag --->
	<cfif NOT FindNoCase("</",string) AND NOT FindNoCase("/>",string)>
		<cfset string = ReplaceNoCase(string,">"," />")>
	</cfif>
	
	<!--- Put space before tag closer --->
	<cfif FindNoCase("/>",string) AND NOT FindNoCase(" />",string)>
		<cfset string = ReplaceNoCase(string,"/>"," />")>
	</cfif>
	
	<cfset string = fixQuotes(string)>
	
	<cfreturn string>
</cffunction>

<cffunction name="fixQuotes" access="private" returntype="string" output="no">
	<cfargument name="string" type="string" required="yes">
	
	<cfset var result = "">
	<cfset var substring = "">
	<cfset var quotedatt = "">
	<cfset var att = "">
	
	<cfloop index="substring" list="#string#" delimiters=" ">
		<cfif FindNoCase("=",substring)>
			<cfset quotedatt = ListRest(substring, "=")>
			<cfif Left(quotedatt,1) eq chr(34) AND Right(quotedatt,1) eq chr(34)>
				<cfset att = Mid(quotedatt,2,Len(quotedatt)-2)>
			<cfelse>
				<cfset att = quotedatt>
			</cfif>
			<cfset att = ReplaceNoCase(att, chr(34), "'", "ALL")>
			<cfset result = ListAppend(result,"#ListFirst(substring,'=')#=#chr(34)##att##chr(34)#"," ")>
		<cfelse>
			<cfset result = ListAppend(result,substring," ")>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

</cfcomponent>
