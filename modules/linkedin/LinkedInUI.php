<?php
/*include_once('./lib/StringUtility.php');
include_once('./lib/ResultSetUtility.php');
include_once('./lib/DateUtility.php');


include_once('./lib/JobOrders.php');
include_once('./lib/ActivityEntries.php');
include_once('./lib/Export.php');
include_once('./lib/ExtraFields.php');
include_once('./lib/Calendar.php');
include_once('./lib/CommonErrors.php');
include_once('./lib/Mailer.php');
*/
include_once('./lib/LinkedIn.php');
include_once('./lib/Contacts.php');
include_once('./lib/Companies.php');
class LinkedInUI extends UserInterface
{
	public function __construct()
    {
        parent::__construct();

        $this->_authenticationRequired = true;
        $this->_moduleDirectory = 'linkedin';
        $this->_moduleName = 'linkedin';
        $this->_moduleTabText = 'LinkedIn';
        $this->_subTabs = array(
            'Import LinkedIn Connections'     => CATSUtility::getIndexName() . '?m=linkedin&amp;a=import*al='.ACCESS_LEVEL_EDIT
        );
		if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_RESEARCHER || 
		   intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_RECRUITER) {
		   CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Insufficient rights to access this page.'); 
		}
    }


    public function handleRequest()
    {
        $action = $this->getAction();

        if (!eval(Hooks::get('CONTACTS_HANDLE_REQUEST'))) return;

        switch ($action)
        {
			case 'import':
				$this->import();
				break;
			default:
				$this->import();
				break;
        }
    }
	
    private function import()
    {
        $this->_template->assign('showGrid', false);
		if(isset($_FILES['file'])) {
			$this->_template->assign('showGrid', true);
			
			/* PARSE CSV FILE TO ARRAY */
			$csv_data = $this->csv_to_array($_FILES['file']['tmp_name']);			
			
			/* CHECK CSV CONTACTS WITH DATABASE */
			$linkedin = new LinkedIn($this->_siteID);
			$_SESSION['data'] = $linkedin->checkConnections($csv_data);
			$this->_template->assign('data', $_SESSION['data']);
		} else if (isset($_POST['add_connections'])) {
			/* ADD TO DATABASE */
			$company = new Companies($this->_siteID);
			$contact = new Contacts($this->_siteID);
		
			foreach($_POST as $index=>$val) {
				$exp = explode('_', $index);
				$conn = $_SESSION['data'][$exp[1]];
				if($exp[0] === "checked" && $val == 'on'){					
					// ADD COMPANY IF IT DOES NOT EXIST
					if ($conn['company_id'] == '') {
						$_SESSION['data'][$exp[1]]['company_id'] = 
							$company->add($conn['Company']
										, $conn['Business Street'].' '.$conn['Business Street 2'].' '.$conn['Business Street 3']
										, $conn['Business City']
										, $conn['Business State']
										, $conn['Business Postal Code']
										, $conn['Company Main Phone']
										, '' 	// phone2
										, $conn['Business Fax']
										, ''	// url
										, '' 	// keyTechnologies
										, 0 	// isHot
										, ''	// notes
										, $this->_userID
										, $this->_userID
										, ''	// industry
										, ''	// cocountry
										, ''	// prospecting
										, ''	// timezone
										, ''	// category
										, 0		// employees
										, 0		// revenue
									);
					}
					// ADD CONTACT
					$_SESSION['data'][$exp[1]]['contact_id'] = 
							$contact->add($_SESSION['data'][$exp[1]]['company_id']
										, $conn['First Name']
										, $conn['Last Name']
										, $conn['Title']
										, $conn['Department']
										, $conn['Manager\'s Name']
										, $conn['E-mail Address']
										, $conn['E-mail 2 Address']
										, $conn['Company Main Phone']
										, $conn['Mobile Phone']
										, $conn['Other Phone']
										, $conn['Home Street'].' '.$conn['Home Street 2'].' '.$conn['Home Street 3']
										, $conn['Home City']
										, $conn['Home State']
										, $conn['Home Postal Code']
										, 0 	// isHot
										, ''	// notes
										, $this->_userID
										, $this->_userID
										, ''	// technologies
										, ''	// web_profile
										, ''	// call_plan
									);
				}
			}
			$this->_template->assign('showGrid', true);
			$this->_template->assign('data', $_SESSION['data']);
		}
		
		$this->_template->assign('active', $this);
		$this->_template->assign('userID', $_SESSION['CATS']->getUserID());
		$this->_template->assign('errMessage', $errMessage);		
        $this->_template->display('./modules/linkedin/LinkedIn.tpl');
    }
	
	private function csv_to_array($filename='', $delimiter=',')
	{
		if(!file_exists($filename) || !is_readable($filename))
			return FALSE;

		$header = NULL;
		$data = array();
		if (($handle = fopen($filename, 'r')) !== FALSE)
		{
			while (($row = fgetcsv($handle, 1000, $delimiter)) !== FALSE)
			{
				if(!$header)
					$header = $row;
				else
					$data[] = array_combine($header, $row);
			}
			fclose($handle);
		}
		return $data;
	}
}
?>