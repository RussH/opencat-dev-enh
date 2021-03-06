<?php /* $Id: Edit.tpl 3695 2007-11-26 22:01:04Z brian $ */ ?>
<?php TemplateUtility::printHeader('Candidates', array('modules/candidates/validator.js', 'js/suggest.js', 'js/sweetTitles.js', 'js/listEditor.js', 'js/doubleListEditor.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active); ?>
<?php

$role_sel =<<<HTML101
						<select role_id="" role_name="" class="selectBox">
							<option value="" >Unknown</option>
							<option value="Application Support" >Application Support</option>
							<option value="Architecture" >Architecture</option>
							<option value="Business Analysis" >Business Analysis</option>
							<option value="Business Intel & Reporting" >Business Intel & Reporting</option>
							<option value="Call Center" >Call Center</option>
							<option value="Databases (DBA, etc)" >Databases (DBA, etc)</option>
							<option value="ERP" >ERP</option>
							<option value="GIS" >GIS</option>
							<option value="Help Desk/Entry Level" >Help Desk/Entry Level</option>
							<option value="Management Consultant" >Management Consultant</option>
							<option value="Network and Infrastructure" >Network and Infrastructure</option>
							<option value="Project & Program Management" >Project & Program Management</option>
							<option value="Quality Assurance/Testing" >Quality Assurance/Testing</option>
							<option value="Tech Writing/Multimedia/Training" >Tech Writing/Multimedia/Training</option>
							<option value="Web & Software Development" >Web & Software Development</option>
						</select>						
HTML101;
							
$year_sel =<<<HTML101
						<select yr_id="" yr_name="" class="selectBox">
							<option value="" >Unknown</option>
							<option value="1" >1</option>
							<option value="2" >2</option>
							<option value="3" >3</option>
							<option value="4" >4</option>
							<option value="5" >5</option>
							<option value="6" >6</option>
							<option value="7" >7</option>
							<option value="8" >8</option>
							<option value="9" >9</option>
							<option value="10" >10</option>
							<option value="11" >11</option>
							<option value="12" >12</option>
							<option value="13" >13</option>
							<option value="14" >14</option>
							<option value="15" >15</option>
							<option value="16" >16</option>
							<option value="17" >17</option>
							<option value="18" >18</option>
							<option value="19" >19</option>
							<option value="20" >20</option>
							<option value="21" >21</option>
							<option value="22" >22</option>
							<option value="23" >23</option>
							<option value="24" >24</option>
							<option value="25" >25</option>
							<option value="26" >26</option>
							<option value="27" >27</option>
							<option value="28" >28</option>
							<option value="29" >29</option>
							<option value="30" >30</option>
							<option value="31" >31</option>
							<option value="32" >32</option>
							<option value="33" >33</option>
							<option value="34" >34</option>
							<option value="35" >35</option>
							<option value="36" >36</option>
							<option value="37" >37</option>
							<option value="38" >38</option>
							<option value="39" >39</option>
							<option value="40" >40</option>
							<option value="41" >41</option>
							<option value="42" >42</option>
							<option value="43" >43</option>
							<option value="44" >44</option>
							<option value="45" >45</option>
							<option value="46" >46</option>
							<option value="47" >47</option>
							<option value="48" >48</option>
							<option value="49" >49</option>
							<option value="50" >50</option>
							<option value="51" >51</option>
							<option value="52" >52</option>
						</select>
HTML101;

?>
	<style >
		input[type="button"]{
			cursor: 'pointer';
		}
	</style>
    <div id="main">
        <?php TemplateUtility::printQuickSearch(); ?>

        <div id="contents">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2><?php if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {echo('My Profile - Edit');} else {echo('Candidates: Edit');} ?></h2></td>
               </tr>
            </table>

            <p class="note"><?php if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {echo('Edit Profile Details');} else {echo('Edit Candidate');} ?></p>

            <form name="editCandidateForm" id="editCandidateForm" action="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=edit" method="post" onsubmit="return checkEditForm(document.editCandidateForm);" autocomplete="off">
                <input type="hidden" name="postback" id="postback" value="postback" />
                <input type="hidden" id="candidateID" name="candidateID" value="<?php $this->_($this->data['candidateID']); ?>" />
				<?php if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {?>
                   <div style="display:none">
                    <input type="checkbox" id="isHot" name="isHot"<?php if ($this->data['isHot'] == 1): ?> checked<?php endif; ?> />
                    <select id="sourceSelect" name="source" class="inputbox" style="width: 150px;" onchange="if (this.value == 'edit') { listEditor('Sources', 'sourceSelect', 'sourceCSV', false, ''); this.value = '(none)'; } if (this.value == 'nullline') { this.value = '(none)'; }">
                                                    <option value="edit">(Edit Sources)</option>
                                                    <option value="nullline">-------------------------------</option>
                                                    <?php if ($this->sourceInRS == false): ?>
                                                        <?php if ($this->data['source'] != '(none)'): ?>
                                                            <option value="(none)">(None)</option>
                                                        <?php endif; ?>
                                                        <option value="<?php $this->_($this->data['source']); ?>" selected="selected"><?php $this->_($this->data['source']); ?></option>
                                                    <?php else: ?>
                                                        <option value="(none)">(None)</option>
                                                    <?php endif; ?>
                                                    <?php foreach ($this->sourcesRS AS $index => $source): ?>
                                                        <option value="<?php $this->_($source['name']); ?>" <?php if ($source['name'] == $this->data['source']): ?>selected<?php endif; ?>><?php $this->_($source['name']); ?></option>
                                                    <?php endforeach; ?>
                                                </select>
                    <input type="hidden" id="sourceCSV" name="sourceCSV" value="<?php $this->_($this->sourcesString); ?>" />
                    <select id="owner" name="owner" class="inputbox" style="width: 150px;" <?php if (!$this->emailTemplateDisabled): ?>onchange="document.getElementById('divOwnershipChange').style.display=''; <?php if ($this->canEmail): ?>document.getElementById('checkboxOwnershipChange').checked=true;<?php endif; ?>"<?php endif; ?>>
                                                    <option value="-1">None</option>
                    
                                                    <?php foreach ($this->usersRS as $rowNumber => $usersData): ?>
                                                        <?php if ($this->data['owner'] == $usersData['userID']): ?>
                                                            <option selected="selected" value="<?php $this->_($usersData['userID']) ?>"><?php $this->_($usersData['lastName']) ?>, <?php $this->_($usersData['firstName']) ?></option>
                                                        <?php else: ?>
                                                            <option value="<?php $this->_($usersData['userID']) ?>"><?php $this->_($usersData['lastName']) ?>, <?php $this->_($usersData['firstName']) ?></option>
                                                        <?php endif; ?>
                                                    <?php endforeach; ?>
                                                </select>
                    <input type="checkbox" name="ownershipChange" id="checkboxOwnershipChange" <?php if (!$this->canEmail): ?>disabled<?php endif; ?>>
                    <input type="checkbox" id="isActive" name="isActive"<?php if ($this->data['isActive'] == 1): ?> checked<?php endif; ?> />                	</div>
                <?php }?>
                <table class="editTable" width="700">
                	<?php if(intval($_SESSION['CATS']->getAccessLevel()) != ACCESS_LEVEL_CANDIDATE) {?>
                    <tr>
                        <td class="tdVertical" valign="top" style="height: 28px;">
                            <label id="isHotLabel" for="isHot">Active:</label>
                        </td>
                        <td class="tdData" >
                            <input type="checkbox" id="isActive" name="isActive"<?php if ($this->data['isActive'] == 1): ?> checked<?php endif; ?> />
                            <img title="Unchecking this box indicates the candidate is inactive, and will no longer display on the resume search results." src="images/information.gif" alt="" width="16" height="16" />
                        </td>
                    </tr>
                    <?php }?>
                    <tr>
                        <td class="tdVertical">
                            <label id="firstNameLabel" for="firstName">First Name:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="firstName" name="firstName" value="<?php $this->_($this->data['firstName']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="middleNameLabel" for="middleName">Middle Name:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="middleName" name="middleName" value="<?php $this->_($this->data['middleName']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="lastNameLabel" for="lastName">Last Name:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="lastName" name="lastName" value="<?php $this->_($this->data['lastName']); ?>" style="width: 150px;" />
                        </td>
                    </tr>
					
					<tr>
                        <td class="tdVertical">
                            <label id="titleLabel" for="title">Title:</label>
                        </td>
                        <td class="tdData">
                            <select id="title" name="title" class="inputbox" style="width:150px;">
                                <option value=""></option>
                                <option <?php if ($this->title == 'Mr.') { echo "selected"; } ?> value="Mr.">Mr.</option>
                                <option <?php if ($this->title == 'Mrs.') { echo "selected"; } ?> value="Mrs.">Mrs.</option>
                                <option <?php if ($this->title == 'Ms.') { echo "selected"; } ?> value="Ms.">Ms.</option>                                
                            </select>
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="email1Label" for="email1">E-Mail:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="email1" name="email1" value="<?php $this->_($this->data['email1']); ?>" style="width: 150px;" />
                        </td>
                    </tr>
                    <tr>
                        <td class="tdVertical">
                            <label id="email2Label" for="email2">2nd E-Mail:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="email2" name="email2" value="<?php $this->_($this->data['email2']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="phoneHomeLabel" for="phoneHome">Home Phone:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="phoneHome" name="phoneHome" value="<?php $this->_($this->data['phoneHome']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="phoneCellLabel" for="phoneCell">Cell Phone:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="phoneCell" name="phoneCell" value="<?php $this->_($this->data['phoneCell']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="phoneWorkLabel" for="phoneWork">Work Phone:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="phoneWork" name="phoneWork" value="<?php $this->_($this->data['phoneWork']); ?>" style="width: 150px;" />
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="tdVertical">
                            <label id="skype_idLabel" for="phoneWork">Skype ID:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="skype_id" name="skype_id" value="<?php $this->_($this->data['skype_id']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="webSiteLabel" for="webSite">LinkedIn Profile URL:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="webSite" name="webSite" value="<?php $this->_($this->data['webSite']); ?>" style="width: 150px" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="addressLabel" for="address1">Address:</label>
                        </td>
                        <td class="tdData">
                            <textarea class="inputbox" id="address" name="address" style="width: 150px;"><?php $this->_($this->data['address']); ?></textarea>
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="cityLabel" for="city">City:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="city" name="city" value="<?php $this->_($this->data['city']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="stateLabel" for="state">State:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="state" name="state" value="<?php $this->_($this->data['state']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="zipLabel" for="zip">Postal Code:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="zip" name="zip" value="<?php $this->_($this->data['zip']); ?>" style="width: 150px;" />
                            <input type="button" class="button" onclick="CityState_populate('zip', 'ajaxIndicator');" value="Lookup" />
                            <img src="images/indicator2.gif" alt="AJAX" id="ajaxIndicator" style="vertical-align: middle; visibility: hidden; margin-left: 5px;" />
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="tdVertical">
                            <label id="countryLabel" for="country">Country:</label>
                        </td>
                        <td class="tdData">                            
                            <select id="country" name="country" class="inputbox" style="width:200px;">
                                <option value=''>----</option>                               
                                <option value='Canada' <?php if (strtolower($this->data['country']) == 'canada' )  echo('selected'); ?>>Canada</option> 
                                <option value='USA' <?php if (strtolower($this->data['country']) == 'united states' )  echo('selected'); ?>>USA</option>
                                <option value='Afghanistan' <?php if (strtolower($this->data['country']) == 'afghanistan' )  echo('selected'); ?>>Afghanistan</option>
                                <option value='Albania' <?php if (strtolower($this->data['country']) == 'albania' )  echo('selected'); ?>>Albania</option>
                                <option value='Algeria' <?php if (strtolower($this->data['country']) == 'algeria' )  echo('selected'); ?>>Algeria</option>
                                <option value='Andorra' <?php if (strtolower($this->data['country']) == 'andorra' )  echo('selected'); ?>>Andorra</option>
                                <option value='Angola' <?php if (strtolower($this->data['country']) == 'angola' )  echo('selected'); ?>>Angola</option>
                                <option value='Antigua and Barbuda' <?php if (strtolower($this->data['country']) == 'antigua and barbuda' )  echo('selected'); ?>>Antigua and Barbuda</option>
                                <option value='Argentina' <?php if (strtolower($this->data['country']) == 'argentina' )  echo('selected'); ?>>Argentina</option>
                                <option value='Armenia' <?php if (strtolower($this->data['country']) == 'armenia' )  echo('selected'); ?>>Armenia</option>
                                <option value='Australia' <?php if (strtolower($this->data['country']) == 'australia' )  echo('selected'); ?>>Australia</option>
                                <option value='Austria' <?php if (strtolower($this->data['country']) == 'austria' )  echo('selected'); ?>>Austria</option>
                                <option value='Azerbaijan' <?php if (strtolower($this->data['country']) == 'azerbaijan' )  echo('selected'); ?>>Azerbaijan</option>
                                <option value='Bahamas' <?php if (strtolower($this->data['country']) == 'bahamas' )  echo('selected'); ?>>Bahamas</option>
                                <option value='Bahrain' <?php if (strtolower($this->data['country']) == 'bahrain' )  echo('selected'); ?>>Bahrain</option>
                                <option value='Bangladesh' <?php if (strtolower($this->data['country']) == 'bangladesh' )  echo('selected'); ?>>Bangladesh</option>
                                <option value='Barbados' <?php if (strtolower($this->data['country']) == 'barbados' )  echo('selected'); ?>>Barbados</option>
                                <option value='Belarus' <?php if (strtolower($this->data['country']) == 'belarus' )  echo('selected'); ?>>Belarus</option>
                                <option value='Belgium' <?php if (strtolower($this->data['country']) == 'belgium' )  echo('selected'); ?>>Belgium</option>
                                <option value='Belize' <?php if (strtolower($this->data['country']) == 'belize' )  echo('selected'); ?>>Belize</option>
                                <option value='Benin' <?php if (strtolower($this->data['country']) == 'benin' )  echo('selected'); ?>>Benin</option>
                                <option value='Bhutan' <?php if (strtolower($this->data['country']) == 'bhutan' )  echo('selected'); ?>>Bhutan</option>
                                <option value='Bolivia' <?php if (strtolower($this->data['country']) == 'bolivia' )  echo('selected'); ?>>Bolivia</option>
                                <option value='Bosnia and Herzegovina' <?php if (strtolower($this->data['country']) == 'bosnia and herzegovina' )  echo('selected'); ?>>Bosnia and Herzegovina</option>
                                <option value='Botswana' <?php if (strtolower($this->data['country']) == 'botswana' )  echo('selected'); ?>>Botswana</option>
                                <option value='Brazil' <?php if (strtolower($this->data['country']) == 'brazil' )  echo('selected'); ?>>Brazil</option>
                                <option value='Brunei ' <?php if (strtolower($this->data['country']) == 'brunei ' )  echo('selected'); ?>>Brunei </option>
                                <option value='Bulgaria' <?php if (strtolower($this->data['country']) == 'bulgaria' )  echo('selected'); ?>>Bulgaria</option>
                                <option value='Burkina Faso' <?php if (strtolower($this->data['country']) == 'burkina faso' )  echo('selected'); ?>>Burkina Faso</option>
                                <option value='Burma' <?php if (strtolower($this->data['country']) == 'burma' )  echo('selected'); ?>>Burma</option>
                                <option value='Burundi' <?php if (strtolower($this->data['country']) == 'burundi' )  echo('selected'); ?>>Burundi</option>
                                <option value='Cambodia' <?php if (strtolower($this->data['country']) == 'cambodia' )  echo('selected'); ?>>Cambodia</option>
                                <option value='Cameroon' <?php if (strtolower($this->data['country']) == 'cameroon' )  echo('selected'); ?>>Cameroon</option>                                
                                <option value='Cape Verde' <?php if (strtolower($this->data['country']) == 'cape verde' )  echo('selected'); ?>>Cape Verde</option>
                                <option value='Central African Republic' <?php if (strtolower($this->data['country']) == 'central african republic' )  echo('selected'); ?>>Central African Republic</option>
                                <option value='Chad' <?php if (strtolower($this->data['country']) == 'chad' )  echo('selected'); ?>>Chad</option>
                                <option value='Chile' <?php if (strtolower($this->data['country']) == 'chile' )  echo('selected'); ?>>Chile</option>
                                <option value='China' <?php if (strtolower($this->data['country']) == 'china' )  echo('selected'); ?>>China</option>
                                <option value='Colombia' <?php if (strtolower($this->data['country']) == 'colombia' )  echo('selected'); ?>>Colombia</option>
                                <option value='Comoros ' <?php if (strtolower($this->data['country']) == 'comoros ' )  echo('selected'); ?>>Comoros </option>
                                <option value='Congo' <?php if (strtolower($this->data['country']) == 'congo' )  echo('selected'); ?>>Congo</option>
                                <option value='Costa Rica' <?php if (strtolower($this->data['country']) == 'costa rica' )  echo('selected'); ?>>Costa Rica</option>
                                <option value='Cote d Ivoire' <?php if (strtolower($this->data['country']) == 'cote d ivoire' )  echo('selected'); ?>>Cote d Ivoire</option>
                                <option value='Croatia' <?php if (strtolower($this->data['country']) == 'croatia' )  echo('selected'); ?>>Croatia</option>
                                <option value='Cuba' <?php if (strtolower($this->data['country']) == 'cuba' )  echo('selected'); ?>>Cuba</option>
                                <option value='Cyprus' <?php if (strtolower($this->data['country']) == 'cyprus' )  echo('selected'); ?>>Cyprus</option>
                                <option value='Czech Republic' <?php if (strtolower($this->data['country']) == 'czech republic' )  echo('selected'); ?>>Czech Republic</option>
                                <option value='Denmark' <?php if (strtolower($this->data['country']) == 'denmark' )  echo('selected'); ?>>Denmark</option>
                                <option value='Djibouti' <?php if (strtolower($this->data['country']) == 'djibouti' )  echo('selected'); ?>>Djibouti</option>
                                <option value='Dominica' <?php if (strtolower($this->data['country']) == 'dominica' )  echo('selected'); ?>>Dominica</option>
                                <option value='Dominican Republic' <?php if (strtolower($this->data['country']) == 'dominican republic' )  echo('selected'); ?>>Dominican Republic</option>
                                <option value='East Timor' <?php if (strtolower($this->data['country']) == 'east timor' )  echo('selected'); ?>>East Timor</option>
                                <option value='Ecuador' <?php if (strtolower($this->data['country']) == 'ecuador' )  echo('selected'); ?>>Ecuador</option>
                                <option value='Egypt' <?php if (strtolower($this->data['country']) == 'egypt' )  echo('selected'); ?>>Egypt</option>
                                <option value='El Salvador' <?php if (strtolower($this->data['country']) == 'el salvador' )  echo('selected'); ?>>El Salvador</option>
                                <option value='Equatorial Guinea' <?php if (strtolower($this->data['country']) == 'equatorial guinea' )  echo('selected'); ?>>Equatorial Guinea</option>
                                <option value='Eritrea' <?php if (strtolower($this->data['country']) == 'eritrea' )  echo('selected'); ?>>Eritrea</option>
                                <option value='Estonia' <?php if (strtolower($this->data['country']) == 'estonia' )  echo('selected'); ?>>Estonia</option>
                                <option value='Ethiopia' <?php if (strtolower($this->data['country']) == 'ethiopia' )  echo('selected'); ?>>Ethiopia</option>
                                <option value='Fiji' <?php if (strtolower($this->data['country']) == 'fiji' )  echo('selected'); ?>>Fiji</option>
                                <option value='Finland' <?php if (strtolower($this->data['country']) == 'finland' )  echo('selected'); ?>>Finland</option>
                                <option value='France' <?php if (strtolower($this->data['country']) == 'france' )  echo('selected'); ?>>France</option>
                                <option value='Gabon' <?php if (strtolower($this->data['country']) == 'gabon' )  echo('selected'); ?>>Gabon</option>
                                <option value='Gambia' <?php if (strtolower($this->data['country']) == 'gambia' )  echo('selected'); ?>>Gambia</option>
                                <option value='Georgia' <?php if (strtolower($this->data['country']) == 'georgia' )  echo('selected'); ?>>Georgia</option>
                                <option value='Germany' <?php if (strtolower($this->data['country']) == 'germany' )  echo('selected'); ?>>Germany</option>
                                <option value='Ghana' <?php if (strtolower($this->data['country']) == 'ghana' )  echo('selected'); ?>>Ghana</option>
                                <option value='Greece' <?php if (strtolower($this->data['country']) == 'greece' )  echo('selected'); ?>>Greece</option>
                                <option value='Grenada' <?php if (strtolower($this->data['country']) == 'grenada' )  echo('selected'); ?>>Grenada</option>
                                <option value='Guatemala' <?php if (strtolower($this->data['country']) == 'guatemala' )  echo('selected'); ?>>Guatemala</option>
                                <option value='Guinea' <?php if (strtolower($this->data['country']) == 'guinea' )  echo('selected'); ?>>Guinea</option>
                                <option value='Guinea-Bissau' <?php if (strtolower($this->data['country']) == 'guinea-bissau' )  echo('selected'); ?>>Guinea-Bissau</option>
                                <option value='Guyana' <?php if (strtolower($this->data['country']) == 'guyana' )  echo('selected'); ?>>Guyana</option>
                                <option value='Haiti' <?php if (strtolower($this->data['country']) == 'haiti' )  echo('selected'); ?>>Haiti</option>
                                <option value='Holy See' <?php if (strtolower($this->data['country']) == 'holy see' )  echo('selected'); ?>>Holy See</option>
                                <option value='Honduras' <?php if (strtolower($this->data['country']) == 'honduras' )  echo('selected'); ?>>Honduras</option>
                                <option value='Hong Kong' <?php if (strtolower($this->data['country']) == 'hong kong' )  echo('selected'); ?>>Hong Kong</option>
                                <option value='Hungary' <?php if (strtolower($this->data['country']) == 'hungary' )  echo('selected'); ?>>Hungary</option>
                                <option value='Iceland' <?php if (strtolower($this->data['country']) == 'iceland' )  echo('selected'); ?>>Iceland</option>
                                <option value='India' <?php if (strtolower($this->data['country']) == 'india' )  echo('selected'); ?>>India</option>
                                <option value='Indonesia' <?php if (strtolower($this->data['country']) == 'indonesia' )  echo('selected'); ?>>Indonesia</option>
                                <option value='Iran' <?php if (strtolower($this->data['country']) == 'iran' )  echo('selected'); ?>>Iran</option>
                                <option value='Iraq' <?php if (strtolower($this->data['country']) == 'iraq' )  echo('selected'); ?>>Iraq</option>
                                <option value='Ireland' <?php if (strtolower($this->data['country']) == 'ireland' )  echo('selected'); ?>>Ireland</option>
                                <option value='Israel' <?php if (strtolower($this->data['country']) == 'israel' )  echo('selected'); ?>>Israel</option>
                                <option value='Italy' <?php if (strtolower($this->data['country']) == 'italy' )  echo('selected'); ?>>Italy</option>
                                <option value='Jamaica' <?php if (strtolower($this->data['country']) == 'jamaica' )  echo('selected'); ?>>Jamaica</option>
                                <option value='Japan' <?php if (strtolower($this->data['country']) == 'japan' )  echo('selected'); ?>>Japan</option>
                                <option value='Jordan' <?php if (strtolower($this->data['country']) == 'jordan' )  echo('selected'); ?>>Jordan</option>
                                <option value='Kazakhstan' <?php if (strtolower($this->data['country']) == 'kazakhstan' )  echo('selected'); ?>>Kazakhstan</option>
                                <option value='Kenya' <?php if (strtolower($this->data['country']) == 'kenya' )  echo('selected'); ?>>Kenya</option>
                                <option value='Kiribati' <?php if (strtolower($this->data['country']) == 'kiribati' )  echo('selected'); ?>>Kiribati</option>
                                <option value='Korea, North' <?php if (strtolower($this->data['country']) == 'korea, north' )  echo('selected'); ?>>Korea, North</option>
                                <option value='Korea, South' <?php if (strtolower($this->data['country']) == 'korea, south' )  echo('selected'); ?>>Korea, South</option>
                                <option value='Kosovo' <?php if (strtolower($this->data['country']) == 'kosovo' )  echo('selected'); ?>>Kosovo</option>
                                <option value='Kuwait' <?php if (strtolower($this->data['country']) == 'kuwait' )  echo('selected'); ?>>Kuwait</option>
                                <option value='Kyrgyzstan' <?php if (strtolower($this->data['country']) == 'kyrgyzstan' )  echo('selected'); ?>>Kyrgyzstan</option>
                                <option value='Laos' <?php if (strtolower($this->data['country']) == 'laos' )  echo('selected'); ?>>Laos</option>
                                <option value='Latvia' <?php if (strtolower($this->data['country']) == 'latvia' )  echo('selected'); ?>>Latvia</option>
                                <option value='Lebanon' <?php if (strtolower($this->data['country']) == 'lebanon' )  echo('selected'); ?>>Lebanon</option>
                                <option value='Lesotho' <?php if (strtolower($this->data['country']) == 'lesotho' )  echo('selected'); ?>>Lesotho</option>
                                <option value='Liberia' <?php if (strtolower($this->data['country']) == 'liberia' )  echo('selected'); ?>>Liberia</option>
                                <option value='Libya' <?php if (strtolower($this->data['country']) == 'libya' )  echo('selected'); ?>>Libya</option>
                                <option value='Liechtenstein' <?php if (strtolower($this->data['country']) == 'liechtenstein' )  echo('selected'); ?>>Liechtenstein</option>
                                <option value='Lithuania' <?php if (strtolower($this->data['country']) == 'lithuania' )  echo('selected'); ?>>Lithuania</option>
                                <option value='Luxembourg' <?php if (strtolower($this->data['country']) == 'luxembourg' )  echo('selected'); ?>>Luxembourg</option>
                                <option value='Macau' <?php if (strtolower($this->data['country']) == 'macau' )  echo('selected'); ?>>Macau</option>
                                <option value='Macedonia' <?php if (strtolower($this->data['country']) == 'macedonia' )  echo('selected'); ?>>Macedonia</option>
                                <option value='Madagascar' <?php if (strtolower($this->data['country']) == 'madagascar' )  echo('selected'); ?>>Madagascar</option>
                                <option value='Malawi' <?php if (strtolower($this->data['country']) == 'malawi' )  echo('selected'); ?>>Malawi</option>
                                <option value='Malaysia' <?php if (strtolower($this->data['country']) == 'malaysia' )  echo('selected'); ?>>Malaysia</option>
                                <option value='Maldives' <?php if (strtolower($this->data['country']) == 'maldives' )  echo('selected'); ?>>Maldives</option>
                                <option value='Mali' <?php if (strtolower($this->data['country']) == 'mali' )  echo('selected'); ?>>Mali</option>
                                <option value='Malta' <?php if (strtolower($this->data['country']) == 'malta' )  echo('selected'); ?>>Malta</option>
                                <option value='Marshall Islands' <?php if (strtolower($this->data['country']) == 'marshall islands' )  echo('selected'); ?>>Marshall Islands</option>
                                <option value='Mauritania' <?php if (strtolower($this->data['country']) == 'mauritania' )  echo('selected'); ?>>Mauritania</option>
                                <option value='Mauritius' <?php if (strtolower($this->data['country']) == 'mauritius' )  echo('selected'); ?>>Mauritius</option>
                                <option value='Mexico' <?php if (strtolower($this->data['country']) == 'mexico' )  echo('selected'); ?>>Mexico</option>
                                <option value='Micronesia' <?php if (strtolower($this->data['country']) == 'micronesia' )  echo('selected'); ?>>Micronesia</option>
                                <option value='Moldova' <?php if (strtolower($this->data['country']) == 'moldova' )  echo('selected'); ?>>Moldova</option>
                                <option value='Monaco' <?php if (strtolower($this->data['country']) == 'monaco' )  echo('selected'); ?>>Monaco</option>
                                <option value='Mongolia' <?php if (strtolower($this->data['country']) == 'mongolia' )  echo('selected'); ?>>Mongolia</option>
                                <option value='Montenegro' <?php if (strtolower($this->data['country']) == 'montenegro' )  echo('selected'); ?>>Montenegro</option>
                                <option value='Morocco' <?php if (strtolower($this->data['country']) == 'morocco' )  echo('selected'); ?>>Morocco</option>
                                <option value='Mozambique' <?php if (strtolower($this->data['country']) == 'mozambique' )  echo('selected'); ?>>Mozambique</option>
                                <option value='Namibia' <?php if (strtolower($this->data['country']) == 'namibia' )  echo('selected'); ?>>Namibia</option>
                                <option value='Nauru' <?php if (strtolower($this->data['country']) == 'nauru' )  echo('selected'); ?>>Nauru</option>
                                <option value='Nepal' <?php if (strtolower($this->data['country']) == 'nepal' )  echo('selected'); ?>>Nepal</option>
                                <option value='Netherlands' <?php if (strtolower($this->data['country']) == 'netherlands' )  echo('selected'); ?>>Netherlands</option>
                                <option value='Netherlands Antilles' <?php if (strtolower($this->data['country']) == 'netherlands antilles' )  echo('selected'); ?>>Netherlands Antilles</option>
                                <option value='New Zealand' <?php if (strtolower($this->data['country']) == 'new zealand' )  echo('selected'); ?>>New Zealand</option>
                                <option value='Nicaragua' <?php if (strtolower($this->data['country']) == 'nicaragua' )  echo('selected'); ?>>Nicaragua</option>
                                <option value='Niger' <?php if (strtolower($this->data['country']) == 'niger' )  echo('selected'); ?>>Niger</option>
                                <option value='Nigeria' <?php if (strtolower($this->data['country']) == 'nigeria' )  echo('selected'); ?>>Nigeria</option>
                                <option value='North Korea' <?php if (strtolower($this->data['country']) == 'north korea' )  echo('selected'); ?>>North Korea</option>
                                <option value='Norway' <?php if (strtolower($this->data['country']) == 'norway' )  echo('selected'); ?>>Norway</option>
                                <option value='Pakistan' <?php if (strtolower($this->data['country']) == 'pakistan' )  echo('selected'); ?>>Pakistan</option>
                                <option value='Palau' <?php if (strtolower($this->data['country']) == 'palau' )  echo('selected'); ?>>Palau</option>
                                <option value='Palestinian Territories' <?php if (strtolower($this->data['country']) == 'palestinian territories' )  echo('selected'); ?>>Palestinian Territories</option>
                                <option value='Panama' <?php if (strtolower($this->data['country']) == 'panama' )  echo('selected'); ?>>Panama</option>
                                <option value='Papua New Guinea' <?php if (strtolower($this->data['country']) == 'papua new guinea' )  echo('selected'); ?>>Papua New Guinea</option>
                                <option value='Paraguay' <?php if (strtolower($this->data['country']) == 'paraguay' )  echo('selected'); ?>>Paraguay</option>
                                <option value='Peru' <?php if (strtolower($this->data['country']) == 'peru' )  echo('selected'); ?>>Peru</option>
                                <option value='Philippines' <?php if (strtolower($this->data['country']) == 'philippines' )  echo('selected'); ?>>Philippines</option>
                                <option value='Poland' <?php if (strtolower($this->data['country']) == 'poland' )  echo('selected'); ?>>Poland</option>
                                <option value='Portugal' <?php if (strtolower($this->data['country']) == 'portugal' )  echo('selected'); ?>>Portugal</option>
                                <option value='Qatar' <?php if (strtolower($this->data['country']) == 'qatar' )  echo('selected'); ?>>Qatar</option>
                                <option value='Romania' <?php if (strtolower($this->data['country']) == 'romania' )  echo('selected'); ?>>Romania</option>
                                <option value='Russia' <?php if (strtolower($this->data['country']) == 'russia' )  echo('selected'); ?>>Russia</option>
                                <option value='Rwanda' <?php if (strtolower($this->data['country']) == 'rwanda' )  echo('selected'); ?>>Rwanda</option>
                                <option value='Saint Kitts and Nevis' <?php if (strtolower($this->data['country']) == 'saint kitts and nevis' )  echo('selected'); ?>>Saint Kitts and Nevis</option>
                                <option value='Saint Lucia' <?php if (strtolower($this->data['country']) == 'saint lucia' )  echo('selected'); ?>>Saint Lucia</option>
                                <option value='Saint Vincent and the Grenadines' <?php if (strtolower($this->data['country']) == 'saint vincent and the grenadines' )  echo('selected'); ?>>Saint Vincent and the Grenadines</option>
                                <option value='Samoa ' <?php if (strtolower($this->data['country']) == 'samoa ' )  echo('selected'); ?>>Samoa </option>
                                <option value='San Marino' <?php if (strtolower($this->data['country']) == 'san marino' )  echo('selected'); ?>>San Marino</option>
                                <option value='Sao Tome and Principe' <?php if (strtolower($this->data['country']) == 'sao tome and principe' )  echo('selected'); ?>>Sao Tome and Principe</option>
                                <option value='Saudi Arabia' <?php if (strtolower($this->data['country']) == 'saudi arabia' )  echo('selected'); ?>>Saudi Arabia</option>
                                <option value='Senegal' <?php if (strtolower($this->data['country']) == 'senegal' )  echo('selected'); ?>>Senegal</option>
                                <option value='Serbia' <?php if (strtolower($this->data['country']) == 'serbia' )  echo('selected'); ?>>Serbia</option>
                                <option value='Seychelles' <?php if (strtolower($this->data['country']) == 'seychelles' )  echo('selected'); ?>>Seychelles</option>
                                <option value='Sierra Leone' <?php if (strtolower($this->data['country']) == 'sierra leone' )  echo('selected'); ?>>Sierra Leone</option>
                                <option value='Singapore' <?php if (strtolower($this->data['country']) == 'singapore' )  echo('selected'); ?>>Singapore</option>
                                <option value='Slovakia' <?php if (strtolower($this->data['country']) == 'slovakia' )  echo('selected'); ?>>Slovakia</option>
                                <option value='Slovenia' <?php if (strtolower($this->data['country']) == 'slovenia' )  echo('selected'); ?>>Slovenia</option>
                                <option value='Solomon Islands' <?php if (strtolower($this->data['country']) == 'solomon islands' )  echo('selected'); ?>>Solomon Islands</option>
                                <option value='Somalia' <?php if (strtolower($this->data['country']) == 'somalia' )  echo('selected'); ?>>Somalia</option>
                                <option value='South Africa' <?php if (strtolower($this->data['country']) == 'south africa' )  echo('selected'); ?>>South Africa</option>
                                <option value='South Korea' <?php if (strtolower($this->data['country']) == 'south korea' )  echo('selected'); ?>>South Korea</option>
                                <option value='South Sudan' <?php if (strtolower($this->data['country']) == 'south sudan' )  echo('selected'); ?>>South Sudan</option>
                                <option value='Spain ' <?php if (strtolower($this->data['country']) == 'spain ' )  echo('selected'); ?>>Spain </option>
                                <option value='Sri Lanka' <?php if (strtolower($this->data['country']) == 'sri lanka' )  echo('selected'); ?>>Sri Lanka</option>
                                <option value='Sudan' <?php if (strtolower($this->data['country']) == 'sudan' )  echo('selected'); ?>>Sudan</option>
                                <option value='Suriname' <?php if (strtolower($this->data['country']) == 'suriname' )  echo('selected'); ?>>Suriname</option>
                                <option value='Swaziland ' <?php if (strtolower($this->data['country']) == 'swaziland ' )  echo('selected'); ?>>Swaziland </option>
                                <option value='Sweden' <?php if (strtolower($this->data['country']) == 'sweden' )  echo('selected'); ?>>Sweden</option>
                                <option value='Switzerland' <?php if (strtolower($this->data['country']) == 'switzerland' )  echo('selected'); ?>>Switzerland</option>
                                <option value='Syria' <?php if (strtolower($this->data['country']) == 'syria' )  echo('selected'); ?>>Syria</option>
                                <option value='Taiwan' <?php if (strtolower($this->data['country']) == 'taiwan' )  echo('selected'); ?>>Taiwan</option>
                                <option value='Tajikistan' <?php if (strtolower($this->data['country']) == 'tajikistan' )  echo('selected'); ?>>Tajikistan</option>
                                <option value='Tanzania' <?php if (strtolower($this->data['country']) == 'tanzania' )  echo('selected'); ?>>Tanzania</option>
                                <option value='Thailand ' <?php if (strtolower($this->data['country']) == 'thailand ' )  echo('selected'); ?>>Thailand </option>
                                <option value='Timor-Leste' <?php if (strtolower($this->data['country']) == 'timor-leste' )  echo('selected'); ?>>Timor-Leste</option>
                                <option value='Togo' <?php if (strtolower($this->data['country']) == 'togo' )  echo('selected'); ?>>Togo</option>
                                <option value='Tonga' <?php if (strtolower($this->data['country']) == 'tonga' )  echo('selected'); ?>>Tonga</option>
                                <option value='Trinidad and Tobago' <?php if (strtolower($this->data['country']) == 'trinidad and tobago' )  echo('selected'); ?>>Trinidad and Tobago</option>
                                <option value='Tunisia' <?php if (strtolower($this->data['country']) == 'tunisia' )  echo('selected'); ?>>Tunisia</option>
                                <option value='Turkey' <?php if (strtolower($this->data['country']) == 'turkey' )  echo('selected'); ?>>Turkey</option>
                                <option value='Turkmenistan' <?php if (strtolower($this->data['country']) == 'turkmenistan' )  echo('selected'); ?>>Turkmenistan</option>
                                <option value='Tuvalu' <?php if (strtolower($this->data['country']) == 'tuvalu' )  echo('selected'); ?>>Tuvalu</option>
                                <option value='Uganda' <?php if (strtolower($this->data['country']) == 'uganda' )  echo('selected'); ?>>Uganda</option>
                                <option value='Ukraine' <?php if (strtolower($this->data['country']) == 'ukraine' )  echo('selected'); ?>>Ukraine</option>
                                <option value='United Arab Emirates' <?php if (strtolower($this->data['country']) == 'united arab emirates' )  echo('selected'); ?>>United Arab Emirates</option>
                                <option value='United Kingdom' <?php if (strtolower($this->data['country']) == 'united kingdom' )  echo('selected'); ?>>United Kingdom</option>
                                <option value='Uruguay' <?php if (strtolower($this->data['country']) == 'uruguay' )  echo('selected'); ?>>Uruguay</option>
                                <option value='Uzbekistan' <?php if (strtolower($this->data['country']) == 'uzbekistan' )  echo('selected'); ?>>Uzbekistan</option>
                                <option value='Vanuatu' <?php if (strtolower($this->data['country']) == 'vanuatu' )  echo('selected'); ?>>Vanuatu</option>
                                <option value='Venezuela' <?php if (strtolower($this->data['country']) == 'venezuela' )  echo('selected'); ?>>Venezuela</option>
                                <option value='Vietnam' <?php if (strtolower($this->data['country']) == 'vietnam' )  echo('selected'); ?>>Vietnam</option>
                                <option value='Yemen' <?php if (strtolower($this->data['country']) == 'yemen' )  echo('selected'); ?>>Yemen</option>
                                <option value='Zambia' <?php if (strtolower($this->data['country']) == 'zambia' )  echo('selected'); ?>>Zambia</option>
                                <option value='Zimbabwe' <?php if (strtolower($this->data['country']) == 'zimbabwe' )  echo('selected'); ?>>Zimbabwe</option>
                            </select>
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="canRelocateLabel" for="canRelocate">Best Time To Call:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="bestTimeToCall" name="bestTimeToCall" value="<?php $this->_($this->data['bestTimeToCall']); ?>" style="width: 150px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="contact_typeLabel" for="contact_type">Contact Type:</label>
                        </td>
                        <td class="tdData">
                            <!--<select id="contact_type" name="contact_type" class="inputbox" style="width:300px;">
                                <option value=""></option>
                                <option value="Contract Only" <?php if (strtolower($this->data['contact_type']) == 'Contract Only') echo('selected'); ?>>Contract Only</option>
                                <option value="Staff Only" <?php if (strtolower($this->data['contact_type']) == 'Staff Only') echo('selected'); ?>>Staff Only</option>
                                <option value="Either" <?php if (strtolower($this->data['contact_type']) == 'Either') echo('selected'); ?>>Either</option>                                
                            </select>-->
							<select id="contact_type" name="contact_type" class="inputbox" style="width:200px;">
								<option value=""></option>
								<option value="Contract" <?php if (strtolower($this->data['contact_type']) == 'contract' )  echo('selected'); ?>>Contract</option>
								<option value="Staff" <?php if (strtolower($this->data['contact_type']) == 'staff' )  echo('selected'); ?>>Staff</option>
								<option value="Either" <?php if (strtolower($this->data['contact_type']) == 'either' )  echo('selected'); ?>>Either</option>
							</select>
                        </td>
                    </tr>                    
                    
					<?php if(intval($_SESSION['CATS']->getAccessLevel()) != ACCESS_LEVEL_CANDIDATE) {?>
                    <tr>
                        <td class="tdVertical">
                            <label id="crclassification_label" for="crclassification">CR Classification:</label>
                        </td>
                        <td class="tdData">
							<select id="crclassification" name="crclassification" class="inputbox" style="width:200px;">
                                <option value="">---</option>
								<option value="Racetrack Star" <?php if (strtolower($this->data['crclassification']) == 'racetrack star' )  echo('selected'); ?>>Racetrack Star</option>
								<option value="Target Driver" <?php if (strtolower($this->data['crclassification']) == 'target driver' )  echo('selected'); ?>>Target Driver</option>
								<option value="Pit Crew" <?php if (strtolower($this->data['crclassification']) == 'pit crew' )  echo('selected'); ?>>Pit Crew (Worth Interviewing)</option>
								<option value="Not Recommended" <?php if (strtolower($this->data['crclassification']) == 'not recommended' )  echo('selected'); ?>>Not Recommended</option>
								<option value="Not Reachable" <?php if (strtolower($this->data['crclassification']) == 'not reachable' )  echo('selected'); ?>>Not Reachable</option>
								<option value="Blacklisted" <?php if (strtolower($this->data['crclassification']) == 'blacklisted' )  echo('selected'); ?>>Blacklisted</option>
							</select>
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="tdVertical">
                            <label id="communication_label" for="communication">Speech:</label>
                        </td>
                        <td class="tdData">
							<select id="communication" name="communication" class="inputbox" style="width:200px;">
                                <option value="">---</option>
								<option value="Articulate" <?php if (strtolower($this->data['communication']) == 'articulate' )  echo('selected'); ?>>Articulate</option>
								<option value="Clear English" <?php if (strtolower($this->data['communication']) == 'clear english' )  echo('selected'); ?>>Clear English</option>
								<option value="Accented" <?php if (strtolower($this->data['communication']) == 'accented' )  echo('selected'); ?>>Accented (but understandable)</option>
								<option value="Not Acceptable" <?php if (strtolower($this->data['communication']) == 'not acceptable' )  echo('selected'); ?>>Not Acceptable</option>
							</select>&nbsp;
                        </td>
                    </tr>
                    <?php } ?>
					
                    <tr>
                        <td class="tdVertical">
                            <label id="eligibilityLabel" for="eligibility">Eligibility:</label>
                        </td>
                        <td class="tdData">
                            <select id="eligibility" name="eligibility" class="inputbox" style="width:200px;">
                                <option value="">---</option>
                                <option value="Canadian Citizen" <?php if (strtolower($this->data['eligibility']) == 'canadian citizen') echo('selected'); ?>>Canadian Citizen</option>
                                <option value="Canadian Permanent Resident" <?php if (strtolower($this->data['eligibility']) == 'canadian permanent resident') echo('selected'); ?>>Canadian Permanent Resident</option>
                                <option value="Canadian Work Permit Holder" <?php if (strtolower($this->data['eligibility']) == 'canadian work permit holder') echo('selected'); ?>>Canadian Work Permit Holder</option>
                                <option value="Not yet eligible" <?php if (strtolower($this->data['eligibility']) == 'not yet eligible') echo('selected'); ?>>Not yet eligible</option>
                                <option value="US Citizen" <?php if (strtolower($this->data['eligibility']) == 'us citizen') echo('selected'); ?>>US Citizen</option>
                            </select>
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="tdVertical">
                            <label id="jobzoneLabel" for="jobzone">Target Job Zone:</label>
                        </td>
                        <td class="tdData">
                            <select id="jobzone" name="jobzone" class="inputbox" style="width:200px;">
                                <option value="">---</option>
                                <option value="Lower Mainland" <?php if (strtolower($this->data['jobzone']) == 'lower mainland') echo('selected'); ?>>Lower Mainland</option>
                                <option value="Calgary" <?php if (strtolower($this->data['jobzone']) == 'calgary') echo('selected'); ?>>Calgary</option>
                                <option value="Edmonton" <?php if (strtolower($this->data['jobzone']) == 'edmonton') echo('selected'); ?>>Edmonton</option>
                                <option value="GTA" <?php if (strtolower($this->data['jobzone']) == 'gta') echo('selected'); ?>>GTA</option>
                                <option value="Montreal" <?php if (strtolower($this->data['jobzone']) == 'montreal') echo('selected'); ?>>Montreal</option>
                                <option value="Will Travel" <?php if (strtolower($this->data['jobzone']) == 'will travel') echo('selected'); ?>>Will Travel</option>
                            </select>
                        </td>
                    </tr>
					
					<?php if(intval($_SESSION['CATS']->getAccessLevel()) != ACCESS_LEVEL_CANDIDATE) {?>
                    <tr>
                        <td class="tdVertical" valign="top" style="height: 28px;">
                            <label id="isHotLabel" for="isHot">Hot Candidate:</label>
                        </td>
                        <td class="tdData" >
                            <input type="checkbox" id="isHot" name="isHot"<?php if ($this->data['isHot'] == 1): ?> checked<?php endif; ?> />

                        </td>
                    </tr>
                            
                    <tr>
                        <td class="tdVertical">
                            <label id="sourceLabel" for="source">Source:</label>
                        </td>
                        <td class="tdData">
                            <select id="sourceSelect" name="source" class="inputbox" style="width: 150px;" onchange="if (this.value == 'edit') { listEditor('Sources', 'sourceSelect', 'sourceCSV', false, ''); this.value = '(none)'; } if (this.value == 'nullline') { this.value = '(none)'; }">
                                <option value="edit">(Edit Sources)</option>
                                <option value="nullline">-------------------------------</option>
                                <?php if ($this->sourceInRS == false): ?>
                                    <?php if ($this->data['source'] != '(none)'): ?>
                                        <option value="(none)">(None)</option>
                                    <?php endif; ?>
                                    <option value="<?php $this->_($this->data['source']); ?>" selected="selected"><?php $this->_($this->data['source']); ?></option>
                                <?php else: ?>
                                    <option value="(none)">(None)</option>
                                <?php endif; ?>
                                <?php foreach ($this->sourcesRS AS $index => $source): ?>
                                    <option value="<?php $this->_($source['name']); ?>" <?php if ($source['name'] == $this->data['source']): ?>selected<?php endif; ?>><?php $this->_($source['name']); ?></option>
                                <?php endforeach; ?>
                            </select>
                            <input type="hidden" id="sourceCSV" name="sourceCSV" value="<?php $this->_($this->sourcesString); ?>" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="ownerLabel" for="owner">Owner:</label>
                        </td>
                        <td class="tdData">
                            <select id="owner" name="owner" class="inputbox" style="width: 150px;" <?php if (!$this->emailTemplateDisabled): ?>onchange="document.getElementById('divOwnershipChange').style.display=''; <?php if ($this->canEmail): ?>document.getElementById('checkboxOwnershipChange').checked=true;<?php endif; ?>"<?php endif; ?>>
                                <option value="-1">None</option>

                                <?php foreach ($this->usersRS as $rowNumber => $usersData): ?>
                                    <?php if ($this->data['owner'] == $usersData['userID']): ?>
                                        <option selected="selected" value="<?php $this->_($usersData['userID']) ?>"><?php $this->_($usersData['lastName']) ?>, <?php $this->_($usersData['firstName']) ?></option>
                                    <?php else: ?>
                                        <option value="<?php $this->_($usersData['userID']) ?>"><?php $this->_($usersData['lastName']) ?>, <?php $this->_($usersData['firstName']) ?></option>
                                    <?php endif; ?>
                                <?php endforeach; ?>
                            </select>&nbsp;*
                            <div style="display:none;" id="divOwnershipChange">
                                <input type="checkbox" name="ownershipChange" id="checkboxOwnershipChange" <?php if (!$this->canEmail): ?>disabled<?php endif; ?>> E-Mail new owner of change
                            </div>
                        </td>
                    </tr>
					<?php } ?>
                     <tr>
                        <td class="tdVertical">
                            <label id="sourceLabel" for="image">Picture:</label>
                        </td>
                        <td class="tdData">
                            <input type="button" class="button" id="addImage" name="addImage" value="Edit Profile Picture" style="width:150px;" onclick="showPopWin('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=addEditImage&amp;candidateID=<?php echo($this->candidateID); ?>', 400, 370, null); return false;" />&nbsp;
                        </td>
                    </tr>
                </table>
               
                <?php if($this->EEOSettingsRS['enabled'] == 1): ?>
                    <?php if(!$this->EEOSettingsRS['canSeeEEOInfo']): ?>
                        <table class="editTable" width="700">
                            <tr>
                                <td>
                                    Editing EEO data is disabled.
                                </td>
                            </tr>
                        </tr>
                        <table class="editTable" width="700" style="display:none;">
                    <?php else: ?>
                        <table class="editTable" width="700">
                    <?php endif; ?>               

                         <?php if ($this->EEOSettingsRS['genderTracking'] == 1): ?>
                             <tr>
                                <td class="tdVertical">
                                    <label id="canRelocateLabel" for="canRelocate">Gender:</label>
                                </td>
                                <td class="tdData">
                                    <select id="gender" name="gender" class="inputbox" style="width:200px;">
                                        <option value="">----</option>
                                        <option value="m" <?php if (strtolower($this->data['eeoGender']) == 'm') echo('selected'); ?>>Male</option>
                                        <option value="f" <?php if (strtolower($this->data['eeoGender']) == 'f') echo('selected'); ?>>Female</option>
                                    </select>
                                </td>
                             </tr>
                         <?php endif; ?>
                         <?php if ($this->EEOSettingsRS['ethnicTracking'] == 1): ?>
                             <tr>
                                <td class="tdVertical">
                                    <label id="canRelocateLabel" for="canRelocate">Ethnic Background:</label>
                                </td>
                                <td class="tdData">
                                    <select id="race" name="race" class="inputbox" style="width:200px;">
                                        <option value="">----</option>
                                        <option value="1" <?php if ($this->data['eeoEthnicTypeID'] == 1) echo('selected'); ?>>American Indian</option>
                                        <option value="2" <?php if ($this->data['eeoEthnicTypeID'] == 2) echo('selected'); ?>>Asian or Pacific Islander</option>
                                        <option value="3" <?php if ($this->data['eeoEthnicTypeID'] == 3) echo('selected'); ?>>Hispanic or Latino</option>
                                        <option value="4" <?php if ($this->data['eeoEthnicTypeID'] == 4) echo('selected'); ?>>Non-Hispanic Black</option>
                                        <option value="5" <?php if ($this->data['eeoEthnicTypeID'] == 5) echo('selected'); ?>>Non-Hispanic White</option>
                                    </select>
                                </td>
                             </tr>
                         <?php endif; ?>
                         <?php if ($this->EEOSettingsRS['veteranTracking'] == 1): ?>
                             <tr>
                                <td class="tdVertical">
                                    <label id="canRelocateLabel" for="canRelocate">Vetran Status:</label>
                                </td>
                                <td class="tdData">
                                    <select id="veteran" name="veteran" class="inputbox" style="width:200px;">
                                        <option value="">----</option>
                                        <option value="1" <?php if ($this->data['eeoVeteranTypeID'] == 1) echo('selected'); ?>>No</option>
                                        <option value="2" <?php if ($this->data['eeoVeteranTypeID'] == 2) echo('selected'); ?>>Eligible Veteran</option>
                                        <option value="3" <?php if ($this->data['eeoVeteranTypeID'] == 3) echo('selected'); ?>>Disabled Veteran</option>
                                        <option value="4" <?php if ($this->data['eeoVeteranTypeID'] == 4) echo('selected'); ?>>Eligible and Disabled</option>
                                    </select>
                                </td>
                             </tr>
                         <?php endif; ?>
                         <?php if ($this->EEOSettingsRS['disabilityTracking'] == 1): ?>
                             <tr>
                                <td class="tdVertical">
                                    <label id="canRelocateLabel" for="canRelocate">Disability Status:</label>
                                </td>
                                <td class="tdData">
                                    <select id="disability" name="disability" class="inputbox" style="width:200px;">
                                        <option value="">----</option>
                                        <option value="No" <?php if ($this->data['eeoDisabilityStatus'] == 'No') echo('selected'); ?>>No</option>
                                        <option value="Yes" <?php if ($this->data['eeoDisabilityStatus'] == 'Yes') echo('selected'); ?>>Yes</option>
                                    </select>
                                </td>
                             </tr>
                         <?php endif; ?>
                    </table>
                <?php endif; ?>

                <table class="editTable" width="700">
                    
                    <?php for ($i = 0; $i < count($this->extraFieldRS); $i++): ?>
                        <tr>
                            <td class="tdVertical" id="extraFieldTd<?php echo($i); ?>">
                                <label id="extraFieldLbl<?php echo($i); ?>">
                                    <?php $this->_($this->extraFieldRS[$i]['fieldName']); ?>:
                                </label>
                            </td>
                            <td class="tdData" id="extraFieldData<?php echo($i); ?>">
                                <?php echo($this->extraFieldRS[$i]['editHTML']); ?>
                            </td>
                        </tr>
                    <?php endfor; ?>

                    <tr>
                        <td class="tdVertical">
                            <label id="canRelocateLabel" for="canRelocate">Can Relocate:</label>
                        </td>
                        <td class="tdData">                            
                            <select name="canRelocate" id="canRelocate">
                            	<option value="2" <?php if ($this->data['canRelocate'] == 2) echo('selected'); ?>>-</option>
                                <option value="1" <?php if ($this->data['canRelocate'] == 1) echo('selected'); ?>>yes</option>
                                <option value="0" <?php if ($this->data['canRelocate'] == 0) echo('selected'); ?>>no</option>
                            </select>
                        </td>
                    </tr>


                    <tr>
                        <td class="tdVertical">
                            <label id="dateAvailableLabel" for="dateAvailable">Date Available:</label>
                        </td>
                        <td class="tdData">
                            <?php if (!empty($this->data['dateAvailable'])): ?>
                                <script type="text/javascript">DateInput('dateAvailable', false, 'MM-DD-YY', '<?php echo($this->data['dateAvailableMDY']); ?>', -1);</script>
                            <?php else: ?>
                                <script type="text/javascript">DateInput('dateAvailable', false, 'MM-DD-YY', '', -1);</script>
                            <?php endif; ?>
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="currentEmployerLabel" for="currentEmployer">Current Employer:</label>
                        </td>
                        <td class="tdData">
                            <input type="hidden" name="companyID" id="companyID" value="<?php $this->_($this->data['companyID']); ?>" />
							<input type="text" name="currentEmployer" id="currentEmployer" value="<?php $this->_($this->data['currentEmployer']); ?>" class="inputbox" style="width: 158px" onFocus="suggestListActivate('getCompanyNames', 'currentEmployer', 'CompanyResults', 'companyID', 'ajaxTextEntryHover', 0, '<?php echo($this->sessionCookie); ?>', 'helpShim');" />
							<script type="text/javascript">watchCompanyIDChange('<?php echo($this->sessionCookie); ?>');</script>
							<br />
							<iframe id="helpShim" src="javascript:void(0);" scrolling="no" frameborder="0" style="position:absolute; display:none;"></iframe>
							<div id="CompanyResults" class="ajaxSearchResults"></div>
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="currentPayLabel" for="currentEmployer">Current Pay:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" name="currentPay" id="currentPay" value="<?php $this->_($this->data['currentPay']); ?>" class="inputbox" style="width: 158px" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="desiredPayLabel" for="currentEmployer">Desired Pay:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" name="desiredPay" id="desiredPay" value="<?php $this->_($this->data['desiredPay']); ?>" class="inputbox" style="width: 158px" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="keySkillsLabel" for="keySkills">Key Skills:</label>
                        </td>
                        <td class="tdData">
							<div style="display:none;" disabled="disabled" id="data_tmp" name="data_tmp">
								<br><span><i>Specialization: </i></span>
								<input type="text" value="" name="" id="" style="display: inline; width: 350px;">
								<a href="javascript: void(0);" onclick="javascript: delete_Roles(this);"><b>[-]</b></a>
								<a href="javascript: void(0);" onclick="javascript: add_Roles(this);"><b>[+]</b>Add Roles</a>
							</div>	
							<div style="display:none;" disabled="disabled" id="data_tmp_2" name="data_tmp_2">
									<?php echo $role_sel; ?> - <b> <?php echo $year_sel; ?> yr</b>
									<a href="javascript: void(0);" onclick="javascript: delete_Roles(this);"><b>[-]</b></a>
									<br>
							</div>	
							<div id="specHolder">
								<div class="data_row">&nbsp;
                            <?php 
							$del_Roles = '<a href="javascript: void(0);" onclick="javascript: delete_Roles(this);"><b>[-]</b></a>';
							$add_Roles = '<a href="javascript: void(0);" onclick="javascript: add_Roles(this);"><b>[+]</b>Add Roles</a>';
							
							$dataStrSkills = $this->data['keySkills'];
							$dataArrSkills = explode(',',$dataStrSkills);
							$sp = '';
							$roles_ptr = 0;
							$spec_ptr = 0;
							$spec_current = 0;
							foreach($dataArrSkills as $val){
								if(strpos($val,":") !== false){
									$col = explode(":", $val);
									$specialization = isset($col[0]) ? trim($col[0]) : false;
									$roles = isset($col[1]) ? trim($col[1]) : false;
									$yr = isset($col[2]) ? trim($col[2]) : false;
								} else {
									$specialization = $val;
									$roles = false;
									$yr = false;
								}
								$roles_ptr++;
								if($sp != $specialization){
									echo '</div><div class="data_row"><br><span><i>Specialization: </i></span><input type="text" name="spec['.$spec_ptr.']" style="display: inline; width: 350px;" value="'.$specialization.'">'.
											"\r\n\t\t\t\t".$del_Roles.
											"\r\n\t\t\t\t".$add_Roles;
									$sp = $specialization;
									$roles_ptr = 0;
									$spec_current = $spec_ptr;
									$spec_ptr++;
								}
								if($roles){
									echo '<div style="padding-left: 130px; margin-top:5px;">';
									if(strpos($role_sel,$roles) !== false){
										$role_input = str_replace('"'.$roles.'" ','"'.$roles.'" selected="selected"',$role_sel);
									} else {
										$role_input = str_replace('"" >Unknown','"'.$roles.'" selected="selected">'.$roles,$role_sel);
									}
									$role_input = str_replace('role_id=""','id="role'.$spec_current.$roles_ptr.'"',$role_input);
									$role_input = str_replace('role_name=""','name="role['.$spec_current.'][]"',$role_input);
									echo $role_input;
								}
								$roles_btn = $roles_ptr == 0 ? $del_Roles : $del_Roles;

								if( $roles ){
									if( $yr ){
										$yr_input = str_replace('"'.$yr.'" ','"'.$yr.'" selected="selected"',$year_sel);
									} else {
										$yr_input = str_replace('"" >Unknown','"" selected="selected">Unknown',$year_sel);
									}
									$yr_input = str_replace('yr_id=""','id="yr'.$spec_current.$roles_ptr.'"',$yr_input);
									$yr_input = str_replace('yr_name=""','name="yr['.$spec_current.'][]"',$yr_input);
									echo ' - <b>'.$yr_input.' yr</b>'."\r\n\t\t\t".$roles_btn.'</div>';
								}
							}
							
							?>
								</div>
							</div>
                            <!--<input type="text" class="inputbox" id="keySkills" name="keySkills" value="<?php $this->_($this->data['keySkills']); ?>" style="width: 400px; float: left;" />-->
							<!--<a href="javascript: void(0);" > Edit </a>-->
							<span > &nbsp; </span>
							<!--<input type="button" class="button" onclick="javascript: location.href = '<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&a=editSkills&candidateID=<?php $this->_($this->data['candidateID']); ?>';" value="Add[+]" />
							-->
							<input type="button" class="button" onclick="javascript: add_Specs();" value="Add Specialization[+]" style="margin-top:20px; margin-bottom: 10px; "/>
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical">
                            <label id="notesLabel" for="notes">Misc. Notes:</label>
                        </td>
                        <td class="tdData">
                            <textarea class="inputbox" id="notes" name="notes" rows="5" style="width: 400px;"><?php $this->_($this->data['notes']); ?></textarea>
                        </td>
                    </tr>
                </table>
                <input type="submit" class="button" name="submit" id="submit" value="Save" />&nbsp;
                <input type="reset"  class="button" name="reset"  id="reset"  value="Reset" onclick="resetFormForeign();" />&nbsp;
                <input type="button" class="button" name="back"   id="back"   value="Back to Details" onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=show&amp;candidateID=<?php echo($this->candidateID); ?>');" />
            </form>

            <script type="text/javascript">
                document.editCandidateForm.firstName.focus();
				var spec_ptr = <?php echo ($spec_ptr); ?>;
				
				function add_Specs(){
					var c = document.getElementById("data_tmp").innerHTML;
					var r = document.createElement("DIV");
					c = c.replace('name=""','name="spec[' + spec_ptr + ']"');
					c = c.replace('yr_name=""','name="yr[' + spec_ptr + '][]"');
					c = c.replace('role_name=""','name="role[' + spec_ptr + '][]"');
					r.setAttribute("class","data_row");
					r.innerHTML = c;
					document.getElementById("specHolder").appendChild(r);
					spec_ptr++;
				}
				
				function add_Roles(obj){
					var c = document.getElementById("data_tmp_2").innerHTML;
					var r = document.createElement("DIV");
					var p = obj.parentNode;
					var p2 = p.parentNode;
					var sel_arr  = p.getElementsByTagName('INPUT');
					var sel_obj = sel_arr[0];
					var name_sel = sel_obj.getAttribute('name');
					var obj_ptr = name_sel.replace('spec[','').replace(']','');

					c = c.replace('yr_name=""','name="yr[' + obj_ptr + '][]"');
					c = c.replace('role_name=""','name="role[' + obj_ptr + '][]"');
					r.setAttribute("style","padding-left:130px; margin-top:5px;");
					r.innerHTML = c;
					p.appendChild(r);
					// alert(name_sel.replace('spec[','').replace(']',''));
					
					/*var p = obj.parentNode;
					var p2 = p.parentNode;
					p2.appendChild(r);*/
					/*var p = obj.nextSibling;
					p.appendChild(r);*/
				}
				
				function delete_Roles(obj){
					var p = obj.parentNode;
					var p2 = p.parentNode;
					p2.removeChild(p);
				}
				
				function deleteParent(obj){
					var p = obj.parentNode;
					var p2 = p.parentNode;
					var p3 = p2.parentNode;
					p3.removeChild(p2);
				}
            </script>
        </div>
    </div>
    <div id="bottomShadow"></div>
<?php TemplateUtility::printFooter(); ?>
