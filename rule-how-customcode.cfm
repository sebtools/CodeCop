
<!--- Start Output --->
<cfoutput>#layout.head(request.ProductName)#</cfoutput>
	<script language="JavaScript" src="rule-how-customcode.js" type="text/javascript"></script>
<cfoutput>#layout.body()#</cfoutput>

<cfoutput><h1>Writing Custom Code</h1></cfoutput>

<div id="customcode-instructions">
	<p>In order to write custom code for a rule, you need to know what data you have available to you and what you need to return.</p>
	
	<p>The variables you have available to you:</p>
	<ul>
		<li><strong>Folder</strong> (string): The folder entered into the field of the same name by the user.</li>
		<li><strong>FileName</strong> (string): The file being examined. This value will be in the format of CGI.SCRIPT_NAME, treating the Folder as the site root.</li>
		<li><strong>string</strong> (string): This is the string found by the regular expression entered into this rule.</li>
		<li>
			<strong>info</strong> (struct): A structure of information about a tag returned for rule type of "Tag".
			<ul>
				<li>innerCFML (string): The code between the opening and closing tags (empty if the tag doesn't have both opening and closing tags)</li>
				<li>outerCFML (string): The opening and closing tags and everything in between.</li>
				<li>attributes (struct): The attributes of the tag.</li>
				<li>type (string): "open","close" or "set" for opening tag, closing tag only, and tag set respectively. If a tag set is found, it will not be separetely reported for the opening and closing tags.</li>
				<li>closed (boolean): Indicates whether a tag is self-closing.</li>
			</ul>
		</li>
	</ul>
	
	<p>
		The custom code should return a variable called "<strong>result</strong>" as a boolean value.
		If true, it will indicate that the string given does represent a valid issue.
		If it is false, this potential issue will be ignored.
	</p>
	
	<p>This code will be executed in a function, so feel free to declare variables using the "var" keyword.</p>
	
	<p>Given that, you can write any ColdFusion code you want to test out whether the potential issue is legitimate or not.</p>
</div>

<cfoutput>#layout.end()#</cfoutput>