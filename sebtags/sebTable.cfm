<cfsilent>
<!---
Version 0.9.8 Build 94
Last Updated 2006-09-26
--->
<cfset TagName = "cf_sebTable">
<cfif ThisTag.ExecutionMode eq "Start">
	<cfscript>
	if ( StructKeyExists(request, "cftags") AND StructKeyExists(request.cftags, "sebtags") ) {
		StructAppend(attributes, request.cftags["sebtags"], "no");
	}
	if ( StructKeyExists(request, "cftags") AND StructKeyExists(request.cftags, TagName) ) {
		StructAppend(attributes, request.cftags[TagName], "no");
	}
	if ( StructKeyExists(request,"sebTableNum") ) {
		request.sebTableNum = request.sebTableNum + 1;
		attributes.suffix = request.sebTableNum;
	} else {
		request.sebTableNum = 1;
		attributes.suffix = "";
	}
	sfx = attributes.suffix;
	
	liHtmlAtts = "id,class,title,style,dir,lang,xml:lang,onclick,ondblclick,onmousedown,onmouseup,onmouseover,onmousemove,onmouseout,onkeypress,onkeydown,onkeyup";
	liColAtts = liHtmlAtts & ",align,char,charoff,span,valign";
	
	function show(showval,rownum) {
		var result = true;
		var fieldname = "";
		var negate = false;
		if ( isBoolean(showval) ) {
			result = showval;
		} else {
			if ( Left(showval,1) eq "!" ) {
				fieldname = Right(showval,Len(showval)-1);
				negate = true;
			} else {
				fieldname = showval;
			}
			if ( ListFindNoCase(qTableData.ColumnList,fieldname) ) {
				if ( isBoolean(qTableData[fieldname][rownum]) ) {
					if ( negate ) {
						result = NOT qTableData[fieldname][rownum];
					} else {
						result = qTableData[fieldname][rownum];
					}
				}
			}
		}
		return result;
	}
	</cfscript>
	<cfparam name="attributes.suffix" default="">
	<cfparam name="attributes.query" default="">
	<cfparam name="attributes.table" default="">
	<cfparam name="attributes.datasource" default="">
	<cfparam name="attributes.pkfield">
	<cfparam name="attributes.pktype" default="identity"><!--- identity or GUID --->
	<cfparam name="attributes.label" default="#attributes.table#">
	<cfparam name="attributes.labelSuffix" default="Manager">
	<cfparam name="attributes.skin" default="">
	<cfparam name="attributes.class" default="">
	<cfparam name="attributes.style" default="">
	<cfparam name="attributes.width" default="">
	<cfparam name="attributes.editpage" default="edit#attributes.table#.cfm">
	<cfparam name="attributes.urlvar" default="id">
	<cfparam name="attributes.classOdd" default="">
	<cfparam name="attributes.styleOdd" default="">
	<cfparam name="attributes.classEven" default="">
	<cfparam name="attributes.styleEven" default="">
	<cfparam name="attributes.classOver" default="">
	<!--- <cfparam name="attributes.styleOver" default=""> --->
	<cfparam name="attributes.orderby" default="">
	<cfparam name="attributes.filter" default="">
	<cfparam name="attributes.maxrows" default="0" type="numeric">
	<cfparam name="attributes.maxpages" default="0" type="numeric">
	<cfparam name="attributes.librarypath" default="lib/">
	<cfparam name="attributes.xhtml" default="true" type="boolean">
	<cfparam name="attributes.isAddable" default="true" type="boolean">
	<cfparam name="attributes.isEditable" default="true" type="boolean">
	<cfparam name="attributes.isDeletable" default="false" type="boolean">
	<cfparam name="attributes.isRowClickable" default="false" type="boolean">
	<cfparam name="attributes.RolodexDelim" default=" ">
	<cfparam name="attributes.TableSubmitValue" default="Submit">
	<cfparam name="url.sebdeleteid#sfx#" default="">
	<cfparam name="url.sebsort#sfx#" default="">
	<cfparam name="url.sebsortorder#sfx#" default="ASC">
	<cfparam name="url.sebstartrow#sfx#" default="1">
	<cfparam name="url.sebstartpage#sfx#" default="1">
	<cfparam name="url.sebrolodex#sfx#" default="">
	<cfparam name="request.sebTableHasSorter#sfx#" default="false">
	
	<!--- <cfparam name="attributes.CFC_Component" default=""> --->
	<cfparam name="attributes.CFC_GetMethod" default="">
	<cfparam name="attributes.CFC_GetArgs" default="">
	<cfparam name="attributes.CFC_DeleteMethod" default="">
	<cfparam name="attributes.CFC_DeleteArgs" default="">
	<cfparam name="attributes.CFC_SortMethod" default="">
	<cfparam name="attributes.CFC_SortListArg" default="">
	<cfparam name="attributes.CFC_SortArgs" default="">
	
	<cfif isDefined("attributes.CFC_Component")>
		<cfparam name="attributes.isForm" default="true" type="boolean">
	<cfelse>
		<cfparam name="attributes.isForm" default="false" type="boolean">
	</cfif><!--- Create form if isForm is true --->
	
	<cfif Len(attributes.label)>
		<cfparam name="attributes.showHeader" type="boolean" default="true">
	<cfelse>
		<cfparam name="attributes.showHeader" type="boolean" default="false">
	</cfif>
	
	<cfset sortorders = "ASC,DESC">
	<cfif NOT ListFindNoCase(sortorders,url["sebsortorder#sfx#"])><cfset url["sebsortorder#sfx#"] = "ASC"></cfif>
	
	<cfif Not ( Len(attributes.query) OR Len(attributes.datasource) OR ( isDefined("attributes.CFC_Component") AND Len(attributes.CFC_GetMethod) ) )>
		<cfthrow message="Either the query attribute or datasource attribute must be provided." type="ctag">
	</cfif>
</cfif>
<cfscript>
useRolodex = false;
if ( Not isNumeric(url["sebstartrow#sfx#"]) ) {
	url["sebstartrow#sfx#"] = 1;
}
if ( Len(url["sebrolodex#sfx#"]) ) {
	url["sebrolodex#sfx#"] = Left(url["sebrolodex#sfx#"],1);
	useRolodex = true;
}
if ( attributes.maxrows ) {
	CurrPage = int((url["sebstartrow#sfx#"]-1+attributes.maxrows) / attributes.maxrows);
} else {
	CurrPage = 1;
}
if ( attributes.maxpages ) {
	url['sebstartpage#sfx#'] = int((CurrPage-1) / attributes.maxpages) * attributes.maxpages + 1;	
} else {
	url['sebstartpage#sfx#'] = 1;
}

//url['sebstartpage#sfx#'] = int(CurrPage / attributes.maxpages) * attributes.maxpages + 1;
//url['sebstartpage#sfx#'] = int((CurrPage-1+attributes.maxpages) / attributes.maxpages);
if ( url['sebstartpage#sfx#'] gt 1 ) {
	PageStartRow = (url['sebstartpage#sfx#'] * attributes.maxrows) + 1;
} else {
	PageStartRow = 1;
}


if ( Not StructKeyExists(request, "cftags") ) {
	request.cftags = StructNew();
}
if ( Not StructKeyExists(request.cftags, TagName) ) {
	request.cftags[TagName] = StructNew();
}
if ( Not StructKeyExists(request.cftags[TagName], "attributes") ) {
	request.cftags[TagName].attributes = StructNew();
}
request.cftags[TagName].attributes = attributes;
</cfscript>

</cfsilent><cfif isDefined("ThisTag.ExecutionMode") AND ThisTag.ExecutionMode eq "End"><cfsilent>

<cfif Not isDefined("ThisTag.qColumns")><cfthrow message="You must include at least one column with cf_sebColumn in order to use cf_sebTable." type="ctag"></cfif>

<!--- Also should handle these deletions/sorts (and other deletion from table) --->
<cfset Message = "">

<cfset doRedir = false>
<cfset sorts = "+,-">
<cfset isSorting = false>
<cfset isDeleting = false>
<cfset isSubmittingColumn = false>
<cfset isSubmittingTable = false>
<cfset DeleteID = 0>
<cfset SubmitCol = 0>
<cfset SubmitID = 0>
<cfset SortList = "">
<cfif isDefined("form.sebTable") AND form.sebTable eq sfx AND isDefined("Form.sebTableRows") AND isNumeric(Form.sebTableRows)>
	<cfif StructKeyExists(Form,"SortList") AND Len(Form.SortList)>
		<cfset SortList = Form["SortList"]>
	</cfif>
	<cfloop index="i" from="1" to="#Form.sebTableRows#" step="1">
		<!--- Handle submission --->
		<cfif StructKeyExists(Form,"submit_#i#")>
			<cfloop index="j" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
				<cfif Form["submit_#i#"] eq ThisTag.qColumns[j].label>
					<cfset isSubmittingColumn = true>
					<cfset SubmitCol = j>
					<cfset SubmitID = Form["sebTable_#i#"]>
				</cfif>
			</cfloop>
		</cfif>
		<cfif StructKeyExists(Form,"sebTableSubmit")>
			<cfset isSubmittingTable = true>
		</cfif>
		<!--- Handle deletion --->
		<cfif StructKeyExists(Form,"delete_#i#") AND StructKeyExists(Form,"sebTable_#i#")>
			<cfset isDeleting = true>
			<cfset DeleteID = Form["sebTable_#i#"]>
		</cfif>
		<cfscript>
		//Handle sort
		if ( isDefined("Form.Sort_#i#") and ListFindNoCase(sorts,Form["Sort_#i#"]) ) {
			isSorting = true;
			if ( Form["Sort_#i#"] eq "+" ) {
				if ( ListLen(SortList) ) {
					SortList = ListInsertAt(SortList, ListLen(SortList), Form["sebTable_#i#"]);
				} else {
					SortList = ListAppend(SortList,Form["sebTable_#i#"]);
				}
			} else {
				if ( i lt Form.sebTableRows ) {
					SortList = ListAppend(SortList,Form["sebTable_#(i+1)#"]);
					SortList = ListAppend(SortList,Form["sebTable_#i#"]);
					i = i + 1;
				} else {
					SortList = ListAppend(SortList,Form["sebTable_#i#"]);
				}
			}
		} else {
			if ( StructKeyExists(Form,"sebTable_#i#") AND NOT ListFindNoCase(SortList,Form["sebTable_#i#"]) ) {
				SortList = ListAppend(SortList,Form["sebTable_#i#"]);
			}
		}
		</cfscript>
	</cfloop>
	<cfif isSorting>
		<cfif isDefined("attributes.CFC_Component") AND Len(attributes.CFC_SortMethod) AND Len(attributes.CFC_SortListArg)>
			<cfinvoke component="#attributes.CFC_Component#" method="#attributes.CFC_SortMethod#">
				<cfinvokeargument name="#attributes.CFC_SortListArg#" value="#SortList#">
				<cfif isStruct(attributes.CFC_SortArgs)>
					<cfloop collection="#attributes.CFC_SortArgs#" item="arg">
						<cfinvokeargument name="#arg#" value="#attributes.CFC_SortArgs[arg]#">
					</cfloop>
				</cfif>
			</cfinvoke>
			<cfset doRedir = true>
		</cfif>
	</cfif>
</cfif>

<cfif attributes.isDeletable AND Len(url["sebdeleteid#sfx#"])>
	<cfset isDeleting = true>
	<cfset DeleteID = url["sebdeleteid#sfx#"]>
</cfif>

<cfif isSubmittingColumn>
	<!--- Only take action if we have a method --->
	<cfset i = SubmitCol>
	<cfif StructKeyExists(ThisTag.qColumns[i],"CFC_Method")>
		<!--- Default Component for this col to Component for table --->
		<cfif NOT StructKeyExists(ThisTag.qColumns[i],"CFC_Component") AND StructKeyExists(attributes,"CFC_Component")>
			<cfset ThisTag.qColumns[i].CFC_Component = attributes.CFC_Component>
		</cfif>
		<!--- Only take action if we have a component --->
		<cfif StructKeyExists(ThisTag.qColumns[i],"CFC_Component")>
			<cfinvoke component="#ThisTag.qColumns[i].CFC_Component#" method="#ThisTag.qColumns[i].CFC_Method#">
				<cfinvokeargument name="#attributes.pkfield#" value="#SubmitID#">
				<cfif StructKeyExists(ThisTag.qColumns[i],"CFC_MethodArgs") AND isStruct(ThisTag.qColumns[i].CFC_MethodArgs)>
					<cfloop collection="#ThisTag.qColumns[i].CFC_MethodArgs#" item="arg">
						<cfinvokeargument name="#arg#" value="#ThisTag.qColumns[i].CFC_MethodArgs[arg]#">
					</cfloop>
				</cfif>
			</cfinvoke>
			<cfif StructKeyExists(ThisTag.qColumns[i],"Message") AND Len(ThisTag.qColumns[i].Message)>
				<cfset Message = ThisTag.qColumns[i].Message>
			<cfelse>
				<cfset doRedir = true>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfif isSubmittingTable AND StructKeyExists(attributes,"CFC_Component") AND StructKeyExists(attributes,"CFC_Method")>
	<cfinvoke component="#attributes.CFC_Component#" method="#attributes.CFC_Method#">
		<cfif StructKeyExists(attributes,"CFC_MethodArgs") AND isStruct(attributes.CFC_MethodArgs)>
			<cfloop collection="#attributes.CFC_MethodArgs#" item="arg">
				<cfinvokeargument name="#arg#" value="#attributes.CFC_MethodArgs[arg]#">
			</cfloop>
		</cfif>
		<cfloop collection="#Form#" item="arg">
			<cfif NOT Left(arg,8) eq "sebTable" AND NOT ( StructKeyExists(attributes,"CFC_MethodArgs") AND StructKeyExists(attributes["CFC_MethodArgs"],arg) )>
				<cfinvokeargument name="#arg#" value="#Form[arg]#">
			</cfif>
		</cfloop>
	</cfinvoke>
	<cfset doRedir = true>
</cfif>

<cfif isDeleting>
	<cfif isDefined("attributes.CFC_Component") AND Len(attributes.CFC_DeleteMethod)>
		<cfinvoke component="#attributes.CFC_Component#" method="#attributes.CFC_DeleteMethod#">
			<cfinvokeargument name="#attributes.pkfield#" value="#DeleteID#">
			<cfif isStruct(attributes.CFC_DeleteArgs)>
				<cfloop collection="#attributes.CFC_DeleteArgs#" item="arg">
					<cfinvokeargument name="#arg#" value="#attributes.CFC_DeleteArgs[arg]#">
				</cfloop>
			</cfif>
		</cfinvoke>
	<cfelseif Len(attributes.table)>
		<cfquery name="qTableDelete" datasource="#attributes.datasource#">
		DELETE
		FROM 	#attributes.table#
		WHERE	#attributes.pkfield# = <cfif attributes.pktype is "GUID"><cfqueryparam value="#DeleteID#" cfsqltype="CF_SQL_IDSTAMP"><cfelse>#Val(DeleteID)#</cfif>
		</cfquery>
	</cfif>
	<cfset doRedir = true>
</cfif>

<cfif doRedir>
	<cfset QueryString = ReplaceNoCase(CGI.QUERY_STRING, "sebdeleteid#sfx#=#url['sebdeleteid#sfx#']#", "")>
	<cflocation url="#CGI.SCRIPT_NAME#?#QueryString#" addtoken="No">
</cfif>

<cfset liColumns = "">
<cfset liLabels = "">
<cfset liRelTables = "">
<cfset liRelJoins = "">
<cfset RolodexField = "">
<cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
	<cfif Len(ThisTag.qColumns[i].dbfield)>
		<cfset liColumns = ListAppend(liColumns, ThisTag.qColumns[i].dbfield)>
		<cfset liLabels = ListAppend(liLabels, ThisTag.qColumns[i].label)>
		<cfif Len(ThisTag.qColumns[i].reltable) AND Not ListFindNoCase(liRelTables, ThisTag.qColumns[i].reltable)>
			<cfset liRelTables = ListAppend(liRelTables, ThisTag.qColumns[i].reltable)>
			<cfset liRelJoins = ListAppend(liRelJoins, "#ThisTag.qColumns[i].reltable#.#ThisTag.qColumns[i].relfield#")>
		</cfif>
		<!--- Check for and set rolodex --->
		<cfif ThisTag.qColumns[i].rolodex>
			<cfif Len(RolodexField)>
				<cfthrow message="You can only set rolodex as true for one column at a time." type="cftag">
			<cfelse>
				<cfset RolodexField = ThisTag.qColumns[i].dbfield>
				<cfset useRolodex = true>
			</cfif>
		</cfif>
	</cfif>
</cfloop>
<cfif Not Len(attributes.orderby) AND Not ListFindNoCase(liLabels, url["sebSort#sfx#"])><cfset url["sebsort#sfx#"] = ThisTag.qColumns[1].label></cfif>

<cfif Len(attributes.query) OR ( isDefined("attributes.CFC_Component") AND Len(attributes.CFC_GetMethod) )>
	<cfif Len(attributes.query)>
		<cfset qTableData = Evaluate("Caller.#attributes.query#")>
	<cfelse>
		<cfinvoke component="#attributes.CFC_Component#" method="#attributes.CFC_GetMethod#" returnvariable="qTableData">
		<cfif isStruct(attributes.CFC_GetArgs)><cfloop collection="#attributes.CFC_GetArgs#" item="arg">
			<cfinvokeargument name="#arg#" value="#attributes.CFC_GetArgs[arg]#">
		</cfloop></cfif>
		</cfinvoke>
	</cfif>

	<cfif Len(Trim(attributes.filter)) OR Len(url["sebsort#sfx#"]) OR ( Len(RolodexField) AND Len(Trim(url["sebrolodex#sfx#"]) eq 1) ) OR Len(attributes.orderby)>
		<cfif Len(url["sebsort#sfx#"])>
			<cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
				<cfif url["sebsort#sfx#"] eq ThisTag.qColumns[i].label AND Len(ThisTag.qColumns[i].sortfield)>
					<cfif NOT ListFindNoCase(qTableData.ColumnList,"#ThisTag.qColumns[i].sortfield#_UCase")>
						<cfset aSortVals = ArrayNew(1)>
						<cfloop query="qTableData">
							<cfset ArrayAppend(aSortVals,UCase(qTableData[ThisTag.qColumns[i].sortfield][CurrentRow]))>
						</cfloop>
						<cfset QueryAddColumn(qTableData, "#ThisTag.qColumns[i].sortfield#_UCase",  aSortVals)>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<cftry>
			<cfquery name="qTableData" dbtype="query">
			SELECT		*
			FROM		qTableData
			WHERE		1 = 1
			<cfif Len(Trim(attributes.filter))>
				AND		#Trim(attributes.filter)#
			</cfif>
			<cfif Len(RolodexField) AND Len(Trim(url["sebrolodex#sfx#"])) eq 1>
				AND		(
							#RolodexField# IS NOT NULL
						AND	1 = 1
						AND (
								#RolodexField# LIKE '#UCase(Left(Trim(url["sebrolodex#sfx#"]),1))#%'
							OR	#RolodexField# LIKE '#LCase(Left(Trim(url["sebrolodex#sfx#"]),1))#%'
							)
						)
			</cfif>
			<cfif Len(url["sebsort#sfx#"])><cfset sortcount = 0>
				<cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
					<cfif url["sebsort#sfx#"] eq ThisTag.qColumns[i].label AND Len(ThisTag.qColumns[i].sortfield)>
					<cfif sortcount>,<cfelse>ORDER BY</cfif>	#ThisTag.qColumns[i].sortfield#_UCase<cfif url["sebsortorder#sfx#"] eq "DESC"> DESC</cfif><cfset sortcount = sortcount + 1>
					</cfif>
				</cfloop>
			<cfelseif Len(attributes.orderby)>
			ORDER BY	#attributes.orderby#
			</cfif>
			</cfquery>
			<cfcatch type="Expression">
				<!--- Catch and handle bug in cf on how it guesses datatypes for QofQ --->
				<cfif NOT CFCATCH.Message CONTAINS "cannot be converted">
					<cfrethrow>
				</cfif>
				
				<!--- Need to create a temporary query to workaround this bug in cf --->
				<cfset qTableData2 = QueryNew(qTableData.ColumnList)>
				
				<!--- Fake row --->
				<cfset QueryAddRow(qTableData2)>
				<cfloop index="col" list="#qTableData.ColumnList#">
					<cfset QuerySetCell(qTableData2, col, "sebTable_FakeData")>
				</cfloop>
				
				<!--- Populate from original query --->
				<cfoutput query="qTableData">
					<cfset QueryAddRow(qTableData2)>
					<cfloop index="col" list="#qTableData.ColumnList#">
						<cfset QuerySetCell(qTableData2, col, qTableData[col][CurrentRow])>
					</cfloop>
				</cfoutput>
				
				<cfquery name="qTableData" dbtype="query">
				SELECT		*
				FROM		qTableData2
				WHERE		1 = 1
					AND		#ListFirst(qTableData.ColumnList)# <> 'sebTable_FakeData'
				<cfif Len(Trim(attributes.filter))>
					AND		#Trim(attributes.filter)#
				</cfif>
				<cfif Len(RolodexField) AND Len(Trim(url["sebrolodex#sfx#"])) eq 1>
					AND		(
								#RolodexField# IS NOT NULL
							AND	1 = 1
							AND (
									#RolodexField# LIKE '#UCase(Left(Trim(url["sebrolodex#sfx#"]),1))#%'
								OR	#RolodexField# LIKE '#LCase(Left(Trim(url["sebrolodex#sfx#"]),1))#%'
								)
							)
				</cfif>
				<cfif Len(url["sebsort#sfx#"])><cfset sortcount = 0>
					<cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
						<cfif url["sebsort#sfx#"] eq ThisTag.qColumns[i].label AND Len(ThisTag.qColumns[i].sortfield)>
						<cfif sortcount>,<cfelse>ORDER BY</cfif>	#ThisTag.qColumns[i].sortfield#_UCase<cfif url["sebsortorder#sfx#"] eq "DESC"> DESC</cfif><cfset sortcount = sortcount + 1>
						</cfif>
					</cfloop>
				<cfelseif Len(attributes.orderby)>
				ORDER BY	#attributes.orderby#
				</cfif>
				</cfquery>
			</cfcatch>
		</cftry>
	</cfif>
<cfelse>
	<cfquery name="qTableData" datasource="#attributes.datasource#">
	SELECT		#attributes.table#.#attributes.pkfield#<cfloop index="thisField" list="#liColumns#">, #thisField#</cfloop><!--- <cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">, #attributes.table#.#ThisTag.qColumns[i].dbfield#</cfloop> --->
	FROM		#attributes.table#<cfif Len(liRelTables)><cfloop index="thisRelTable" list="#liRelTables#">, #thisRelTable#</cfloop></cfif>
	WHERE		1 = 1
	<cfif Len(liRelTables)><cfloop index="thisRelField" list="#liRelJoins#">
		AND		#attributes.table#.#ListLast(thisRelField,".")# = #thisRelField#</cfloop>
	</cfif>
	<cfif Len(Trim(attributes.filter))>
		AND		#PreserveSingleQuotes(attributes.filter)#
	</cfif>
	<cfif Len(RolodexField) AND Len(Trim(url["sebrolodex#sfx#"]) eq 1)>
		AND		#RolodexField# LIKE '#url["sebrolodex#sfx#"]#%'
	</cfif>
	<cfif Len(url["sebsort#sfx#"])>
		<cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
			<cfif Len(ThisTag.qColumns[i].sortfield) AND (url["sebsort#sfx#"] eq ThisTag.qColumns[i].label)>
			ORDER BY	#ThisTag.qColumns[i].sortfield#<cfif url["sebsortorder#sfx#"] eq "DESC"> DESC</cfif>
			</cfif>
		</cfloop>
	<cfelseif Len(attributes.orderby)>
	ORDER BY	#attributes.orderby#
	</cfif>
	</cfquery>
</cfif>

<cfscript>
if ( attributes.maxrows eq 0 ) {
	attributes.maxrows = qTableData.RecordCount;
}
if ( qTableData.RecordCount gt attributes.maxrows ) {
	useRolodex = true;
}
numRecords = Min(attributes.maxrows,qTableData.RecordCount);
EndRow = Min((url["sebstartrow#sfx#"] + numRecords - 1),qTableData.RecordCount);
if ( attributes.maxrows AND attributes.maxpages ) {
	EndPage = Min(url['sebstartpage#sfx#'] + attributes.maxpages - 1,int(qTableData.RecordCount/attributes.maxrows)+1);
} else {
	if ( attributes.maxrows ) {
		EndPage = ceiling(qTableData.RecordCount/attributes.maxrows);
	} else {
		EndPage = qTableData.RecordCount;
	}
}
hasInputs = false;
requiresSubmit = false;

varThisPage = CGI.SCRIPT_NAME;
varQueryString = CGI.Query_String;
thisName = "";
//Ditch url variables previously created by this tag from links in this tag (but keep url vars not created by this tag)
liTagUrlVars = "sebdeleteid#sfx#,sebsort#sfx#,sebsortorder#sfx#,sebrolodex#sfx#,sebstartrow#sfx#,sebstartpage#sfx#";
for (ii=1; ii lte ListLen(liTagUrlVars); ii=ii+1) {
	for (i=1; i lte ListLen(varQueryString,"&"); i=i+1) {
		if ( Len(varQueryString) AND ListFindNoCase(ListGetAt(varQueryString, i, "&"),ListGetAt(liTagUrlVars,ii),"=") ) {
			varQueryString = ListDeleteAt(varQueryString, i, "&");
		}
	}
}

if ( Len(varQueryString) ) {
	varQueryString = ReplaceNoCase(varQueryString, "&", "&amp;", "ALL");
	varThisPage = varThisPage & "?#varQueryString#&amp;";
} else {
	varThisPage = varThisPage & "?";
}

varEditPage = attributes.editpage;
if ( varEditPage CONTAINS "?" ) {
	varEditPage = varEditPage & "&amp;#attributes.urlvar#=";
} else {
	varEditPage = varEditPage & "?#attributes.urlvar#=";
}

if ( attributes.xhtml ) {
	jsThisPage = varThisPage;
	jsEditPage = varEditPage;
} else {
	jsThisPage = ReplaceNoCase(varThisPage, "&amp;", "&", "ALL");
	jsEditPage = ReplaceNoCase(varEditPage, "&amp;", "&", "ALL");
}

TrOdd = "";
TrEven = "";
TrOver = "";
ClassOdd = "odd";
ClassEven = "even";
if ( Len(attributes.StyleOdd) ) {
	TrOdd = TrOdd & ' style="#attributes.StyleOdd#"';
}
if ( Len(attributes.StyleEven) ) {
	TrEven = TrEven & ' style="#attributes.StyleEven#"';
}
if ( Len(attributes.ClassOdd) ) {
	ClassOdd = ClassOdd & " #attributes.ClassOdd#";
}
if ( Len(attributes.ClassEven) ) {
	ClassEven = ClassEven & " #attributes.ClassEven#";
}
if ( Len(attributes.ClassOver) ) {
	TrOver = TrOver & ' onmouseover="seb#attributes.Table##sfx#On(this);" onmouseout="seb#sfx##attributes.Table##sfx#Off(this);"';
}
arrHiddenPK = ArrayNew(1);
</cfscript>

</cfsilent><cfoutput><cfsavecontent variable="htmlhead"><style type="text/css"><cfif attributes.isRowClickable>.sebTable tr {cursor:pointer;}; .sebTable td, </cfif>.sebTable th {text-align:left;}</style><cfif Len(attributes.skin)>
<style type="text/css">@import url(#attributes.librarypath#skins/#attributes.skin#.css);</style></cfif>
<!--[if IE 6]><style type="text/css">.sebTable th a {height:1%;}</style><![endif]-->
<cfif attributes.isDeletable OR attributes.isRowClickable OR Len(attributes.classOver)><script type="text/javascript"><cfif attributes.isDeletable>
function sebDeleteIt(id,name) {
	var checkDel = confirm("Are you sure that you want to delete '"+ name +"'?");
	if ( checkDel ) {
		window.location.href='#jsThisPage#sebdeleteid#sfx#=' + id;
	}
}</cfif><cfif attributes.isRowClickable>
function sebEditIt(id) {
	window.location.href='#jsEditPage#' + id;
}</cfif><cfif Len(attributes.classOver)>
function seb#attributes.Table##sfx#On(obj) {
	obj.className+=" #attributes.classOver#";
}
function seb#sfx##attributes.Table##sfx#Off(obj) {
	obj.className=obj.className.replace(new RegExp(" #attributes.classOver#\\b"), "");
}</cfif>
</script></cfif></cfsavecontent><cfhtmlhead text="#htmlhead#">
<div id="sebTable" class="seb sebTable"<cfif Len(attributes.width)> style="width:#attributes.width#px;"</cfif>><cfif Len(Message)>
<p class="sebTableMessage">#Message#</p></cfif><cfif attributes.isForm>
<form action="#CGI.SCRIPT_NAME#?#XmlFormat(CGI.QUERY_STRING)#" method="post" name="frmSebTable#sfx#" id="frmSebTable#sfx#"><input type="hidden" name="sebTable" value="#sfx#"/></cfif>
	<cfif attributes.showHeader><p class="sebTableCount"><cfif EndRow>(#url["sebstartrow#sfx#"]# - #EndRow#) of </cfif>#qTableData.RecordCount# record<cfif numRecords neq 1>s</cfif></p></cfif>
	<cfif attributes.showHeader><p class="sebHeader"><cfif Len(attributes.label)><strong>#attributes.label# #attributes.labelSuffix#</strong></cfif><cfif attributes.isAddable> [<a href="#attributes.editpage#">Add New #attributes.label#</a>]</cfif></p></cfif>
	<cfif Len(RolodexField) AND useRolodex>
	<div id="sebTable-rolodex" class="sebTable-rolodex">
		<p><cfloop index="L" from="#ASC('A')#" to="#ASC('Z')#" ><a href="#varThisPage#sebsort#sfx#=#url['sebsort#sfx#']#&amp;sebsortorder#sfx#=#url['sebsortorder#sfx#']#&amp;sebrolodex#sfx#=#CHR(L)#"<cfif chr(L) eq url["sebrolodex#sfx#"]> class="currLetter"</cfif>>#CHR(L)#</a>#Attributes.RolodexDelim#</cfloop><a href="#varThisPage#sebsort#sfx#=#url['sebsort#sfx#']#&amp;sebsortorder#sfx#=#url['sebsortorder#sfx#']#"<cfif NOT Len(url["sebrolodex#sfx#"])> class="currLetter"</cfif>>ALL</a></p>
	</div>
	</cfif>
	<cfif qTableData.RecordCount gt attributes.maxrows>
	<div id="sebTable-pager" class="sebTable-pager">
		<cfif url["sebstartrow#sfx#"] gt 1><cfset SortListVal = ""><cfloop index="i" from="1" to="#DecrementValue(url["sebstartrow#sfx#"])#" step="1"><cfset SortListVal = ListAppend(SortListVal,qTableData[attributes.pkfield][i])></cfloop><input type="hidden" name="SortList" value="#SortListVal#" /></cfif>
		<table<cfif Len(attributes.width)> width="#attributes.width#"</cfif> border="0" cellspacing="0">
		<tr>
			<td align="left" class="sebTable-pager-prev"><cfif url["sebstartrow#sfx#"] gt 1><cfset PrevStart = Max(1,url["sebstartrow#sfx#"] - attributes.maxrows)><a href="#varThisPage#sebrolodex#sfx#=#url['sebrolodex#sfx#']#&amp;sebsort#sfx#=#url['sebsort#sfx#']#&amp;sebsortorder#sfx#=#url['sebsortorder#sfx#']#&amp;sebstartrow#sfx#=#PrevStart#">Previous</a><cfelse>&nbsp;</cfif></td><!--- &amp;sebstartpage#sfx#=#url['sebstartpage#sfx#']# --->
			<td class="sebTable-pager-pages"><cfset page = url['sebstartpage#sfx#'] - 1><cfif url["sebstartpage#sfx#"] gt 1><cfset PrevPage = url["sebstartpage#sfx#"] - 1><a href="#varThisPage#sebrolodex#sfx#=#url['sebrolodex#sfx#']#&amp;sebsort#sfx#=#url['sebsort#sfx#']#&amp;sebsortorder#sfx#=#url['sebsortorder#sfx#']#&amp;sebstartrow#sfx#=#((PrevPage-1)*attributes.maxrows)+1#&amp;sebstartpage#sfx#=#PrevPage#">&lt;</a> </cfif><cfloop index="page" from="#url["sebstartpage#sfx#"]#" to="#EndPage#" step="1"><cfset i = ((page-1)*attributes.maxrows) + 1><a href="#varThisPage#sebrolodex#sfx#=#url['sebrolodex#sfx#']#&amp;sebsort#sfx#=#url['sebsort#sfx#']#&amp;sebsortorder#sfx#=#url['sebsortorder#sfx#']#&amp;sebstartrow#sfx#=#i#"<cfif CurrPage eq page> class="sebTable-currPage"</cfif>>#page#</a> <cfif EndPage AND (page gte EndPage)><cfbreak></cfif></cfloop><cfif Int(qTableData.RecordCount / attributes.maxrows)+1 gt page> <cfset NextPage = (page + 1)><a href="#varThisPage#sebrolodex#sfx#=#url['sebrolodex#sfx#']#&amp;sebsort#sfx#=#url['sebsort#sfx#']#&amp;sebsortorder#sfx#=#url['sebsortorder#sfx#']#&amp;sebstartrow#sfx#=#((NextPage-1)*attributes.maxrows)+1#&amp;sebstartpage#sfx#=#NextPage#">&gt;</a></cfif></td>
			<td align="right" class="sebTable-pager-next"><cfif qTableData.RecordCount gt EndRow><cfset NextStart = (EndRow + 1)><a href="#varThisPage#sebrolodex#sfx#=#url['sebrolodex#sfx#']#&amp;sebsort#sfx#=#url['sebsort#sfx#']#&amp;sebsortorder#sfx#=#url['sebsortorder#sfx#']#&amp;sebstartrow#sfx#=#NextStart#">Next</a><cfelse>&nbsp;</cfif></td><!--- &amp;sebstartpage#sfx#=#url['sebstartpage#sfx#']# --->
		</tr>
		</table>
	</div>
	</cfif>
<cfif qTableData.RecordCount>
<table<cfif Len(attributes.width)> width="#attributes.width#"</cfif> border="0" cellspacing="0"><cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
<col<cfif Len(ThisTag.qColumns[i].width) AND isNumeric(ThisTag.qColumns[i].width) AND ThisTag.qColumns[i].width> width="#ThisTag.qColumns[i].width#"</cfif><cfloop index="att" list="#liColAtts#"><cfif StructKeyExists(ThisTag.qColumns[i],att) AND Len(ThisTag.qColumns[i][att])> #att#="#ThisTag.qColumns[i][att]#"</cfif></cfloop>><cfif attributes.xhtml></col></cfif></cfloop>
<tr><cfset editLinkShowed = false><cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1"><cfif ThisTag.qColumns[i].datatype eq "delete" AND attributes.isEditable AND NOT editLinkShowed>
	<td>&nbsp;</td><cfset editLinkShowed = true></cfif>
	<th><cfif Len(ThisTag.qColumns[i].header)><cfif request["sebTableHasSorter#sfx#"]>#ThisTag.qColumns[i].header#<cfelse><a href="#varThisPage#sebrolodex#sfx#=#url['sebrolodex#sfx#']#&amp;sebsort#sfx#=#URLEncodedFormat(ThisTag.qColumns[i].label)#<cfif (url['sebsort#sfx#'] eq ThisTag.qColumns[i].label) AND (url['sebsortorder#sfx#'] neq 'DESC')>&amp;sebsortorder#sfx#=desc</cfif>" title="Sort by #ThisTag.qColumns[i].label#"<cfif (url["sebsort#sfx#"] eq ThisTag.qColumns[i].label)> class="sort #LCase(url['sebsortorder#sfx#'])#"</cfif>>#ThisTag.qColumns[i].header#</a></cfif><cfelse>&nbsp;</cfif></th></cfloop><cfif attributes.isEditable>
	<th class="sebTable-editlink">&nbsp;</th></cfif><cfif attributes.isDeletable>
	<th class="sebTable-deletelink">&nbsp;</th></cfif>
</tr><cfloop query="qTableData" startrow="#url['sebstartrow#sfx#']#" endrow="#EndRow#"><cfset editLinkShowed = false><cfset deleteShowed = false><cfif CurrentRow MOD 2><cfset rowClass = ClassOdd><cfelse><cfset rowClass = ClassEven></cfif><cfset pkid = qTableData[attributes.pkfield][CurrentRow]><cfset arrHiddenPK[CurrentRow] = false>
<tr id="row#attributes.Table##CurrentRow#" class="#rowclass#"#TrOver#><cfloop index="i" from="1" to="#ArrayLen(ThisTag.qColumns)#" step="1">
	<cfscript>
	if ( Len(ThisTag.qColumns[i].dbfield) ) {
		thisValue = qTableData[ThisTag.qColumns[i].dbfield][CurrentRow];
	} else if ( Len(ThisTag.qColumns[i].label) ) {
		thisValue = "#ThisTag.qColumns[i].label#"; //ThisTag.qColumns[i].label;
	} else {
		thisValue = "";
	}
	/*
	if ( attributes.xhtml AND NOT ThisTag.qColumns[i].type eq "date" ) {
		thisDisplay = XmlFormat(thisValue);	
	} else {
		thisDisplay = thisValue;
	}
	*/
	if ( ThisTag.qColumns[i].isInput ) {
		hasInputs = true;
	}
	if ( ThisTag.qColumns[i].requiresSubmit ) {
		requiresSubmit = true;
	}
	if ( CurrentRow eq RecordCount ) {
		ThisTag.qColumns[i].isLastRow = true;
	}
	
	thisDisplay = ThisTag.qColumns[i].display(thisValue,CurrentRow,pkid,ThisTag.qColumns[i]);
	
	if ( hasInputs AND NOT arrHiddenPK[CurrentRow] ) {//ThisTag.qColumns[i].isInput AND NOT arrHiddenPK[CurrentRow]
		thisDisplayHidden = '<input type="hidden" name="sebTable_#CurrentRow#" id="sebTable#CurrentRow#" value="#pkid#"/>';
		thisDisplay = thisDisplay & thisDisplayHidden;
		arrHiddenPK[CurrentRow] = true;
	}
	if ( (ThisTag.qColumns[i].DataType neq "icon") AND NOT Len(thisName) ) {
		thisName = thisValue;
		if ( attributes.xhtml ) {
			thisName = XmlFormat(thisName);
		}
	}
	if ( ThisTag.qColumns[i].datatype eq "delete" ) {
		deleteShowed = true;
	}
	</cfscript><cfif ThisTag.qColumns[i].datatype eq "delete" AND attributes.isEditable AND NOT editLinkShowed>
	<td>&nbsp;<a href="#varEditPage##pkid#">edit</a>&nbsp;</td><cfset editLinkShowed = true></cfif>
	<td<cfif attributes.isRowClickable AND Not Len(ThisTag.qColumns[i].link) AND NOT ThisTag.qColumns[i].type eq "link"> onclick="sebEditIt('#JSStringFormat(URLEncodedFormat(pkid))#');"</cfif>><cfif (isBoolean(ThisTag.qColumns[i].show) AND ThisTag.qColumns[i].show) OR show(ThisTag.qColumns[i].show,CurrentRow)><cfif Len(ThisTag.qColumns[i].link) AND NOT ThisTag.qColumns[i].type eq "link"><a href="#ThisTag.qColumns[i].link##pkid#"<cfif StructKeyExists(ThisTag.qColumns[i],"title") AND Len(ThisTag.qColumns[i].title)> title="#ThisTag.qColumns[i].title#"</cfif>>#thisDisplay#</a>&nbsp;<cfelse>#thisDisplay#</cfif><cfelse>#ThisTag.qColumns[i].noshowalt#</cfif></td></cfloop><cfif attributes.isEditable AND NOT editLinkShowed>
	<td class="sebTable-editlink">&nbsp;<a href="#varEditPage##URLEncodedFormat(pkid)#">edit</a>&nbsp;</td></cfif><cfif attributes.isDeletable AND NOT deleteShowed>
	<td class="sebTable-deletelink">&nbsp;<a href="##" onclick="javascript:sebDeleteIt('#pkid#','#JSStringFormat(thisName)#');">delete</a>&nbsp;</td></cfif>
</tr><cfset thisName = ""></cfloop>
</table><cfif hasInputs><input type="hidden" name="sebTableRows" id="sebTableRows" value="#qTableData.RecordCount#"/></cfif><cfif attributes.isForm><cfif requiresSubmit>
<p><input name="sebTableSubmit" type="submit" value="#attributes.tableSubmitValue#"/></p>
</cfif>
</cfif>
<cfelse>
<p>(No #attributes.label# Records)</p>
</cfif><cfif attributes.isForm></form></cfif>
</div>
</cfoutput>
</cfif>