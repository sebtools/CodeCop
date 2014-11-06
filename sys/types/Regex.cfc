<cfcomponent extends="base">

<cffunction name="checkRule" access="public" returntype="any" output="no">
	<cfargument name="ReviewID" type="numeric" required="yes">
	<cfargument name="RuleID" type="numeric" required="yes">
	<cfargument name="FileInfo" type="struct" required="yes">
	
	<cfset var qRule = variables.Rules.getRule(arguments.RuleID)>
	<cfset var pos = 1>
	<cfset var i = 1>
	<cfset var start = 1>
	<cfset var result = 0>
	
	<cfif Len(qRule.Regex)>
		<!--- Keep looking for this rule until you can find it no more (or until you find it 20 times, because that is plenty for one rule. --->
		<cfloop condition="pos neq 0 AND i lte 20">
			<!--- Search for the rule by regex --->
			<cfset result = REFindNoCase(qRule.Regex, FileInfo.Contents, start, true)>
			<cfset pos = result.pos[1]>
			<!--- If a string is found matching the regex, go to work on the issue --->
			<cfif ArrayLen(result.pos) AND result.pos[1] gt 0>
				<cfset saveIssue(arguments.ReviewID,arguments.RuleID,FileInfo,result.pos[1],result.len[1])>
			</cfif>
			<cfset i = i + 1>
			<cfset start = pos + 1>
		</cfloop>
	</cfif>
	
</cffunction>

</cfcomponent>
