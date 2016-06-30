<?php /* $Id: SHow.tpl 3810 2012-15-02 19:13:25Z allan $ */ ?>
<?php TemplateUtility::printHeader('Job Orders', array('js/jquery/js/jquery-1.7.1.min.js', 'js/jquery/js/jquery-ui-1.8.17.custom.min.js', 'js/autocomplete2/javascript/jquery.autocomplete.js', 'js/autocomplete2/css/jquery.autocomplete.css', 'js/jquery/css/ui-lightness/jquery-ui-1.8.17.custom.css', 'js/jquery.balloon.js', 'js/jquery.jeditable.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active); ?>
	<style>
		.close_dialog {			
			float:right
			padding: 1px 3px 1px 3px;
			position: relative;
		}
		.close_dialog a {
			font-family: Tahoma, Geneva, sans-serif;
			font-size: 10px; 
			color: #666666;
			font-weight: bold;
			text-decoration: none;
			float: right;
			border:1px solid #666666;
			display: inline-block;
		}
		.closebtn {
			display: inline-block;			
			float: right;
			padding: 2px 0px 0px 5px;
		}
		.closebtn a {
			font-family: Tahoma, Geneva, sans-serif;
			font-size: 10px; 
			color: #666666;
			font-weight: normal;			
			text-decoration: none;
		}
	    .commonstyle {font-family:Tahoma, Geneva, sans-serif;
					  font-size: 12px; 
					  font-weight: normal; 
					  color:#333333;}
		.controlbox {width:450px; display:block; clear:both; margin:20px 0 0 5px}
		
		.skillbox {width:600px; display:block; margin: 0 0 10px 5px; 
		           background-color: #DEDEDE;
				   height:200px}		
		/*
        .skillbox ul { list-style-type: none; list-style:none; margin: 0; padding: 0; margin-bottom: 10px; }
        .skillbox li { margin: 5px; padding: 5px; width: 150px; }
		*/
		.skillbox ul { list-style-type: none; margin: 0; padding: 10px 12px 10px 12px;  }
		.skillbox li { margin: 3px 3px 3px 0; 
					   padding: 6px 8px 8px 8px; 
					   float: left; display: inline-block;
					   font-family:Tahoma, Geneva, sans-serif;
					   /* width: 100px; height: 90px; */					   
					   font-size: 12px; 
					   font-weight: normal; 
					   color:#006;
					   background-color: #ffffff;
					   text-align: left; }
    </style>
    <div id="main">
        <div id="contents">
        	<style>
				.colheader {
					font-family:Arial, Helvetica, sans-serif;
					font-weight: bold;
					font-size:12px;
				}
			</style>
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/job_orders.gif" width="24" height="24" border="0" alt="Job Orders" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Candidate Role & Specialization</h2></td>
                </tr>
            </table>
            <p class="note">Edit Details</p>
            <form name="editSpecializationForm" id="editSpecializationForm" onsubmit="return submit_form();" action="<?php echo(CATSUtility::getIndexName()); ?>?m=specialization&amp;a=edit" method="post" autocomplete="off">
                <input type="hidden" name="postback" id="postback" value="postback" />
                <input type="hidden" id="candidateID" name="candidateID" value="<?php echo($this->candidateID); ?>" />
                <input type="hidden" name="skill_values" id="skill_values" value="<?php echo($this->skill_values); ?>" />
                <input type="hidden" name="skillyear_values" id="skillyear_values" value="<?php echo($this->skillyear_values); ?>" />
                <input type="hidden" name="skillprof_values" id="skillprof_values" value="<?php echo($this->skillprof_values); ?>" />
                <table border="0" cellpadding="1" cellspacing="5">
                <tr>
                	<td align="left" valign="middle"><span class="colheader">Specialization/Role</span></td>
                    <td align="left" valign="middle"><span class="colheader">Years of Experience</span></td>
                    <td align="left" valign="middle"><span class="colheader">Proficiency/Usage</span></td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                	<td align="left" valign="middle"><input type="text" style="width: 200px;" onKeyPress="return disableEnterKey(event);" value="" id="CityAjax" class="commonstyle"/></td>
                    <td align="left" valign="middle"><select name="years" id="years" class="commonstyle">
                    	<option value="" selected>(Not Specified)</option>
                        <option value="<1"><1</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
                        <option value="7">7</option>
                        <option value="8">8</option>
                        <option value="9">9</option>
                        <option value="10">10</option>
                        <option value="11">11</option>
                        <option value="12">12</option>
                        <option value="13">13</option>
                        <option value="14">14</option>
                        <option value="15">15</option>
                        <option value="16">16</option>
                        <option value="17">17</option>
                        <option value="18">18</option>
                        <option value="19">19</option>
                        <option value="20+">20+</option>
                    </select></td>
                    <td align="left" valign="middle"><select name="level" id="level" class="commonstyle">
                    	<option value="" selected>(Not Specified)</option>                        
                        <option value="Beginner">Beginner</option>
                        <option value="Intermediate">Intermediate</option>
                        <option value="Advanced">Advanced</option>
                        <option value="Expert">Expert</option>
                        <option value=" ">-----</option>
                        <option value="Seldom">Seldom Used</option>
                        <option value="Often">Often Used</option>                        
                    </select></td>
                    <td align="left" valign="middle"><input type="button" value="Add"  onClick="javascript:add_skill('','','', false);" class="button"></td>
                </tr>                
                </table>
                <div class="skillbox">
                    <ul id="sortable">
                        <!-- 
                        <li class="ui-state-default" id="skill_1"><span id="skilltext_1" style="cursor:pointer">Visual Basic</span><div class="closebtn"><a href="javascript:remove_skill('skill_1');">X</a></div></li>
                        <li class="ui-state-default" id="skill_2"><span id="skilltext_2" style="cursor:pointer">PHP</span><div class="closebtn"><a href="javascript:remove_skill('skill_2');">X</a></div></li>
                        <li class="ui-state-default" id="skill_3"><span id="skilltext_3" style="cursor:pointer">Java</span><div class="closebtn"><a href="javascript:remove_skill('skill_3');">X</a></div></li>
                        -->
                    </ul>
                </div>
                <div style="clear:both"></div>
                <div class="controlbox">
                    <input type="submit" tabindex="22" class="button" name="submit" id="submit" value="Save"/>&nbsp;
                    <!-- <input type="reset"  tabindex="23" class="button" name="reset"  id="reset"  value="Reset" />&nbsp; -->                
                </div>
            </form>			
            <script type="text/javascript">		
			      var default_skill_count = 0;
				  
				  function submit_form() {
					var main_list = document.getElementById("sortable");
					var list_items = main_list.childNodes;
					var skill_spacer = "&spc;";
					var cnt=0;
					var final_val_skills = "";
					var final_val_years = "";
					var final_val_profs = "";
					
					for(i=0; i<list_items.length; i++) {
						if(list_items[i].tagName == "LI") {
							cnt++;
							skill_index = list_items[i].id.split("_")[1];
							skill_text = $("#skilltext_"+skill_index).text();
							skill_prof = $("#skillprof_"+skill_index).val();
							skill_year = $("#skillyear_"+skill_index).val();

							if(cnt > 1) {
								final_val_skills = final_val_skills + (skill_spacer + skill_text);
								final_val_years  = final_val_years  + (skill_spacer + skill_year);
								final_val_profs  = final_val_profs  + (skill_spacer + skill_prof);
							} else {
								final_val_skills = final_val_skills + (skill_text);
								final_val_years  = final_val_years  + (skill_year);
								final_val_profs  = final_val_profs  + (skill_prof);
							}							
						}
					}  
					$("#skill_values").val(final_val_skills);
					$("#skillyear_values").val(final_val_years);
					$("#skillprof_values").val(final_val_profs);
					//alert($("#skill_values").val());
					return true;
				  }
				 
				  function disableEnterKey(e) {
					 var key;
					 if(window.event)
						  key = window.event.keyCode;     //IE
					 else
						  key = e.which;     //firefox
					 if(key == 13) {
						add_skill('','','', false);						
						return false;
					 } else
						return true;
				  }				  
				  
				  function skill_exists(skill_text) {
					var result = false;
					var main_list = document.getElementById("sortable");
					var list_items = main_list.childNodes;
					for(i=0; i<list_items.length; i++) {
						if(list_items[i].tagName == "LI") {
							skill_index = list_items[i].id.split("_")[1];
							if($("#skilltext_"+skill_index).text().toLowerCase() == skill_text.toLowerCase()) {
								result = true;	
							}
						}
					}
					return result;
				  }
				  
				  function load_saved_skills() {
					  var saved_skill_text = $("#skill_values").val(); 
					  var saved_skill_year = $("#skillyear_values").val(); 
					  var saved_skill_prof = $("#skillprof_values").val(); 
					  
					  if(saved_skill_text.length == 0) return false;
					  
					  var skill_text_arr = saved_skill_text.split(",");
					  var skill_year_arr = saved_skill_year.split(",");
					  var skill_prof_arr = saved_skill_prof.split(",");
					  
					  for(xi=0; xi<skill_text_arr.length; xi++) {						  
						  add_skill(skill_text_arr[xi], skill_year_arr[xi], skill_prof_arr[xi], true);
					  }
				  }
				  	
				  function add_skill(param_skill_text, param_skill_year, param_skill_prof, load_init) {
					  //create the ff. item
					  if(load_init == false) {
						  var skill_text = $("#CityAjax").val(); 
						  var skill_year = $("#years").val(); 
						  var skill_prof = $("#level").val(); 
					  } else {
						  var skill_text = param_skill_text; 
						  var skill_year = param_skill_year; 
						  var skill_prof = param_skill_prof; 						  
					  }
					  
					  if(skill_text.length = 0) return false;
					  if(skill_exists(skill_text)==true) {
						alert("Skill already exists");
						return false;  
					  }
					  $('#sortable').append('<li class="ui-state-default" id="skill_'+default_skill_count+'">' +
						   					'<span id="skilltext_'+default_skill_count+'" style="cursor:pointer">'+skill_text+'</span>' +
						   					'<input type="hidden" id="skillyear_'+default_skill_count+'" name="skillyear_'+default_skill_count+'" value="">' +
						   					'<input type="hidden" id="skillprof_'+default_skill_count+'" name="skillprof_'+default_skill_count+'" value="">' +
						   					'<div class="closebtn"><a href="javascript:remove_skill(\'skill_'+default_skill_count+'\',\'skilltext_'+default_skill_count+'\');">X</a></div>' +
											'</li>');	
					  $("#skillyear_"+default_skill_count).val(skill_year);
					  $("#skillprof_"+default_skill_count).val(skill_prof);
					  init_sortable();				  					  
					  $("#skilltext_"+default_skill_count).editable(function(value, settings){
						  												//level_
																		//years_																		
																		//var sel_pref = $("#level_"+default_skill_count).val();
																		//var sel_year = $("#years_"+default_skill_count).val();
																		//$("#skillyear_"+default_skill_count).val(sel_year);
																		//$("#skillprof_"+default_skill_count).val(sel_pref);																		
						  												return(value);
																	}, { 						  
						  tooltip   : "Click to edit...",
						  style  	: "inherit",
						  submit	: 'OK',
						  cancel	: 'Cancel',
						  onblur	: 'ignore'
					  }); 
					  default_skill_count++;
					  if(load_init == false) {
						  $("#CityAjax").val('');
						  $("#years").val('');
						  $("#level").val('');
					  }
				  }
				  
				  function remove_skill(skill_item_id, skilltext_item_id) {
					try {
					   close_balloon(skill_item_id);				  
					} catch (err) {
					   //ignore	
					}
					$('#'+skill_item_id).remove();						   
				  }
				  
				  function findValue(li) {
					if( li == null ) return alert("No match!");				
					// if coming from an AJAX call, let's use the CityId as the value
					if( !!li.extra ) var sValue = li.extra[0];				
					// otherwise, let's just display the value in the text box
					else var sValue = li.selectValue;				
					//alert("The value you selected was: " + sValue);
				  }
				
				  function selectItem(li) {
					findValue(li);
				  }
				
				  function formatItem(row) {
					//return row[0] + " (id: " + row[1] + ")";
					return row[0];
				  }
				
				  function lookupAjax(){
					var oSuggest = $("#CityAjax")[0].autocompleter;
					oSuggest.findValue();
					return false;
				  }
				
				  function lookupLocal(){
					var oSuggest = $("#CityLocal")[0].autocompleter;				
					oSuggest.findValue();				
					return false;
				  }				  
				  
				  $("#CityAjax").autocomplete(
					  "<?php echo(CATSUtility::getIndexName()); ?>?m=specialization&a=getlookupvalues",
					  {
							delay:10,
							minChars:2,
							matchSubset:1,
							matchContains:1,
							cacheLength:10,
							onItemSelect:selectItem,
							onFindValue:findValue,
							formatItem:formatItem,
							autoFill:true
						}
				  );  
				  
				  function close_balloon(skill_id) {
					  $('#'+skill_id).hideBalloon();					  
				  }
				  
				  function is_selected(strvalue, strcurrent) {
					  result = "";
					  if(strvalue == strcurrent)
					  	result = " selected = \"selected\" ";
					  return result;
				  }
				  
				  function pref_update(selobj) {
					  var skill_index = selobj.id.split("_")[2];
					  $("#skillprof_"+skill_index).val($("#"+selobj.id).val());					  
				  }
				  
				  function year_update(selobj) {
					  var skill_index = selobj.id.split("_")[2];
					  $("#skillyear_"+skill_index).val($("#"+selobj.id).val());					  
				  }
				  
				  function skill_popup(skill_id) {
					  var skill_index = skill_id.split("_")[1];
					  
					  var sel_pref = $("#skillprof_"+skill_index).val();
					  var sel_year = $("#skillyear_"+skill_index).val();
			  													
					  result = '<div class="balloondiv"><div class="close_dialog"><a href="javascript:close_balloon(\''+skill_id+'\');">X</a></div>'+
					  		   '<span class="commonstyle">Proficiency</span><br>'+
					           '<select onchange="javascript:pref_update(this);" name="level_'+skill_id+'" id="level_'+skill_id+'" class="commonstyle" onClick="return prevent_click_bubble(event);">'+
		                    	'<option '+is_selected(sel_pref,'')+' value="">(Not Specified)</option>'+                     
		                        '<option '+is_selected(sel_pref,'Beginner')+' value="Beginner">Beginner</option>'+
                        		'<option '+is_selected(sel_pref,'Intermediate')+' value="Intermediate">Intermediate</option>'+
                        		'<option '+is_selected(sel_pref,'Advanced')+' value="Advanced">Advanced</option>'+
                        		'<option '+is_selected(sel_pref,'Expert')+' value="Expert">Expert</option>'+
                        		'<option '+is_selected(sel_pref,' ')+' value=" ">-----</option>'+
                        		'<option '+is_selected(sel_pref,'Seldom')+' value="Seldom">Seldom Used</option>'+
                        		'<option '+is_selected(sel_pref,'Often')+' value="Often">Often Used</option>'+                    
                    			'</select>'+ 
								'<br>'+
					           '<span class="commonstyle">Years of Experience</span><br>'+
							   '<select onchange="javascript:year_update(this);" name="years_'+skill_id+'" id="years_'+skill_id+'" class="commonstyle">'+
								'<option '+is_selected(sel_year,'')+' value="">(Not Specified)</option>'+
								'<option '+is_selected(sel_year,'<1')+' value="<1"><1</option>'+
								'<option '+is_selected(sel_year,'1')+' value="1">1</option>'+
								'<option '+is_selected(sel_year,'2')+' value="2">2</option>'+
								'<option '+is_selected(sel_year,'3')+' value="3">3</option>'+
								'<option '+is_selected(sel_year,'4')+' value="4">4</option>'+
								'<option '+is_selected(sel_year,'5')+' value="5">5</option>'+
								'<option '+is_selected(sel_year,'6')+' value="6">6</option>'+
								'<option '+is_selected(sel_year,'7')+' value="7">7</option>'+
								'<option '+is_selected(sel_year,'8')+' value="8">8</option>'+
								'<option '+is_selected(sel_year,'9')+' value="9">9</option>'+
								'<option '+is_selected(sel_year,'10')+' value="10">10</option>'+
								'<option '+is_selected(sel_year,'11')+' value="11">11</option>'+
								'<option '+is_selected(sel_year,'12')+'  value="12">12</option>'+
								'<option '+is_selected(sel_year,'13')+' value="13">13</option>'+
								'<option '+is_selected(sel_year,'14')+' value="14">14</option>'+
								'<option '+is_selected(sel_year,'15')+' value="15">15</option>'+
								'<option '+is_selected(sel_year,'16')+' value="16">16</option>'+
								'<option '+is_selected(sel_year,'17')+' value="17">17</option>'+
								'<option '+is_selected(sel_year,'18')+' value="18">18</option>'+
								'<option '+is_selected(sel_year,'19')+' value="19">19</option>'+
								'<option '+is_selected(sel_year,'20+')+' value="20+">20+</option></select>'+
								'<br></div>';
					  return result;
				  }
				  
				  function init_sortable() {
					$("#sortable").sortable({
						revert: true,
						cursor: 'pointer',
						helper: 'clone'
					});
					$("#draggable").draggable({
						connectToSortable: "#sortable",
						helper: "clone",
						revert: "invalid",
						cursor: "pointer"												
					});					
					$("#sortable").disableSelection();					  
				  }
				  
				  $(function() {
					init_sortable();					
					load_saved_skills();
					//initialize text edits
					/*
					$("#skilltext_1").editable(function(value, settings){return(value);}, { 						  
						  tooltip   : "Click to edit...",
						  style  	: "inherit",
						  submit	: 'OK'
					  }); 
					$("#skilltext_2").editable(function(value, settings){return(value);}, { 						  
						  tooltip   : "Click to edit...",
						  style  	: "inherit",
						  submit	: 'OK'
					  });
					$("#skilltext_3").editable(function(value, settings){return(value);}, { 						  
						  tooltip   : "Click to edit...",
						  style  	: "inherit",
						  submit	: 'OK'
					  }); */					  
				  });		
				  
				  		  				               
            </script>
        </div>
    </div>
    <div id="bottomShadow"></div>
<?php TemplateUtility::printFooter(); ?>
