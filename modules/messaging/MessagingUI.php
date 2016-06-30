<?php
/*
 * Messaging Module
 *
 * $Id: MessagingUI.php 3444 2013-05-03 7:06:20Z ryan $
 */

include_once('./lib/StringUtility.php');
include_once('./lib/ResultSetUtility.php');
include_once('./lib/DateUtility.php');
include_once('./lib/Candidates.php');
include_once('./lib/Contacts.php');
include_once('./lib/Companies.php');
include_once('./lib/JobOrders.php');
include_once('./lib/ActivityEntries.php');
include_once('./lib/Export.php');
include_once('./lib/ExtraFields.php');
include_once('./lib/Calendar.php');
include_once('./lib/CommonErrors.php');
include_once('./lib/Mailer.php');
include_once('./lib/Messaging.php');
include_once('./lib/MailerSettings.php');

class MessagingUI extends UserInterface
{

    const NOTES_MAXLEN = 500;

    public function __construct()
    {
        parent::__construct();

        $this->_authenticationRequired = true;
        $this->_moduleDirectory = 'messaging';
        $this->_moduleName = 'messaging';
        $this->_moduleTabText = 'Messaging';
        $this->_subTabs = array(
            'Compose'     => CATSUtility::getIndexName() . '?m=messaging&amp;a=add',
            'Sent Items'     => CATSUtility::getIndexName() . '?m=messaging&amp;a=messages&amp;stat=1',
            'Drafts'     => CATSUtility::getIndexName() . '?m=messaging&amp;a=messages&amp;stat=0',
            'Trash'     => CATSUtility::getIndexName() . '?m=messaging&amp;a=messages&amp;stat=-1',
            'Search' => CATSUtility::getIndexName() . '?m=messaging&amp;a=search',
            'Templates'  => CATSUtility::getIndexName() . '?m=messaging&amp;a=templates'
			// 'Contacts'  	  => CATSUtility::getIndexName() . '?m=messaging&amp;a=contacts'
        );
		if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_RESEARCHER || 
		   intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_RECRUITER) {
		   CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Insufficient rights to access this page.'); 
		}
    }


    public function handleRequest()
    {
        $action = $this->getAction();
		
        switch ($action)
        {
			case 'search':
				$this->search();
				break;

			case 'loadTemplate':
				$this->loadTemplate();
				break;
				
			case 'loadTemplateList':
				$this->loadTemplateList();
				break;

			case 'loadContactList':
				$this->loadContactList();
				break;
				
            case 'templateEdit':
                if (!$this->isPostBack())
                {
                    $this->templateEdit();
                }
                else
                {
                    $this->onTemplateEdit();
                }
                break;

            case 'templateAdd':
                if (!$this->isPostBack())
                {
                    $this->templateAdd();
                }
                else
                {
                    $this->onTemplateAdd();
                }
                break;

			case 'templates':
				$this->templates();
				break;

			case 'contacts':
				$this->contacts();
				break;

			case 'emailSearchSendEmail':
				include_once('./lib/Search.php');
				$this->emailSearchSendEmail();
				break;
				
            case 'show':
                $this->show();
                break;

            case 'add':
                if ($this->isPostBack())
                {
                    $this->onAdd();
                }
                else
                {
                    $this->add();
                }

                break;

            case 'edit':
                if (!$this->isPostBack())
                {
                    $this->edit();
                }
                else
                {
                    $this->onEdit();
                }
                break;

            case 'messageDelete':
                $this->onDelete();
                break;

            case 'templateDelete':
                $this->onTemplateDelete();
                break;

            case 'search':
                include_once('./lib/Search.php');

                if ($this->isGetBack())
                {
                    $this->onSearch();
                }
                else
                {
                    $this->search();
                }

                break;

            case 'addActivityScheduleEvent':
                if ($this->isPostBack())
                {
                    $this->onAddActivityScheduleEvent();
                }
                else
                {
                    $this->addActivityScheduleEvent();
                }

                break;

            case 'showColdCallList':
                $this->showColdCallList();
                break;

            case 'downloadVCard':
                include_once('./lib/VCard.php');

                $this->downloadVCard();
                break;

            /* Main messages page. */
			case 'messages':
            default:
                $this->listByView();
                break;
        }
    }

	//MESSAGING FUNCTIONS AND PROCEDURES ****************************** //
	private function emailSearchSendEmail() 
	{	/*
		print_r($_POST);
		echo "<p></p>";
		print_r($_REQUEST);
		die("..."); */
		
		//$candidateIDArray
		$recipient		= $_POST['recipient']; //$jobOrderID 	= $_REQUEST['jobOrderID'];
		$stage 			= $_REQUEST['stage'];
		$email_body 	= $_POST['email_body'];
		$email_subject 	= $_POST['subject'];

		//check for overrides
		if(isset($_POST['stage_override'])) {
			$stage	= $_POST['stage_override'];
		}
		
		if(isset($_POST['email_subject'])) {
			$email_subject	= $_POST['email_subject'];
		}
		
		$returned_recipient = "";
		$contact_array = array();	
		$this->_template->assign('active', $this);
		$this->_template->assign('subActive', 'Messaging');	
		if(intval($stage) == 0) { //EDIT STAGE
			$messages = new Messaging($this->_siteID);
			$contact_array = $messages->getEmailListing(-1);
			
			$this->_template->assign('contact_array', $contact_array);
			$this->_template->assign('recipient', $recipient);        	
			$this->_template->assign('subject', $email_subject);
			$this->_template->assign('emailTemplate', $email_body);			
			$this->_template->assign('stage', 0);			
						
        	$this->_template->display('./modules/messaging/Messaging.tpl');
			
		} elseif(intval($stage) == 1) { //PREVIEW MODE STAGE
			//TODO: Formulate test email here			
			//      Use First Candidate
			
			$actual_email_body	= "";
			$actual_recipient	= $recipient;
			//die($recipient);
			
			// $actual_email_body	= $this->SendSearchEmail($email_body, $email_subject, 1, $recipient, &$returned_recipient);
			$actual_email_body	= $email_body; //$this->SendSearchEmail($email_body, $email_subject, 1, $recipient, &$returned_recipient);
		    
			$this->_template->assign('contact_array', $contact_array);	
			$this->_template->assign('stage', 1);			
			$this->_template->assign('email_subject', $email_subject);			
			$this->_template->assign('email_body', $email_body);			
			$this->_template->assign('actual_email_body', $actual_email_body);
			$this->_template->assign('recipient', $recipient);
			$this->_template->assign('actual_recipient', $returned_recipient);			
			
        	//$this->_template->assign('candidateIDArray', $candidateIDArray);
        	//$this->_template->assign('candidateIDArrayStored', $_SESSION['CATS']->storeData($candidateIDArray));
			
        	$this->_template->display('./modules/messaging/Messaging.tpl');
		} elseif(intval($stage) == 2) {  //SEND EMAIL STAGE			
			//normal email send
			$jobOrderTitle	= "Email Result";
			$is_finished    = 1;
			$email_result_text	= "";
			
			$emails_sent	=  $this->SendSearchEmail($email_body, $email_subject, 0, $recipient, $returned_recipient);
			//$emails_sent	=  true; //$this->SendSearchEmail($email_body, $email_subject, 0, $recipient, &$returned_recipient);
			
			$this->_template->assign('contact_array', $contact_array);
			//$this->_template->assign('jobOrderID', $jobOrderID);
			$this->_template->assign('stage', 2);
			$this->_template->assign('email_body', $email_body);
			$this->_template->assign('email_subject', $email_subject);
			
			//temp
			//$email_result_text = $emails_sent." emails sent.";
			$email_result_text = " <p>Email sent.</p>";
			
			$this->_template->assign('is_finished', $is_finished);
			$this->_template->assign('jobOrderTitle', $jobOrderTitle);			
			$this->_template->assign('email_result_text', $email_result_text);
			
        	$this->_template->display('./modules/messaging/Messaging.tpl');
		}
	}
	
	private function SendSearchEmail($email_template, $email_subject, $preview_mode, $recipient_id, $returned_recipient) {
		
		$activityEntries = new ActivityEntries($this->_siteID);
		$messages = new Messaging($this->_siteID);
		//$contact_array = $messages->getAll(-1, -1);
		
		$stringsToFind = array(				
				'%SITENAME%',
				'%DATETIME%',				
				'%USERFULLNAME%',
				'%USERMAIL%',
				'%CONTOWNER%',
				'%CONTFIRSTNAME%',
				'%CONTFULLNAME%',
				'%CONTCLIENTNAME%',
				'%CONTCATSURL%',
				'%SIGNATURE%'
		);
		/*
		%SITENAME%	- Site Name
		%DATETIME%	- CUrrent Date/Time
		%JBODID%	- Job Order ID
		%JBODOWNER%	- Job Order Owner
		*/
		$uri = str_replace('employment', '', $_SERVER['REQUEST_URI']);
		$uri = str_replace('http://', 'http', $uri);
		$uri = str_replace('//', '/', $uri);
		$uri = str_replace('http', 'http://', $uri);
		$uri = str_replace('/careers', '', $uri);
		
		$result = false;
		$candidate_count = 0;
		$email_sent = 0;
		
		
		//

			//initialize mailer and settings if we're not in preview mode
		$users = new Users($this->_siteID);        
		$userID	= $_SESSION['CATS']->getUserID();
		$user_data = $users->get($userID);
		$user_fullname = $user_data["fullName"];
		$user_email = $user_data["email"];
		
		$mailerSettings = new MailerSettings($this->_siteID);
        $mailerSettingsRS = $mailerSettings->getAll();
		$signature = $mailerSettingsRS['signature'];
		
		if($preview_mode == 0) {
			$mailer = new Mailer($this->_siteID, $userID);
		}
		
		$site_name = $_SESSION['CATS']->getSiteName();

		if ($_SESSION['CATS']->isDateDMY()) {
            $dateFormat = 'd-m-y';
		} else {
            $dateFormat = 'm-d-y';
		}
		$curr_datetime = DateUtility::getAdjustedDate($dateFormat . ' g:i A');
		
		// ----------------------------------------------------------------------------------------------
				
		$contact_data_array = $messages->getAll(-1, -1, $recipient_id);
		$contact_data = $contact_data_array[0];
		
		$replacementStrings = array(
			$site_name,
			$curr_datetime,
			$user_fullname,
			$user_email,
			$contact_data["ownerFirstName"]. " " .$contact_data["ownerLastName"],
			$contact_data["firstName"],
			$contact_data["firstName"]. " " .$contact_data["lastName"],
			$contact_data["companyName"],
			'<a href="http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=messages&amp;a=show&amp;contactID=' . $contact_data["contactID"] . '">'.
                        'http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=messages&amp;a=show&amp;contactID=' . $contact_data["contactID"] . '</a>',
		    $signature 
		);		

		$actual_email_body = str_replace(
			$stringsToFind,
			$replacementStrings,
			$email_template
		);

		$activity_replacementStrings = array(
			$site_name,
			$curr_datetime,
			$user_fullname,
			$user_email,
			$contact_data["ownerFirstName"]. " " .$contact_data["ownerLastName"],
			$contact_data["firstName"],
			$contact_data["firstName"]. " " .$contact_data["lastName"],
			$contact_data["companyName"],
			'<a href="http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=messages&amp;a=show&amp;contactID=' . $contact_data["contactID"] . '">'.
                        'http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=messages&amp;a=show&amp;contactID=' . $contact_data["contactID"] . '</a>',
		    ''
		);		
		
		$activity_email_body = str_replace(
			$stringsToFind,
			$activity_replacementStrings,
			$email_template
		);

		$email_sent = 0;
		$destination	= trim($contact_data["email1"]);
		if(strlen($destination) == 0) $destination	= trim($contact_data["email2"]);
		$returned_recipient = $destination;
		
		if($preview_mode == 1) {
			return $actual_email_body;
		} else {
			//actually send email here
			
			
			$mailerStatus = $mailer->sendToOne(array($destination, ''), $email_subject, $actual_email_body, true);
			//$mailerStatus = true; //$mailer->sendToOne(array($destination, ''), $email_subject, $actual_email_body, true);
			$activity_text = "SUBJECT: ".$email_subject."<br>".
			                 str_replace($email_template,"",$activity_email_body);
			$activityID = $activityEntries->add(
							$contact_data["contactID"],
							DATA_ITEM_CONTACT,
							400,
							$activity_text,
							$this->_userID,
							$contact_data["contactID"]
						);				
			$email_sent++;
		}		
		
		//return actual number of emails sent
		return $email_sent;
	}
	
	//END MESSAGING FUNCTIONS AND PROCEDURES ********************************************** //

    private function listByView($errMessage = '')
    {
	
		$dataGridProperties = DataGrid::getRecentParamaters("messaging:messagingListByViewDataGrid");

        if ($dataGridProperties == array())
        {
            $dataGridProperties = array('rangeStart'    => 0,
                                        'maxResults'    => 15,
                                        'filterVisible' => false);
        }

        $dataGrid = DataGrid::get("messaging:messagingListByViewDataGrid", $dataGridProperties);
		$userID = $_SESSION['CATS']->getUserID();
        $this->_template->assign('active', $this);
        $this->_template->assign('dataGrid', $dataGrid);
        $this->_template->assign('userID', $userID);
        $this->_template->assign('errMessage', $errMessage);

        $messages = new Messaging($this->_siteID);
        $this->_template->assign('totalMessages', $messages->getCount($userID));

        $this->_template->display('./modules/messaging/Messaging.tpl');
    }

    private function templates($errMessage = '')
    {

		$userID = $this->_userID;
		$siteID = $this->_siteID;
		
		$messages = new Messaging($siteID);
		
		$data = $messages->getAllTemplate();
		
        $this->_template->assign('active', $this);
        $this->_template->assign('data', $data);
        $this->_template->assign('userID', $userID);
        $this->_template->assign('errMessage', $errMessage);

        $messages = new Messaging($this->_siteID);
        $this->_template->assign('totalMessages', $messages->getCount($userID));

        $this->_template->display('./modules/messaging/Templates.tpl');
    }
	
	
    /*
     * Called by handleRequest() to process loading the details page.
     */
    private function show()
    {
        /* Bail out if we don't have a valid contact ID. */
        if (!$this->isRequiredIDValid('messageID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid contact ID.');
        }

        $messageID = $_GET['messageID'];

        $messages = new Messaging($this->_siteID);
        $data = $messages->get($messageID);

        /* Bail out if we got an empty result set. */
        if (empty($data))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'The specified contact ID could not be found.');
        }
		
		$contact_list = explode( ',' , $data['contact_list']);
		$contactList = array();
		foreach($contact_list as $c){
			$d = explode( '.' , $c);
			$da = array();			
			if ($d[0] == '1') {
				// candidate
				$candidate = new Candidates($this->_siteID);
				$da = $candidate->getFullName($d[1]);
			} else if ($d[0] == '2') {
				// contact
				$contact = new Contacts($this->_siteID);
				$da = $contact->getFullName($d[1]);
			}
			
			if (!empty($da['email1'])){ array_push($contactList, $da['fullname'].' ('.$da['email1'].')'); }
			else{ array_push($contactList, $da['fullname'].' ('.$da['email2'].')'); }
		}
		$data['contact_list'] = implode(', ', $contactList);

        $activityEntries = new ActivityEntries($this->_siteID);
        $activityRS = $activityEntries->getAllByDataItem($messageID, DATA_ITEM_CONTACT);
        if (!empty($activityRS))
        {
            foreach ($activityRS as $rowIndex => $row)
            {
                if (empty($activityRS[$rowIndex]['notes']))
                {
                    $activityRS[$rowIndex]['notes'] = '(No Notes)';
                }

                if (empty($activityRS[$rowIndex]['jobOrderID']) ||
                    empty($activityRS[$rowIndex]['regarding']))
                {
                    $activityRS[$rowIndex]['regarding'] = 'General';
                }

                $activityRS[$rowIndex]['enteredByAbbrName'] = StringUtility::makeInitialName(
                    $activityRS[$rowIndex]['enteredByFirstName'],
                    $activityRS[$rowIndex]['enteredByLastName'],
                    false,
                    LAST_NAME_MAXLEN
                );
            }
        }

        /* Get upcoming calendar entries. */
        $calendarRS = $messages->getUpcomingEvents($messageID);
        if (!empty($calendarRS))
        {
            foreach ($calendarRS as $rowIndex => $row)
            {
                $calendarRS[$rowIndex]['enteredByAbbrName'] = StringUtility::makeInitialName(
                    $calendarRS[$rowIndex]['enteredByFirstName'],
                    $calendarRS[$rowIndex]['enteredByLastName'],
                    false,
                    LAST_NAME_MAXLEN
                );
            }
        }

        /* Get extra fields. */
        $extraFieldRS = $messages->extraFields->getValuesForShow($messageID);

        /* Is the user an admin - can user see history? */
        if ($this->_accessLevel < ACCESS_LEVEL_DEMO)
        {
            $privledgedUser = false;
        }
        else
        {
            $privledgedUser = true;
        }

        if ($this->_accessLevel != ACCESS_LEVEL_CANDIDATE)
        {
            $data['isAdminHidden'] = 0;
        }
        else
        {
            $data['isAdminHidden'] = 1;
        }

        $this->_template->assign('active', $this);
        $this->_template->assign('data', $data);
        $this->_template->assign('extraFieldRS', $extraFieldRS);
        $this->_template->assign('calendarRS', $calendarRS);
        $this->_template->assign('activityRS', $activityRS);
        $this->_template->assign('messageID', $messageID);
        $this->_template->assign('privledgedUser', $privledgedUser);
        $this->_template->assign('sessionCookie', $_SESSION['CATS']->getCookie());

        // if (!eval(Hooks::get('messages_SHOW'))) return;

        $this->_template->display('./modules/messaging/Show.tpl');
    }

    /*
     * Called by handleRequest() to process loading the add page.
     */
    private function add()
    {
        $companies = new Companies($this->_siteID);
        $messages = new Messaging($this->_siteID);

        /* Do we have a selected_company_id? */
        if ($_SESSION['CATS']->isHrMode())
        {
            $selectedCompanyID = $companies->getDefaultCompany();
            $companyRS = $companies->get($selectedCompanyID);
            $reportsToRS = $messages->getAll(-1, $selectedCompanyID);
        }
        else if (!$this->isRequiredIDValid('selected_company_id', $_GET))
        {
            $selectedCompanyID = false;
            $companyRS = array();
            $reportsToRS = array();
        }
        else
        {
            $selectedCompanyID = $_GET['selected_company_id'];
            $companyRS = $companies->get($selectedCompanyID);
            $reportsToRS = $messages->getAll(-1, $_GET['selected_company_id']);
        }

        /* Get extra fields. */
        $extraFieldRS = $messages->extraFields->getValuesForAdd();

        $defaultCompanyID = $companies->getDefaultCompany();
        if ($defaultCompanyID !== false)
        {
            $defaultCompanyRS = $companies->get($defaultCompanyID);
        }
        else
        {
            $defaultCompanyRS = array();
        }

        if (!eval(Hooks::get('CONTACTS_ADD'))) return;

        $this->_template->assign('defaultCompanyID', $defaultCompanyID);
        $this->_template->assign('defaultCompanyRS', $defaultCompanyRS);
        $this->_template->assign('active', $this);
        $this->_template->assign('extraFieldRS', $extraFieldRS);
        $this->_template->assign('subActive', 'Add Contact');
        $this->_template->assign('companyRS', $companyRS);
        $this->_template->assign('reportsToRS', $reportsToRS); //goback
        $this->_template->assign('selectedCompanyID', $selectedCompanyID);
        $this->_template->assign('sessionCookie', $_SESSION['CATS']->getCookie());
        $this->_template->display('./modules/messaging/Add.tpl');
    }

    /*
     * Called by handleRequest() to process saving / submitting the add page.
     */
    private function onAdd()
    {
        /* Bail if we don't have add permision. */
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

		$sendMessage = isset($_POST['send']) ? true : false;
		
		$message  = $this->getTrimmedInput('message', $_POST);
        $subject   = $this->getTrimmedInput('subject', $_POST);
        $contactlist  = $this->getTrimmedInput('contactlist', $_POST);
        $contactgroup = $this->getTrimmedInput('contactgroup', $_POST);
		$site_id = $this->_siteID;
		$user_id = $this->_userID;
		$modifiedby_id = $this->_userID;
		$status = 0;	
		
		$mailerSettings = new MailerSettings($this->_siteID);
        $mailerSettingsRS = $mailerSettings->getAll();
		$signature = $mailerSettingsRS['signature'];
		$message = str_replace('%SIGNATURE%',$signature,$message);

        /* Bail out if any of the required fields are empty. */
        if (empty($message) || empty($subject))
        {
            CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this, 'Required fields are missing.');
        }

        $messages = new Messaging($this->_siteID);
        $messageID = $messages->add($user_id, $modifiedby_id, $site_id, $status, $message, $subject, $contactlist, $contactgroup, true);
		
        if ($messageID <= 0)
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to add message.');
        }

		if($sendMessage){
			CATSUtility::transferRelativeURI(
				'm=messaging&a=messages'
			);
		} else {
			CATSUtility::transferRelativeURI(
				'm=messaging&a=show&messageID=' . $messageID
			);
		}
    }

    private function templateAdd()
    {
        $this->_template->assign('active', $this);
        $this->_template->display('./modules/messaging/templateAdd.tpl');
    }

    private function onTemplateAdd()
    {
		// id, user_id, modifiedby_id, site_id, status, message, subject, date_created, date_modified, date_sent
		$content  = $this->getTrimmedInput('content', $_POST);
		$title   = $this->getTrimmedInput('title', $_POST);
		$signature  = $this->getTrimmedInput('signature', $_POST);
		$site_id = $this->_siteID;
		$user_id = $this->_userID;
		$modifiedby_id = $this->_userID;
		$status = 0;
		$date_sent = date('Y-m-d H:i:s');

						
		$template = array('title' => $title,
				'content' => $content,
				'user_id' => $user_id,
				'status' => $status,
				'signature' => $signature,
				'sharedlist' => '',
				'sharedgroup' => '',
				'id' => -1);
		
		/* Bail out if any of the required fields are empty. */
		if (empty($content) || empty($title))
		{
			CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this, 'Required fields are missing.');
		}

		$messages = new Messaging($this->_siteID);
        $id = $messages->addTemplate($template);
		if(!$id)
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to update template entry.');
        } /*else {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Successfully added new template.');
		}*/

        CATSUtility::transferRelativeURI(
            'm=messaging&a=templateEdit&id='.$id
        );
	}
	
    private function templateEdit()
    {
        if (!$this->isRequiredIDValid('id', $_GET) && !$this->isRequiredIDValid('id', $_POST))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid template ID.');
        }

		$messages = new Messaging($this->_siteID);

		$id = $_GET['id'];
		$data = $messages->getTemplate($id);
		
        $this->_template->assign('data', $data);
        $this->_template->assign('active', $this);
        $this->_template->display('./modules/messaging/templateEdit.tpl');
    }
	
	private function onTemplateEdit()
	{
        if (!$this->isRequiredIDValid('id', $_POST))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid message ID.');
        }

		$id = $_POST['id'];

		// id, user_id, modifiedby_id, site_id, status, message, subject, date_created, date_modified, date_sent
		$content  = $this->getTrimmedInput('content', $_POST);
		$title   = $this->getTrimmedInput('title', $_POST);
		$signature  = $this->getTrimmedInput('signature', $_POST);
		$site_id = $this->_siteID;
		$user_id = $this->_userID;
		$modifiedby_id = $this->_userID;
		$status = 1;
		$date_sent = date('Y-m-d H:i:s');

						
		$template = array('title' => $title,
				'content' => $content,
				'user_id' => $user_id,
				'status' => $status,
				'signature' => $signature,
				'sharedlist' => '',
				'sharedgroup' => '',
				'id' => $id);
		
		/* Bail out if any of the required fields are empty. */
		if (empty($content) || empty($title))
		{
			CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this, 'Required fields are missing.');
        // } else {
            // CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Successfully updated template.');
		}

		$messages = new Messaging($this->_siteID);
        if (!$messages->updateTemplate($template))
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to update template entry.');
        }

        CATSUtility::transferRelativeURI(
            'm=messaging&a=templateEdit&id=' . $id
        );
	}

    private function edit()
    {
        /* Bail out if we don't have a valid contact ID. */
        if (!$this->isRequiredIDValid('messageID', $_GET) && !$this->isRequiredIDValid('messageID', $_POST))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid message ID.');
        }

		$messages = new Messaging($this->_siteID);

		$messageID = $_GET['messageID'];
		$data = $messages->get($messageID);
		
		$contactlist = $messages->getEmailListinginList($this->_userID ,$data['contact_list']); 

        $this->_template->assign('contactlist', $contactlist);
        $this->_template->assign('contactgroup', '');
        $this->_template->assign('data', $data);
        $this->_template->assign('data', $data);
        $this->_template->assign('active', $this);
        $this->_template->display('./modules/messaging/Edit.tpl');
    }

    private function onEdit()
    {
        if (!$this->isRequiredIDValid('messageID', $_POST))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid message ID.');
        }

		$messageID = isset($_POST['messageID']) ? $_POST['messageID'] : -1;
		$sendMessage = isset($_POST['send']) ? true : false;		

		// id, user_id, modifiedby_id, site_id, status, message, subject, date_created, date_modified, date_sent
		$message  = $this->getTrimmedInput('message', $_POST);
		$subject   = $this->getTrimmedInput('subject', $_POST);
		$contactlist  = $this->getTrimmedInput('contactlist', $_POST);
		$contactgroup = $this->getTrimmedInput('contactgroup', $_POST);
		$site_id = $this->_siteID;
		$user_id = $this->_userID;
		$modifiedby_id = $this->_userID;
		$status = 0;
		$date_sent = date('Y-m-d H:i:s');

		/* Bail out if any of the required fields are empty. */
		if (empty($message) || empty($subject))
		{
			CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this, 'Required fields are missing.');
		}

		$messages = new Messaging($this->_siteID);
		// $messages->update($messageID, $modifiedby_id, $site_id, $status, $message, $subject, $date_sent,$contactlist,$contactgroup);
        if (!$messages->update($messageID, $modifiedby_id, $site_id, $status, $message, $subject, $date_sent,$contactlist,$contactgroup,$sendMessage))
					  //update($messageID, $modifiedby_id, $site_id, $status, $message, $subject, $date_sent, $contact_list, $contact_group){
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to update message.');
        }
		if($sendMessage){
			CATSUtility::transferRelativeURI(
				'm=messaging&a=messages'
			);
		} else {
			CATSUtility::transferRelativeURI(
				'm=messaging&a=edit&messageID=' . $messageID
			);
		}
    }

    public function onDelete()
    {
		if(isset($_POST['id_list']) && $_POST['id_list'] != '' && $_POST['id_list'] != 'undefined' ){
			$messageIDs = $_POST['id_list'];
			$messages = new Messaging($this->_siteID);
			$messages->deleteIDs($messageIDs);
		} else {
			$message_ids = '';
			foreach($_POST as $k => $v) {
			  if (substr( $k, 0, 8 ) === "checked_" && $v == 'on' ) {
				  $message_ids .= substr( $k, 8, strlen($k) ) . ',';
				} else continue;
			}
			$message_ids = rtrim($message_ids,',');
			$messages = new Messaging($this->_siteID);
			$messages->deleteIDs($message_ids);
		}
		
        CATSUtility::transferRelativeURI('m=messaging&a=messages');
    }

    public function onTemplateDelete()
    {
		if(isset($_POST['id_list'][0])){
			$templateIDs = $_POST['id_list'];
			$messages = new Messaging($this->_siteID);
			$messages->deleteTemplates($templateIDs);
		}
		
        CATSUtility::transferRelativeURI('m=messaging&a=templates');
    }

    /*
     * Called by handleRequest() to process loading the search page.
     */
    private function search()
    {
		if(isset($_POST['search'])) {
			$messages = new Messaging($this->_siteID);
			$search_data = $messages->search($_POST['search'], array('subject' => $_POST['subject'], 'contact' => $_POST['contact']));
			$candidate = new Candidates($this->_siteID);
			$contact = new Contacts($this->_siteID);			
			$total = count($search_data['data']);
			for($i=0; $i<$total; $i++) {
				$contactList = array();
				$list = explode( ',' , $search_data['data'][$i]['contact_list']);
				foreach($list as $e) {
					$d = explode( '.' , $e);
					$da = array();			
					if ($d[0] == '1') {
						$da = $candidate->getFullName($d[1]);
					} else if ($d[0] == '2') {
						$da = $contact->getFullName($d[1]);
					}
					
					if (!empty($da['email1'])){ array_push($contactList, $da['fullname'].' ('.$da['email1'].')'); }
					else{ array_push($contactList, $da['fullname'].' ('.$da['email2'].')'); }
				}				
				$search_data['data'][$i]['contact_list'] = implode(', ', $contactList);
			}	
			
			$this->_template->assign('search_data', $search_data);
			$this->_template->assign('search_result', true);
		}
        $this->_template->assign('active', $this);
        $this->_template->assign('data', $data);
        $this->_template->display('./modules/messaging/Search.tpl');
    }
	
	private function loadContactList(){
		$alpha = (isset($_GET['alpha'])) ? $_GET['alpha'] : 'a' ;
		
		$contact = new Contacts($this->_siteID);
		$candidate = new Candidates($this->_siteID);
		$templateList1 = $candidate->getEmailListingByAlpha($alpha);
		$templateList2 = $contact->getEmailListingByAlpha($alpha);		
		
		for ($x = 0; $x < count($templateList1); $x++) {
			$templateList1[$x]['id'] = '1.'.$templateList1[$x]['id'];
		}
		for ($x = 0; $x < count($templateList2); $x++) {
			$templateList2[$x]['id'] = '2.'.$templateList2[$x]['id'];
		}
		
		$templateList = array_merge($templateList1, $templateList2);
		$tmp = Array(); 
		foreach($templateList as &$ma) 
			$tmp[] = &$ma["lastName"]; 
		array_multisort($tmp, $templateList); 
		
		foreach($templateList as $val){
			$lastName = (isset($val['lastName']) && strlen($val['lastName']) > 0 ? $val['lastName'] : '');
			$firstName = (isset($val['firstName']) && strlen($val['firstName']) > 0 ? $val['firstName'] : '');
			$email1 = (isset($val['email1']) && strlen($val['email1']) > 0 ? $val['email1'] : '');
			$email2 = (isset($val['email2']) && strlen($val['email2']) > 0 ? $val['email2'] : '');
			
			// exclude contacts with no name & email
			if ($lastName == '' && $firstName == '') continue;
			if ($email1 == '' && $email2 == '') continue;
			
			$emailTextDisplay = ( strlen($email1) > 0 ? $email1 : (strlen($email2) > 0 ? $email2 : 'Unknown') );
			$textDisplay = ((strlen($lastName) + strlen($firstName)) > 0 ? $lastName.', '.$firstName : $emailTextDisplay);
			echo '<div id="div'.$val['id'].'" style="padding: 3px; padding-left: 35px; border-bottom: 1px solid #EEE;" onclick="javascript:setContactList('.$val['id'].')"><b>'.$textDisplay.'</b> ('.$emailTextDisplay.')</div>';
		}
		exit();
	}

	private function loadTemplateList(){
		$message = new Messaging($this->_siteID);
		$templateList = $message->getAllTemplate();
		foreach($templateList as $val){
			echo '<div id="div'.$val['templateID'].'" style="background: url(\'images/checkbox_blank.gif\') no-repeat 8px 3px; padding: 3px; padding-left: 35px; border-bottom: 1px solid #EEE;" onclick="javascript:setTemplateID('.$val['templateID'].')"><b>'.(isset($val['title']) && strlen($val['title']) > 0 ? $val['title'] : 'Unknown').'</b></div>';
		}
		exit();
	}
	
	private function loadTemplate(){
		if(!isset($_GET['templateID'])) return '';
		$templateID = $_GET['templateID'];
		$message = new Messaging($this->_siteID);
		$template = $message->getTemplate($templateID);
		echo json_encode($template);
	}

    /*
     * Called by handleRequest() to process displaying the search results.
     */
    private function onSearch()
    {
        $wildCardContactName = '';
        $wildCardCompanyName = '';
        $wildCardContactTitle = '';

        /* Bail out to prevent an error if the GET string doesn't even contain
         * a field named 'wildCardString' at all.
         */
        if (!isset($_GET['wildCardString']))
        {
            CommonErrors::fatal(COMMONERROR_WILDCARDSTRING, $this, 'No wild card string specified.');
        }

        $query = trim($_GET['wildCardString']);

        /* Set up sorting. */
        if ($this->isRequiredIDValid('page', $_GET))
        {
            $currentPage = $_GET['page'];
        }
        else
        {
            $currentPage = 1;
        }

        $searchPager = new SearchPager(
            CANDIDATES_PER_PAGE, $currentPage, $this->_siteID, $_GET
        );

        if ($searchPager->isSortByValid('sortBy', $_GET))
        {
            $sortBy = $_GET['sortBy'];
        }
        else
        {
            $sortBy = 'lastName';
        }

        if ($searchPager->isSortDirectionValid('sortDirection', $_GET))
        {
            $sortDirection = $_GET['sortDirection'];
        }
        else
        {
            $sortDirection = 'ASC';
        }

        $baseURL = CATSUtility::getFilteredGET(
            array('sortBy', 'sortDirection', 'page'), '&amp;'
        );
        $searchPager->setSortByParameters($baseURL, $sortBy, $sortDirection);

        /* Get our current searching mode. */
        $mode = $this->getTrimmedInput('mode', $_GET);

        /* Execute the search. */
        $search = new ContactsSearch($this->_siteID);
        switch ($mode)
        {
            case 'searchByFullName':
                $wildCardContactName = $query;
                $rs = $search->byFullName($query, $sortBy, $sortDirection);
                break;

            case 'searchByCompanyName':
                $wildCardCompanyName = $query;
                $rs = $search->byCompanyName($query, $sortBy, $sortDirection);
                break;

            case 'searchByTitle':
                $wildCardContactTitle = $query;
                $rs = $search->byTitle($query, $sortBy, $sortDirection);
                break;

            default:
                CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid search mode.');
                break;
        }

        foreach ($rs as $rowIndex => $row)
        {
            if ($row['isHotContact'] == 1)
            {
                $rs[$rowIndex]['linkClassContact'] = 'jobLinkHot';
            }
            else
            {
                $rs[$rowIndex]['linkClassContact'] = 'jobLinkCold';
            }

            if ($row['leftCompany'] == 1)
            {
                 $rs[$rowIndex]['linkClassCompany'] = 'jobLinkDead';
            }
            else if ($row['isHotCompany'] == 1)
            {
                $rs[$rowIndex]['linkClassCompany'] = 'jobLinkHot';
            }
            else
            {
                $rs[$rowIndex]['linkClassCompany'] = 'jobLinkCold';
            }

            if (!empty($row['ownerFirstName']))
            {
                $rs[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                    $row['ownerFirstName'],
                    $row['ownerLastName'],
                    false,
                    LAST_NAME_MAXLEN
                );
            }
            else
            {
                $rs[$rowIndex]['ownerAbbrName'] = 'None';
            }
        }


        $messageIDs = implode(',', ResultSetUtility::getColumnValues($rs, 'messageID'));
        $exportForm = ExportUtility::getForm(
            DATA_ITEM_CONTACT, $messageIDs, 40, 15
        );

        /* Save the search. */
        $savedSearches = new SavedSearches($this->_siteID);
        $savedSearches->add(
            DATA_ITEM_CONTACT,
            $query,
            $_SERVER['REQUEST_URI'],
            false
        );
        $savedSearchRS = $savedSearches->get(DATA_ITEM_CONTACT);

        $query = urlencode(htmlspecialchars($query));

        if (!eval(Hooks::get('CONTACTS_ON_SEARCH'))) return;

        $this->_template->assign('savedSearchRS', $savedSearchRS);
        $this->_template->assign('active', $this);
        $this->_template->assign('pager', $searchPager);
        $this->_template->assign('exportForm', $exportForm);
        $this->_template->assign('subActive', 'Search Contacts');
        $this->_template->assign('rs', $rs);
        $this->_template->assign('isResultsMode', true);
        $this->_template->assign('wildCardString', $query);
        $this->_template->assign('wildCardContactName', $wildCardContactName);
        $this->_template->assign('wildCardCompanyName', $wildCardCompanyName);
        $this->_template->assign('wildCardContactTitle', $wildCardContactTitle);
        $this->_template->assign('mode', $mode);
        $this->_template->display('./modules/messaging/Search.tpl');
    }

    /*
     * Called by handleRequest() to process loading the cold call list.
     */
    private function showColdCallList()
    {
        $messages = new Messaging($this->_siteID);

        $rs = $messages->getColdCallList();

        if (!eval(Hooks::get('CONTACTS_COLD_CALL_LIST'))) return;

        $this->_template->assign('rs', $rs);
        $this->_template->display('./modules/messaging/ColdCallList.tpl');
    }

    //TODO: Document me.
    private function addActivityScheduleEvent()
    {
        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('messageID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid contact ID.');
        }

        $messageID = $_GET['messageID'];

        $messages = new Messaging($this->_siteID);
        $contactData = $messages->get($messageID);

        $regardingRS = $messages->getJobOrdersArray($messageID);

        $calendar = new Calendar($this->_siteID);
        $calendarEventTypes = $calendar->getAllEventTypes();

        /* Are we in "Only Schedule Event" mode? */
        $onlyScheduleEvent = $this->isChecked('onlyScheduleEvent', $_GET);

        if (!eval(Hooks::get('CONTACTS_ADD_ACTIVITY_SCHEDULE_EVENT'))) return;

        if (SystemUtility::isSchedulerEnabled() && !$_SESSION['CATS']->isDemo())
        {
            $allowEventReminders = true;
        }
        else
        {
            $allowEventReminders = false;
        }

        $this->_template->assign('messageID', $messageID);
        $this->_template->assign('regardingRS', $regardingRS);
        $this->_template->assign('allowEventReminders', $allowEventReminders);
        $this->_template->assign('userEmail', $_SESSION['CATS']->getEmail());
        $this->_template->assign('onlyScheduleEvent', $onlyScheduleEvent);
        $this->_template->assign('calendarEventTypes', $calendarEventTypes);
        $this->_template->assign('isFinishedMode', false);
        $this->_template->display(
            './modules/messaging/AddActivityScheduleEventModal.tpl'
        );
    }

    //TODO: Document me.
    private function onAddActivityScheduleEvent()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid regardingjob order ID. */
        if (!$this->isOptionalIDValid('regardingID', $_POST))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid job order ID.');
        }

        $regardingID = $_POST['regardingID'];

        $this->_addActivityScheduleEvent($regardingID);
    }

    /*
     * Called by handleRequest() to process downloading of a contact's vCard.
     *
     * Example vCard output in doc/NOTES.
     */
    private function downloadVCard()
    {
        /* Bail out if we don't have a valid contact ID. */
        if (!$this->isRequiredIDValid('messageID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid contact ID.');
        }

        $messageID = $_GET['messageID'];

        $messages = new Messaging($this->_siteID);
        $contact = $messages->get($messageID);

        $companies = new Companies($this->_siteID);
        $company = $companies->get($contact['companyID']);

        /* Bail out if we got an empty result set. */
        if (empty($contact))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'The specified contact ID could not be found.');
        }

        /* Create a new vCard. */
        $vCard = new VCard();

        $vCard->setName($contact['lastName'], $contact['firstName']);

        if (!empty($contact['phoneWork']))
        {
            $vCard->setPhoneNumber($contact['phoneWork'], 'PREF;WORK;VOICE');
        }

        if (!empty($contact['phoneCell']))
        {
            $vCard->setPhoneNumber($contact['phoneCell'], 'CELL;VOICE');
        }

        /* FIXME: Add fax to messages and use setPhoneNumber('WORK;FAX') here */

        $addressLines = explode("\n", $contact['address']);

        $address1 = trim($addressLines[0]);
        if (isset($addressLines[1]))
        {
            $address2 = trim($addressLines[1]);
        }
        else
        {
            $address2 = '';
        }

        $vCard->setAddress(
            $address1, $address2, $contact['city'],
            $contact['state'], $contact['zip']
        );

        if (!empty($contact['email1']))
        {
            $vCard->setEmail($contact['email1']);
        }

        if (!empty($company['url']))
        {
            $vCard->setURL($company['url']);
        }

        $vCard->setTitle($contact['title']);
        $vCard->setOrganization($company['name']);

        if (!eval(Hooks::get('CONTACTS_GET_VCARD'))) return;

        $vCard->printVCardWithHeaders();
    }


    /**
     * Formats SQL result set for display. This is factored out for code
     * clarity.
     *
     * @param array result set from listByView()
     * @return array formatted result set
     */
    private function _formatListByViewResults($resultSet)
    {
        if (empty($resultSet))
        {
            return $resultSet;
        }

        foreach ($resultSet as $rowIndex => $row)
        {
            if (!empty($resultSet[$rowIndex]['ownerFirstName']))
            {
                $resultSet[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                    $resultSet[$rowIndex]['ownerFirstName'],
                    $resultSet[$rowIndex]['ownerLastName'],
                    false,
                    LAST_NAME_MAXLEN
                );
            }
            else
            {
                $resultSet[$rowIndex]['ownerAbbrName'] = 'None';
            }

            /* Hot messages [can] have different title styles than normal
             * companies.
             */
            if ($resultSet[$rowIndex]['isHotContact'] == 1)
            {
                $resultSet[$rowIndex]['linkClassContact'] = 'jobLinkHot';
            }
            else
            {
                $resultSet[$rowIndex]['linkClassContact'] = 'jobLinkCold';
            }

           /* Strikethrough on no longer associated companies takes priority
            * over hot companies.
            */
            if ($resultSet[$rowIndex]['leftCompany'] == 1)
            {
                $resultSet[$rowIndex]['linkClassCompany'] = 'jobLinkDead';
            }
            else if ($resultSet[$rowIndex]['isHotCompany'] == 1)
            {
                $resultSet[$rowIndex]['linkClassCompany'] = 'jobLinkHot';
            }
            else
            {
                $resultSet[$rowIndex]['linkClassCompany'] = 'jobLinkCold';
            }

            /* Truncate Company Name column */
            if (strlen($resultSet[$rowIndex]['companyName']) > self::TRUNCATE_CLIENT_NAME)
            {
                $resultSet[$rowIndex]['companyName'] = substr(
                    $resultSet[$rowIndex]['companyName'], 0, self::TRUNCATE_CLIENT_NAME
                ) . "...";
            }

            /* Truncate Title column */
            if (strlen($resultSet[$rowIndex]['title']) > self::TRUNCATE_TITLE)
            {
                $resultSet[$rowIndex]['title'] = substr(
                    $resultSet[$rowIndex]['title'], 0, self::TRUNCATE_TITLE
                ) . "...";
            }
        }

        if (!eval(Hooks::get('CONTACTS_FORMAT_LIST_BY_VIEW'))) return;

        return $resultSet;
    }

    /**
     * Processes an Add Activity / Schedule Event form and displays
     * messages/AddActivityScheduleEventModal.tpl. This is factored out
     * for code clarity.
     *
     * @param boolean from joborders module perspective
     * @param integer "regarding" job order ID or -1
     * @param string module directory
     * @return void
     */
    private function _addActivityScheduleEvent($regardingID, $directoryOverride = '')
    {
        /* Module directory override for fatal() calls. */
        if ($directoryOverride != '')
        {
            $moduleDirectory = $directoryOverride;
        }
        else
        {
            $moduleDirectory = $this->_moduleDirectory;
        }

        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('messageID', $_POST))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid contact ID.');
        }

        $messageID = $_POST['messageID'];

        //if (!eval(Hooks::get('CONTACT_ON_ADD_ACTIVITY_SCHEDULE_EVENT_PRE'))) return;

        if ($this->isChecked('addActivity', $_POST))
        {
            /* Bail out if we don't have a valid job order ID. */
            if (!$this->isOptionalIDValid('activityTypeID', $_POST))
            {
                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid activity type ID.');
            }

            $activityTypeID = $_POST['activityTypeID'];

            $activityNote = $this->getTrimmedInput('activityNote', $_POST);

            $activityNote = htmlspecialchars($activityNote);

            /* Add the activity entry. */
            $activityEntries = new ActivityEntries($this->_siteID);
            $activityID = $activityEntries->add(
                $messageID,
                DATA_ITEM_CONTACT,
                $activityTypeID,
                $activityNote,
                $this->_userID,
                $regardingID
            );
            $activityTypes = $activityEntries->getTypes();
            $activityTypeDescription = ResultSetUtility::getColumnValueByIDValue(
                $activityTypes, 'typeID', $activityTypeID, 'type'
            );

            $activityAdded = true;
        }
        else
        {
            $activityAdded = false;
            $activityNote = '';
            $activityTypeDescription = '';
        }

        if ($this->isChecked('scheduleEvent', $_POST))
        {
            /* Bail out if we received an invalid date. */
            $trimmedDate = $this->getTrimmedInput('dateAdd', $_POST);
            if (empty($trimmedDate) ||
                !DateUtility::validate('-', $trimmedDate, DATE_FORMAT_MMDDYY))
            {
                CommonErrors::fatalModal(COMMONERROR_MISSINGFIELDS, $this, 'Invalid date.');
            }

            /* Bail out if we don't have a valid event type. */
            if (!$this->isRequiredIDValid('eventTypeID', $_POST))
            {
                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid event type ID.');
            }

            /* Bail out if we don't have a valid time format ID. */
            if (!isset($_POST['allDay']) ||
                ($_POST['allDay'] != '0' && $_POST['allDay'] != '1'))
            {
                CommonErrors::fatalModal(COMMONERROR_MISSINGFIELDS, $this, 'Invalid time format ID.');
            }

            $eventTypeID = $_POST['eventTypeID'];

            if ($_POST['allDay'] == 1)
            {
                $allDay = true;
            }
            else
            {
                $allDay = false;
            }

            $publicEntry = $this->isChecked('publicEntry', $_POST);

            $reminderEnabled = $this->isChecked('reminderToggle', $_POST);
            $reminderEmail = $this->getTrimmedInput('sendEmail', $_POST);
            $reminderTime  = $this->getTrimmedInput('reminderTime', $_POST);

            $duration = -1;

            /* Is this a scheduled event or an all day event? */
            if ($allDay)
            {
                $date = DateUtility::convert(
                    '-', $trimmedDate, DATE_FORMAT_MMDDYY, DATE_FORMAT_YYYYMMDD
                );

                $hour = 12;
                $minute = 0;
                $meridiem = 'AM';
            }
            else
            {
                /* Bail out if we don't have a valid hour. */
                if (!isset($_POST['hour']))
                {
                    CommonErrors::fatalModal(COMMONERROR_MISSINGFIELDS, $this, 'Invalid hour.');
                }

                /* Bail out if we don't have a valid minute. */
                if (!isset($_POST['minute']))
                {
                    CommonErrors::fatalModal(COMMONERROR_MISSINGFIELDS, $this, 'Invalid minute.');
                }

                /* Bail out if we don't have a valid meridiem value. */
                if (!isset($_POST['meridiem']) ||
                    ($_POST['meridiem'] != 'AM' && $_POST['meridiem'] != 'PM'))
                {
                    CommonErrors::fatalModal(COMMONERROR_MISSINGFIELDS, $this, 'Invalid meridiem value.');
                }

                $hour     = $_POST['hour'];
                $minute   = $_POST['minute'];
                $meridiem = $_POST['meridiem'];

                /* Convert formatted time to UNIX timestamp. */
                $time = strtotime(
                    sprintf('%s:%s %s', $hour, $minute, $meridiem)
                );

                /* Create MySQL date string w/ 24hr time (YYYY-MM-DD HH:MM:SS). */
                $date = sprintf(
                    '%s %s',
                    DateUtility::convert(
                        '-',
                        $trimmedDate,
                        DATE_FORMAT_MMDDYY,
                        DATE_FORMAT_YYYYMMDD
                    ),
                    date('H:i:00', $time)
                );
            }

            $description = $this->getTrimmedInput('description', $_POST);
            $title       = $this->getTrimmedInput('title', $_POST);

            /* Bail out if any of the required fields are empty. */
            if (empty($title))
            {
                CommonErrors::fatalModal(COMMONERROR_MISSINGFIELDS, $this, 'Required fields are missing.');
            }

            if ($regardingID > 0)
            {
                $eventJobOrderID = $regardingID;
            }
            else
            {
                $eventJobOrderID = -1;
            }

            $calendar = new Calendar($this->_siteID);
            $eventID = $calendar->addEvent(
                $eventTypeID, $date, $description, $allDay, $this->_userID,
                $messageID, DATA_ITEM_CONTACT, $eventJobOrderID, $title,
                $duration, $reminderEnabled, $reminderEmail, $reminderTime,
                $publicEntry, $_SESSION['CATS']->getTimeZoneOffset()
            );

            if ($eventID <= 0)
            {
                CommonErrors::fatalModal(COMMONERROR_RECORDERROR, $this, 'Failed to add calendar event.');
            }

            /* Extract the date parts from the specified date. */
            $parsedDate = strtotime($date);
            $formattedDate = date('l, F jS, Y', $parsedDate);

            $calendar = new Calendar($this->_siteID);
            $calendarEventTypes = $calendar->getAllEventTypes();

            $eventTypeDescription = ResultSetUtility::getColumnValueByIDValue(
                $calendarEventTypes, 'typeID', $eventTypeID, 'description'
            );

            $eventHTML = sprintf(
                '<p>An event of type <span class="bold">%s</span> has been scheduled on <span class="bold">%s</span>.</p>',
                htmlspecialchars($eventTypeDescription),
                htmlspecialchars($formattedDate)

            );
            $eventScheduled = true;
        }
        else
        {
            $eventHTML = '<p>No event has been scheduled.</p>';
            $eventScheduled = false;
        }

        if (isset($_GET['onlyScheduleEvent']))
        {
            $onlyScheduleEvent = true;
        }
        else
        {
            $onlyScheduleEvent = false;
        }

        if (!$activityAdded && !$eventScheduled)
        {
            $changesMade = false;
        }
        else
        {
            $changesMade = true;
        }

        if (!eval(Hooks::get('CANDIDATE_ON_ADD_ACTIVITY_CHANGE_STATUS_POST'))) return;

        $this->_template->assign('messageID', $messageID);
        $this->_template->assign('regardingID', $regardingID);
        $this->_template->assign('activityAdded', $activityAdded);
        $this->_template->assign('activityDescription', $activityNote);
        $this->_template->assign('activityType', $activityTypeDescription);
        $this->_template->assign('eventScheduled', $eventScheduled);
        $this->_template->assign('onlyScheduleEvent', $onlyScheduleEvent);
        $this->_template->assign('eventHTML', $eventHTML);
        $this->_template->assign('changesMade', $changesMade);
        $this->_template->assign('isFinishedMode', true);
        $this->_template->display(
            './modules/messaging/AddActivityScheduleEventModal.tpl'
        );
    }
}

?>