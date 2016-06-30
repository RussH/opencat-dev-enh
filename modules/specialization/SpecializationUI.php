<?php
/*
 * CATS
 * Specialization Module
 *
 * Copyright (C) 2012 Clear Road IT
 *
 *
 * $Id: SpecializationUI.php 3810 2007-12-05 19:13:25Z brian $
 */

include_once('./lib/StringUtility.php');
include_once('./lib/ResultSetUtility.php');
include_once('./lib/DateUtility.php'); /* Depends on StringUtility. */
include_once('./lib/Candidates.php');
include_once('./lib/Export.php');
include_once('./lib/InfoString.php');
include_once('./lib/EmailTemplates.php');
include_once('./lib/FileUtility.php');
include_once('./lib/ExtraFields.php');
include_once('./lib/CommonErrors.php');
include_once('./lib/Specialization.php');

class SpecializationUI extends UserInterface
{
	
	private $_last_query = "";
	
    public function __construct()
    {
        parent::__construct();

        $this->_authenticationRequired = true;
        $this->_moduleDirectory = 'specialization';
        $this->_moduleName = 'specialization';
        $this->_moduleTabText = 'Specialization';
		/* 
        $this->_subTabs = array(
            'Add Job Order' => 'javascript:void(0);*js=showPopWin(\''.CATSUtility::getIndexName().'?m=joborders&amp;a=addJobOrderPopup\', 400, 250, null);*al='.ACCESS_LEVEL_EDIT,
            'Search Job Orders' => CATSUtility::getIndexName() . '?m=joborders&amp;a=search'
        );
		 */
    }


    public function handleRequest()
    {
        $action = $this->getAction();
        switch ($action)
        {
			case 'getlookupvalues':
				$this->getLookupValues();
				break;
				
            case 'delete':
                $this->onDelete();
                break;

            case 'update':
                $this->update();
				break;
				
            case 'addnew':
                $this->addNew();
				break;

            case 'deleteListModal':
                $this->deleteListModal();
				break;
				
            case 'edit':
            default:
                if ($this->isPostBack())
                    $this->onEdit();
                else
                    $this->edit();
                break;
        }
    }
	
	private function getLookupValues() {
		$q = strtolower($_GET["q"]);		
		if (!$q) return;
		/*
		$items = array(
			"PHP"		  =>"PHP",
			"Java"		  =>"Java",
			"MySQL"		  =>"MySQL",
			"Apache"	  =>"Apache",
			"Linux"		  =>"Linux",
			"Windows"	  =>"Windows",
			"Javascript"  =>"Javascript",
			"VBScript"	  =>"VBScript",
			"Perl"		  =>"Perl",
			"Python"	  =>"Python",
			"Flash"		  =>"Flash",
			"Actionscript"=>"Actionscript",
			"J2EE"		  =>"J2EE",
			".NET"		  =>".NET",
			"VB"		  =>"VB",
			"Visual Basic"=>"Visual Basic"			
		);
		
		foreach ($items as $key=>$value) {
			if (strpos(strtolower($key), $q) !== false) {
				echo "$key|$value\n";
			}
		}
		*/
		$this->_last_query = $q;
		$specialization = new Specialization($this->_siteID);
		$specialization->get_specializations($q);
		exit();
	}
	
    /*
     *  Add new specialization and roles fields.
     */
    private function addNew()
    {
		if ($this->isPostBack()){
			$roles = isset($_POST['roles']) && isset($_POST['years']) && count($_POST['roles']) == count($_POST['years']) ? array_combine($_POST['roles'],$_POST['years']) : false;
			if($roles){
				$str = '';
				foreach($roles as $key => $value){
					if($key != '' && $value != ''){
						$str .= 'rl:'.$key.'yr:'.$value.',';
					}
				}
				$str = substr($str,0,-1);
			}
			$roles = $str;
			$keyword = isset($_POST['keyword']) ? $_POST['keyword'] : '' ;
			$specialization = new Specialization($this->_siteID);
			if($keyword != '' && $roles != ''){
				$specialization->addnew_specialization_keyword($keyword,$roles);
			} else {
				
			}
			CATSUtility::transferRelativeURI( 'm=settings&a=specializationPanel' );
		} else {
			$id = false;
			$rs = array('keyword'=>'','masterkeyword'=>'','roles'=>'');
			$this->_template->assign('data',$rs);
			$this->_template->assign('id',$id);
			$this->_template->display('./modules/specialization/Update.tpl');
		}
    }

    /*
     *  Updates the new specialization and roles fields.
     */
    private function update()
    {
		if ($this->isPostBack()){
			$id = isset($_POST['id']) ? $_POST['id'] : false;
			$roles = isset($_POST['roles']) && isset($_POST['years']) && count($_POST['roles']) == count($_POST['years']) ? array_combine($_POST['roles'],$_POST['years']) : false;
			if($roles){
				$str = '';
				foreach($roles as $key => $value){
					if($key != '' && $value != ''){
						$str .= 'rl:'.$key.'yr:'.$value.',';
					}
				}
				$str = substr($str,0,-1);
			}
			$roles = $str;
			$keyword = isset($_POST['keyword']) ? $_POST['keyword'] : '' ;
			$specialization = new Specialization($this->_siteID);
			if($id && $keyword != '' && $roles != ''){
				$specialization->update_specialization_keyword($keyword,$roles,$id);
			} else {
				
			}
			CATSUtility::transferRelativeURI( 'm=settings&a=specializationPanel' );
		} else {
			$id = intval($this->getTrimmedInput('id', $_GET));
	        $this->_db = DatabaseConnection::getInstance();
			$sql = sprintf("
            SELECT 
				specializations.id AS id,
				specializations.keyword AS keyword,
				specializations.master_keyword AS master_keyword,
				roles.data AS roles_data
            FROM
                specializations
			LEFT JOIN
				roles
			ON
				roles.specialization_id = specializations.id
			WHERE
				specializations.id = %s",
			$id
			);
			$rs = $this->_db->getAllAssoc($sql);
			if(!empty($rs) ) {
				$rs = array_shift($rs);
				$this->_template->assign('data',$rs);
				$this->_template->assign('id',$id);
				$this->_template->display('./modules/specialization/Update.tpl');
			} else {
				CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this, 'Invalid Specialization ID.');
				CATSUtility::transferRelativeURI( 'm=settings&a=specializationPanel' );
			}
		}
    }

    /*
     * Called by handleRequest() to process loading the details page.
     */
    private function edit()
    {
		$candidateID = intval($_SESSION['CATS']->getCandidateID());			
		if($candidateID == -1) {
			CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid Candidate ID.');
			return;
		}
		
		$specialization = new Specialization($this->_siteID);
		$skills_structure = $specialization->get_skills($candidateID);
		
        $this->_template->assign('active', $this);        
        $this->_template->assign('sessionCookie', $_SESSION['CATS']->getCookie());
		$this->_template->assign('candidateID', $candidateID);
		
		$this->_template->assign('skill_values', $skills_structure["skill_texts"]);
		$this->_template->assign('skillyear_values', $skills_structure["skill_years"]);
		$this->_template->assign('skillprof_values', $skills_structure["skill_profs"]);
		
        $this->_template->display('./modules/specialization/Show.tpl');
    }

	/*
     * Called by handleRequest() to process saving / submitting the edit page.
     */
    private function onEdit()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        $specialization = new Specialization($this->_siteID);

        /* Bail out if we don't have a valid job order ID. */
        if (!$this->isRequiredIDValid('candidateID', $_POST))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID 	   	   = $_POST['candidateID'];
        $skill_values          = $_POST["skill_values"];
		$skillyear_values      = $_POST["skillyear_values"];
		$skillprof_values      = $_POST["skillprof_values"];

        if (!$specialization->update($candidateID, $skill_values, $skillyear_values, $skillprof_values))
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to candidate specialization.');
        } else {
			//attempt to add keyword if not already existing
			$skill_values_array = explode("&spc;", $skill_values);
			for($i=0; $i<count($skill_values_array); $i++) {
				$specialization->add_specialization_keyword($skill_values_array[$i]);
			}
		}

        CATSUtility::transferRelativeURI(
            'm=specialization&a=edit'
        );
    }
	
    /*
     * Called by handleRequest() to process deleting a job order.
     */
    private function deleteListModal()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_DELETE)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        $specialization = new Specialization($this->_siteID);
		if(isset($_GET) && !empty($_GET)){
			$c = count($_GET);
			$i = 0;
			foreach($_GET as $val){
				$i++;
				$newval = $i >= $c ? unserialize($val) : false;
			}
			if($newval){
				$specialization->delete_entry($newval);
			}
		}
		CATSUtility::transferRelativeURI( 'm=settings&a=specializationPanel' );
    }

    /*
     * Called by handleRequest() to process deleting a job order.
     */
    private function onDelete()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_DELETE)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid job order ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID = $_GET['candidateID'];


        $specialization = new Specialization($this->_siteID);
        $specialization->delete($candidateID);

        CATSUtility::transferRelativeURI(
            'm=specialization&a=edit&candidateID=' . $candidateID
        );
    }

    private function listByView($errMessage = '')
    {
        // Log message that shows up on the top of the list page
        $topLog = '';

        $dataGridProperties = DataGrid::getRecentParamaters("specializations:specializationListByViewDataGrid");

        /* If this is the first time we visited the datagrid this session, the recent paramaters will
         * be empty.  Fill in some default values. */
        if ($dataGridProperties == array())
        {
            $dataGridProperties = array('rangeStart'    => 0,
                                        'maxResults'    => 15,
                                        'filterVisible' => false);
        }

        $dataGrid = DataGrid::get("specializations:specializationListByViewDataGrid", $dataGridProperties);

        $specializations = new Specialization($this->_siteID);
        $this->_template->assign('totalCandidates', $specializations->getCount());

        $this->_template->assign('active', $this);
        $this->_template->assign('dataGrid', $dataGrid);
        $this->_template->assign('userID', $_SESSION['CATS']->getUserID());
        $this->_template->assign('errMessage', $errMessage);
        $this->_template->assign('topLog', $topLog);

        $this->_template->display('./modules/specialization/List.tpl');
    }
    
}

?>

