<?php
/*
 * CATS
 * Companies Module
 *
 * Copyright (C) 2005 - 2007 Cognizo Technologies, Inc.
 *
 *
 * The contents of this file are subject to the CATS Public License
 * Version 1.1a (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.catsone.com/.
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is "CATS Standard Edition".
 *
 * The Initial Developer of the Original Code is Cognizo Technologies, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2005 - 2007
 * (or from the year in which this file was created to the year 2007) by
 * Cognizo Technologies, Inc. All Rights Reserved.
 *
 *
 * $Id: CompaniesUI.php 3460 2007-11-07 03:50:34Z brian $
 */

include_once('./lib/StringUtility.php');
include_once('./lib/DateUtility.php'); /* Depends on StringUtility. */
include_once('./lib/ResultSetUtility.php');
include_once('./lib/Candidates.php');
include_once('./lib/Companies.php');
include_once('./lib/Contacts.php');
include_once('./lib/JobOrders.php');
include_once('./lib/Attachments.php');
include_once('./lib/Export.php');
include_once('./lib/ListEditor.php');
include_once('./lib/FileUtility.php');
include_once('./lib/ExtraFields.php');
include_once('./lib/CommonErrors.php');

class CompaniesUI extends UserInterface
{
    /* Maximum number of characters of the job notes to show without the user
     * clicking "[More]"
     */
    const NOTES_MAXLEN = 500;


    public function __construct()
    {
        parent::__construct();

        $this->_authenticationRequired = true;
        $this->_moduleDirectory = 'companies';
        $this->_moduleName = 'companies';
        $this->_moduleTabText = 'Companies';
        $this->_subTabs = array(
            'Add Company'     => CATSUtility::getIndexName() . '?m=companies&amp;a=add*al='.ACCESS_LEVEL_EDIT.'*hrmode=0',
            'Search Companies' => CATSUtility::getIndexName() . '?m=companies&amp;a=search*hrmode=0',
            'Go To My Company' => CATSUtility::getIndexName() . '?m=companies&amp;a=internalPostings*hrmode=0'
        );
		
		if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_RESEARCHER || 
		   intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_RECRUITER) {
		   CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Insufficient rights to access this page.'); 
		}
    }


    public function handleRequest()
    {
        $action = $this->getAction();

        if (!eval(Hooks::get('CLIENTS_HANDLE_REQUEST'))) return;

        switch ($action)
        {
            case 'show':
                $this->show();
                break;

            case 'internalPostings':
                $this->internalPostings();
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
                if ($this->isPostBack())
                {
                    $this->onEdit();
                }
                else
                {
                    $this->edit();
                }

                break;

            case 'delete':
                $this->onDelete();
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

            /* Add an attachment */
            case 'createAttachment':
                include_once('./lib/DocumentToText.php');

                if ($this->isPostBack())
                {
                    $this->onCreateAttachment();
                }
                else
                {
                    $this->createAttachment();
                }

                break;

            /* Delete an attachment */
            case 'deleteAttachment':
                $this->onDeleteAttachment();
                break;

            /* Main companies page. */
            case 'listByView':
            default:
                $this->listByView();
                break;
        }
    }


    /*
     * Called by handleRequest() to process loading the list / main page.
     */
    private function listByView($errMessage = '')
    {
        /* First, if we are operating in HR mode we will never see the
           companies pager.  Immediantly forward to My Company. */

        if ($_SESSION['CATS']->isHrMode())
        {
            $this->internalPostings();
            die();
        }

        $dataGridProperties = DataGrid::getRecentParamaters("companies:CompaniesListByViewDataGrid");

        /* If this is the first time we visited the datagrid this session, the recent paramaters will
         * be empty.  Fill in some default values. */
        if ($dataGridProperties == array())
        {
            $dataGridProperties = array('rangeStart'    => 0,
                                        'maxResults'    => 15,
                                        'filterVisible' => false);
        }

        $dataGrid = DataGrid::get("companies:CompaniesListByViewDataGrid", $dataGridProperties);

        $this->_template->assign('active', $this);
        $this->_template->assign('dataGrid', $dataGrid);
        $this->_template->assign('userID', $_SESSION['CATS']->getUserID());
        $this->_template->assign('errMessage', $errMessage);

        if (!eval(Hooks::get('CLIENTS_LIST_BY_VIEW'))) return;

        $this->_template->display('./modules/companies/Companies.tpl');
    }

    /*
     * Called by handleRequest() to process loading the details page.
     */
    private function show()
    {
        /* Bail out if we don't have a valid company ID. */
        if (!$this->isRequiredIDValid('companyID', $_GET))
        {
            $this->listByView('Invalid company ID.');
            return;
        }

        $companyID = $_GET['companyID'];

        $companies = new Companies($this->_siteID);
        $data = $companies->get($companyID);

        /* Bail out if we got an empty result set. */
        if (empty($data))
        {
            $this->listByView('The specified company ID could not be found.');
            return;
        }

        /* We want to handle formatting the city and state here instead
         * of in the template.
         */
        $data['cityAndState'] = StringUtility::makeCityStateString(
            $data['city'], $data['state']
        );

        /*
         * Replace newlines with <br />, fix HTML "special" characters, and
         * strip leading empty lines and spaces.
         */
        $data['notes'] = trim(
            nl2br(htmlspecialchars($data['notes'], ENT_QUOTES))
        );

        /* Chop $data['notes'] to make $data['shortNotes']. */
        if (strlen($data['notes']) > self::NOTES_MAXLEN)
        {
            $data['shortNotes']  = substr(
                $data['notes'], 0, self::NOTES_MAXLEN
            );
            $isShortNotes = true;
        }
        else
        {
            $data['shortNotes'] = $data['notes'];
            $isShortNotes = false;
        }

        /* Hot companies [can] have different title styles than normal companies. */
        if ($data['isHot'] == 1)
        {
            $data['titleClass'] = 'jobTitleHot';
        }
        else
        {
            $data['titleClass'] = 'jobTitleCold';
        }

        /* Link to Google Maps for this address */
        if (!empty($data['address']) && !empty($data['city']) && !empty($data['state']))
        {
            $data['googleMaps'] = '<a href="http://maps.google.com/maps?q=' .
                     urlencode($data['address']) . '+' .
                     urlencode($data['city'])     . '+' .
                     urlencode($data['state']);

            /* Google Maps will find an address without Zip. */
            if (!empty($data['zip']))
            {
                $data['googleMaps'] .= '+' . $data['zip'];
            }

            $data['googleMaps'] .= '" target=_blank><img src="images/google_maps.gif" style="border: none;" class="absmiddle" /></a>';
        }
        else
        {
            $data['googleMaps'] = '';
        }

        /* Attachments */
        $attachments = new Attachments($this->_siteID);
        $attachmentsRS = $attachments->getAll(
            DATA_ITEM_COMPANY, $companyID
        );

        foreach ($attachmentsRS as $rowNumber => $attachmentsData)
        {
            /* Show an attachment icon based on the document's file type. */
            $attachmentIcon = strtolower(
                FileUtility::getAttachmentIcon(
                    $attachmentsRS[$rowNumber]['originalFilename']
                )
            );

            $attachmentsRS[$rowNumber]['attachmentIcon'] = $attachmentIcon;
        }

        /* Job Orders for this company */
        $jobOrders   = new JobOrders($this->_siteID);
        $jobOrdersRS = $jobOrders->getAll(
            JOBORDERS_STATUS_ALL, -1, $companyID, -1
        );

        if (!empty($jobOrdersRS))
        {
            foreach ($jobOrdersRS as $rowIndex => $row)
            {
                /* Convert '00-00-00' dates to empty strings. */
                $jobOrdersRS[$rowIndex]['startDate'] = DateUtility::fixZeroDate(
                    $jobOrdersRS[$rowIndex]['startDate']
                );

                /* Hot jobs [can] have different title styles than normal
                 * jobs.
                 */
                if ($jobOrdersRS[$rowIndex]['isHot'] == 1)
                {
                    $jobOrdersRS[$rowIndex]['linkClass'] = 'jobLinkHot';
                }
                else
                {
                    $jobOrdersRS[$rowIndex]['linkClass'] = 'jobLinkCold';
                }

                $jobOrdersRS[$rowIndex]['recruiterAbbrName'] = StringUtility::makeInitialName(
                    $jobOrdersRS[$rowIndex]['recruiterFirstName'],
                    $jobOrdersRS[$rowIndex]['recruiterLastName'],
                    false,
                    LAST_NAME_MAXLEN
                );

                $jobOrdersRS[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                    $jobOrdersRS[$rowIndex]['ownerFirstName'],
                    $jobOrdersRS[$rowIndex]['ownerLastName'],
                    false,
                    LAST_NAME_MAXLEN
                );
            }
        }

        /* Contacts for this company */
        $contacts   = new Contacts($this->_siteID);
        $contactsRS = $contacts->getAll(-1, $companyID);
        $contactsRSWC = null;

        if (!empty($contactsRS))
        {
            foreach ($contactsRS as $rowIndex => $row)
            {

                /* Hot contacts [can] have different title styles than normal contacts. */
                if ($contactsRS[$rowIndex]['isHot'] == 1)
                {
                    $contactsRS[$rowIndex]['linkClass'] = 'jobLinkHot';
                }
                else
                {
                    $contactsRS[$rowIndex]['linkClass'] = 'jobLinkCold';
                }

                if (!empty($contactsRS[$rowIndex]['ownerFirstName']))
                {
                    $contactsRS[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                        $contactsRS[$rowIndex]['ownerFirstName'],
                        $contactsRS[$rowIndex]['ownerLastName'],
                        false,
                        LAST_NAME_MAXLEN
                    );
                }
                else
                {
                    $contactsRS[$rowIndex]['ownerAbbrName'] = 'None';
                }
				
				$contactsRS[$rowIndex]['IsHiringMgr'] = ($contactsRS[$rowIndex]['IsHiringMgr'] == 1) ? 'yes' : 'no';

                if ($contactsRS[$rowIndex]['leftCompany'] == 0)
                {
                    $contactsRSWC[] = $contactsRS[$rowIndex];
                }
                else
                {
                    $contactsRS[$rowIndex]['linkClass'] = 'jobLinkDead';
                }
            }
        }
		
		/* Candidates for this company */
        $candidates   = new Candidates($this->_siteID);
        $candidatessRS = $candidates->getAll(false, $companyID);
        $candidatesRSWC = null;

        if (!empty($candidatessRS))
        {
			foreach ($candidatessRS as $rowIndex => $row)
			{
				if ($candidatessRS[$rowIndex]['isHot'] == 1)
				{
					$candidatessRS[$rowIndex]['linkClass'] = 'jobLinkHot';
				}
				else
				{
					$candidatessRS[$rowIndex]['linkClass'] = 'jobLinkCold';
				}

				if (!empty($candidatessRS[$rowIndex]['ownerFirstName']))
				{
					$candidatessRS[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
						$candidatessRS[$rowIndex]['ownerFirstName'],
						$candidatessRS[$rowIndex]['ownerLastName'],
						false,
						LAST_NAME_MAXLEN
					);
				}
				else
				{
					$candidatessRS[$rowIndex]['ownerAbbrName'] = 'None';
				}
				$candidatesRSWC[] = $candidatessRS[$rowIndex];
			}
        }

        /* Add an MRU entry. */
        $_SESSION['CATS']->getMRU()->addEntry(
            DATA_ITEM_COMPANY, $companyID, $data['name']
        );

        /* Get extra fields. */
        $extraFieldRS = $companies->extraFields->getValuesForShow($companyID);

        /* Get departments. */
        $departmentsRS = $companies->getDepartments($companyID);

        /* Is the user an admin - can user see history? */
        if ($this->_accessLevel < ACCESS_LEVEL_DEMO)
        {
            $privledgedUser = false;
        }
        else
        {
            $privledgedUser = true;
        }

        $this->_template->assign('active', $this);
        $this->_template->assign('data', $data);
        $this->_template->assign('attachmentsRS', $attachmentsRS);
        $this->_template->assign('departmentsRS', $departmentsRS);
        $this->_template->assign('extraFieldRS', $extraFieldRS);
        $this->_template->assign('isShortNotes', $isShortNotes);
        $this->_template->assign('jobOrdersRS', $jobOrdersRS);
        $this->_template->assign('contactsRS', $contactsRS);
        $this->_template->assign('candidatesRS', $candidatessRS);
        $this->_template->assign('contactsRSWC', $contactsRSWC);
        $this->_template->assign('candidatesRSWC', $candidatesRSWC);
        $this->_template->assign('privledgedUser', $privledgedUser);
        $this->_template->assign('companyID', $companyID);

        if (!eval(Hooks::get('CLIENTS_SHOW'))) return;

        $this->_template->display('./modules/companies/Show.tpl');
    }

    /*
     * Called by handleRequest() to process loading the internal postings company.
     */
    private function internalPostings()
    {
        $companies = new Companies($this->_siteID);
        $companyID = $companies->getDefaultCompany();

        CATSUtility::transferRelativeURI(
            'm=companies&a=show&companyID=' . $companyID
        );
    }

    /*
     * Called by handleRequest() to process loading the add page.
     */
    private function add()
    {
        $companies = new Companies($this->_siteID);

        /* Get extra fields. */
        $extraFieldRS = $companies->extraFields->getValuesForAdd();
		$industryRS = $companies->getIndustries();
		$categoryRS = $companies->getCategories();
	
        if (!eval(Hooks::get('CLIENTS_ADD'))) return;

        $this->_template->assign('extraFieldRS', $extraFieldRS);
		$this->_template->assign('industryRS', $industryRS);
		$this->_template->assign('categoryRS', $categoryRS);
		
        $this->_template->assign('active', $this);
        $this->_template->assign('subActive', 'Add Company');
        $this->_template->display('./modules/companies/Add.tpl');
    }

    /*
     * Called by handleRequest() to process saving / submitting the add page.
     */
    private function onAdd()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            $this->listByView('Invalid user level for action.');
            return;
        }

        $formattedPhone1 = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phone1', $_POST)
        );
        if (!empty($formattedPhone1))
        {
            $phone1 = $formattedPhone1;
        }
        else
        {
            $phone1 = $this->getTrimmedInput('phone1', $_POST);
        }

        $formattedPhone2 = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phone2', $_POST)
        );
        if (!empty($formattedPhone2))
        {
            $phone2 = $formattedPhone2;
        }
        else
        {
            $phone2 = $this->getTrimmedInput('phone2', $_POST);
        }

        $formattedFaxNumber = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('faxNumber', $_POST)
        );
        if (!empty($formattedFaxNumber))
        {
            $faxNumber = $formattedFaxNumber;
        }
        else
        {
            $faxNumber = $this->getTrimmedInput('faxNumber', $_POST);
        }

        $url = $this->getTrimmedInput('url', $_POST);
        if (!empty($url))
        {
            $formattedURL = StringUtility::extractURL($url);

            if (!empty($formattedURL))
            {
                $url = $formattedURL;
            }
        }

        /* Hot company? */
        $isHot = $this->isChecked('isHot', $_POST);

        $name            = $this->getTrimmedInput('name', $_POST);
        $address         = $this->getTrimmedInput('address', $_POST);
        $city            = $this->getTrimmedInput('city', $_POST);
        $state           = $this->getTrimmedInput('state', $_POST);
        $zip             = $this->getTrimmedInput('zip', $_POST);
        $keyTechnologies = $this->getTrimmedInput('keyTechnologies', $_POST);
        $notes           = $this->getTrimmedInput('notes', $_POST);
		
		$industry        = $this->getTrimmedInput('industry', $_POST);
		$cocountry       = $this->getTrimmedInput('cocountry', $_POST);
		$prospecting     = $this->getTrimmedInput('prospecting', $_POST);
		$timezone        = $this->getTrimmedInput('timezone', $_POST);
		$category        = $this->getTrimmedInput('category', $_POST);
		$employees       = $this->getTrimmedInput('employees', $_POST);
		$revenue          = $this->getTrimmedInput('revenue', $_POST);
		
		$sic          = $this->getTrimmedInput('sic', $_POST);
		$naics          = $this->getTrimmedInput('naics', $_POST);
		
        /* Departments list editor. */
        $departmentsCSV = $this->getTrimmedInput('departmentsCSV', $_POST);

        /* Bail out if any of the required fields are empty. */
        if (empty($name))
        {
            $this->listByView('Required fields are missing.');
            return;
        }

        if (!eval(Hooks::get('CLIENTS_ON_ADD_PRE'))) return;

        $companies = new Companies($this->_siteID);
        $companyID = $companies->add(
            $name, $address, $city, $state, $zip, $phone1,
            $phone2, $faxNumber, $url, $keyTechnologies, $isHot,
            $notes, $this->_userID, $this->_userID,
			$industry, $cocountry, $prospecting, $timezone, $category, $employees, $revenue, $sic, $naics
        );

        if ($companyID <= 0)
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to add company.');
        }

        if (!eval(Hooks::get('CLIENTS_ON_ADD_POST'))) return;

        /* Update extra fields. */
        $companies->extraFields->setValuesOnEdit($companyID);

        /* Add departments */
        $departments = array();
        $departmentsDifferences = ListEditor::getDifferencesFromList(
            $departments, 'name', 'departmentID', $departmentsCSV
        );

        $companies->updateDepartments($companyID, $departmentsDifferences);

        CATSUtility::transferRelativeURI(
            'm=companies&a=show&companyID=' . $companyID
        );
    }

    /*
     * Called by handleRequest() to process loading the edit page.
     */
    private function edit()
    {
        /* Bail out if we don't have a valid company ID. */
        if (!$this->isRequiredIDValid('companyID', $_GET))
        {
            $this->listByView('Invalid company ID.');
            return;
        }

        $companyID = $_GET['companyID'];

        $companies = new Companies($this->_siteID);
        $data = $companies->getForEditing($companyID);

        /* Bail out if we got an empty result set. */
        if (empty($data))
        {
            $this->listByView('The specified company ID could not be found.');
            return;
        }

        /* Get the company's contacts data. */
        $contactsRS = $companies->getContactsArray($companyID);

        $users = new Users($this->_siteID);
        $usersRS = $users->getSelectList();

        /* Add an MRU entry. */
        $_SESSION['CATS']->getMRU()->addEntry(
            DATA_ITEM_COMPANY, $companyID, $data['name']
        );

        /* Get extra fields. */
        $extraFieldRS = $companies->extraFields->getValuesForEdit($companyID);

        /* Get departments. */
        $departmentsRS = $companies->getDepartments($companyID);
        $departmentsString = ListEditor::getStringFromList($departmentsRS, 'name');

        $emailTemplates = new EmailTemplates($this->_siteID);
        $statusChangeTemplateRS = $emailTemplates->getByTag(
            'EMAIL_TEMPLATE_OWNERSHIPASSIGNCLIENT'
        );

        if (!isset($statusChangeTemplateRS['disabled']) || $statusChangeTemplateRS['disabled'] == 1)
        {
            $emailTemplateDisabled = true;
        }
        else
        {
            $emailTemplateDisabled = false;
        }

        if ($this->_accessLevel == ACCESS_LEVEL_DEMO)
        {
            $canEmail = false;
        }
        else
        {
            $canEmail = true;
        }

        if (!eval(Hooks::get('CLIENTS_EDIT'))) return;
		
		$industryRS = $companies->getIndustries();
		$categoryRS = $companies->getCategories();


        $this->_template->assign('industryRS', $industryRS);
		$this->_template->assign('categoryRS', $categoryRS);
		
        $this->_template->assign('canEmail', $canEmail);
        $this->_template->assign('active', $this);
        $this->_template->assign('data', $data);
        $this->_template->assign('usersRS', $usersRS);
        $this->_template->assign('extraFieldRS', $extraFieldRS);
        $this->_template->assign('contactsRS', $contactsRS);
        $this->_template->assign('departmentsRS', $departmentsRS);
        $this->_template->assign('departmentsString', $departmentsString);
        $this->_template->assign('emailTemplateDisabled', $emailTemplateDisabled);
        $this->_template->assign('companyID', $companyID);
        $this->_template->display('./modules/companies/Edit.tpl');
    }

    /*
     * Called by handleRequest() to process saving / submitting the edit page.
     */
    private function onEdit()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            $this->listByView('Invalid user level for action.');
            return;
        }

        $companies = new Companies($this->_siteID);

        /* Bail out if we don't have a valid company ID. */
        if (!$this->isRequiredIDValid('companyID', $_POST))
        {
            $this->listByView('Invalid company ID.');
            return;
        }

        /* Bail out if we don't have a valid owner user ID. */
        if (!$this->isOptionalIDValid('owner', $_POST))
        {
            $this->listByView('Invalid owner user ID.');
            return;
        }

        /* Bail out if we don't have a valid billing contact ID. */
        if (!$this->isOptionalIDValid('billingContact', $_POST))
        {
            $this->listByView('Invalid billing contact ID.');
            return;
        }

        $formattedPhone1 = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phone1', $_POST)
        );
        if (!empty($formattedPhone1))
        {
            $phone1 = $formattedPhone1;
        }
        else
        {
            $phone1 = $this->getTrimmedInput('phone1', $_POST);
        }

        $formattedPhone2 = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phone2', $_POST)
        );
        if (!empty($formattedPhone2))
        {
            $phone2 = $formattedPhone2;
        }
        else
        {
            $phone2 = $this->getTrimmedInput('phone2', $_POST);
        }

        $formattedFaxNumber = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('faxNumber', $_POST)
        );
        if (!empty($formattedFaxNumber))
        {
            $faxNumber = $formattedFaxNumber;
        }
        else
        {
            $faxNumber = $this->getTrimmedInput('faxNumber', $_POST);
        }

        $url = $this->getTrimmedInput('url', $_POST);
        if (!empty($url))
        {
            $formattedURL = StringUtility::extractURL($url);

            if (!empty($formattedURL))
            {
                $url = $formattedURL;
            }
        }

        /* Hot company? */
        $isHot = $this->isChecked('isHot', $_POST);

        $companyID       = $_POST['companyID'];
        $owner           = $_POST['owner'];
        $billingContact  = $_POST['billingContact'];

        /* Change ownership email? */
        if ($this->isChecked('ownershipChange', $_POST) && $owner > 0)
        {
            $companyDetails = $companies->get($companyID);

            $users = new Users($this->_siteID);
            $ownerDetails = $users->get($_POST['owner']);

            if (!empty($ownerDetails))
            {
                $emailAddress = $ownerDetails['email'];

                /* Get the change status email template. */
                $emailTemplates = new EmailTemplates($this->_siteID);
                $statusChangeTemplateRS = $emailTemplates->getByTag(
                    'EMAIL_TEMPLATE_OWNERSHIPASSIGNCLIENT'
                );

                if (empty($statusChangeTemplateRS) ||
                    empty($statusChangeTemplateRS['textReplaced']))
                {
                    $statusChangeTemplate = '';
                }
                else
                {
                    $statusChangeTemplate = $statusChangeTemplateRS['textReplaced'];
                }
                /* Replace e-mail template variables. */
                $stringsToFind = array(
                    '%CLNTOWNER%',
                    '%CLNTNAME%',
                    '%CLNTCATSURL%'
                );
                $replacementStrings = array(
                    $ownerDetails['fullName'],
                    $companyDetails['name'],
                    '<a href="http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=companies&amp;a=show&amp;companyID=' . $companyID . '">'.
                        'http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=companies&amp;a=show&amp;companyID=' . $companyID . '</a>'
                );
                $statusChangeTemplate = str_replace(
                    $stringsToFind,
                    $replacementStrings,
                    $statusChangeTemplate
                );

                $email = $statusChangeTemplate;
            }
            else
            {
                $email = '';
                $emailAddress = '';
            }
        }
        else
        {
            $email = '';
            $emailAddress = '';
        }

        $name            = $this->getTrimmedInput('name', $_POST);
        $address         = $this->getTrimmedInput('address', $_POST);
        $city            = $this->getTrimmedInput('city', $_POST);
        $state           = $this->getTrimmedInput('state', $_POST);
        $zip             = $this->getTrimmedInput('zip', $_POST);
        $keyTechnologies = $this->getTrimmedInput('keyTechnologies', $_POST);
        $notes           = $this->getTrimmedInput('notes', $_POST);
		
		$industry        = $this->getTrimmedInput('industry', $_POST);
		$cocountry       = $this->getTrimmedInput('cocountry', $_POST);
		$prospecting     = $this->getTrimmedInput('prospecting', $_POST);
		$timezone        = $this->getTrimmedInput('timezone', $_POST);
		$category        = $this->getTrimmedInput('category', $_POST);
		$employees       = $this->getTrimmedInput('employees', $_POST);
		$revenue          = $this->getTrimmedInput('revenue', $_POST);
		
		$sic          	= $this->getTrimmedInput('sic', $_POST);
		$naics          = $this->getTrimmedInput('naics', $_POST);

        /* Departments list editor. */
        $departmentsCSV = $this->getTrimmedInput('departmentsCSV', $_POST);

        /* Bail out if any of the required fields are empty. */
        if (empty($name))
        {
            $this->listByView('Required fields are missing.');
            return;
        }

       if (!eval(Hooks::get('CLIENTS_ON_EDIT_PRE'))) return;

        $departments = $companies->getDepartments($companyID);
        $departmentsDifferences = ListEditor::getDifferencesFromList(
            $departments, 'name', 'departmentID', $departmentsCSV
        );
        $companies->updateDepartments($companyID, $departmentsDifferences);

        if (!$companies->update($companyID, $name, $address, $city, $state,
            $zip, $phone1, $phone2, $faxNumber, $url, $keyTechnologies,
            $isHot, $notes, $owner, $billingContact, $email, $emailAddress,
			$industry, $cocountry, $prospecting, $timezone, $category, $employees, $revenue,
			$sic, $naics))
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to update company.');
        }

       if (!eval(Hooks::get('CLIENTS_ON_EDIT_POST'))) return;

        /* Update extra fields. */
        $companies->extraFields->setValuesOnEdit($companyID);

        /* Update contacts? */
        if (isset($_POST['updateContacts']))
        {
            if ($_POST['updateContacts'] == 'yes')
            {
                $contacts = new Contacts($this->_siteID);
                $contacts->updateByCompany($companyID, $address, $city, $state, $zip);
            }
        }


       CATSUtility::transferRelativeURI(
            'm=companies&a=show&companyID=' . $companyID
        );
    }

    /*
     * Called by handleRequest() to process deleting a company.
     */
    private function onDelete()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_DELETE)
        {
            $this->listByView('Invalid user level for action.');
            return;
        }

        /* Bail out if we don't have a valid company ID. */
        if (!$this->isRequiredIDValid('companyID', $_GET))
        {
            $this->listByView('Invalid company ID.');
            return;
        }

        $companyID = $_GET['companyID'];

        $companies = new Companies($this->_siteID);
        $rs = $companies->get($companyID);

        if (empty($rs))
        {
            $this->listByView('The specified company ID could not be found.');
            return;
        }

        if ($rs['defaultCompany'] == 1)
        {
            $this->listByView('Cannot delete internal postings company.');
            return;
        }

       if (!eval(Hooks::get('CLIENTS_ON_DELETE_PRE'))) return;

        $companies->delete($companyID);

        /* Delete the MRU entry if present. */
        $_SESSION['CATS']->getMRU()->removeEntry(
            DATA_ITEM_COMPANY, $companyID
        );

       if (!eval(Hooks::get('CLIENTS_ON_DELETE_POST'))) return;

        CATSUtility::transferRelativeURI('m=companies&a=listByView');
    }

    /*
     * Called by handleRequest() to process loading the search page.
     */
    private function search()
    {
        $savedSearches = new SavedSearches($this->_siteID);
        $savedSearchRS = $savedSearches->get(DATA_ITEM_COMPANY);

        if (!eval(Hooks::get('CLIENTS_SEARCH'))) return;

        $this->_template->assign('wildCardString', '');
        $this->_template->assign('savedSearchRS', $savedSearchRS);
        $this->_template->assign('active', $this);
        $this->_template->assign('subActive', 'Search Companies');
        $this->_template->assign('isResultsMode', false);
        $this->_template->assign('wildCardCompanyName' , '');
        $this->_template->assign('wildCardKeyTechnologies', '');
        $this->_template->assign('mode', '');
        $this->_template->display('./modules/companies/Search.tpl');
    }

    /*
     * Called by handleRequest() to process displaying the search results.
     */
	private function onSearch()
    {
        $wildCardCompanyName = '';
        $wildCardKeyTechnologies = '';

        /* Bail out to prevent an error if the GET string doesn't even contain
         * a field named 'wildCardString' at all.
         */
         $search = new SearchCompanies($this->_siteID);
		
		 $index = -1;
		 if(isset($_GET["query_list"]))
		 	$query_array = $_GET["query_list"];
		 elseif(isset($_POST["query_list"]))
		 	$query_array = $_POST["query_list"];
		 
		 
		 $query_line = "";
		 for($i=0; $i<count($query_array); $i++) {
			$query_line .= (" ".$query_array[$i]);
		 }
		 $query_line_orig = $query_line;
		 //now parse and divide the single query line
		 $begin_phrase = false;
		 $dblqoute_count = 0;
		 $query_lines_array = array();
		 $curr_filter = "";
		 for($i=0; $i<strlen($query_line); $i++) {
			if(substr($query_line, $i, 1) == "[") {
				$begin_phrase = true;
			} elseif(substr($query_line, $i, 1) == "\"") {
				$dblqoute_count++;				
			}
			if($begin_phrase == true) {
				$curr_filter .= substr($query_line, $i, 1);
			}
			if($dblqoute_count==2) {
				$query_lines_array[] = $curr_filter;
				$curr_filter = "";
				$begin_phrase = false;
				$dblqoute_count = 0;
			}
		 }		 
		 
		 
		 $query_line_attachment = "";
		 $actual_mode = "regular";
		 $resume_keywords = "";
		 $criteria_count = 0;
		 $single_resume_text = "";
		 
		 
		 
		 foreach($query_lines_array as $filter_line_phrase) {			 
		 	 $filter_line_phrase_orig = $filter_line_phrase;	
			 $numeric_operator = "";		 
			 if(substr($filter_line_phrase, 0, 10) == "[LOCATION]") {
				 //e.g., [LOCATION] Is Within 0 kilometers From ZIP Code "1235"
				 $field_parts = split(" Is Within ", $filter_line_phrase);
				 $field_name = trim($field_parts[0]);
				 // left is: 0 kilometers From ZIP Code "1235"
				 $field_parts[1] = str_replace("From ZIP Code ", "", $field_parts[1]);
				 // left is: 0 kilometers "1235"
				 $value_field_parts = split(" ", $field_parts[1]);
				 $location_distance = $value_field_parts[0];
				 $location_distance_unit = $value_field_parts[1];
				 $location_zip_code = "";
				 for($i=2; $i<count($value_field_parts); $i++) {
					 $location_zip_code .= $value_field_parts[$i];
				 }
				 $location_zip_code = strtolower(str_replace(" ","",str_replace("\"","", trim($location_zip_code))));
				 
			 } else if(substr($filter_line_phrase, 0, 9) == "[REVENUE]" || substr($filter_line_phrase, 0, 11) == "[EMPLOYEES]") {
				 if(stripos($filter_line_phrase, "IS EQUAL TO") > 0) {
					$filter_line_phrase = str_replace("IS EQUAL TO", "=", $filter_line_phrase);
				 	$field_parts = split(" = ", $filter_line_phrase);	 	
					$numeric_operator = "=";
				 } elseif(stripos($filter_line_phrase, "IS GREATER THAN") > 0) {
				    $filter_line_phrase = str_replace("IS GREATER THAN", ">", $filter_line_phrase);
				 	$field_parts = split(" > ", $filter_line_phrase);	 					
					$numeric_operator = ">";
				 } elseif(stripos($filter_line_phrase, "IS LESSER THAN") > 0) {
					$filter_line_phrase = str_replace("IS LESSER THAN", "<", $filter_line_phrase);
				 	$field_parts = split(" < ", $filter_line_phrase);	 					 
					$numeric_operator = "<";
				 }
				 $field_name = trim($field_parts[0]);
				 $field_value = intval(trim(str_replace('"',"",$field_parts[1])));
			 } else {
				 $filter_line_phrase = str_replace("Contains The Word", "LIKE", $filter_line_phrase);
				 $field_parts = split(" LIKE ", $filter_line_phrase);
				 $field_name = trim($field_parts[0]);
				 $field_value = strtolower(str_replace("\"","", trim($field_parts[1])));
			 }
			 $translated_filter_phrase = "";
			 $criteria_count++;
			 $b_resume_criteria = false;
			 switch($field_name) {
				case "[REVENUE]":
					$translated_filter_phrase = "company.revenue ".$numeric_operator." ".$field_value." ";
					break;
					
				case "[EMPLOYEES]":
					$translated_filter_phrase = "company.employees ".$numeric_operator." ".$field_value." ";					
					break;
					
				case "[LOCATION]":
					//die("pass loc: [".$location_distance."],[".$location_distance_unit."],[".$location_zip_code."]");
					$inclusive_zip_codes_array = $search->get_inclusive_zipcodes($location_distance, $location_distance_unit, $location_zip_code);
					//die("pass end");
					if($inclusive_zip_codes_array) {
						if(count($inclusive_zip_codes_array)==0) {
							$inclusive_zip_codes = "'-x-x-'"; 
						} else {
							$inclusive_zip_codes = "";
							foreach($inclusive_zip_codes_array as $rowIndex => $zip_code) {
								if(strlen($inclusive_zip_codes)>0) 
									$inclusive_zip_codes .= ",";
									$inclusive_zip_codes .= ("'".strtolower($zip_code["postalcode"])."'");
							}
						}
					} else
						$inclusive_zip_codes = "'-x-x-'"; 
					$translated_filter_phrase = "LOWER(REPLACE(company.zip,' ','')) IN (".$inclusive_zip_codes.")";					
					break;
				case "[CITY]":
					$translated_filter_phrase = "LOWER(company.city) LIKE \"%".$field_value."%\"";
					break;
				case "[STATE]":
					$translated_filter_phrase = "LOWER(company.state) LIKE \"%".$field_value."%\"";
					break;
				case "[NAICS]":
					$translated_filter_phrase = "LOWER(company.naics) LIKE \"%".$field_value."%\"";
					break;
				case "[INDUSTRY]":
					$translated_filter_phrase = "LOWER(company.industry) LIKE \"%".$field_value."%\"";
					break;
				/*
				case "[REVENUE]":
					$translated_filter_phrase = "LOWER(company.revenue) LIKE \"%".$field_value."%\"";
					break;
				case "[EMPLOYEES]":
					$translated_filter_phrase = "LOWER(company.employees) LIKE \"%".$field_value."%\"";
					break; */
				case "[CATEGORY]":
					$translated_filter_phrase = "LOWER(company.category) LIKE \"%".$field_value."%\"";
					break;
				case "[PROSPECTING]":
					$translated_filter_phrase = "LOWER(company.prospecting) LIKE \"%".$field_value."%\"";
					break;
				case "[KEY TECHNOLOGIES]":
					$translated_filter_phrase = "LOWER(company.key_technologies) LIKE \"%".$field_value."%\"";
					break;
				
			 }
			 if($b_resume_criteria == true) {
				$query_line = str_replace($filter_line_phrase_orig, "(".$translated_filter_phrase.")", $query_line);
			 } else
			 	$query_line = str_replace($filter_line_phrase_orig, "(".$translated_filter_phrase.")", $query_line);			
		 }
		 
		if(trim($query_line )== "") {
			$this->listByView('No wild card string specified.');
            return;
		}
		$query = $query_line;
		//die($query);
		
        /* Initialize stored wildcard strings to safe default values. */
        $resumeWildCardString      = '';
        $keySkillsWildCardString   = '';
        $phoneNumberWildCardString = '';
        $fullNameWildCardString    = '';

        //$query = trim($_GET['wildCardString']);

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
            $sortBy = 'name';
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

        if (!eval(Hooks::get('CLIENTS_ON_SEARCH_PRE'))) return;

        /* Get our current searching mode. */
        $mode = $this->getTrimmedInput('mode', $_GET);

        /* Execute the search. */
		/*
        $search = new SearchCompanies($this->_siteID);
        switch ($mode)
        {
            case 'searchByName':
                $wildCardCompanyName = $query;
                $rs = $search->byName($query, $sortBy, $sortDirection);
                break;

            case 'searchByKeyTechnologies':
                $wildCardKeyTechnologies = $query;
                $rs = $search->byKeyTechnologies($query, $sortBy, $sortDirection);
                break;

            default:
                $this->listByView('Invalid search mode.');
                return;
                break;
        }
		*/
		
		
		
		switch ($actual_mode)
        {
			case 'regular':												
				$rs = $search->byMultiple($query, $sortBy, $sortDirection);				
                $fullNameWildCardString = $query;
				break;				
			default:
				$this->listByView('Invalid search mode.');
                return;
				break;
		}
        foreach ($rs as $rowIndex => $row)
        {
            if ($row['isHot'] == 1)
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkHot';
            }
            else
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkCold';
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
		
				
		$companyIDArray =  ResultSetUtility::getColumnValues($rs, 'companyID');
		$companyIDArrayStored = $_SESSION['CATS']->storeData($companyIDArray);
		
        $companyIDs = implode(',', ResultSetUtility::getColumnValues($rs, 'companyID'));
        $exportForm = ExportUtility::getForm(
            DATA_ITEM_COMPANY, $companyIDs, 40, 15
        );
	
        /* Save the search. */
        $savedSearches = new SavedSearches($this->_siteID);
        $savedSearches->add(
            DATA_ITEM_COMPANY,
            $query,
            $_SERVER['REQUEST_URI'],
            false
        );
        $savedSearchRS = $savedSearches->get(DATA_ITEM_COMPANY);

        $query = urlencode(htmlspecialchars($query));

        if (!eval(Hooks::get('CLIENTS_ON_SEARCH_POST'))) return;
		
		
        $this->_template->assign('savedSearchRS', $savedSearchRS);

        $this->_template->assign('active', $this);

        $this->_template->assign('subActive', 'Search Companies');

        $this->_template->assign('exportForm', $exportForm);

        $this->_template->assign('pager', $searchPager);

        $this->_template->assign('rs', $rs);

        $this->_template->assign('isResultsMode', true);

		
		$this->_template->assign('query_array', $query_array);
        /*
		$this->_template->assign('companyIDArray', $companyIDArray);		
		$this->_template->assign('companyIDArrayStored', $companyIDArrayStored);
		*/
		
		/*
        $this->_template->assign('wildCardCompanyName', $wildCardCompanyName);
        $this->_template->assign('wildCardString', $query);
        $this->_template->assign('wildCardKeyTechnologies', $wildCardKeyTechnologies);
		*/
		
        $this->_template->assign('mode', $mode);
        $this->_template->display('./modules/companies/Search.tpl');
			
		
    }
	 
    private function onSearch_OLD()
    {
        $wildCardCompanyName = '';
        $wildCardKeyTechnologies = '';

        /* Bail out to prevent an error if the GET string doesn't even contain
         * a field named 'wildCardString' at all.
         */
		 /*
        if (!isset($_GET['wildCardString']))
        {
            $this->listByView('No wild card string specified.');
            return;
        }
		*/
		
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
            $sortBy = 'name';
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

        if (!eval(Hooks::get('CLIENTS_ON_SEARCH_PRE'))) return;

        /* Get our current searching mode. */
        $mode = $this->getTrimmedInput('mode', $_GET);

        /* Execute the search. */
        $search = new SearchCompanies($this->_siteID);
        switch ($mode)
        {
            case 'searchByName':
                $wildCardCompanyName = $query;
                $rs = $search->byName($query, $sortBy, $sortDirection);
                break;

            case 'searchByKeyTechnologies':
                $wildCardKeyTechnologies = $query;
                $rs = $search->byKeyTechnologies($query, $sortBy, $sortDirection);
                break;

            default:
                $this->listByView('Invalid search mode.');
                return;
                break;
        }

        foreach ($rs as $rowIndex => $row)
        {
            if ($row['isHot'] == 1)
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkHot';
            }
            else
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkCold';
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

        $companyIDs = implode(',', ResultSetUtility::getColumnValues($rs, 'companyID'));
        $exportForm = ExportUtility::getForm(
            DATA_ITEM_COMPANY, $companyIDs, 40, 15
        );

        /* Save the search. */
        $savedSearches = new SavedSearches($this->_siteID);
        $savedSearches->add(
            DATA_ITEM_COMPANY,
            $query,
            $_SERVER['REQUEST_URI'],
            false
        );
        $savedSearchRS = $savedSearches->get(DATA_ITEM_COMPANY);

        $query = urlencode(htmlspecialchars($query));

        if (!eval(Hooks::get('CLIENTS_ON_SEARCH_POST'))) return;

        $this->_template->assign('savedSearchRS', $savedSearchRS);
        $this->_template->assign('active', $this);
        $this->_template->assign('subActive', 'Search Companies');
        $this->_template->assign('exportForm', $exportForm);
        $this->_template->assign('pager', $searchPager);
        $this->_template->assign('rs', $rs);
        $this->_template->assign('isResultsMode', true);
        $this->_template->assign('wildCardCompanyName', $wildCardCompanyName);
        $this->_template->assign('wildCardString', $query);
        $this->_template->assign('wildCardKeyTechnologies', $wildCardKeyTechnologies);
        $this->_template->assign('mode', $mode);
        $this->_template->display('./modules/companies/Search.tpl');
    }

    /*
     * Called by handleRequest() to process loading the create attachment
     * modal dialog.
     */
    private function createAttachment()
    {
        /* Bail out if we don't have a valid joborder ID. */
        if (!$this->isRequiredIDValid('companyID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid job order ID.');
        }

        $companyID = $_GET['companyID'];

        if (!eval(Hooks::get('CLIENTS_CREATE_ATTACHMENT'))) return;

        $this->_template->assign('isFinishedMode', false);
        $this->_template->assign('companyID', $companyID);
        $this->_template->display(
            './modules/companies/CreateAttachmentModal.tpl'
        );
    }

    /*
     * Called by handleRequest() to process creating an attachment.
     */
    private function onCreateAttachment()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            $this->listByView('Invalid user level for action.');
            return;
        }

        /* Bail out if we don't have a valid joborder ID. */
        if (!$this->isRequiredIDValid('companyID', $_POST))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid company ID.');
        }

        $companyID = $_POST['companyID'];

        if (!eval(Hooks::get('CLIENTS_ON_CREATE_ATTACHMENT_PRE'))) return;

        $attachmentCreator = new AttachmentCreator($this->_siteID);
        $attachmentCreator->createFromUpload(
            DATA_ITEM_COMPANY, $companyID, 'file', false, false
        );

        if ($attachmentCreator->isError())
        {
            CommonErrors::fatalModal(COMMONERROR_FILEERROR, $this, $attachmentCreator->getError());
        }

        if (!eval(Hooks::get('CLIENTS_ON_CREATE_ATTACHMENT_POST'))) return;

        $this->_template->assign('isFinishedMode', true);
        $this->_template->assign('companyID', $companyID);
        $this->_template->display(
            './modules/companies/CreateAttachmentModal.tpl'
        );
    }

    /*
     * Called by handleRequest() to process deleting an attachment.
     */
    private function onDeleteAttachment()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_DELETE)
        {
            $this->listByView('Invalid user level for action.');
            return;
        }

        /* Bail out if we don't have a valid attachment ID. */
        if (!$this->isRequiredIDValid('attachmentID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid attachment ID.');
        }

        /* Bail out if we don't have a valid joborder ID. */
        if (!$this->isRequiredIDValid('companyID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid company ID.');
        }

        $companyID  = $_GET['companyID'];
        $attachmentID = $_GET['attachmentID'];

        if (!eval(Hooks::get('CLIENTS_ON_DELETE_ATTACHMENT_PRE'))) return;

        $attachments = new Attachments($this->_siteID);
        $attachments->delete($attachmentID);

        if (!eval(Hooks::get('CLIENTS_ON_DELETE_ATTACHMENT_POST'))) return;

        CATSUtility::transferRelativeURI(
            'm=companies&a=show&companyID=' . $companyID
        );
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
            /* Hot companies [can] have different title styles than normal
             * companies.
             */
            if ($resultSet[$rowIndex]['isHot'] == 1)
            {
                $resultSet[$rowIndex]['linkClass'] = 'jobLinkHot';
            }
            else
            {
                $resultSet[$rowIndex]['linkClass'] = 'jobLinkCold';
            }

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

            if ($resultSet[$rowIndex]['attachmentPresent'] == 1)
            {
                $resultSet[$rowIndex]['iconTag'] = '<img src="images/paperclip.gif" alt="" width="16" height="16" />';
            }
            else
            {
                $resultSet[$rowIndex]['iconTag'] = '&nbsp;';
            }

            /* Display nothing instead of zero's for Job Order Count on Companies
             * display page.
             */
            if ($resultSet[$rowIndex]['jobOrdersCount'] == 0)
            {
                $resultSet[$rowIndex]['jobOrdersCount'] = '&nbsp;';
            }
        }

        return $resultSet;
    }
}

?>
