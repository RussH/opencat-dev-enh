<?php /* $Id: Search.tpl 3676 2007-11-21 21:02:15Z brian $ */ ?>
<?php TemplateUtility::printHeader('Companies', array('js/jquery/js/jquery-1.7.1.min.js', 'modules/companies/validator.js', 'js/searchSaved.js', 'js/sweetTitles.js', 'js/searchAdvanced.js', 'js/highlightrows.js', 'js/export.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active, $this->subActive); ?>
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
					$("#div_location_search").show();
					$("#div_normal_search").hide();
					$("#div_numeric_search").hide();
					$("#searchTextLoc").focus();
				} else if(filter_by.toLowerCase() == "searchbyrevenue" || filter_by.toLowerCase() == "searchbyemployees") {
					$("#div_location_search").hide();
					$("#div_normal_search").hide();
					$("#div_numeric_search").show();
					$("#searchNumericValue").focus();
				} else {
					$("#div_location_search").hide();
					$("#div_numeric_search").hide();
					$("#div_normal_search").show();
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
					case "searchbyrevenue":
					case "searchbyemployees":
						search_by_num = true;
						var operator_value = $.trim($("#search_numeric_operator").val());
						var numeric_value = $("#searchNumericValue").val();
						if(isNaN(numeric_value)==true) {
							alert("Please enter a valid numeric value");
							$("#numeric_value").focus();
							return false;	
						}
						if(filter_by.toLowerCase() == "searchbyrevenue") 
							actual_query = "[REVENUE] IS "+ operator_value +" \""+numeric_value+"\"";
						else if(filter_by.toLowerCase() == "searchbyemployees") 
							actual_query = "[EMPLOYEES] IS "+ operator_value +" \""+numeric_value+"\"";
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
					case "searchbynaics":						
						actual_query = "[NAICS] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbyindustry":						
						actual_query = "[INDUSTRY] Contains The Word \""+filter_text+"\"";
						break;		
					/*			
					case "searchbyrevenue":						
						actual_query = "[REVENUE] Contains The Word \""+filter_text+"\"";
						break;
					case "searchbyemployees":						
						actual_query = "[EMPLOYEES] Contains The Word \""+filter_text+"\"";
						break; */
					case "searchbycategory":						
						actual_query = "[CATEGORY] Contains The Word \""+filter_text+"\" ";                		
						break;
					case "searchbyprospecting":						
						actual_query = "[PROSPECTING] Contains The Word \""+filter_text+"\" ";                		
						break;	
					case "searchbykeytechnologies":						
						actual_query = "[KEY TECHNOLOGIES] Contains The Word \""+filter_text+"\" ";                		
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
            <a id="searchtop" name="searchtop"></a>
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/companies.gif" width="24" height="24" border="0" alt="Companies" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Companies: Search Companies</h2></td>
                </tr>
            </table>

            <p class="note">Search Companies</p>

            <table class="searchTable" id="searchTable">
                <tr>
                    <td>
                        <form name="searchForm" id="searchForm" onsubmit="form_submit();" action="<?php echo(CATSUtility::getIndexName()); ?>#searchtop" method="get" autocomplete="off">
                            <input type="hidden" name="m" id="moduleName" value="companies" />
                            <input type="hidden" name="a" id="moduleAction" value="search" />
                            <input type="hidden" name="getback" id="getback" value="getback" />

                            <?php TemplateUtility::printSavedSearch($this->savedSearchRS); ?>

                            <table border="0" width="800px" cellpadding="5" cellspacing="10">
                            <tr>
                            	<td align="left" valign="top" width="625px" style="border:1px solid #ccc">
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
                                        	<option value="searchbycity" selected="selected">City</option>
                                            <option value="searchbystate">State</option>                                        
                                            <option value="searchbylocation">Proximity</option>
                                            <option value="searchbynaics">NAICS</option>
                                            <option value="searchbyindustry">Industry</option>
                                            <option value="searchbyrevenue">Revenue</option>
                                            <option value="searchbyemployees">Employees</option>                                            
                                            <option value="searchbycategory">Category</option>
                                            <option value="searchbyprospecting">Prospecting</option>
                                            <option value="searchbykeytechnologies">Key Technologies</option>
                                        </select>&nbsp;
                                        <div style="display:inline-block; border:2px solid #333; background-color:#eee" id="div_normal_search">
                                            <input type="text" class="inputbox" id="searchText" name="wildCardString" value="<?php if (!empty($this->wildCardString)) $this->_($this->wildCardString); ?>" style="width:150px" onKeyPress="return disableEnterKey(event);" />&nbsp;*&nbsp;
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
                                            </select>&nbsp;&nbsp;
                                            <input type="text" class="inputbox" id="searchNumericValue" name="searchNumericValue" value="" style="width:60px" onKeyPress="return disableEnterKeyLocZip(event);" />&nbsp;                                            
                                            <input type="button" class="button" id="add_filter_loc" name="add_filter_loc" value="Add Filter" onclick="add_filterx();" />
                                        </div>
                                    </div>
                                </td>
                                <td align="left" valign="top" width="175px" style="border:0px solid #ccc;">
                                     <div style="visibility:hidden">
                                        <!-- hide for the moment -->
                                	 	<label id="searchKeywordWeight" for="">Keyword Weight</label>&nbsp;<br />
                                     </div>
                                </td>
                            </tr>                            
                            </table>    
                            <br /><br />
                            
                            <input type="submit" class="button" id="searchCompanies" name="searchCompanies" value="Search" />
                            <?php TemplateUtility::printAdvancedSearch('searchByKeyTechnologies'); ?>
                        </form>
                    </td>
                </tr>
            </table>
			
            <script type="text/javascript">
                document.searchForm.wildCardString.focus();
            </script>

            <?php if ($this->isResultsMode): ?>
                <br />
                <p class="note">Search Results (<?php if(count($this->rs)>=3000) echo "Greater than "; echo(count($this->rs)); ?>)</p>

                <?php if (!empty($this->rs)): ?>
                    <?php echo($this->exportForm['header']); ?>
                    <table class="sortable" width="100%" onmouseover="javascript:trackTableHighlight(event)">
                        <tr>
                            <th>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('name', 'Name'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('phone1', 'Primary Phone'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">Key Technologies</th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('city', 'Created'); ?>
                            </th>
                            <th align="left" nowrap="nowrap">
                                <?php $this->pager->printSortLink('owner_user.last_name', 'Owner'); ?>
                            </th>
                        </tr>

                        <?php foreach ($this->rs as $rowNumber => $data): ?>
                            <tr class="<?php TemplateUtility::printAlternatingRowClass($rowNumber); ?>">
                                <td valign="top" nowrap="nowrap">
                                    <input type="checkbox" id="checked_<?php echo($data['companyID']); ?>" name="checked_<?php echo($data['companyID']); ?>" />
                                    <a href="javascript:void(0);" onclick="window.open('<?php echo(CATSUtility::getIndexName()); ?>?m=companies&amp;a=show&amp;companyID=<?php $this->_($data['companyID']); ?>')" title="View in New Window">
                                        <img src="images/new_window.gif" alt="(Preview)" border="0" width="15" height="15" />
                                    </a>
                                </td>
                                <td valign="top" align="left">
                                    <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=companies&amp;a=show&amp;companyID=<?php $this->_($data['companyID']); ?>" class="<?php $this->_($data['linkClass']); ?>">
                                        <?php $this->_($data['name']); ?>
                                    </a>
                                </td>
                                <td valign="top" align="left" nowrap="nowrap"><?php $this->_($data['phone1']); ?></td>
                                <td valign="top" align="left"><?php $this->_($data['keyTechnologies']); ?></td>
                                <td valign="top" align="left" nowrap="nowrap"><?php $this->_($data['dateCreated']); ?></td>
                                <td valign="top" align="left" nowrap="nowrap"><?php $this->_($data['ownerAbbrName']); ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </table>                    
                    <?php echo($this->exportForm['footer']); ?>
                    <div style="float: right"><?php $this->pager->printNavigation('name'); ?></div>
                    <?php echo($this->exportForm['menu']); ?>
                <?php else: ?>
                    <p>No matching entries found.</p>
                <?php endif; ?>
            <?php endif; ?>            
        </div>
    </div>
    <div id="bottomShadow"></div>
<?php TemplateUtility::printFooter(); ?>
