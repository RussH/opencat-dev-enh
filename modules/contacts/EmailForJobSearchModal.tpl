<?php /* $Id: Search.tpl 3676 2007-11-21 21:02:15Z brian $ */ ?>
<?php TemplateUtility::printHeader('Contacts', array('modules/contacts/validator.js', 'js/searchSaved.js', 'js/sweetTitles.js', 'js/searchAdvanced.js', 'js/highlightrows.js', 'js/export.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active, $this->subActive); ?>
    <div id="main">
        <?php TemplateUtility::printQuickSearch(); ?>

        <div id="contents">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/contact.gif" width="24" height="24" border="0" alt="Contacts" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Contacts: Messaging</h2></td>
                </tr>
            </table>

            <p class="note">Mail Contacts</p>
				<style>
                .captions {
                    font-family: Arial, Helvetica, sans-serif;
                    font-size: 12px;
                    font-weight: bold;
                    color: #000;			
                }
                .field_text {
                    font-family: Arial, Helvetica, sans-serif;
                    font-size: 12px;
                    font-weight: normal;
                    color: #333333;			
                }
                .email_body {
                    font-family: Arial, Helvetica, sans-serif;
                    font-size: 12px;
                    font-weight: normal;
                    color: #333333;			
                    width: 100%;			
                }
                .email_button {			
                    font-family: Arial, Helvetica, sans-serif;
                    font-size: 12px;
                    font-weight: normal;
                    border:1px solid #ccc;
                    color: #111111;
                    width: 130px;
                }
                .div_body {
                    font-family: Arial, Helvetica, sans-serif;
                    font-size: 12px;
                    font-weight: normal;
                    color: #333333;			
                    border: 1px solid #ccc;;
                    width:100%;
                    height:250px;
                }
                
                .insert_button {
                    font-family: Arial, Helvetica, sans-serif;
                    font-size: 12px;
                    font-weight: normal;
                    border:1px solid #ccc;
                    color: #000;
                    width: 130px;			
                    cursor: pointer;
                    width:175px;
                }
                </style>	
                <script language="javascript">
                    function insertAtCursor(myField, myValue) {
                        if (document.selection)
                        {
                            myField.focus();
                            sel = document.selection.createRange();
                            sel.text = myValue;
                        }
                        else if (myField.selectionStart || myField.selectionStart == 0)
                        {
                            var startPos = myField.selectionStart;
                            var endPos = myField.selectionEnd;
                            myField.value = myField.value.substring(0, startPos)
                                + myValue
                                + myField.value.substring(endPos, myField.value.length);
                        }
                        else
                        {
                            myField.value += myValue;
                        }
                        //insertAtCursor(document.getElementById('messageText20'),  '%DATETIME%')
                    }
                </script>    
                
                <?php if(intval($this->stage) == 2) { ?>    
                    <table width="100%" height="100%" cellpadding="0" cellspacing="2" align="center">
                    <tr>
                        <td align="center" valign="middle" class="captions"><?php echo($this->email_result_text); ?></td>
                    </tr>
                    </table>
                <?php } elseif(intval($this->stage) == 1) { ?>   
                    <form method="post" 
                          name="email_form"
                          action="<?php echo(CATSUtility::getIndexName()); ?>?m=contacts&amp;a=emailSearchSendEmail&amp;stage=2">         
                          <input name="email_subject" id="email_subject" type="hidden" value="<?php echo($this->email_subject); ?>" />
                          <input name="stage_override" id="stage_override" type="hidden" value="2" />
                          <input name="recipient" id="recipient" type="hidden" value="<?php echo($this->recipient); ?>" />
                          <textarea style="display:none" name="email_body" id="email_body"><?php echo($this->email_body); ?></textarea>
                    <table width="100%" cellpadding="0" cellspacing="2">
                    <tr>
                        <td align="left" valign="middle" class="captions" colspan="2">(Email Preview)</td>        
                    </tr>
                    <tr>
                        <td align="left" valign="middle" class="captions">To</td>
                        <td align="left" valign="middle" class="field_text"><?php echo($this->actual_recipient); ?></td>
                    </tr>
                    <tr>
                        <td align="left" valign="middle" class="captions">Subject</td>
                        <td align="left" valign="middle" class="field_text"><?php echo($this->email_subject); ?></td>
                    </tr>
                    <tr><td colspan="2" valign="middle" align="right">&nbsp;</td></tr>
                    <tr>
                        <td colspan="2" class="field_text">
                            <!--<textarea class="div_body" readonly>-->
				<?php echo str_replace("\n","<br>",$this->actual_email_body); ?>
			    <!--</textarea>-->
                        </td>
                    </tr>
                    <tr><td colspan="2" valign="middle" align="right">&nbsp;</td></tr>
                    <tr>
                        <td colspan="2" valign="middle" align="right">
                        <a href="javascript:document.getElementById('stage_override').value='0';document.email_form.submit();" class="email_button">&lt;&lt; Back</a>
                        &nbsp;
                        <a href="javascript:document.email_form.submit();" class="email_button">Send Email</a></td>
                    </tr>
                    </table>
                    
                    </form>    
                <?php } elseif(intval($this->stage) == 0) { ?>   
                    <form method="post" 
                          name="email_form"
                          action="<?php echo(CATSUtility::getIndexName()); ?>?m=contacts&amp;a=emailSearchSendEmail&amp;stage=1">
                          <input name="stage_override" id="stage_override" type="hidden" value="1" />
                    <table width="100%" cellpadding="0" cellspacing="2">
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td align="left" valign="middle" class="captions">To</td>
                        <td align="left" valign="middle" class="field_text">
                                                        <select id="recipient" name="recipient" class="inputbox" style="width: 450px;" >
                                                            <option value="(none)" selected="selected">(Select contact...)</option>
                                                            <?php foreach ($this->contact_array as $index => $contact) { 
                                                                  $email_target = trim($contact['email1']);
								  $selected = ( isset($this->recipient) && $contact['contactID'] == $this->recipient ? ' selected="selected"' : '') ;
                                                                  if(strlen($email_target) == 0) $email_target = trim($contact['email2']);
                                                                  if(strlen($email_target)>0) {
                                                            ?>
                                                                <option value="<?php $this->_($contact['contactID']); ?>"<?php echo $selected; ?>><?php $this->_($contact['firstName'] . ' ' . $contact['lastName'] . ' ('.$email_target.')'); ?></option>
                                                            <?php 
                                                                  } 
                                                                 } ?>
                                                        </select>        
                        </td>
                    </tr>
                    <tr>
                        <td align="left" valign="middle" class="captions">Subject</td>
                        <td align="left" valign="middle" class="field_text"><input type="text" name="subject" id="subject" value="<?php echo($this->subject); ?>" class="field_text" style="width:600px" /></td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td align="left"><table width="100%" cellpadding="0" cellspacing="2" border="0">
                            <tr>
                                <td width="500" align="left" valign="top"><textarea name="email_body" id="email_body" rows="18" class="email_body" style="width:600px"><?php echo($this->emailTemplate); ?></textarea></td>
                                <td width="200" align="center" valign="top"><table width="200" border="0" cellpadding="0" cellspacing="1">
                                    <tr>
                                        <td align="center" valign="top"><span class="captions">Mail Merge Fields</span></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Current Date/Time" onclick="insertAtCursor(document.getElementById('email_body'),  '%DATETIME%');" /></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Site Name" onclick="insertAtCursor(document.getElementById('email_body'),  '%SITENAME%');" /></td>
                                    </tr>
                                    <tr><td>&nbsp;</td></tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Recruiter/Current User Name" onclick="insertAtCursor(document.getElementById('email_body'),  '%USERFULLNAME%');" /></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Recruiter/Current User E-mail Link" onclick="insertAtCursor(document.getElementById('email_body'),  '%USERMAIL%');" /></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Contact Owner" onclick="insertAtCursor(document.getElementById('email_body'),  '%CONTOWNER%');" /></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Contact First Name" onclick="insertAtCursor(document.getElementById('email_body'),  '%CONTFIRSTNAME%');" /></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Contact Full Name" onclick="insertAtCursor(document.getElementById('email_body'),  '%CONTFULLNAME%');" /></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Contacts Company Name" onclick="insertAtCursor(document.getElementById('email_body'),  '%CONTCLIENTNAME%');" /></td>
                                    </tr>                    
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="CATS Contact URL" onclick="insertAtCursor(document.getElementById('email_body'),  '%CONTCATSURL%');" /></td>
                                    </tr>
                                    <tr>
                                        <td align="center" valign="top"><input type="button" class="insert_button" value="Email Signature" onclick="insertAtCursor(document.getElementById('email_body'),  '%SIGNATURE%');" /></td>
                                    </tr>                    
                                </table></td>
                            </tr>
                            
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" valign="middle" align="right"><a href="javascript: validateFormandSend();" class="email_button" style="display:block; margin-right:40px; text-align: center">&nbsp;Preview & Send&nbsp;</a></td>
                    </tr>
                    </table>
                    </form>
		<script language="javascript">
			function validateFormandSend(){
				var result = true;
				if(document.email_form.recipient.value == '' || document.email_form.recipient.value == '(none)' ) result = false;
				if(document.email_form.subject.value == '') result = false;
				if(document.email_form.email_body.value == '') result = false;
				if(result){
					document.email_form.submit();
				} else {
					alert('Please complete the required fields.');
				}
			}
		</script>

                <?php } ?>    
            

            
        </div>
    </div>
    <div id="bottomShadow"></div>
<?php TemplateUtility::printFooter(); ?>
