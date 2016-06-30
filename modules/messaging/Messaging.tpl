<?php /* $Id: Contacts.tpl 3430 2007-11-06 20:44:51Z will $ */ ?>
<?php TemplateUtility::printHeader('Contacts', array('js/highlightrows.js', 'js/export.js', 'js/dataGrid.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active); ?>
<?php
	if(isset($_GET['stat'][0])){
		$stat = $_GET['stat'];
	} else {
		$stat = 1;
	}
	switch($stat){
		case -1:
			$pageDisplay = 'Trash';
			break;
		case 0:
			$pageDisplay = 'Drafts';
			break;
		default:
			$pageDisplay = 'Sent items';
			break;
	}
?>
    <style type="text/css">
    div.addContactsButton { background: #4172E3 url(images/nodata/contactsButton.jpg); cursor: pointer; width: 337px; height: 67px; }
    div.addContactsButton:hover { background: #4172E3 url(images/nodata/contactsButton-o.jpg); cursor: pointer; width: 337px; height: 67px; }
    </style>
	<script src="js/jquery.min.js"></script>
    <div id="main">
        <?php TemplateUtility::printQuickSearch(); ?>
		<div id="contents"<?php echo !$this->totalMessages ? ' style="background-color: #E6EEFF; padding: 0px;"' : ''; ?>>
            <?php if ($this->totalMessages): ?>
			<form id="messagesTableForm" action="<?php echo(CATSUtility::getIndexName()); ?>?m=messaging&a=messageDelete" method="post">
			<input type="hidden" value="" id="id_list" name="id_list">
            <input type="hidden" value="1" name="postback" id="postback">
            <table width="100%">
                <tr>
                    <td width="3%">
                        <img src="images/contact.gif" width="24" height="24" border="0" alt="Contacts" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Messaging: <?php echo $pageDisplay; ?></h2></td>
                    <td align="right">
                        <form name="contactsViewSelectorForm" id="contactsViewSelectorForm" action="<?php echo(CATSUtility::getIndexName()); ?>" method="get">
                            <input type="hidden" name="m" value="messaging" />
                            <input type="hidden" name="a" value="messageDelete" />

                            <table class="viewSelector">
                                <tr>
                                    <td valign="top" align="right" nowrap="nowrap">
                                        <?php $this->dataGrid->printNavigation(false); ?>
                                    </td>
                                </tr>
                            </table>
                        </form>
                    </td>
                </tr>
            </table>
			</form>
            <?php if ($this->errMessage != ''): ?>
            <div id="errorMessage" style="padding: 25px 0px 25px 0px; border-top: 1px solid #800000; border-bottom: 1px solid #800000; background-color: #f7f7f7;margin-bottom: 15px;">
            <table>
                <tr>
                    <td align="left" valign="center" style="padding-right: 5px;">
                        <img src="images/large_error.gif" align="left">
                    </td>
                    <td align="left" valign="center">
                        <span style="font-size: 12pt; font-weight: bold; color: #800000; line-height: 12pt;">There was a problem with your request:</span>
                        <div style="font-size: 10pt; font-weight: bold; padding: 3px 0px 0px 0px;"><?php echo $this->errMessage; ?></div>
                    </td>
                </tr>
            </table>
            </div>
            <?php endif; ?>

            <p class="note">
                <span style="float:left;">
                    Messaging - Page <?php echo($this->dataGrid->getCurrentPageHTML()); ?>
                    (<?php echo($this->dataGrid->getNumberOfRows()); ?> Items)
                </span>
                <span style="float:right;">
                    <?php $this->dataGrid->drawRowsPerPageSelector(); ?>
                    <?php $this->dataGrid->drawShowFilterControl(); ?>
                </span>&nbsp;
            </p>

            <?php $this->dataGrid->drawFilterArea(); ?>
            <?php $this->dataGrid->draw();  ?>

            <div style="display:block;">
                <span style="float:left;">
                    <?php $this->dataGrid->printActionArea(); ?>
                </span>
                <span style="float:right;">
                    <?php $this->dataGrid->printNavigation(true); ?>
                </span>&nbsp;
            </div>

            <?php else: ?>

            <br /><br /><br /><br />
            <div style="height: 95px; background: #E6EEFF url(images/nodata/contactsTop.jpg);">
                &nbsp;
            </div>
            <br /><br />
            <table cellpadding="0" cellspacing="0" border="0" width="956">
                <tr>
                <td style="padding-left: 62px;" align="center" valign="center">

                    <div style="text-align: center; width: 600px; line-height: 22px; font-size: 18px; font-weight: bold; color: #666666; padding-bottom: 20px;">
                    Add Messages to keep track of people you work with.
                    </div>
                    </a>
                </td>

                </tr>
            </table>

            <?php endif; ?>

        </div>
    </div>
    <div id="bottomShadow"></div>
	<script language="javascript">
		var contactIDTemp = ',';
		var splitStr = ',';

		$(document).ready(function(){
			$("#deleteSelected").click(function(){
				$("#messagesTableForm").submit();
			});
			
			$("input[type='checkbox']").each(function(){
				$(this).click(function(){
					var id = $(this).attr("name").split("_")[1];
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
