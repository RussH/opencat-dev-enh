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
		<script src="js/jquery.min.js"></script>
		<script src="js/ckeditor/ckeditor.js"></script>
        <div id="contents">
            <form id="templateTableForm" action="<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&a=templateDelete" method="post">
			<input type="hidden" value="" id="id_list" name="id_list">
            <input type="hidden" value="1" name="postback" id="postback">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Messaging: Templates</h2></td>
               </tr>
            </table>

            <p class="note"> List View</p>

				<table width="925" id="table688bb3eb23850c7b90a2de3c5b810f71" onmouseover="javascript:trackTableHighlight(event)" class="sortable" style="width: 725px;">
					<thead style="-moz-user-select:none; -khtml-user-select:none; user-select:none; ">
						<tr>
							<th align="left" style="width: 10px;">&nbsp;</th>
							<th align="left">Title</th>
							<th align="left">Status</th>
							<th align="left">Signature</th>
							<th align="left">Date Created</th>
							<th align="left">Date Modified</th>
						</tr>
					</thead>
					<tbody>
						<?php
							$classRow = "oddTableRow";
							foreach($this->data as $val){
								$classRow = $classRow == "evenTableRow" ? "oddTableRow" : "evenTableRow";
						?>
							<tr class="<?php echo $classRow; ?>">
								<td>
									<input type="checkbox" value="<?php echo $val['templateID']; ?>" name="id[]" id="template<?php echo $val['templateID']; ?>">
								</td>
								<td>
									<a href="<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&a=templateEdit&id=<?php echo $val['templateID']; ?>">
										<?php echo $val['title']; ?>
									</a>
								</td>
								<td>
									<?php echo strtoupper($message_status[$val['status']]); ?>
								</td>
								<td>
									<?php echo strtoupper($signature[$val['emailSignature']]); ?>
								</td>
								<td>
									<?php echo $val['dateCreated']; ?>
								</td>
								<td>
									<?php echo $val['dateModified']; ?>
								</td>
							</tr>
						<?php } ?>
					</tbody>
				</table>
				<div style="padding-left: 10px;">
					<input type="button" value="Delete" id="deleteTemplates" class="button">&nbsp;
					<input type="button" value="Add New" class="button" onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&a=templateAdd');">&nbsp;
				</div>
			</form>
		<script language="javascript">
			var contactIDTemp = ',';
			var splitStr = ',';

			$(document).ready(function(){
				$("#deleteTemplates").click(function(){
					$("#templateTableForm").submit();
				});
				
				$("input[type='checkbox']").each(function(){
					$(this).click(function(){
						var id = $(this).val();
						setIDList(id);
					});
				});
			});

			function setIDList(id){
				if(contactIDTemp.search(splitStr + id + splitStr) != -1){
					contactIDTemp = contactIDTemp.replace(splitStr + id + splitStr, splitStr);
				} else {
					contactIDTemp += id + splitStr;
				}

				var clen = contactIDTemp.length;
				var listStr = contactIDTemp.substr(1,clen - 2);
				$("#id_list").val(listStr);
			}		
		</script>
<?php TemplateUtility::printFooter(); ?>

