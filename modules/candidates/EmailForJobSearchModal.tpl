<?php /* $Id: EmailForJobSearchNodal.tpl 3093 2012-03-17 21:09:45Z allan $ */ ?>
<?php
	TemplateUtility::printModalHeader('Candidates', array(), 'Email Job Order to Search Results ('.$this->jobOrderTitle.')'); 
?>
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
          action="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=emailSearchSendEmail&amp;stage=2&amp;jobOrderID=<?php echo($this->jobOrderID); ?>&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>&amp;jobOrderTitle=<?php echo($this->jobOrderTitle); ?>">         
          <input name="email_subject" id="email_subject" type="hidden" value="<?php echo($this->email_subject); ?>" />
          <input name="stage_override" id="stage_override" type="hidden" value="2" />
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
        	<textarea class="div_body" readonly="readonly"><?php echo($this->actual_email_body); ?></textarea>
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
          action="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=emailSearchSendEmail&amp;stage=1&amp;jobOrderID=<?php echo($this->jobOrderID); ?>&amp;candidateIDArrayStored=<?php echo($this->candidateIDArrayStored); ?>&amp;jobOrderTitle=<?php echo($this->jobOrderTitle); ?>">
          <input name="stage_override" id="stage_override" type="hidden" value="1" />
	<table width="100%" cellpadding="0" cellspacing="2">
    <tr>
    	<td align="left" valign="middle" class="captions">To</td>
        <td align="left" valign="middle" class="field_text">(<?php echo(count($this->candidateIDArray)); ?> recipients)</td>
    </tr>
    <tr>
    	<td align="left" valign="middle" class="captions">Subject</td>
        <td align="left" valign="middle" class="field_text"><input type="text" name="subject" id="subject" value="<?php echo($this->subject); ?>" class="field_text" style="width:450px" /></td>
    </tr>
    <tr>
    	<td colspan="2" align="center"><table width="100%" cellpadding="0" cellspacing="2" border="0">
        	<tr>
            	<td width="500" align="left" valign="top"><textarea name="email_body" id="email_body" rows="18" class="email_body" style="width:500px"><?php echo($this->emailTemplate); ?></textarea></td>
                <td width="200" align="center" valign="top"><table width="200" border="0" cellpadding="0" cellspacing="1">
                	<tr>
                    	<td align="center" valign="top"><span class="captions">Mail Merge Fields</span></td>
                    </tr>
                    <tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Current Date/Time" onclick="insertAtCursor(document.getElementById('email_body'),  '%DATETIME%');" /></td></td>
                    </tr>
                    <tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Site Name" onclick="insertAtCursor(document.getElementById('email_body'),  '%SITENAME%');" /></td></td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                	<tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Candidate Fullname" onclick="insertAtCursor(document.getElementById('email_body'),  '%CANDFULLNAME%');" /></td></td>
                    </tr>
                    <tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Job/Position" onclick="insertAtCursor(document.getElementById('email_body'),  '%JBODTITLE%');" /></td></td>
                    </tr>
                    <tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Company" onclick="insertAtCursor(document.getElementById('email_body'),  '%JBODCLIENT%');" /></td></td>
                    </tr>
                    <tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Job URL" onclick="insertAtCursor(document.getElementById('email_body'),  '%JBODCATSURL%');" /></td></td>
                    </tr>
                    <tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Job ID" onclick="insertAtCursor(document.getElementById('email_body'),  '%JBODID%');" /></td></td>
                    </tr>
                    <tr>
                    	<td align="center" valign="top"><input type="button" class="insert_button" value="Job Owner" onclick="insertAtCursor(document.getElementById('email_body'),  '%JBODOWNER%');" /></td></td>
                    </tr>                    
                </table></td>
            </tr>
        	
            </table>
        </td>
    </tr>
    <tr>
    	<td colspan="2" valign="middle" align="right"><a href="javascript:document.email_form.submit();" class="email_button">Preview and Send Email</a></td>
    </tr>
    </table>
    </form>
<?php } ?>    
    </body>
</html>
