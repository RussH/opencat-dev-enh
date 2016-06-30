<?php /* $Id: Edit.tpl 3695 2007-11-26 22:01:04Z brian $ */ ?>
<?php TemplateUtility::printHeader('Candidates', array('modules/candidates/validator.js', 'js/sweetTitles.js', 'js/listEditor.js', 'js/doubleListEditor.js')); ?>
<?php TemplateUtility::printHeaderBlock(); ?>
<?php TemplateUtility::printTabs($this->active); ?>
	<style type="text/css">
		#rolesHolder, .data_row{
			display: block;
			float: none;
		}

		.data_row .data_col{
			display: block;
			float: left;
		}
		
		.data_col label{
			display: block;
			float: left;
			width: 100px;
		}
		
		.data_col .year{
			display: block;
			float: left;
			width: 100px;
		}
		
		.data_col .role{
			display: block;
			float: left;
			width: 300px;
		}
	</style>
    <div id="main">
        <?php TemplateUtility::printQuickSearch(); ?>

        <div id="contents">
            <table>
                <tr>
                    <td width="3%">
                        <img src="images/candidate.gif" width="24" height="24" border="0" alt="Candidates" style="margin-top: 3px;" />&nbsp;
                    </td>
                    <td><h2><?php echo ($this->id ? 'UPDATE' : 'ADD' ); ?> : Specialization</h2></td>
               </tr>
            </table>

            <form name="editSpecializationForm" id="editSpecializationForm" action="<?php echo(CATSUtility::getIndexName()); ?>?m=specialization&amp;a=<?php echo ($this->id ? 'update' : 'addnew'); ?>" method="post" onsubmit="return checkEditForm(document.editSpecializationForm);" autocomplete="off">
                <input type="hidden" name="postback" id="postback" value="postback" />
				<?php if($this->id) { ?>
                <input type="hidden" name="id" id="id" value="<?php echo $this->id; ?>" />
				<?php } ?>
                <table class="editTable" width="700">
                    <tr>
                        <td class="tdVertical">
                            <label id="firstNameLabel" for="keyword">Specialization:</label>
                        </td>
                        <td class="tdData">
                            <input type="text" class="inputbox" id="keyword" name="keyword" value="<?php $this->_($this->data['keyword']); ?>" style="width: 300px;" />
                        </td>
                    </tr>

                    <tr>
                        <td class="tdVertical" colspan="2">
							<div class="data_row">
								<div class="data_col">
									<label id="contact_typeLabel" for="roles" >&nbsp;</label>
									<span class="role"><h3>Roles</h3></span>
								</div>
								<div class="data_col">
									<label id="contact_typeLabel" for="years">&nbsp;</label>
									<span class="year"><h3>Years</h3></span>
								</div>
							</div>
                        </td>
                    </tr>
					
                    <tr>
                        <td class="tdVertical" colspan="2">
							<div id="rolesHolder">
								<div style="display:none;" disabled="disabled" id="data_tmp" name="data_tmp">
									<div class="data_col">
										<label id="contact_typeLabel" for="roles" >Roles:</label>
										<input type="text" class="inputbox role" id="roles" name="roles[]" value="" />
									</div>
									<div class="data_col">
										<label id="contact_typeLabel" for="years">Years:</label>
										<input type="text" class="inputbox year" id="years" name="years[]" value="1" />
									</div>
									<div class="data_col">
										<a href="javascript: void();" onclick="javascript: deleteParent(this);"> [-] Delete </a>
									</div>
								</div>
								<?php if($this->data['roles_data'] == ''){ ?>
								<div class="data_row">
									<div class="data_col">
										<label id="contact_typeLabel" for="roles" >Roles:</label>
										<input type="text" class="inputbox role" id="roles" name="roles[]" value="" />
									</div>
									<div class="data_col">
										<label id="contact_typeLabel" for="years">Years:</label>
										<input type="text" class="inputbox year" id="years" name="years[]" value="1" />
									</div>
								</div>
								<?php } else {
									$roles = explode(',',$this->data['roles_data']);
									foreach($roles as $value){ 
									$row = explode('yr:',str_replace('rl:','',$value));
									$role = $row[0];
									$years = $row[1];
									?>
								<div class="data_row">
									<div class="data_col">
										<label id="contact_typeLabel" for="roles" >Roles:</label>
										<input type="text" class="inputbox role" id="roles" name="roles[]" value="<?php echo $role; ?>" />
									</div>
									<div class="data_col">
										<label id="contact_typeLabel" for="years">Years:</label>
										<input type="text" class="inputbox year" id="years" name="years[]" value="<?php echo $years; ?>" />
									</div>
								</div>
								<?php }
								} ?>
							</div>
							<br>
                        </td>
                    </tr>
                    <tr>
                        <td class="tdVertical" colspan="2">
							<div class="data_row">
								<a href="javascript:void();" onclick="javascript:add_Roles();"> [+] Add Roles </a>
							</div>
							<br>
                        </td>
                    </tr>
                </table>
                <input type="submit" class="button" name="submit" id="submit" value="Save" />&nbsp;
                <input type="reset"  class="button" name="reset"  id="reset"  value="Reset" onclick="resetFormForeign();" />&nbsp;
                <input type="button" class="button" name="back"   id="back"   value="Back to Details" onclick="javascript:goToURL('<?php echo(CATSUtility::getIndexName()); ?>?m=settings&a=specializationPanel');" />
            </form>

            <script type="text/javascript">
                document.editSpecializationForm.keyword.focus();
				function add_Roles(){
					var c = document.getElementById("data_tmp").innerHTML;
					var r = document.createElement("DIV");
					r.setAttribute("class","data_row");
					r.innerHTML = c;
					document.getElementById("rolesHolder").appendChild(r);
				}
				
				function deleteParent(obj){
					var p = obj.parentNode;
					var p2 = p.parentNode;
					var p3 = p2.parentNode;
					p3.removeChild(p2);
				}
            </script>
        </div>
    </div>
    <div id="bottomShadow"></div>
<?php TemplateUtility::printFooter(); ?>
