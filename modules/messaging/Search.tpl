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
		<script src="js/ckeditor/ckeditor.js"></script>
		<div id="contents">
            <form name="editMessageForm" id="editMessageForm" action="<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&amp;a=search" method="post" onsubmit="return checkEditForm(document.editMessageForm);" autocomplete="off">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Messaging: Search Engine</h2></td>
               </tr>
            </table>

            <p class="note"> Search form</p>

            <table class="detailsOutside" width="925">
                <tr style="vertical-align:top;">
                    <td width="100%" height="100%" valign="top">
                        <table class="detailsInside" height="100%">
                            <tr>
                                <td class="vertical">Search:</td>
                                <td class="data" colspan="3">
                                    <input type="text" value="" name="search" id="search" class="inputbox" style="width: 400px;">
                                </td>
                            </tr>

                            <!--<tr>
                                <td class="vertical">&nbsp;
                                    <span>Include Contact field</span>
								</td>
                                <td class="data" colspan="3" align="left">
									<input type="checkbox" value="1" name="contact" id="contact" class="inputbox">
                                </td>
                            </tr>-->

                            <tr>
                                <td class="vertical">&nbsp;
                                    <span>Include Subject field</span>
								</td>
                                <td class="data" colspan="3" align="left">
									<input type="checkbox" value="1" name="subject" id="subject" class="inputbox">
                                </td>
                            </tr>

                            <tr>
								<td class="vertical">&nbsp;</td>
								<td colspan="3">&nbsp;</td>
                            </tr>

							<tr>
								<td class="data">
									<a href="<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&amp;a=messages">
										<img src="images/careers_return.gif" id="addActivityIndicator" alt="" style="margin-left: 5px;" />
									</a>
								</td>
								<td class="data">&nbsp;
									<input type="image" name="submit" src="images/message_search.gif" border="0" alt="Submit" />
								</td>
							</tr>
                        </table>
                    </td>
                </tr>
            </table>
		<?php if(isset($this->search_result) && $this->search_result === true) { ?>
			<table class="sortable" width="925">
				<tr>
					<th>ID</th>
					<th>Subject</th>
					<th>Recipients</th>
				</tr>
		<?php foreach($this->search_data['data'] as $i=>$d) { 
				$class_name = ($i%2 == 0) ?'evenTableRow':'oddTableRow';
				$subject_link = '<a href="'.CATSUtility::getIndexName().'?m=messaging&a=show&messageID='.$d['id'].'">'.$d['subject'].'</a>';
		?>
				<tr class="<?php echo $class_name; ?>">
					<td><?php echo $d['id']; ?></td>
					<td><?php echo $subject_link; ?></td>
					<td><?php echo $d['contact_list']; ?></td>
				</tr>
		<?php } ?>
			</table>
		<?php } ?>
			
<?php TemplateUtility::printFooter(); ?>

