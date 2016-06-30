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
		0 => 'original',
		1 => 'modified',
		2 => 'trash',
		3 => 'trash'
	);
	$message_stat_display = strtoupper($message_status[$status]); 
	$signature = array(
		0 => 'no',
		1 => 'yes',
	);
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
				display: inline;
				border: 1px solid #DDD;
				width: auto;
				height: auto;
				padding: 3px;
				margin: 5px;
			}
			#contactBox {
				display: block;
				height: auto;
				overflow: auto;
			}
		</style>
		<script src="js/jquery.min.js"></script>
		<script src="js/ckeditor/ckeditor.js"></script>
        <div id="contents">
            <form action="<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&a=templateAdd" method="post">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Messaging: Add Template Form</h2></td>
               </tr>
            </table>

            <p class="note"> Add Template Form</p>

            <input type="hidden" value="1" name="postback" id="postback">
            <table class="detailsOutside" width="925">
                <tr style="vertical-align:top;">
                    <td width="100%" height="100%" valign="top">
                        <table class="detailsInside" height="100%">
                            <tr>
                                <td class="vertical">Title:</td>
                                <td class="data" colspan="3">
                                    <input type="text" value="" name="title" id="title" class="inputbox" style="width: 800px;">
                                </td>
                            </tr>

                            <tr>
                                <td class="vertical">Message:</td>
                                <td class="data" colspan="3">
									<textarea style="width: 800px; height: 200px;" name="content" id="content" class="ckeditor" ></textarea>
                                </td>
                            </tr>

                            <tr>
                                <td class="vertical">Signature:</td>
                                <td class="data" colspan="3">
									<select name="signature" id="signature">
										<option value="0">No</option>
										<option value="1">Yes</option>
									</select>
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
									<input type="button" class="button" name="back"   id="back"   value="Back to Details" onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&a=templates');" />&nbsp;
									<input type="submit" class="button" name="submit" id="submit" value="Save" />&nbsp;
									<!--<input type="button" class="button" name="preview" id="preview" value="Preview"  onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&amp;a=show&amp;messageID=<?php $this->_($this->data['messagingID']); ?>');" />&nbsp;-->
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
					<div id="popupTitle">Contast List</div>
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
				$("#contactBox").click(function(){
					showContactList();
				});
				contactIDTemp = $("#contactlist").val() == '' ? ',' : splitStr + $("#contactlist").val() + splitStr ;
			});
			
			function setContactList(id){
				if(contactIDTemp.search(splitStr + id + splitStr) != -1){
					$("#div" + id).css({"background":"url('images/checkbox_blank.gif') no-repeat 8px 3px"});
					contactIDTemp = contactIDTemp.replace(splitStr + id + splitStr, splitStr);
					$("#cEntry" + id).remove();
				} else {
					$("#div" + id).css({"background":"url('images/checkbox.gif') no-repeat 8px 3px"});
					contactIDTemp += id + splitStr;
					var divEntry = $("<div />").attr({'id':'cEntry'+id,'class':'contactEntry'}).html($("#div" + id).html());
					// $("#contactDisplayTempHolder").append(divEntry);
					$("#contactBox").append(divEntry);
				}

				var clen = contactIDTemp.length;
				var listStr = contactIDTemp.substr(1,clen - 2);
				$("#contactlist").val(listStr);
			}
			
			function closeContactList(){
				$("#addContact").attr("disabled","disabled");
				$("#contactListHolder").hide();
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
							$("#message").val(success);
							$("#message").html(success);
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
		</script>
<?php TemplateUtility::printFooter(); ?>

