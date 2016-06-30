<?php TemplateUtility::printHeader('LinkedIn', array('js/jquery/js/jquery-1.7.1.min.js','js/highlightrows.js', 'js/export.js', 'js/dataGrid.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active); ?>
    <style type="text/css">
    div.addContactsButton { background: #4172E3 url(images/nodata/contactsButton.jpg); cursor: pointer; width: 337px; height: 67px; }
    div.addContactsButton:hover { background: #4172E3 url(images/nodata/contactsButton-o.jpg); cursor: pointer; width: 337px; height: 67px; }
    </style>
    <div id="main">
        <?php TemplateUtility::printQuickSearch(); ?>

        <div id="contents">
            <table width="100%">
                <tr>
                    <td width="3%">
                        <img src="images/contact.gif" width="24" height="24" border="0" alt="Contacts" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2>Import LinkedIn Connections</h2></td>
                </tr>
				<tr>
					<td colspan="2">
						1. exports connections from <a href="https://www.linkedin.com/people/export-settings" target="_blank">LinkedIn</a><br>
						2. save csv file to local folder<br>
						3. upload file below
					</td>
				</tr>
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr>
					<td colspan="2">
						<form action="" method="post" accept-charset="utf-8" enctype="multipart/form-data">
							<input type="file" name="file">
							<input type="submit" name="btn_submit" value="Upload File" />
						</form>
					</td>
				</td>
				<tr><td colspan="2">&nbsp;</td></tr>				
            </table>
	<?php if ($this->showGrid === true) { ?>			
			<p class="note" style="width:100%; padding:4px 0px;">
                <span>&nbsp;&nbsp;Connections</span>
            </p>
			<form action="" method="post">
				<table class="sortable" width="100%">
					<tr>
						<th>&nbsp;</th>
						<th>In DB</th>
						<th>Job Title</th>
						<th>First Name</th>
						<th>Last Name</th>
						<th>E-mail Address</th>
						<th>Company</th>
						<th>Job Title</th>
					</tr>
		<?php
				foreach($this->data as $index=>$d) {http://www.clearroad.it/cats/index.php?m=&a=show&=14315
					if ($d['First Name'] == '') continue;
					$class_name = ($index%2 == 0) ?'evenTableRow':'oddTableRow';
					$in_db = ($d['contact_id']<>'') ?'&#10003;':'';
					$check_box = ($d['contact_id']=='') ?"<input type='checkbox' onclick='' name='checked_$index' id='checked_$index' class='checkbox-class'>":"";
					$contact_fname_link = ($d['contact_id']<>'') ? '<a href="'.CATSUtility::getIndexName().'?m=contacts&amp;a=show&amp;contactID='.$d['contact_id'].'">'.$d['First Name'].'</a>' : $d['First Name'];
					$contact_lname_link = ($d['contact_id']<>'') ? '<a href="'.CATSUtility::getIndexName().'?m=contacts&amp;a=show&amp;contactID='.$d['contact_id'].'">'.$d['Last Name'].'</a>' : $d['Last Name'];
					$company_link = ($d['company_id']<>'') ? '<a href="'.CATSUtility::getIndexName().'?m=companies&amp;a=show&amp;companyID='.$d['company_id'].'">'.$d['Company'].'</a>' : $d['Company'];
					echo "<tr class='$class_name'>
							<td>$check_box</td>
							<td align='center'>$in_db</td>
							<td>".$d['Job Title']."</td>
							<td>$contact_fname_link</td>
							<td>$contact_lname_link</td>
							<td>".$d['E-mail Address']."</td>
							<td>$company_link</td>
							<td>".$d['Job Title']."</td>
						</tr>";				
				}
		?>
				</table>
				<button type="button" class="check-all">Check All</button>
				<input type="submit" value="Add Connections to Contacts" name="add_connections">
			</form>
	<?php } ?>
        </div>
    </div>
    <div id="bottomShadow"></div>
<?php TemplateUtility::printFooter(); ?>
<script type="text/javascript">
    (function() {
        var checked = false;
        $('button.check-all').click(function() {
            checked = !checked;
            $('.checkbox-class').prop('checked', checked); // jQuery 1.6+
            if (checked) $(this).text('Uncheck All');
            else $(this).text('Check All');
        });
    })();
</script>