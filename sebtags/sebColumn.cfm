<cfsilent>
<!---
Version 0.9.4 Build 90
Last Updated 2006-08-08
--->
<cfset TagName = "cf_sebColumn">
<cfset ParentTag = "cf_sebTable">
<cfif Not ListFindNoCase(GetBaseTagList(), ParentTag)>
	<cfthrow message="This tag must be called between &lt;#ParentTag#&gt; and &lt;/#ParentTag#&gt;" type="cftag">
</cfif>
<cfif isDefined("ThisTag.ExecutionMode") AND ThisTag.ExecutionMode eq "Start">
	<cfassociate basetag="#ParentTag#" datacollection="qColumns">
	<cfset ParentAtts = request.cftags[ParentTag].attributes>
	<cfset sfx = ParentAtts.suffix>
	<cfset ColumnTypes = "text,numeric,date,yesno,icon,checkbox,radio,input,select,sorter,delete,submit,link,money,html">
	<cfset dbcolumns = "text,date,yesno,icon,money">
	<cfparam name="attributes.name" default="">
	<cfparam name="attributes.DataType" default="text"><!--- text,date,yesno,icon,checkbox,input,select,delete --->
	<cfparam name="attributes.type" default="#attributes.DataType#">
	<cfparam name="attributes.link" default="">
	<cfif ListFindNoCase(dbcolumns,attributes.type) AND NOT Len(attributes.link)>
		<cfparam name="attributes.dbfield">
	<cfelse>
		<cfparam name="attributes.dbfield" default="">
	</cfif>
	<cfparam name="attributes.sortfield" default="#attributes.dbfield#">
	<cfparam name="attributes.label" default="#attributes.dbfield#">
	<cfparam name="attributes.width" default="">
	<cfparam name="attributes.reltable" default="">
	<cfparam name="attributes.relfield" default="">
	<cfparam name="attributes.style" default="">
	<cfparam name="attributes.iconif" default="">
	<cfparam name="attributes.show" default="true">
	<cfparam name="attributes.noshowalt" default="&nbsp;">
	<cfparam name="attributes.size" default="0" type="numeric">
	<cfparam name="attributes.defaultSort" default="">
	<cfif Len(attributes.sortfield) AND ( attributes.defaultSort eq "ASC" OR attributes.defaultSort eq "DESC" ) AND NOT Len(ParentAtts.orderby) >
		<cfset ParentAtts.orderby = "#attributes.sortfield# #attributes.defaultSort#">
	</cfif>
	<cfswitch expression="#attributes.DataType#">
		<cfcase value="date"><cfparam name="attributes.mask" default="m/dd/yyyy"></cfcase>
		<cfdefaultcase><cfparam name="attributes.mask" default=""></cfdefaultcase>
	</cfswitch>
	<cfparam name="attributes.rolodex" default="false" type="boolean">
	
	<!--- For type="select" --->
	<cfparam name="attributes.subquery" default="">
	<cfparam name="attributes.subtable" default="">
	<cfparam name="attributes.subvalues" default="">
	<cfparam name="attributes.subdisplays" default="#attributes.subvalues#">
	<cfparam name="attributes.isInput" default="false" type="boolean">
	<cfparam name="attributes.requiresSubmit" default="false" type="boolean">
	
	<cfparam name="attributes.header_img" default="">
	<cfparam name="attributes.header_img_height" default="0" type="numeric">
	<cfparam name="attributes.header_img_width" default="0" type="numeric">
	
	<cfif Len(attributes.header_img) AND NOT (attributes.header_img_height AND attributes.header_img_width)>
		<cfthrow message="header_img_height and header_img_width must be provided with header_img.">
	</cfif>
	<cfif Len(attributes.header_img)>
		<cfsavecontent variable="attributes.header"><cfoutput><img src="#attributes.header_img#" width="#attributes.header_img_width#" height="#attributes.header_img_height#" alt="#attributes.label#"/></cfoutput></cfsavecontent>
	<cfelse>
		<cfset attributes.header = attributes.label>
	</cfif>
	
	<cfif attributes.defaultSort eq "ASC" OR attributes.defaultSort eq "DESC">
		<cfset sfx = ParentAtts.suffix>
		<cfif NOT ( isDefined("url.sebsort#sfx#") AND Len(url["sebsort#sfx#"]) AND isDefined("url.sebsortorder#sfx#") AND Len(url["sebsortorder#sfx#"]) )>
			<cfset url["sebsort#sfx#"] = attributes.Label>
			<cfset url["sebsortorder#sfx#"] = attributes.defaultSort>
		</cfif>
	</cfif>

	<cfif Len(attributes.dbfield) AND NOT Len(attributes.name)>
		<cfset attributes.name = attributes.dbfield>
	</cfif>
	
	<cfif attributes.type eq "select">
		<cfset attributes.qOptions = QueryNew("value,display")>
		<cfif Len(attributes.subquery)>
			<cfif StructKeyExists(Caller,attributes.subquery) AND isQuery(Caller[attributes.subquery])>
				<cfoutput query="Caller.#attributes.subquery#">
					<cfset QueryAddRow(attributes.qOptions)>
					<cfset QuerySetCell(attributes.qOptions, "value", Caller[attributes.subquery][attributes.subvalues][CurrentRow])>
					<cfset QuerySetCell(attributes.qOptions, "display", Caller[attributes.subquery][attributes.subdisplays][CurrentRow])>
				</cfoutput>
			<cfelse>
				<cfthrow message="query #attributes.subquery# doesn't exist on the calling page.">
			</cfif>
		<cfelseif Len(attributes.subtable)>
			<cfif StructKeyExists(ParentAtts,"datasource")>
				<cfquery name="attributes.qOptions" datasource="#ParentAtts.datasource#">
				SELECT		#attributes.subvalues# AS value, #attributes.subdisplays# AS display
				FROM		#attributes.subtable#
				ORDER BY	#attributes.subdisplays#
				</cfquery>
			<cfelse>
				<cfthrow message="subtable attribute of #TagName# can only be used if datasource attribute of #ParentTag# is set.">
			</cfif>
		<cfelse>
			<cfloop index="i" from="1" to="#ListLen(attributes.subvalues)#" step="1">
				<cfset value = ListGetAt(attributes.subvalues,i)>
				<cfif ListLen(attributes.subdisplays) gte i>
					<cfset display = ListGetAt(attributes.subdisplays,i)>
				<cfelse>
					<cfset display = value>
				</cfif>
				<cfset QueryAddRow(attributes.qOptions)>
				<cfset QuerySetCell(attributes.qOptions, "value", value)>
				<cfset QuerySetCell(attributes.qOptions, "display", display)>
			</cfloop>
		</cfif>
	</cfif>
	<cfscript>
	function display_default(value,rownum,pkid,atts) {
		return value;
	}
	</cfscript>
	
	<cfswitch expression="#attributes.type#">
		<cfcase value="date">
			<cfscript>
			function display_date(value,rownum,pkid,atts) {
				var result = value;
				if ( isDate(result) OR isNumericDate(result) ) {
					result = DateFormat(result,atts.mask);
				}
				return result;
			}
			</cfscript>
		</cfcase>
		<cfcase value="money">
			<cfscript>
			function display_money(value,rownum,pkid,atts) {
				return '<div style="float:right;">#DollarFormat(value)#</div>';
			}
			</cfscript>
		</cfcase>
		<cfcase value="numeric">
			<cfscript>
			function display_numeric(value,rownum,pkid,atts) {
				return '<div style="float:right;">#value#</div>';
			}
			</cfscript>
		</cfcase>
		<cfcase value="yesno">
			<cfscript>
			function display_yesno(value,rownum,pkid,atts) {
				var result = value;
				if ( isBoolean(result) ) {
					result = YesNoFormat(result);
				}
				return result;
			}
			</cfscript>
		</cfcase>
		<cfcase value="checkbox">
			<cfset attributes.isInput = true>
			<cfset attributes.requiresSubmit = true>
			<cfscript>
			function display_checkbox(value,rownum,pkid,atts) {
				var result = value;
				var checked = false;
				if ( Len(atts.name) ) {
					if ( isBoolean(value) AND value ) {
						checked = true;
					}
					result = '<input type="checkbox" name="#atts.name#" id="#atts.name##rownum#" value="#pkid#"';
					if ( checked ) {
						result = result & ' checked="checked"';
					}
					result = result & '/>';
				}
				return result;
			}
			</cfscript>
		</cfcase>
		<cfcase value="radio">
			<cfset attributes.isInput = true>
			<cfset attributes.requiresSubmit = true>
			<cfscript>
			function display_radio(value,rownum,pkid,atts) {
				var result = value;
				var checked = false;
				if ( Len(atts.name) ) {
					if ( isBoolean(value) AND value ) {
						checked = true;
					}
					result = '<input type="radio" name="#atts.name#" id="#atts.name##rownum#" value="#pkid#"';
					if ( checked ) {
						result = result & ' checked="checked"';
					}
					result = result & '/>';
				}
				return result;
			}
			</cfscript>
		</cfcase>
		<cfcase value="input">
			<cfset attributes.isInput = true>
			<cfset attributes.requiresSubmit = true>
			<cffunction name="display_input">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = value>
				<cfset var inputval = value>
				
				<cfif isDate(inputval)>
					<cfif StructKeyExists(atts,"mask")>
						<cfset inputval = DateFormat(inputval,atts.mask)>
					<cfelse>
						<cfset inputval = DateFormat(inputval,"mm/dd/yyyy")>
					</cfif>
				</cfif>
				
				<cfif Len(atts.name)>
					<cfsavecontent variable="result"><cfoutput><input type="text" name="#atts.name#_#rownum#" id="#atts.name##rownum#" value="#inputval#"<cfif atts.size> size="#atts.size#"</cfif>/></cfoutput></cfsavecontent>
				</cfif>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="select">
			<cfset attributes.isInput = true>
			<cfset attributes.requiresSubmit = true>
			<cffunction name="display_select">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = value>
				<cfset var thisQuery = atts.qOptions>
				
				<cfif Len(atts.name)>
					<cfsavecontent variable="result"><cfoutput><select name="#atts.name#_#rownum#" id="#atts.name##rownum#"><option value=""></option><cfloop query="thisQuery"><option value="#thisQuery.value[CurrentRow]#"<cfif thisQuery.value[CurrentRow] eq result> selected<cfif attributes.xhtml>="selected"</cfif></cfif>>#display#</option></cfloop></select></cfoutput></cfsavecontent>
				</cfif>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="icon">
			<cffunction name="display_icon">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = "&nbsp;">
				<cfset var icif = "">
				
				<cfloop index="icif" list="#atts.iconif#" delimiters=";">
					<cfif ListLen(icif,":") eq 2 AND (ListGetAt(icif, 1, ":") eq thisValue)>
						<cfset result = '<img src="#ListGetAt(icif, 2,":")#" height="16" width="16" alt="#value#"/>'>
					<cfelse>
						<cfset result = "&nbsp;"> 
					</cfif>
				</cfloop>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="sorter">
			<cfset attributes.isInput = true>
			<cfset attributes.requiresSubmit = false>
			<cfset url["sebSort#sfx#"] = attributes.label>
			<cfset url["sebsortorder#sfx#"] = "ASC">
			<cfif request["sebTableHasSorter#sfx#"]>
				<cfthrow message="You can only have one sorter column per table.">
			</cfif>
			<cfset request["sebTableHasSorter#sfx#"] = true>
			<cffunction name="display_sorter">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = value>
				
				<!--- Make sure that value is a positive integer --->
				<cfif isNumeric(value) AND (Value eq Int(value))><!---  AND (value gt 0) --->
					<cfsavecontent variable="result"><cfoutput><div style="width:48px;"><cfif rownum eq 1><input type="button" name="sort_#rownum#" value="" style="width:24px;height:20px;"/><cfelse><input type="submit" name="sort_#rownum#" value="+" style="width:24px;height:20px;"/></cfif><cfif StructKeyExists(atts,"isLastRow")><input type="button" name="sort_#rownum#" value=" " style="width:24px;height:20px;"/><cfelse><input type="submit" name="sort_#rownum#" value="-" style="width:24px;height:20px;"/></cfif><!---  (#value#) ---></div></cfoutput></cfsavecontent>
				</cfif>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="delete">
			<cfset attributes.header = "">
			<cfset attributes.isInput = true>
			<cffunction name="display_delete">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = "">
				<cfset var Label = "delete">
				
				<cfif StructKeyExists(atts,"label") AND Len(atts.label)>
					<cfset Label = atts.label>
				</cfif>
				
				<cfif NOT ( ListFindNoCase(qTableData.ColumnList,"isDeletable") AND isBoolean(qTableData.isDeletable[rownum]) AND NOT qTableData.isDeletable[rownum] )>
					<cfsavecontent variable="result"><cfoutput><input type="submit" name="delete_#rownum#" value="#Label#" class="delete" style="height:20px;" onclick="return confirm('Are you sure you want to delete this item?')"/></cfoutput></cfsavecontent>
				</cfif>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="submit">
			<cfset attributes.header = "">
			<cfset attributes.isInput = true>
			<cffunction name="display_submit">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = "">
				
				<cfif NOT (StructKeyExists(atts,"label") AND Len(atts.label))>
					<cfset atts.label = "Submit">
				</cfif>
				
				<cfsavecontent variable="result"><cfoutput><input type="submit" name="submit_#rownum#" value="#atts.label#" class="submit" style="height:20px;"<cfif StructKeyExists(atts,"confirm") AND Len(atts.confirm)> onclick="return confirm('#JSStringFormat(atts.confirm)#')"</cfif>/></cfoutput></cfsavecontent>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="link">
			<cfset attributes.isInput = false>
			<cffunction name="display_link">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = "">
				<cfset var link = atts.link>
				<cfset var col = "">
				
				<cfif rownum>
					<cfloop index="col" list="#qTableData.ColumnList#">
						<cfif FindNoCase("[#col#]", link)>
							<cfset link = ReplaceNoCase(link, "[#col#]", qTableData[col][rownum], "ALL")>
						</cfif>
					</cfloop>
				</cfif>
				
				<cfsavecontent variable="result"><cfoutput><a href="#link#"<cfif StructKeyExists(atts,"title")> title="#atts.title#"</cfif>>#value#</a></cfoutput></cfsavecontent>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="text">
			<cfset attributes.isInput = false>
			<cffunction name="display_text">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = arguments.value>
				
				<cfif attributes.xhtml>
					<cfset result = XmlFormat(arguments.value)>
				<cfelse>
					<cfset result = HTMLEditFormat(arguments.value)>
				</cfif>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
		<cfcase value="html">
			<cfset attributes.isInput = false>
			<cffunction name="display_html">
				<cfargument name="value" type="string" required="yes">
				<cfargument name="rownum" type="numeric" required="yes">
				<cfargument name="pkid" type="string" required="yes">
				<cfargument name="atts" type="struct" required="yes">
				
				<cfset var result = arguments.value>
				
				<cfreturn result>
			</cffunction>
		</cfcase>
	</cfswitch>
	<cfif NOT ListFindNoCase(ColumnTypes,attributes.type)>
		<cfinclude template="sebColumn_#attributes.type#.cfm">
	</cfif>
	<cfif StructKeyExists(variables,"display_#attributes.type#")>
		<cfset attributes.display = variables["display_#attributes.type#"]>
	<cfelse>
		<cfset attributes.display = variables["display_default"]>
	</cfif>
	
	<!--- <cfif (attributes.type neq "icon") AND NOT Len(thisName)><cfset thisName = thisValue><cfif ParentAtts.xhtml><cfset thisName = XmlFormat(thisName)></cfif></cfif> --->
	<!--- <td<cfif ParentAtts.isRowClickable AND Not Len(attributes.link)> onclick="sebEditIt('#pkid#');"</cfif>><cfif Len(attributes.link)><a href="#attributes.link##pkid#">#thisDisplay#</a>&nbsp;<cfelse>#thisDisplay#</cfif></td> --->
	<cfif Len(attributes.link) AND NOT (Len(attributes.label) AND Len(attributes.dbfield))>
		<cfset attributes.header = "">
	</cfif>
	
</cfif>
</cfsilent>
