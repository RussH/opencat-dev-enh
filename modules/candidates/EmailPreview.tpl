<?php /* $Id: EmailPreview.tpl 3093 2012-03-17 21:09:45Z allan $ */ ?>
<?php 
		 TemplateUtility::printModalHeader('Candidates', array(), 'Email Preview'); 
      
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
	</style>

	<table width="100%" cellpadding="0" cellspacing="2">
    <tr>
    	<td align="left" valign="middle" class="captions">To</td>
        <td align="left" valign="middle" class="field_text"><?php echo($this->actual_recipient); ?></td>
    </tr>
    <tr>
    	<td align="left" valign="middle" class="captions">Subject</td>
        <td align="left" valign="middle" class="field_text"><?php echo($this->email_subject); ?></td>
    </tr>
    <tr>
    	<td colspan="2" valign="middle" align="right">&nbsp;</td>
    </tr>
    <tr>
    	<td colspan="2" class="fiield_text"><?php echo($this->actual_email_body); ?></td>
    </tr>
    <tr>
    	<td colspan="2" valign="middle" align="right">&nbsp;</td>
    </tr>
    </table>
    	
    </body>
</html>
