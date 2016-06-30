<?php /* $Id: Search.tpl 3813 2007-12-05 23:16:22Z brian $ */ ?>
<?php TemplateUtility::printHeader('Candidates', array('js/jquery/js/jquery-1.7.1.min.js', 'modules/candidates/validator.js', 'js/searchSaved.js', 'js/sweetTitles.js', 'js/searchAdvanced.js', 'js/highlightrows.js', 'js/export.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active); ?>
    <div id="main">
        <?php TemplateUtility::printQuickSearch(); ?>
        <div id="contents">
        	<style>
				.cfield {
					font-family:Arial, Helvetica, sans-serif;
					font-weight: bold;
					font-size: 12px;
					color: #000;
					text-decoration: underline;
				}
				
				.coperator {
					font-family:Arial, Helvetica, sans-serif;
					font-weight: normal;
					font-size: 12px;
					color: #666;
					text-decoration: none;					
				}
				
				.cvalue{
					font-family:Arial, Helvetica, sans-serif;
					font-weight: normal;
					font-size: 12px;
					color: #00F;
					text-decoration: underline;
					font-style: italic;
				}
			</style>
        	<script language="javascript">
			var resume_keywords_added = false;
			
			function edit_filter() {
				if($("select#query_list option:selected").length == 1) {
					orig_text = $("#query_list").val();
					var edited_text = prompt("Edit Filter", orig_text);					
					if(edited_text) {
						if(edited_text.length > 0)
							$("select#query_list option:selected").each(function(i, option){ 
								$(option).val(edited_text);
								$(option).text(edited_text);
								return;
							});
						else
							alert("Filter can not be empty");
					}
				} else {
					alert("Select a single filter line to edit.");
				}
			}
			
			function delete_query() {				
				if($("select#query_list option:selected").length == 1) {					
						var remove_buddy_index = -1;
						$("select#query_list option").each(function(i, option){ 					
						  if($(option).attr('selected')) {
							if($.trim($(option).text())=="AND" || $.trim($(option).text())=="OR") {
								remove_buddy_index = i;
							} else if(i==0) {
								remove_buddy_index = i;
							} else {
								remove_buddy_index = i-1;
							}
							$(this).remove();
							return;
						  }
						});		
						if(remove_buddy_index > -1) {
							$("select#query_list option").each(function(i, option){ 
								if(i==remove_buddy_index) $(option).remove();
							});
						}
				} else {
					alert("Select a single filter line to delete.");
				}
			}
			
			function enclose_parenthesis() {
				var start_index = -1;
				var end_index = -1;
				if($("select#query_list option:selected").length > 1) {					
					$("select#query_list option").each(function(i, option){ 					
					  if($(option).attr('selected')) {
						if(start_index == -1) {
							if($.trim($(option).text())=="AND" || $.trim($(option).text())=="OR")
								start_index = i+1;
							else
								start_index = i;
						} else {
							if($.trim($(option).text())=="AND" || $.trim($(option).text())=="OR")
								end_index = i-1;
							else
								end_index = i;
						}
					  }
					});
					var query_lines = new Array();
					var combined_line = "";
					var main_index = -1;
					$("select#query_list option").each(function(i, option){
						if(i>=start_index && i<=end_index) {
							if(i==start_index) combined_line = "(";
							combined_line += (" "+$.trim($(option).text())+" ");
							if(i==end_index) {
								combined_line += ")";
								main_index++;
								query_lines[main_index] = combined_line;	
							}
						} else {
							main_index++;
							query_lines[main_index] = $(option).text();
						}
					});
					$("#query_list").empty();
					for(i=0; i<query_lines.length; i++) {
						$("#query_list").append('<option value=\''+query_lines[i]+'\'>'+query_lines[i]+'</option>');
					}
				} else {
					alert("Select 2 or more filters to combine (hold Ctrl key while clicking to select)");
				}
			}
			
			function search_change() {
				var filter_by 	= $("#searchMode").val();				
				if(filter_by.toLowerCase() == "searchbylocation") {
					$("#div_location_search").show().css({'display':'inline-block'});
					$("#div_normal_search").hide();
					$("#div_numeric_search").hide();
					$("#div_specialization_search").hide();
					$("#div_preferred_terms_search").hide();
					$("#div_communication_search").hide();
					$("#div_cr_classification_search").hide();
					$("#div_jobzone_search").hide();
					$("#searchTextLoc").focus();
				} else if(filter_by.toLowerCase() == "searchbydateavailable") {
					$("#div_location_search").hide();
					$("#div_normal_search").hide();
					$("#div_specialization_search").hide();
					$("#div_preferred_terms_search").hide();
					$("#div_communication_search").hide();
					$("#div_cr_classification_search").hide();
					$("#div_jobzone_search").hide();
					$("#div_normal_search").hide();
					$("#div_numeric_search").show().css({'display':'inline-block'});
					$("#searchNumericValue").focus();
				} else if(filter_by.toLowerCase() == "searchbypreferredterms") {
					$("#div_location_search").hide();
					$("#div_normal_search").hide();
					$("#div_specialization_search").hide();
					$("#div_preferred_terms_search").show().css({'display':'inline-block'});
					$("#div_communication_search").hide();
					$("#div_cr_classification_search").hide();
					$("#div_jobzone_search").hide();
					$("#div_normal_search").hide();
					$("#div_numeric_search").hide();
					$("#searchNumericValue").focus();
				} else if(filter_by.toLowerCase() == "searchbycrclassification") {
					$("#div_location_search").hide();
					$("#div_normal_search").hide();
					$("#div_specialization_search").hide();
					$("#div_preferred_terms_search").hide();
					$("#div_communication_search").hide();
					$("#div_cr_classification_search").show().css({'display':'inline-block'});
					$("#div_jobzone_search").hide();
					$("#div_normal_search").hide();
					$("#div_numeric_search").hide();
					$("#searchNumericValue").focus();
				} else if(filter_by.toLowerCase() == "searchbyjobzone") {
					$("#div_location_search").hide();
					$("#div_normal_search").hide();
					$("#div_specialization_search").hide();
					$("#div_preferred_terms_search").hide();
					$("#div_communication_search").hide();
					$("#div_cr_classification_search").hide();
					$("#div_jobzone_search").show().css({'display':'inline-block'});
					$("#div_normal_search").hide();
					$("#div_numeric_search").hide();
					$("#searchNumericValue").focus();
				} else if(filter_by.toLowerCase() == "searchbycommunication") {
					$("#div_location_search").hide();
					$("#div_specialization_search").hide();
					$("#div_preferred_terms_search").hide();
					$("#div_communication_search").show().css({'display':'inline-block'});
					$("#div_cr_classification_search").hide();
					$("#div_jobzone_search").hide();
					$("#div_normal_search").hide();
					$("#div_numeric_search").hide();
					$("#searchNumericValue").focus();
				} else if(filter_by.toLowerCase() == "searchbykeyskills") {
					$("#div_location_search").hide();
					/*Edit By CLifton*/
					$("#div_specialization_search").hide();
					//$("#div_specialization_search").show().css({'display':'inline-block'});
					$("#div_preferred_terms_search").hide();
					$("#div_communication_search").hide();
					$("#div_cr_classification_search").hide();
					$("#div_jobzone_search").hide();
					$("#div_normal_search").show().css({'display':'inline-block'});//.hide();
					$("#div_numeric_search").hide();
					$("#searchNumericValue").hide();
					$("#searchText").focus();
				} else {
					$("#div_specialization_search").hide();
					$("#div_preferred_terms_search").hide();
					$("#div_communication_search").hide();
					$("#div_cr_classification_search").hide();
					$("#div_jobzone_search").hide();
					$("#div_location_search").hide();
					$("#div_numeric_search").hide();
					$("#div_normal_search").show().css({'display':'inline-block'});
					$("#searchText").focus();
				}
			}
			
			function add_filterx() {
				var append_as 	= $("#append_as").val();
				var filter_by 	= $("#searchMode").val();
				var filter_text = $("#searchText").val();
				var actual_query = "";	
				var display_query = "";	
				
				var resume_keyword_filter = false;
				var search_by_loc = false;
				var search_by_num = false;
				
				switch(filter_by.toLowerCase()) {
					case "searchbydateavailable":
						search_by_num = true;
						var operator_value = $.trim($("#search_numeric_operator").val());
						var numeric_value = $("#searchNumericValue").val();
						/*
						if(isNaN(numeric_value)==true) {
							alert("Please enter a valid numeric value");
							$("#numeric_value").focus();
							return false;	
						}
						*/
						actual_query = "[DATE AVAILABLE] IS "+ operator_value +" \""+numeric_value+"\"";
						break;
						
					case "searchbylocation":						
						search_by_loc = true;
						var distance = $.trim($("#searchTextLoc").val());
						var distance_unit = $("#search_location_distance").val();
						var zip_code = $.trim($("#searchTextLocZip").val());
						
						if(isNaN(distance)==true || distance.length==0) {
							alert("Please enter a valid radius/distance");
							$("#searchTextLoc").focus();
							return false;	
						}						
						if(zip_code.length < 4) {
							alert("Please enter a valid Zip Code");
							$("#searchTextLocZip").focus();
							return false;	
						}
						if(parseInt(distance)>500 && distance_unit == "miles") {
							alert("Proximity search can't exceed 500 miles");
							$("#searchTextLoc").focus();
							return false;	
						}
						if(parseInt(distance)>800 && distance_unit == "kilometers") {
							alert("Proximity search can't exceed 800 kilometers");
							$("#searchTextLoc").focus();
							return false;	
						}
						actual_query = "[LOCATION] Is Within "+distance+" "+distance_unit+" From ZIP Code \""+zip_code+"\"";
						break;
					case "searchbycity":						
						actual_query = "[CITY] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbystate":						
						actual_query = "[STATE] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbycountry":						
						actual_query = "[COUNTRY] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbycurrentemployer":						
						actual_query = "[CURRENT EMPLOYER] Contains The Word \""+filter_text+"\"";
						break;
					case "phonenumber":						
						actual_query = "[PHONE] Contains The Word \""+filter_text+"\" ";                        
						break;
					
					case "searchbypreferredterms":					
						filter_text = $.trim($("#search_preferred_terms").val());
						actual_query = "[PREFERRED TERMS] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbycrclassification":					
						filter_text = $.trim($("#search_cr_classification").val());
						actual_query = "[CR CLASSIFICATION] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbyeligibility":						
						actual_query = "[ELIGIBILITY] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbyjobzone":						
						filter_text = $.trim($("#search_jobzone").val());
						actual_query = "[TARGET JOB ZONE] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbycommunication":				
						filter_text = $.trim($("#search_communication_skill").val());
						actual_query = "[COMMUNICATION] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbykeyskills":					
						//filter_text = $.trim($("#specialization_skill").val());
						//filter_role = $.trim($("#search_roles").val());
						//actual_query = "[KEY SKILLS] Contains The Word \""+filter_text+"\" with roles of \""+filter_role+"\"";
						
						actual_query = "[KEY SKILLS] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbycompany":						
						actual_query = "[COMPANY] Contains The Word \""+filter_text+"\"";
						resume_keyword_filter = true;
						break;
					case "searchbyresume":						
						actual_query = "[RESUME ATTACHMENT] Contains The Word \""+filter_text+"\"";
						resume_keyword_filter = true;
						break;
					case "searchbyfullname":						
						actual_query = "[FULL NAME] Contains The Word \""+filter_text+"\" ";                		
						break;
				}				
				if($("select#query_list option").length > 0) {
					if(resume_keyword_filter == true) {
						if(resume_keywords_added == false) {							
							$("#query_list").append('<option value="'+append_as+'">'+append_as+'</option>');
						} else {
							$("#query_list").append('<option value="'+append_as+'">'+append_as+'</option>');
						}
					} else {
						if(resume_keywords_added == true && resume_keyword_filter == false) {
							$("#query_list").append('<option value="'+append_as+'">'+append_as+'</option>');
						} else
							$("#query_list").append('<option value="'+append_as+'">'+append_as+'</option>');
					}
				}
				$("#query_list").append('<option value=\''+actual_query+'\'>'+actual_query+'</option>');
				if(search_by_loc == false && search_by_num == false)
					$("#searchText").val("");		
				else if(search_by_loc == true) {
					$("#searchTextLoc").val("");
					$("#searchTextLocZip").val("");
					$("#searchTextLoc").focus();
				} else {
					$("#searchNumericValue").val("");
					$("#searchNumericValue").focus();
				}
				if(resume_keyword_filter == true) resume_keywords_added = true;
			}
			
			function clear_query() {
					$("#query_list").empty();
					resume_keywords_added = false;
			}
			
			function disableEnterKey(e) {
				 var key;
				 if(window.event)
					  key = window.event.keyCode;     //IE
				 else
					  key = e.which;     //firefox
				 if(key == 13) {
					add_filterx();						
					return false;
				 } else
					return true;
			}
			
			function disableEnterKeyLoc(e) {
				 var key;
				 if(window.event)
					  key = window.event.keyCode;     //IE
				 else
					  key = e.which;     //firefox
				 if(key == 13) {
					$("#searchTextLocZip").focus();					
					return false;
				 } else
					return true;
			}
			
			function disableEnterKeyLocZip(e) {
				 var key;
				 if(window.event)
					  key = window.event.keyCode;     //IE
				 else
					  key = e.which;     //firefox
				 if(key == 13) {
					add_filterx();						
					return false;
				 } else
					return true;
			}
			
			function form_submit() {
				$("select#query_list option").each(function(i, option){ 					
					$(option).attr('selected','selected');
				});
				return true;
				
			}
			</script>
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Candidates: Search Candidates</h2></td>
                </tr>
            </table>

            <p class="note">Search Candidates</p>

            <table class="searchTable" id="searchTable ">
                <tr>
                    <td>
                        <form name="searchForm" id="searchForm" onsubmit="form_submit();" action="<?php echo(CATSUtility::getIndexName()); ?>#searchtop" method="get" autocomplete="off">
                            <input type="hidden" name="m" id="moduleName" value="candidates" />
                            <input type="hidden" name="a" id="moduleAction" value="search" />
                            <input type="hidden" name="getback" id="getback" value="getback" />

                            <?php TemplateUtility::printSavedSearch($this->savedSearchRS); ?>
							
                            <table border="0" width="800px" cellpadding="5" cellspacing="10">
                            <tr>
                            	<td align="left" valign="top" width="700px" style="border:1px solid #ccc">
                                    <!-- <label id="searchModeLabel" for="query_list">Query</label>&nbsp; -->                                    
                                    <input type="button" class="button" id="enclose_query" name="enclose_query" value="Combine Selected Filters" onclick="enclose_parenthesis();" />&nbsp;
                                    <input type="button" class="button" id="edit_query" name="edit_query" value="Edit Selected Filter" onclick="edit_filter();" />&nbsp;
                                    <input type="button" class="button" id="remove_query" name="remove_query" value="Delete Selected Filter" onclick="delete_query();" />&nbsp;
                                    <input type="button" class="button" id="removeall_query" name="removeall_query" value="Clear All Filters" onclick="clear_query();" />&nbsp;
                                    <br /><br />
                                    <select id="query_list"  name="query_list[]" multiple="multiple" ondblclick="edit_filter();" style="border:1px solid #ccc; width:100%; height:175px; font-size:12px">                            	
                                    <?php for($i=0; $i<count($this->query_array); $i++) { ?>
                                       <option value='<?php echo($this->query_array[$i]);?>'><?php echo($this->query_array[$i]);?></option>
                                    <?php } ?>
                                    </select>
                                    <br /><br />   
                                    <div style="display:inline-block; vertical-align:top">                         
                                        <label id="searchModeLabel" for="searchMode">Filter:</label>&nbsp;
                                        <select id="append_as" name="append_as" class="selectBox">
                                            <option value="AND">append with AND</option>
                                            <option value="OR">append with OR</option>
                                        </select>                                        
                                    </div>&nbsp;
                                    <!-- <select id="searchMode" name="mode" onclick="advancedSearchConsider();" class="selectBox"> -->
                                    <div style="display:inline-block; vertical-align:top">
                                        <select id="searchMode" name="mode" class="selectBox" onchange="search_change();">
                                        	<option value="searchByResume" selected="selected">Resume Keywords</option>
                                            <option value="searchByFullName">Candidate Name</option>                                        
                                            <option value="searchByKeySkills">Key Skills</option>
                                            <option value="phoneNumber">Phone Number</option>
                                            <option value="searchByCity">City</option>
                                            <option value="searchByState">State</option>
                                            <option value="searchByCountry">Country</option>                                            
                                            <option value="searchByLocation">Location</option>
                                            <option value="searchByCurrentEmployer">Current Employer</option>
                                            <!--<option value="searchByCompany">Company</option>-->
                                            <option value="searchByEligibility">Eligibility</option>
                                            <option value="searchByJobZone">Target Job Zone</option>
                                            <option value="searchByCommunication">Communication</option>
                                            <option value="searchByCRClassification">CR Classification</option>
                                            <option value="searchByPreferredTerms">Preferred Terms</option>
                                            <option value="searchByDateAvailable">Date Available</option>
                                        </select>&nbsp;
                                        <div style="display:inline-block; border:2px solid #333; background-color:#eee" id="div_normal_search">
                                            <input type="text" class="inputbox" id="searchText" name="wildCardString" value="<?php if (!empty($this->wildCardString)) $this->_($this->wildCardString); ?>" style="width:150px" onKeyPress="return disableEnterKey(event);" />&nbsp;*&nbsp;
                                            <input type="button" class="button" id="add_filter" name="add_filter" value="Add Filter" onclick="add_filterx();" />                                
                                        </div>   
                                        <div style="display:none; border:2px solid #333; background-color:#eee" id="div_cr_classification_search">
                                            <select id="search_cr_classification" name="search_cr_classification" class="selectBox">
                                                <option value="Racetrack Star">Racetrack Star</option>
                                                <option value="Target Driver">Target Driver</option>
                                                <option value="Pit Crew">Pit Crew (Worth Interviewing)</option>
                                                <option value="Not Recommended">Not Recommended</option>
                                                <option value="Not Reachable">Not Reachable</option>
                                                <option value="Blacklisted">Blacklisted</option>
											</select>
                                            <input type="button" class="button" id="add_filter" name="add_filter" value="Add Filter" onclick="add_filterx();" />
                                        </div>   
                                        <div style="display:none; border:2px solid #333; background-color:#eee" id="div_jobzone_search">
											<select id="search_jobzone" name="search_jobzone" class="selectBox">
												<option value="Lower Mainland">Lower Mainland</option>
												<option value="Calgary">Calgary</option>
												<option value="Edmonton">Edmonton</option>
												<option value="GTA">GTA</option>
												<option value="Montreal">Montreal</option>
												<option value="Will Travel">Will Travel</option>
											</select>
											<input type="button" class="button" id="add_filter" name="add_filter" value="Add Filter" onclick="add_filterx();" />
                                        </div>   
                                        <div style="display:none; border:2px solid #333; background-color:#eee" id="div_preferred_terms_search">
                                            <select id="search_preferred_terms" name="search_preferred_terms" class="selectBox">
                                                <option value="Contract">Contract</option>
                                                <option value="Staff">Staff</option>
                                                <option value="Either">Either</option>
											</select>
                                            <input type="button" class="button" id="add_filter" name="add_filter" value="Add Filter" onclick="add_filterx();" />
                                        </div>   
                                        <div style="display:none; border:2px solid #333; background-color:#eee" id="div_specialization_search">
                                            <select id="search_roles" name="search_roles" class="selectBox">
                                                <option value="Application Support">Application Support</option>
                                                <option value="Architecture">Architecture</option>
                                                <option value="Business Analysis">Business Analysis</option>
                                                <option value="Business Intel & Reporting">Business Intel & Reporting</option>
                                                <option value="Call Center">Call Center</option>
                                                <option value="Databases (DBA, etc)">Databases (DBA, etc)</option>
                                                <option value="ERP">ERP</option>
                                                <option value="GIS">GIS</option>
                                                <option value="Help Desk/Entry Level">Help Desk/Entry Level</option>
                                                <option value="Management Consultant">Management Consultant</option>
                                                <option value="Network and Infrastructure">Network and Infrastructure</option>
                                                <option value="Project & Program Management">Project & Program Management</option>
                                                <option value="Quality Assurance/Testing">Quality Assurance/Testing</option>
                                                <option value="Tech Writing/Multimedia/Training">Tech Writing/Multimedia/Training</option>
                                                <option value="Web & Software Development">Web & Software Development</option>
											</select>
                                            <input type="text" class="inputbox" id="specialization_skill" name="wildCardString" value="<?php if (!empty($this->wildCardString)) $this->_($this->wildCardString); ?>" style="width:150px" onKeyPress="return disableEnterKey(event);" />&nbsp;*&nbsp;
                                            <input type="button" class="button" id="add_filter" name="add_filter" value="Add Filter" onclick="add_filterx();" />
                                        </div>   
                                        <div style="display:none; border:2px solid #333; background-color:#eee" id="div_communication_search">
                                            <select id="search_communication_skill" name="search_location_distance" class="selectBox">
                                                <option value="Articulate">Articulate</option>
                                                <option value="Clear English">Clear English</option>
                                                <option value="Accented">Accented (but understandable)</option>
                                                <option value="Not Acceptable">Not Acceptable</option>
                                            </select>&nbsp;
                                            <input type="button" class="button" id="add_filter" name="add_filter" value="Add Filter" onclick="add_filterx();" />
                                        </div>   
                                        <div style="display:none; border:2px solid #333; background-color:#eee" id="div_location_search" style="border:1px solid #ccc;">                                            
                                            <!-- 25 miles/kilometers from country, city -->
                                            <input type="text" class="inputbox" size="3" id="searchTextLoc" name="wildCardStringLoc" value="" style="width:30px" onKeyPress="return disableEnterKeyLoc(event);" />&nbsp;
                                            <select id="search_location_distance" name="search_location_distance" class="selectBox">
                                                <option value="kilometers">kilometers</option>
                                                <option value="miles">miles</option>
                                            </select>&nbsp;
                                            from ZIP&nbsp;
                                            <input type="text" class="inputbox" id="searchTextLocZip" name="wildCardStringLocZip" value="" style="width:60px" onKeyPress="return disableEnterKeyLocZip(event);" />&nbsp;
                                            <input type="button" class="button" id="zip_browse" name="zip_browse" value=">>" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=ziplookup&amp;ajax=0', 350, 250, null); return false;" />
                                            <input type="button" class="button" id="add_filter_loc" name="add_filter_loc" value="Add Filter" onclick="add_filterx();" />
                                        </div>
                                        <div style="display:none; border:2px solid #333; background-color:#eee" id="div_numeric_search" style="border:1px solid #ccc;">                                            
                                            <!-- 25 miles/kilometers from country, city -->
                                            <!-- <input type="text" class="inputbox" size="3" id="searchTextLoc" name="wildCardStringLoc" value="" style="width:30px" onKeyPress="return disableEnterKeyLoc(event);" />&nbsp; --> 
                                            <select id="search_numeric_operator" name="search_numeric_operator" class="selectBox">
                                            	<option value="EQUAL TO">Equal To</option>
                                                <option value="GREATER THAN">Greater Than</option>
                                                <option value="LESSER THAN">Lesser Than</option>
                                            </select>&nbsp;&nbsp;(yyyy-mm-dd)&nbsp;&nbsp;
                                            <input type="text" class="inputbox" id="searchNumericValue" name="searchNumericValue" value="" style="width:60px" onKeyPress="return disableEnterKeyLocZip(event);" />&nbsp;                                            
                                            <input type="button" class="button" id="add_filter_loc" name="add_filter_loc" value="Add Filter" onclick="add_filterx();" />
                                        </div>
                                    </div>
                                </td>
                                <td align="left" valign="top" width="0px" style="border:0px solid #ccc;">
                                     <div style="visibility:hidden">
                                        <!-- hide for the moment -->
                                	 	<label id="searchKeywordWeight" for="">Keyword Weight</label>&nbsp;<br />
                                     </div>
                                </td>
                            </tr>                            
                            </table>    
                            <br /><br />
                            <input type="submit" class="button" id="searchCandidates" name="searchCandidates" value="Search" />                        
                            <?php TemplateUtility::printAdvancedSearch('searchByKeySkills,searchByResume'); ?>
                        </form>
                    </td>
                </tr>
            </table>

            <script type="text/javascript">
                document.searchForm.wildCardString.focus();
            </script>
			<a id="searchtop" name="searchtop"></a>
            <?php if ($this->isResumeMode && $this->isResultsMode): ?>
                <br />
                <?php if (!empty($this->rs)): ?>
                    <p class="note">Search Results &nbsp;<?php $this->_($this->pageStart); ?> to <?php $this->_($this->pageEnd); ?> of <?php $this->_($this->totalResults); ?></p>
                    <?php echo($this->exportForm['header']); ?>
                <?php else: ?>
                    <p class="note">Search Results</p>
                <?php endif; ?>

                <table class="sortable" width="925">
                    <thead>
                        <tr>
                            <th nowrap>&nbsp;</th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('firstName', 'First Name'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('lastName', 'Last Name'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">Resume</th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('city', 'City'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('state', 'State'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('dateCreatedSort', 'Created'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('dateModifiedSort', 'Modified'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('ownerSort', 'Owner'); ?>
                            </th>
                        </tr>
                    </thead>

                    <?php if (!empty($this->rs)): ?>
                        <?php foreach ($this->rs as $rowNumber => $data): ?>
                            <tr class="<?php TemplateUtility::printAlternatingRowClass($rowNumber); ?>">
                                <?php if ($data['candidateID'] > 0): ?>
                                    <td valign="top" nowrap>
                                        <input type="checkbox" id="checked_<?php echo($data['candidateID']); echo($data['attachmentID']); ?>" name="checked_<?php echo($data['candidateID']); ?>" />
                                        <a href="javascript:void(0);" onClick="window.open('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=show&amp;candidateID=<?php $this->_($data['candidateID']); ?>')" title="View in New Window">
                                            <img src="images/new_window.gif" class="abstop" alt="(Preview)" border="0" width="15" height="15" />
                                        </a>
                                        <a href="#" onclick="showPopWin('index.php?m=candidates&amp;a=considerForJobSearch&amp;candidateID=<?php echo($data['candidateID']); ?>', 750, 390, null); return false;">
											<img src="images/consider.gif" width="15" height="15" class="abstop" alt="Add to Pipeline" border="0">
                                        </a>
                                    </td>
                                    <td valign="top">
                                        <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=show&amp;candidateID=<?php $this->_($data['candidateID']); ?>">
                                            <?php $this->_($data['firstName']); ?>
                                        </a>
                                    </td>
                                    <td valign="top">
                                        <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=show&amp;candidateID=<?php $this->_($data['candidateID']); ?>">
                                            <?php $this->_($data['lastName']); ?>
                                        </a>
                                    </td>
                                <?php else: ?>
                                    <td>&nbsp;</td>
                                    <td valign="top" nowrap="nowrap">
                                    </td>
                                    <td valign="top" colspan="2">
                                        <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=add&amp;attachmentID=<?php $this->_($data['attachmentID']); ?>">
                                            <img src="images/candidate_tiny.gif" width="16" height="16" border="0" class="absmiddle" alt="" title="Create Candidate Profile" />
                                        </a>
                                        &nbsp;Bulk Resume
                                    </td>
                                <?php endif; ?>
                                <td valign="top">
                                    <a href="#" onclick="window.open('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=viewResume&amp;wildCardString=<?php $this->_(urlencode($this->wildCardString)); ?>&amp;attachmentID=<?php $this->_($data['attachmentID']); ?>', 'viewResume', 'scrollbars=1,width=700,height=600')">
                                        <img src="images/resume_preview_inline.gif" class="abstop" alt="(Preview)" border="0" width="15" height="15" />
                                    </a>&nbsp;
                                    <?php echo($data['excerpt']); ?>
                                </td>
                                <td valign="top"><?php $this->_($data['city']); ?></td>
                                <td valign="top"><?php $this->_($data['state']); ?></td>
                                <td valign="top"><?php $this->_($data['dateCreated']); ?></td>
                                <td valign="top"><?php $this->_($data['dateModified']); ?></td>
                                <td valign="top" nowrap="nowrap"><?php $this->_($data['ownerAbbrName']); ?>&nbsp;</td>
                            </tr>
                        <?php endforeach; ?>                        
                    <?php else: ?>
                        <tr>
                            <td colspan="8">No matching entries found.</td>
                        </tr>
                    <?php endif; ?>
                </table>
                <?php echo($this->exportForm['footer']); ?>
                <?php echo($this->exportForm['menu']); ?>
                <?php if (!empty($this->rs)): ?>
                    <div style="float: right"><?php $this->pager->printNavigation(); ?></div>
                    <br />
                <?php endif; ?>
                <?php if(count($this->candidateIDArray) > 0) { ?>
                   <div style="display:block">
                    &nbsp;<!--                            	
                     <table border="0" cellpadding="1" cellspacing="1">
                     <tr>
                        <td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                        <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=considerForJobSearch&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>', 750, 390, null); return false;">Add Results to Job Order</a></td>
                     </tr>
                     <tr>
                        <td align="left" valign="middle"><img border="0" src="images/email-icon.png" /></td>
                        <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=emailForJobSearchSelectJob&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>', 750, 390, null); return false;">Email Job Order to Results</a></td>
                     </tr>
                     <tr>
                        <td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                        <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=lists&amp;a=addToListFromDatagridModal&amp;dataItemType=100&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>', 450, 350, null); return false;">Add Results to List</a></td>
                     </tr>
                     </table> -->
                     <table border="0" cellpadding="1" cellspacing="1">
                     <tr>
                        <td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                        <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>'+checkSelected_Parameter('candidates', 'considerForJobSearch', '<?php echo($this->candidateIDArrayStored); ?>'), 750, 390, null); return false;">Add Results to Job Order</a></td>
                     </tr>
                     <tr>
                        <td align="left" valign="middle"><img border="0" src="images/email-icon.png" /></td>
                        <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>'+checkSelected_Parameter('candidates', 'emailForJobSearchSelectJob', '<?php echo($this->candidateIDArrayStored); ?>'), 750, 390, null); return false;">Email Job Order to Results</a></td>
                     </tr>
                     <tr>
                        <td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                        <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>'+checkSelected_Parameter('lists', 'addToListFromDatagridModal', '<?php echo($this->candidateIDArrayStored); ?>'), 450, 350, null); return false;">Add Results to List</a></td>
                     </tr>
                     </table>
                   </div>                             
               <?php } ?>
            <?php elseif ($this->isResultsMode): ?>
                <br />
                <p class="note">Search Results (<?php if(count($this->rs) >= 1000) echo('Greater than '.count($this->rs)); else echo(count($this->rs)); ?>)</p>

                <?php if (!empty($this->rs)): ?>
                    <?php echo($this->exportForm['header']); ?>
                    <table class="sortable" width="100%" onmouseover="javascript:trackTableHighlight(event)">
                        <tr>
                            <th nowrap>&nbsp;</th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('firstName', 'First Name'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('lastName', 'Last Name'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">Key Skills</th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('city', 'City'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('state', 'State'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('dateCreated', 'Created'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('dateModified', 'Modified'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('owner_user.last_name', 'Owner'); ?>
                            </th>
                        </tr>

                        <?php foreach ($this->rs as $rowNumber => $data): ?>
			     			 <tr class="<?php TemplateUtility::printAlternatingRowClass($rowNumber); ?>">
                                <td nowrap>
                                    <input type="checkbox" id="checked_<?php echo($data['candidateID']); ?>" name="checked_<?php echo($data['candidateID']); ?>" />
                                    <a href="javascript:void(0);" onClick="window.open('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=show&amp;candidateID=<?php $this->_($data['candidateID']); ?>')" title="View in New Window">
                                        <img src="images/new_window.gif" class="abstop" alt="(Preview)" border="0" width="15" height="15" />
                                    </a>
                                    <a href="#" onclick="showPopWin('index.php?m=candidates&amp;a=considerForJobSearch&amp;candidateID=<?php echo($data['candidateID']); ?>', 750, 390, null); return false;">
										<img src="images/consider.gif" width="15" height="15" class="abstop" alt="Add to Pipeline" border="0">
                                    </a>
                                </td>
                                <td>
                                    <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=show&amp;candidateID=<?php $this->_($data['candidateID']); ?>">
                                        <?php $this->_($data['firstName']); ?>
                                    </a>
                                </td>
                                <td>
                                    <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=show&amp;candidateID=<?php $this->_($data['candidateID']); ?>">
                                        <?php $this->_($data['lastName']); ?>
                                    </a>
                                </td>
                                <td>
                                    <?php if (isset($data['resumeID'])): ?>
                                        <a href="javascript:void(0);" onclick="window.open('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=viewResume&amp;wildCardString=<?php $this->_(urlencode($this->wildCardString)); ?>&amp;attachmentID=<?php $this->_($data['resumeID']); ?>', 'viewResume', 'scrollbars=1,width=700,height=600')" Title="View resume">
                                            <img src="images/resume_preview_inline.gif" class="abstop" alt="(Preview)" border="0" width="15" height="15" />
                                        </a>
                                    <?php endif; ?>
                                    <?php 
										// $this->_($data['keySkills']); 
										//echo str_replace(':','-',str_replace(',','<br>',$this->_($data['keySkills']))); 
									?>
                                    <?php 
										$dataStrSkills = $data['keySkills'];
										$dataArrSkills = explode(',',$dataStrSkills);
										$sp = '';
										foreach($dataArrSkills as $val){
											if(strpos($val,':') !== false){
												$col = explode(':', $val);
												$specialization = isset($col[0]) ? trim($col[0]) : false;
												$roles = isset($col[1]) ? trim($col[1]) : false;
												$yr = isset($col[2]) ? trim($col[2]) : false;
											} else {
												$specialization = $val;
												$roles = false;
												$yr = false;
											}
											if($sp != $specialization){
												echo '<br><span><i>Specialization: </i></span><h3 style=\'display: inline; width: 600px;\'>'.$specialization.'</h3>';
												$sp = $specialization;
											}
											if($roles){
												echo '<div style=\'padding-left: 30px;\'><u>'.$roles;
											}
											if($roles && $yr){
												echo '</u> - <b>'.$yr.' yr</b></div>';
											} elseif($roles) {
												echo '</u> - <b>Unknown</b></div>';
											}
										}
									?>&nbsp;
                                </td>
                                <td><?php $this->_($data['city']); ?>&nbsp;</td>
                                <td><?php $this->_($data['state']); ?>&nbsp;</td>
                                <td><?php $this->_($data['dateCreated']); ?>&nbsp;</td>
                                <td><?php $this->_($data['dateModified']); ?>&nbsp;</td>
                                <td nowrap="nowrap"><?php $this->_($data['ownerAbbrName']); ?>&nbsp;</td>
                            </tr>
                        <?php endforeach; ?>
                        
                    </table>
                    <?php echo($this->exportForm['footer']); ?>
                    <?php echo($this->exportForm['menu']); ?>
                    <?php if(count($this->candidateIDArray) > 0) { ?>
                           <div style="display:block">
                            &nbsp;                    
                            <!-- old buttons        	
                             <table border="0" cellpadding="1" cellspacing="1">
                             <tr>
                             	<td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                                <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=considerForJobSearch&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>', 750, 390, null); return false;">Add Results to Job Order</a></td>
                             </tr>
                             <tr>
                             	<td align="left" valign="middle"><img border="0" src="images/email-icon.png" /></td>
                                <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=emailForJobSearchSelectJob&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>', 750, 390, null); return false;">Email Job Order to Results</a></td>
                             </tr>
                             <tr>
                             	<td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                                <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=lists&amp;a=addToListFromDatagridModal&amp;dataItemType=100&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>', 450, 350, null); return false;">Add Results to List</a></td>
                             </tr>
                             </table>
                             -->
                             <table border="0" cellpadding="1" cellspacing="1">
                             <tr>
                             	<td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                                <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>'+checkSelected_Parameter('candidates', 'considerForJobSearch', '<?php echo($this->candidateIDArrayStored); ?>'), 750, 390, null); return false;">Add Results to Job Order</a></td>
                             </tr>
                             <tr>
                             	<td align="left" valign="middle"><img border="0" src="images/email-icon.png" /></td>
                                <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>'+checkSelected_Parameter('candidates', 'emailForJobSearchSelectJob', '<?php echo($this->candidateIDArrayStored); ?>'), 750, 390, null); return false;">Email Job Order to Results</a></td>
                             </tr>
                             <tr>
                             	<td align="left" valign="middle"><img border="0" src="images/joborder_add-icon.jpg" /></td>
                                <td align="left" valign="middle"><a href="#" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>'+checkSelected_Parameter('lists', 'addToListFromDatagridModal', '<?php echo($this->candidateIDArrayStored); ?>'), 450, 350, null); return false;">Add Results to List</a></td>
                             </tr>
                             </table>                             
                           </div>                             
                    <?php } ?>
                <?php else: ?>
                    <p>No matching entries found.</p>
                <?php endif; ?>
            <?php endif; ?>
        </div>
    </div>
    <div id="bottomShadow"></div>
<?php TemplateUtility::printFooter(); ?>
