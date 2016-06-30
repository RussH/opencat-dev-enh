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
	$status = (int)$this->data['status'];
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
        <div id="contents">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Messaging: <?php echo $message_stat_display; ?> Details</h2></td>
               </tr>
            </table>

            <p class="note"> <?php echo ucwords($message_stat_display); ?> Details</p>

            <?php if ($this->data['isAdminHidden'] == 1): ?>
                <p class="warning">This <?php echo $message_stat_display; ?> Message is hidden.  Only CATS Administrators can view it or search for it.  To make it visible by the site users, click <a href="<?php echo(CATSUtility::getIndexName()); ?>?m=candidates&amp;a=administrativeHideShow&amp;candidateID=<?php echo($this->messageID); ?>&amp;state=0" style="font-weight:bold;">Here.</a></p>
            <?php endif; ?>

            <table class="detailsOutside" width="925">
                <tr style="vertical-align:top;">
                    <td width="100%" height="100%" valign="top">
                        <table class="detailsInside" height="100%">
                            <tr>
                                <td class="vertical">To:</td>
                                <td class="data" colspan="3">
                                    <span style="font-weight: bold;" class="<?php echo($this->data['titleClass']); ?>">
                                        <?php echo $this->_($this->data['contact_list']); ?>
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td class="vertical">Subject:</td>
                                <td class="data" colspan="3">
                                    <span style="font-weight: bold;" class="<?php echo($this->data['titleClass']); ?>">
                                        <?php $this->_($this->data['subject']); ?>
                                    </span>
                                </td>
                            </tr>

                            <tr>
								<td class="vertical">&nbsp;</td>
								<td colspan="3">&nbsp;</td>
                            </tr>

                            <tr>
                                <td class="vertical">Message:</td>
                                <td style="background-color: #EFF4FE;" colspan="3">
									<div style="display:block; height: auto; width: auto; padding: 5px 20px;">
                                        <?php echo $this->data['message']; ?>
									</div>
                                </td>
                            </tr>

                            <tr>
								<td class="vertical">&nbsp;</td>
								<td colspan="3">&nbsp;</td>
                            </tr>

                            <tr>
                                <td class="vertical">Sent:</td>
                                <td class="data" width="40%">
                                    <?php $this->_($this->data['dateSent']); ?>
                                </td>
                                <td class="vertical">Status</td>
                                <td class="data" width="40%">
                                    <b><i><?php echo $message_stat_display; ?></i></b>
                                </td>
                            </tr>

                            <tr>
                                <td class="vertical">Created:</td>
                                <td class="data" width="40%">
                                    <?php $this->_($this->data['dateCreated']); ?>
                                </td>
                                <td class="vertical">Created by:</td>
                                <td class="data" width="40%">
                                    <?php $this->_($this->data['owner_user_name']); ?>
                                </td>
                            </tr>

                            <tr>
                                <td class="vertical">Modified:</td>
                                <td class="data" width="40%">
									<?php $this->_($this->data['dateModified']); ?>
								</td>
                                <td class="vertical">Modified by:</td>
                                <td class="data" width="40%">
                                    <?php $this->_($this->data['modified_user_name']); ?>
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
									<input type="button" class="button" name="back"   id="back"   value="Back to Details" onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=messaging');" />&nbsp;
									<input type="submit" class="button" name="submit" id="submit" value="Edit"  onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&amp;a=edit&amp;messageID=<?php  $this->_($this->data['messagingID']); ?>');" />&nbsp;
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

<?php TemplateUtility::printFooter(); ?>

