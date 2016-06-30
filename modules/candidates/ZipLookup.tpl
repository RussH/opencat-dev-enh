<?php /* $Id: ZipLookup.tpl 3093 2012-02-29 21:09:45Z allan $ */ ?>
<?php 
    TemplateUtility::printModalHeader('Candidates', array('js/jquery/js/jquery-1.7.1.min.js', 'js/jquery/js/jquery-ui-1.8.17.custom.min.js'), 'ZIP Code Lookup');        
?>
	<script language="javascript">
		function select_zipcode() {
			if($("#zip").val() == "") {
				alert("Please select a Zip Code");
				return;
			}
			parent.document.getElementById("searchTextLocZip").value = $("#zip").val();
			parentHidePopWin();
		}
	
		function filter_change(selectobj) {
			if($("#"+selectobj.id).val() == "") {
				//ignore if empty selected
			} else {
				var curr_id = selectobj.id;
				switch(curr_id) {
					case "country":
						empty_combobox('state');
						empty_combobox('city');
						empty_combobox('zip');
						break;
					case "state":
						empty_combobox('city');
						empty_combobox('zip');
						break;
					case "city":
						empty_combobox('zip');
						break;
				}
				
				var city = $("#city").val();
				var state = $("#state").val();
				var country = $("#country").val();
				$.ajax({
					type : "GET",
					url : "http://www.clearroad.it/cats/<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&a=ziplookup&ajax=1&country="+country+"&city="+city+"&state="+state+"",					
					success : function(data){						
						switch(curr_id) {
							case "country":						
								$("#state").append(data);
								break;	
							case "state":								
								$("#city").append(data);
								break;
							case "city":								
								$("#zip").append(data);
								break;
						}
					}					
				});				
				/* 
				$.get("http://www.clearroad.it/cats/<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&a=ziplookup&ajax=1&country="+country+"&city="+city+"&state="+state+"",
				      function(data) { 					    
					  	switch(curr_id) {
							case "country":
								empty_combobox('state');
								empty_combobox('city');
								empty_combobox('zip');								
								$("#state").append(data);
								break;	
							case "state":
								empty_combobox('city');
								empty_combobox('zip');
								$("#city").append(data);
								break;
							case "city":
								empty_combobox('zip');
								$("#zip").append(data);
								break;
						}
					  }
				);
				*/
			}
		}
		
		function empty_combobox(selector_id) {
			$("#"+selector_id).empty();
			$("#"+selector_id).append('<option value="">(select)</option>');
		}
	</script>
    <p>Search for a ZIP code below, and then click on Select.</p>
    <table class="searchTable">
    <tr>
    	<td>Country</td>
        <td><select id="country" name="country" class="selectBox" onchange="filter_change(this);">
            <option value="">(select)</option>
        	<?php if (!empty($this->rs)): ?>
                <?php foreach ($this->rs as $rowNumber => $data): ?>
                	<option value="<?php $this->_($data['value']); ?>"><?php $this->_($data['text']); ?></option>
                <?php endforeach; ?>
            <?php endif; ?>
        </select></td>
    </tr>
    <tr>
    	<td>State</td>
        <td><select id="state" name="state" class="selectBox" onchange="filter_change(this);">
        	<option value="">(select)</option>
        </select></td>
    </tr>
    <tr>
    	<td>City</td>
        <td><select id="city" name="city" class="selectBox" onchange="filter_change(this);">
        	<option value="">(select)</option>
        </select></td>
    </tr>
    <tr>
    	<td>ZIP Code</td>
        <td><select id="zip" name="zip" class="selectBox">
        	<option value="">(select)</option>
        </select></td>
    </tr>
    <tr>
    	<td colspan="2"><input type="button" name="close" value="Select" onclick="select_zipcode();" /></td>
    </tr>    
    </table>    
    </body>
</html>
