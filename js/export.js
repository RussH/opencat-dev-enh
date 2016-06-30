/*
 * CATS
 * Search Advanced JavaScript Library
 *
 * Portions Copyright (C) 2005 - 2007 Cognizo Technologies, Inc.
 *
 *
 * The contents of this file are subject to the CATS Public License
 * Version 1.1a (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.catsone.com/.
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is "CATS Standard Edition".
 *
 * The Initial Developer of the Original Code is Cognizo Technologies, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2005 - 2007
 * (or from the year in which this file was created to the year 2007) by
 * Cognizo Technologies, Inc. All Rights Reserved.
 *
 *
 * $Id: export.js 2356 2007-04-20 17:18:14Z brian $
 */

//FIXME: Clean up!


function docjslib_getRealLeftExport(imgElem)
{
    xPos = eval(imgElem).offsetLeft;
    tempEl = eval(imgElem).offsetParent;
    while (tempEl != null)
    {
        xPos += tempEl.offsetLeft;
        tempEl = tempEl.offsetParent;
    }
    return xPos;
}

function showBox(boxID)
{
    var box = document.getElementById(boxID);

    box.style.left = docjslib_getRealLeftExport(
        document.getElementById('exportBoxLink')
    ) + 'px';
    box.style.display = 'block';
}

function hideBox(boxID)
{
    document.getElementById(boxID).style.display = 'none';
}

function toggleChecksAll()
{
    var num_elements = document.selectedObjects.length;

    for (var i = 1 ; i < num_elements ; i++)
    {
        e = document.selectedObjects.elements[i];
        if (document.selectAll.allBox.checked == true)
        {
            if (e.type == 'checkbox')
            {
                e.checked = true;
            }
        }
        else
        {
            e.checked = false;
        }
    }
}

function checkSelected()
{
    var num_elements = document.selectedObjects.length;
    var check = false;
	
	//document.selectedObjects.elements["m"].value = "export_modified";
	//alert(document.selectedObjects.elements["m"].value);
	
    for (var i = 1 ; i < num_elements ; i++)
    {
        e = document.selectedObjects.elements[i];
        if (e.checked == true)
        {
            check = true;
        }
    }

    if (check == true)
    {
        document.selectedObjects.submit();
    }
    else
    {
        alert("Form Error: You must select at least one item for export.");
    }
}

function checkSelected_Parameter(modulename, moduleaction, candidateIDArrayStored)
{
    var num_elements = document.selectedObjects.length;
    var check = false;
	var result = "?m="+modulename+"&a="+moduleaction+"&dataItemType=100&candidateIDArrayStored="+candidateIDArrayStored;
	
	//document.selectedObjects.elements["m"].value = modulename;
	//document.selectedObjects.elements["dataItemType"].value = moduleaction;
	//alert(document.selectedObjects.elements["m"].value);
	var checked_items = "";
	
    for (var i = 1 ; i < num_elements ; i++)
    {
        e = document.selectedObjects.elements[i];
        if (e.checked == true)
        {
            check = true;
			//alert(e.name);
			checked_items = checked_items + "&"+e.name+"=on";
        }
    }

    if (check == true)
    {
		
		/* 
		//modify module name
		document.selectedObjects.elements["m"].value = modulename;		
		//add action parameter
		var action_element = document.createElement('input');
		action_element.name = "a";
		action_element.value = moduleaction;
		action_element.type = "hidden";		
		document.selectedObjects.appendChild(action_element); 				
		//add candidateIDArrayStored parameter
		var candidateIDArrayStored_element = document.createElement('input');
		candidateIDArrayStored_element.name = "candidateIDArrayStored";
		candidateIDArrayStored_element.value = candidateIDArrayStored;
		candidateIDArrayStored_element.type = "hidden";		
		document.selectedObjects.appendChild(candidateIDArrayStored_element); 
		//flag that only selected objects will be included	
		document.selectedObjects.elements["onSelected"].value = "true";
        document.selectedObjects.submit();
		*/
		result = result + checked_items + "&onlySelected=1";
    }
    else
    {
		//var fret = confirm("All records within the result will be included. Are you sure you want to do this?");
		//if(fret) {
			/*
			//modify module name			
			document.selectedObjects.elements["m"].value = modulename;		
			//add action parameter
			var action_element = document.createElement('input');
			action_element.name = "a";
			action_element.value = moduleaction;
			action_element.type = "hidden";		
			document.selectedObjects.appendChild(action_element); 				
			//add candidateIDArrayStored parameter
			var candidateIDArrayStored_element = document.createElement('input');
			candidateIDArrayStored_element.name = "candidateIDArrayStored";
			candidateIDArrayStored_element.value = candidateIDArrayStored;
			candidateIDArrayStored_element.type = "hidden";		
			document.selectedObjects.appendChild(candidateIDArrayStored_element); 			
			//flag that all records will be included
			document.selectedObjects.elements["onSelected"].value = "false";
			document.selectedObjects.submit();
			*/
			//result = false;
		//}
		//Do nothing, include All
		result = result + "&onlySelected=0";
    }
	//alert(result);
	return result;
}
