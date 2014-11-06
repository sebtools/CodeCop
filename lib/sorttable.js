// ===================================================================
// Author: Matt Kruse <matt@mattkruse.com>
// WWW: http://www.mattkruse.com/
//
// NOTICE: You may use this code for any purpose, commercial or
// private, without any further permission from the author. You may
// remove this notice from your final code if you wish, however it is
// appreciated by the author if at least my web site address is kept.
//
// You may *NOT* re-distribute this code in any way except through its
// use. That means, you can include it in your product, or your web
// site, or any other form where the code is actually being used. You
// may not put the plain javascript up on your site for download or
// include it in your javascript libraries for download. 
// If you wish to share this code with others, please just point them
// to the URL instead.
// Please DO NOT link directly to my .js files from your site. Copy
// the files to your server and use them there. Thank you.
// ===================================================================

var use_css=false;var use_layers=false;var use_dom=false;if(document.all){use_css    = true;}if(document.layers){use_layers = true;}if(document.getElementById){use_dom=true;}var sort_object;var sort_column;var reverse=0;
function SortTable(name){this.name = name;this.sortcolumn="";this.dosort=true;this.tablecontainsforms=false;this.AddLine = AddLine;this.AddColumn = AddColumn;this.WriteRows = WriteRows;this.SortRows = SortRows;this.AddLineProperties = AddLineProperties;this.AddLineSortData = AddLineSortData;this.Columns = new Array();this.Lines = new Array();this.LineProperties = new Array();}
function AddLine(){var index = this.Lines.length;this.Lines[index] = new Array();for(var i=0;i<arguments.length;i++){this.Lines[index][i] = new Object();this.Lines[index][i].text = arguments[i];this.Lines[index][i].data = arguments[i];}}
function AddLineProperties(prop){var index = this.Lines.length-1;this.LineProperties[index] = prop;}
function AddLineSortData(){var index = this.Lines.length-1;for(var i=0;i<arguments.length;i++){if(arguments[i] != ''){this.Lines[index][i].data = arguments[i];}}}
function AddColumn(name,td,align,type){var index = this.Columns.length;this.Columns[index] = new Object;this.Columns[index].name = name;this.Columns[index].td   = td;this.Columns[index].align=align;this.Columns[index].type = type;if(type == "form"){this.tablecontainsforms=true;if(use_layers){this.dosort=false;}}}
function WriteRows(){var open_div = "";var close_div = "";for(var i=0;i<this.Lines.length;i++){document.write("<TR "+this.LineProperties[i]+">");for(var j=0;j<this.Columns.length;j++){var div_name = "d"+this.name+"-"+i+"-"+j;if(use_css || use_dom){if(this.Columns[j].align != ''){var align = " ALIGN="+this.Columns[j].align;}else{var align = "";}open_div = "<DIV ID=\""+div_name+"\" "+align+">";close_div= "</DIV>";}else if(use_layers){if(!this.dosort){if(this.Columns[j].align != ''){open_div="<SPAN CLASS=\""+this.Columns[j].align+"\">";}}else{open_div = "<ILAYER NAME=\""+div_name+"\" WIDTH=100%>";open_div+= "<LAYER NAME=\""+div_name+"x\" WIDTH=100%>";if(this.Columns[j].align != ''){open_div+= "<SPAN CLASS=\""+this.Columns[j].align+"\">";}}if(this.Columns[j].align != ''){close_div = "</SPAN>";}if(this.dosort){close_div += "</LAYER></ILAYER>";}}document.write("<TD "+this.Columns[j].td+">"+open_div+this.Lines[i][j].text+close_div+"</TD>");}document.write("</TR>");}}
function SortRows(table,column){sort_object = table;if(!sort_object.dosort){return;}if(sort_column == column){reverse=1-reverse;}else{reverse=0;}sort_column = column;if(table.tablecontainsforms){var iname="1";var tempcolumns = new Object();for(var i=0;i<table.Lines.length;i++){for(var j=0;j<table.Columns.length;j++){if(table.Columns[j].type == "form"){var cell_name = "d"+table.name+"-"+i+"-"+j;if(use_css){tempcolumns[iname] = document.all[cell_name].innerHTML;}else{tempcolumns[iname] = document.getElementById(cell_name).innerHTML;}table.Lines[i][j].text = iname;iname++;}}}}if(table.Columns[column].type == "numeric"){table.Lines.sort(	
function by_name(a,b){if(parseFloat(a[column].data) < parseFloat(b[column].data) ){return -1;}if(parseFloat(a[column].data) > parseFloat(b[column].data) ){return 1;}return 0;});}else if(table.Columns[column].type == "money"){table.Lines.sort(	
function by_name(a,b){if(parseFloat(a[column].data.substring(1)) < parseFloat(b[column].data.substring(1))){return -1;}if(parseFloat(a[column].data.substring(1)) > parseFloat(b[column].data.substring(1))){return 1;}return 0;});}else if(table.Columns[column].type == "date"){table.Lines.sort(	
function by_name(a,b){if(Date.parse(a[column].data) < Date.parse(b[column].data) ){return -1;}if(Date.parse(a[column].data) > Date.parse(b[column].data) ){return 1;}return 0;});}else{table.Lines.sort(	
function by_name(a,b){if(a[column].data+"" < b[column].data+""){return -1;}if(a[column].data+"" > b[column].data+""){return 1;}return 0;});}if(reverse){table.Lines.reverse();}for(var i=0;i<table.Lines.length;i++){for(var j=0;j<table.Columns.length;j++){var cell_name = "d"+table.name+"-"+i+"-"+j;if(use_dom){if(table.Columns[j].type == "form"){var iname = table.Lines[i][j].text;document.getElementById(cell_name).innerHTML = tempcolumns[iname];}else{document.getElementById(cell_name).innerHTML = table.Lines[i][j].text;}}else if(use_css){if(table.Columns[j].type == "form"){var iname = table.Lines[i][j].text;document.all[cell_name].innerHTML = tempcolumns[iname];}else{document.all[cell_name].innerHTML = table.Lines[i][j].text;}}else if(use_layers){var cell_namex= "d"+table.name+"-"+i+"-"+j+"x";if(table.Columns[j].align != ''){document.layers[cell_name].document.layers[cell_namex].document.write("<SPAN CLASS=\""+table.Columns[j].align+"\">");}document.layers[cell_name].document.layers[cell_namex].document.write(table.Lines[i][j].text);if(table.Columns[j].align != ''){document.layers[cell_name].document.layers[cell_namex].document.write("</SPAN>");}document.layers[cell_name].document.layers[cell_namex].document.close();}}}}

