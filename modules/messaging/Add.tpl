<?php /* $Id: Show.tpl 2013-06-30 Ryan Barril */ ?>
<?php if (isset($this->isPopup) && $this->isPopup): ?>
    <?php TemplateUtility::printHeader('Messaging', array( 'js/activity.js', 'js/sorttable.js', 'js/match.js', 'js/lib.js', 'js/pipeline.js', 'js/attachment.js')); ?>
<?php else: ?>
    <?php TemplateUtility::printHeader('Messaging', array( 'js/activity.js', 'js/sorttable.js', 'js/match.js', 'js/lib.js', 'js/pipeline.js', 'js/attachment.js')); ?>
    <?php TemplateUtility::printHeaderBlock(); ?>
    <?php TemplateUtility::printTabs($this->active); ?>
        <div id="main">
            <?php TemplateUtility::printQuickSearch(); ?>
<?php endif; ?>
<?php
	$status = 0;
	$message_status = array(
		0 => 'Drafts',
		1 => 'On Queue',
		2 => 'Sent',
		3 => 'sent and then trash',
		4 => 'drafts and then trash',
		5 => 'failed'
	);
	$message_stat_display = strtoupper($message_status[$status]); 
?>
		<style>
			input.button:disabled {
				border: 1px solid #DDD;
				color: #DDD;
			}
			#popupTitle {
				margin-top: -4px;
			}
			div.contactEntry {
				border: 1px solid #DDD;
				width: auto;
				height: auto;
				padding-bottom: 3px;
			}
			#contactBox {
				display: block;
				height: auto;
				overflow: auto;
			}
			.suggestionsBox {
				background: rgba(255, 255, 255, 0.9) none repeat scroll 0 0;
				border: 1px solid #c9c9c9;
				border-radius: 3px;
				color: #0f5b7f;
				display: none;
				font-family: Helvetica;
				font-size: 12px;
				font-weight: 700;
				position: absolute;
				width: 350px;
				z-index: 6;
			}
		</style>
		<script src="js/jquery.min.js"></script>
		<script src="js/ckeditor/ckeditor.js"></script>
        <div id="contents">
            <form name="editMessageForm" id="editMessageForm" action="<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&a=add" method="post" onsubmit="return checkFields()">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Messaging: Add <?php echo $message_stat_display; ?> Form</h2></td>
               </tr>
            </table>

            <p class="note"> Add <?php echo ucwords($message_stat_display); ?> Form</p>

            <table class="detailsOutside" width="925">
                <tr style="vertical-align:top;">
                    <td width="100%" height="100%" valign="top">
                        <table class="detailsInside" height="100%">
                            <tr>
                                <td class="vertical">To:</td>
                                <td class="data" colspan="3">
									<div>
										<input type="text" style="width: 350px;" autocomplete="off" onchange="javascript:clearField();" onkeyup="lookup(this.value, 'recipient_name');" placeholder="Search by first or last name" name="recipient_name" id="recipient_name">
									</div>
									<div id="recipientSuggestions" class="suggestionsBox">
										<a class="close" onclick="document.getElementById('recipientSuggestions').style.display = 'none';"><u>Close</u></a>
										<div id="autoSuggestionsList" class="suggestionList"></div>
									</div>
                                    <div class="inputbox" id="contactBox" style="display:block; width: 800px; height: auto; padding: 10px 0px; border:0;"></div>
                                    <input type="hidden" value="" name="contactlist" id="contactlist">
                                    <input type="hidden" value="" name="contactgroup" id="contactgroup">
                                    <input type="hidden" value="" name="messageID" id="messageID">
                                    <input type="hidden" value="1" name="postback" id="postback">
                                </td>
                            </tr>

                            <tr>
                                <td class="vertical">Subject:</td>
                                <td class="data" colspan="3">
                                    <input type="text" value="" name="subject" id="subject" class="inputbox" style="width: 800px;padding: 0px 10px;">
                                </td>
                            </tr>

                            <tr>
                                <td class="vertical">Message:</td>
                                <td class="data" colspan="3">
									<textarea style="width: 815px; height: 200px;" name="message" id="message" class="ckeditor" ></textarea>
                                </td>
                            </tr>

                            <tr>
								<td class="vertical">&nbsp;</td>
								<td colspan="3">&nbsp;</td>
                            </tr>
							
							<tr>
								<td class="vertical">
									&nbsp;
								</td>
								<td class="data" colspan="3">
									<input type="button" class="button" name="back"   id="back"   value="Back to Details" onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&stat=2');" />&nbsp;
									<input type="button" class="button" name="save" id="save" value="Add Email Signature" onclick="insertAtCursor(document.getElementById('message'),  '%SIGNATURE%');"/>&nbsp;
									<input type="submit" class="button" name="save" id="save" value="Save" />&nbsp;
									<input type="submit" class="button" name="send" id="send" value="Send" />&nbsp;
									<!--<input type="button" class="button" name="preview" id="preview" value="Preview"  onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&amp;a=show');" />&nbsp;-->
									<input type="button" class="button" name="usetemplate" id="usetemplate" value="Use Template" />&nbsp;
								</td>
							</tr>
							
                            <tr>
								<td class="vertical">&nbsp;</td>
								<td colspan="3">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
			</form>
			<div id="templateListHolder" style="position: fixed; display:none; width: 400px; height: 350px; left: 50%; top: 50%; margin-left: -200px; margin-top: -175px;" class="inputbox">
				<div id="popupTitleBar">
					<div id="popupTitle">Template List</div>
					<div id="popupControls">
						<img width="16" height="16" onclick="closeTemplateList();" alt="X" src="js/submodal/close.gif">
					</div>
				</div>
				<div style="display:block; width:100%; height: 295px; overflow:auto;" id="templateList">
				</div>
				<div style="padding-left: 10px;">
					<input type="button" value="Load Template" id="loadTemplate" class="button disabled" disabled="disabled">&nbsp;
					<input type="button" value="Cancel" class="button" id="closeTemplateList">&nbsp;
				</div>
			</div>
			<div id="contactListHolder" style="position: fixed; display:none; width: 400px; height: 360px; left: 50%; top: 50%; margin-left: -200px; margin-top: -180px;" class="inputbox">
				<div id="popupTitleBar">
					<div id="popupTitle">Contact List</div>
					<div id="popupControls">
						<img width="16" height="16" onclick="closeContactList();" alt="X" src="js/submodal/close.gif">
					</div>
				</div>
				<div style="display:block; width:100%; height: 295px; overflow:auto; margin-bottom: 10px;" id="contactList">
				</div>
				<div style="padding-left: 40px; margin-bottom: 5px;">
					<a href="javascript:displayContactList('a');">a</a>&nbsp;
					<a href="javascript:displayContactList('b');">b</a>&nbsp;
					<a href="javascript:displayContactList('c');">c</a>&nbsp;
					<a href="javascript:displayContactList('d');">d</a>&nbsp;
					<a href="javascript:displayContactList('e');">e</a>&nbsp;
					<a href="javascript:displayContactList('f');">f</a>&nbsp;
					<a href="javascript:displayContactList('g');">g</a>&nbsp;
					<a href="javascript:displayContactList('h');">h</a>&nbsp;
					<a href="javascript:displayContactList('i');">i</a>&nbsp;
					<a href="javascript:displayContactList('j');">j</a>&nbsp;
					<a href="javascript:displayContactList('k');">k</a>&nbsp;
					<a href="javascript:displayContactList('l');">l</a>&nbsp;
					<a href="javascript:displayContactList('m');">m</a>&nbsp;
					<a href="javascript:displayContactList('n');">n</a>&nbsp;
					<a href="javascript:displayContactList('o');">o</a>&nbsp;
					<a href="javascript:displayContactList('p');">p</a>&nbsp;
					<a href="javascript:displayContactList('q');">q</a>&nbsp;
					<a href="javascript:displayContactList('r');">r</a>&nbsp;
					<a href="javascript:displayContactList('s');">s</a>&nbsp;
					<a href="javascript:displayContactList('t');">t</a>&nbsp;
					<a href="javascript:displayContactList('u');">u</a>&nbsp;
					<a href="javascript:displayContactList('v');">v</a>&nbsp;
					<a href="javascript:displayContactList('w');">w</a>&nbsp;
					<a href="javascript:displayContactList('x');">x</a>&nbsp;
					<a href="javascript:displayContactList('y');">y</a>&nbsp;
					<a href="javascript:displayContactList('z');">z</a>
				</div>
				<!--<div style="padding-left: 10px;">
					<input type="button" value="Add to Contact List" id="addContact" class="button disabled" disabled="disabled">&nbsp;
					<input type="button" value="Cancel" class="button" id="closeContactList">&nbsp;
				</div>
				<div id="contactDisplayTempHolder" style="display:none; border: 1px solid #444;"></div>-->
			</div>
		<script language="javascript">
			var templateID = 0;
			var oldTemplateID = 0;
			var splitStr = ',';
			var contactIDlist = '';
			var contactIDTemp = ',';
			$(document).ready(function(){
				$("#loadTemplate").click(function(){
					loadTemplate(templateID);
				});
				$("#closeTemplateList").click(function(){
					closeTemplateList();
				});
				$("#usetemplate").click(function(){
					showTemplateList();
				});
				$("#addContact").click(function(){
					addContacttoList();
				});
				$("#closeContactList").click(function(){
					closeContactList();
				});
				/*
				$("#contactBox").click(function(){
					showContactList();
				});*/
				contactIDTemp = $("#contactlist").val() == '' ? ',' : splitStr + $("#contactlist").val() + splitStr ;
			});
			
			function setContactList(id){
				document.getElementById('recipientSuggestions').style.display = 'none';
				if(contactIDTemp.search(splitStr + id + splitStr) != -1){
					$("#div" + id).css({"background":"url('images/checkbox_blank.gif') no-repeat 8px 3px"});
					contactIDTemp = contactIDTemp.replace(splitStr + id + splitStr, splitStr);
					$("#cEntry" + id).remove();
				} else {
					$("#div" + id).css({"background":"url('images/checkbox.gif') no-repeat 8px 3px"});
					contactIDTemp += id + splitStr;
					var idsplit1 = String(id);
					var idsplit = idsplit1.split('.');
					var divEntry = $("<div />").attr({'id':'cEntry'+id,'class':'contactEntry'}).html($("#div" + idsplit[0] + '\\.'+idsplit[1]).html());
					// $("#contactDisplayTempHolder").append(divEntry);
					$("#contactBox").append(divEntry);
				}
				
				var clen = contactIDTemp.length;
				var listStr = contactIDTemp.substr(1,clen - 2);
				$("#contactlist").val(listStr);

				// document.title = contactIDTemp;
				// if(contactIDTemp == splitStr){
					// $("#addContact").attr("disabled","disabled");
				// } else {
					// $("#addContact").removeAttr("disabled");
				// }
			}
			
			function closeContactList(){
				// contactIDTemp = splitStr;
				$("#addContact").attr("disabled","disabled");
				$("#contactListHolder").hide();
				// $("#contactDisplayTempHolder").html("");
			}
			
			function closeTemplateList(){
				$("#loadTemplate").attr("disabled","disabled");
				$("#templateListHolder").hide();
			}
			
			function updateList(){
				var clen = contactIDTemp.length;
				var listStr = contactIDTemp.substr(1,clen - 2);
				var listArr = listStr.split(splitStr);
				for(var v in listArr){
					if(listArr[v] != ''){
						$("#div" + listArr[v]).css({"background":"url('images/checkbox.gif') no-repeat 8px 3px"});
					}
				}
			}
			
			function addContacttoList(contactID){
				var clen = contactIDTemp.length;
				var list = $("#contactlist").val();
				var listStr = contactIDTemp.substr(1,clen - 2);
				var listAddStr = list.length > 0 ? ',' : '';
				var Alllist = list + listAddStr + listStr;
				// var contactEntry = $("#contactDisplayTempHolder").html();
				// $("#contactlist").val(Alllist);
				// $("#contactBox").append(contactEntry);
				$("#contactlist").val(listStr);
				$("#contactBox").append(contactEntry);

				closeContactList();
			}			
			
			function showContactList(){
				var str = 'm=messaging&a=loadContactList';
				document.title = 'retrieving contact list...';
				$.get('<?php echo(CATSUtility::getIndexName()); ?>', str, function(success){
					if(success != ''){
						$("#contactList").html(success);
						$("#contactListHolder").show();
						document.title = 'Contact List loaded';
						// contactIDTemp = splitStr + $("#contactlist").val() + splitStr;
						updateList();
					} else {
						document.title = 'Cant retrieve data';
					}
				});
			}
			
			function displayContactList(letter){
				var str = 'm=messaging&a=loadContactList&alpha=' + letter;
				document.title = 'retrieving contact list...';
				$.get('<?php echo(CATSUtility::getIndexName()); ?>', str, function(success){
					if(success != ''){
						$("#contactList").html(success);
						// $("#contactListHolder").show();
						document.title = 'Contact List loaded';
						updateList();
					} else {
						document.title = 'Cant retrieve data';
					}
				});
			}
			
			function showTemplateList(){
				var str = 'm=messaging&a=loadTemplateList';
				document.title = 'retrieving template list...';
				$.get('<?php echo(CATSUtility::getIndexName()); ?>', str, function(success){
					if(success != ''){
						$("#templateList").html(success);
						$("#templateListHolder").show();
						document.title = 'Template List loaded';
					} else {
						document.title = 'Cant retrieve data';
					}
				});
			}
			
			function setTemplateID(id){
				oldTemplateID = templateID;
				templateID = id;
				$("#loadTemplate").removeAttr("disabled");
				$("#div" + oldTemplateID).css({"background":"url('images/checkbox_blank.gif') no-repeat 8px 3px"});
				$("#div" + templateID).css({"background":"url('images/checkbox.gif') no-repeat 8px 3px"});
			}
			
			function loadTemplate(id){
				if(id != 0){
					var str = 'm=messaging&a=loadTemplate&templateID=' + id;
					document.title = 'retrieving template list...';
					$.get('<?php echo(CATSUtility::getIndexName()); ?>', str, function(success){
						if(success != ''){
							var template = jQuery.parseJSON( success );
							
							$("#message").val(template.content);
							$("#message").html(template.content);
							$("#subject").val(template.title);
							$("#subject").html(template.title);
							
							document.title = 'Template is now loaded';
							$("#templateListHolder").hide();
							$("#loadTemplate").attr("disabled","disabled");
							CKEDITOR.instances['message'].setData($("#message").val());
							templateID = 0;
						} else {
							document.title = 'Cant load template';
						}
					});
				} else {
					alert('No template selected');
				}
			}
			
			function insertAtCursor(myField, myValue)
			{
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
					
					
					var $iframe = $('.cke_wysiwyg_frame');
					$iframe.ready(function() {
						$iframe.contents().find("body").append(myValue);
					});
				}
				else
				{
					myField.value += myValue;
				}
			}
			
			function clearField() {
				$('#recipient_id').val('');
				$('#recipient_name').val('');
			}
			function lookup(inputString, e) {
				var recipientSuggestions = $('#recipientSuggestions');
				var autoSuggestionsList = $('#autoSuggestionsList');
				var wrapper = $('#'+e+'Suggestions');
				var container = $('#'+e+'Suggestions .suggestionList');

				if(inputString.length == 0) {
					recipientSuggestions.hide();
				} else {
					var str = 'm=messaging&a=loadContactList&alpha=' + inputString;
					$.get('<?php echo(CATSUtility::getIndexName()); ?>', str, function(success){
						if(success != ''){
							recipientSuggestions.show();
							autoSuggestionsList.html(success);;
							//updateList();
						} else {
							recipientSuggestions.show();
							autoSuggestionsList.html('<li><span style="color:#a1a1a1">Recipient not found</span></li>');
						}
					});
				}
			}
			function checkFields() {
				var contactlist = document.forms["editMessageForm"]["contactlist"].value;
				var subject = document.forms["editMessageForm"]["subject"].value;
				var message = document.forms["editMessageForm"]["message"].value;
				if (contactlist == null || contactlist == "") {
					alert("Please specify at least one recipient.");
					return false;
				}
				if (subject == null || subject == "") {
					alert("Please fill in the subject of this message.");
					return false;
				}
				if (message == null || message == "") {
					alert("Please fill in the text of this message.");
					return false;
				}
			}
		</script>
<?php TemplateUtility::printFooter(); ?>