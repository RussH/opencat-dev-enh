<?php
/*
 * CATS
 * Candidates Module
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
 * $Id: CandidatesUI.php 3810 2007-12-05 19:13:25Z brian $
 */

include_once('./lib/FileUtility.php');
include_once('./lib/StringUtility.php');
include_once('./lib/ResultSetUtility.php');
include_once('./lib/DateUtility.php'); /* Depends on StringUtility. */
include_once('./lib/Candidates.php');
include_once('./lib/Pipelines.php');
include_once('./lib/Attachments.php');
include_once('./lib/ActivityEntries.php');
include_once('./lib/JobOrders.php');
include_once('./lib/Export.php');
include_once('./lib/ExtraFields.php');
include_once('./lib/Calendar.php');
include_once('./lib/SavedLists.php');
include_once('./lib/EmailTemplates.php');
include_once('./lib/DocumentToText.php');
include_once('./lib/DatabaseSearch.php');
include_once('./lib/CommonErrors.php');
include_once('./lib/License.php');
include_once('./lib/ParseUtility.php');
include_once('./lib/Questionnaire.php');

class CandidatesUI extends UserInterface
{
    /* Maximum number of characters of the candidate notes to show without the
     * user clicking "[More]"
     */
    const NOTES_MAXLEN = 500;

    /* Maximum number of characters of the candidate name to show on the main
     * contacts listing.
     */
    const TRUNCATE_KEYSKILLS = 30;


    public function __construct()
    {
        parent::__construct();

        $this->_authenticationRequired = true;
        $this->_moduleDirectory = 'candidates';
        $this->_moduleName = 'candidates';
        $this->_moduleTabText = 'Candidates';
        $this->_subTabs = array(
            'Add Candidate'     => CATSUtility::getIndexName() . '?m=candidates&amp;a=add*al=' . ACCESS_LEVEL_EDIT,
            'Search Candidates' => CATSUtility::getIndexName() . '?m=candidates&amp;a=search'
        );
    }


    public function handleRequest()
    {
        if (!eval(Hooks::get('CANDIDATES_HANDLE_REQUEST'))) return;
        
        $action = $this->getAction();
        switch ($action)
        {
			case 'getphoto':
				$this->getphoto();
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

            case 'viewResume':
                include_once('./lib/Search.php');

                $this->viewResume();
                break;
			
			case 'ziplookup':
				include_once('./lib/Search.php');

                $this->zipLookUp();
				break;
			
			case 'emailForJobSearchSelectJob':
				include_once('./lib/Search.php');
				$this->emailForJobSearchSelectJob();
				break;
			
			case 'emailForJobSearch':
				include_once('./lib/Search.php');
				$this->emailForJobSearch();
				break;
				
			case 'emailSearchSendEmail':
				include_once('./lib/Search.php');
				$this->emailSearchSendEmail();
				break;
			
            /*
             * Search for a job order (in the modal window) for which to
             * consider a candidate.
             */
            case 'considerForJobSearch':
                include_once('./lib/Search.php');

                $this->considerForJobSearch();

                break;

            /*
             * Add candidate to pipeline after selecting a job order for which
             * to consider a candidate (in the modal window).
             */
            case 'addToPipeline':
                $this->onAddToPipeline();
                break;

            /* Change candidate-joborder status. */
            case 'addActivityChangeStatus':
                if ($this->isPostBack())
                {
                    $this->onAddActivityChangeStatus();
                }
                else
                {
                    $this->addActivityChangeStatus();
                }

                break;

            /* Remove a candidate from a pipeline. */
            case 'removeFromPipeline':
                $this->onRemoveFromPipeline();
                break;

            case 'addEditImage':
                if ($this->isPostBack())
                {
                    $this->onAddEditImage();
                }
                else
                {
                    $this->addEditImage();
                }

                break;

            /* Add an attachment to the candidate. */
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

            /* Administrators can hide a candidate from a site with this action. */
            case 'administrativeHideShow':
                $this->administrativeHideShow();
                break;

            /* Delete a candidate attachment */
            case 'deleteAttachment':
                $this->onDeleteAttachment();
                break;

            /* Hot List Page */
            case 'savedLists':
                $this->savedList();
                break;

            case 'emailCandidates':
                $this->onEmailCandidates();
                break;

            case 'show_questionnaire':
                $this->onShowQuestionnaire();
                break;

            /* Main candidates page. */
            case 'listByView':
            default:
				//modified by Allan, 2/9/2012
				if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {
					$this->show(); //show current profile details by default
				} else
                	$this->listByView();
                break;
        }
    }
	
	function getphoto() {
		$photo_type = $_GET["type"];
		$photo_id   = $_GET["id"];
		
		
		$photo_base64 = base64_encode($_SESSION['CATS']->retrieveData($photo_id));
		
		echo "data:image;base64," . $photo_base64;
		flush();
		exit();
	}
	
    /*
     * Called by external modules for adding candidates.
     */
    public function publicAddCandidate($isModal, $transferURI, $moduleDirectory)
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid user level for action.');
            return;
        }

        $candidateID = $this->_addCandidate($isModal, $moduleDirectory);

        if ($candidateID <= 0)
        {
            CommonErrors::fatalModal(COMMONERROR_RECORDERROR, $this, 'Failed to add candidate.');
        }

        $transferURI = str_replace(
            '__CANDIDATE_ID__', $candidateID, $transferURI
        );
        CATSUtility::transferRelativeURI($transferURI);
    }

    /*
     * Called by external modules for processing the log activity / change
     * status dialog.
     */
    public function publicAddActivityChangeStatus($isJobOrdersMode, $regardingID, $moduleDirectory)
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        $this->_AddActivityChangeStatus(
            $isJobOrdersMode, $regardingID, $moduleDirectory
        );
    }

    /*
     * Called by handleRequest() to process loading the list / main page.
     */
    private function listByView($errMessage = '')
    {
        // Log message that shows up on the top of the list page
        $topLog = '';

        $dataGridProperties = DataGrid::getRecentParamaters("candidates:candidatesListByViewDataGrid");

        /* If this is the first time we visited the datagrid this session, the recent paramaters will
         * be empty.  Fill in some default values. */
        if ($dataGridProperties == array())
        {
            $dataGridProperties = array('rangeStart'    => 0,
                                        'maxResults'    => 15,
                                        'filterVisible' => false);
        }

        $dataGrid = DataGrid::get("candidates:candidatesListByViewDataGrid", $dataGridProperties);

        $candidates = new Candidates($this->_siteID);
        $this->_template->assign('totalCandidates', $candidates->getCount());

        $this->_template->assign('active', $this);
        $this->_template->assign('dataGrid', $dataGrid);
        $this->_template->assign('userID', $_SESSION['CATS']->getUserID());
        $this->_template->assign('errMessage', $errMessage);
        $this->_template->assign('topLog', $topLog);

        if (!eval(Hooks::get('CANDIDATE_LIST_BY_VIEW'))) return;

        $this->_template->display('./modules/candidates/Candidates.tpl');
    }

    /*
     * Called by handleRequest() to process loading the details page.
     */
    private function show()
    {
        /* Is this a popup? */
        if (isset($_GET['display']) && $_GET['display'] == 'popup')
        {
            $isPopup = true;
        }
        else
        {
            $isPopup = false;
        }

		
		//Modified by Allan, 2/8/2012
		if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {
			$candidateID = intval($_SESSION['CATS']->getCandidateID());			
			if($candidateID == -1) {
				CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'You have no candidate profile defined.');
            	return;
			}
			$candidates = new Candidates($this->_siteID);
		} else {
			/* Bail out if we don't have a valid candidate ID. */
			if (!$this->isRequiredIDValid('candidateID', $_GET) && !isset($_GET['email']))
			{
				CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
			}			
			$candidates = new Candidates($this->_siteID);
			if (isset($_GET['candidateID']))
			{
				$candidateID = $_GET['candidateID'];
			}
			else
			{
				$candidateID = $candidates->getIDByEmail($_GET['email']);
			}
		}
        $data = $candidates->get($candidateID);
		// print_r($data);

        /* Bail out if we got an empty result set. */
        if (empty($data))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'The specified candidate ID could not be found.');
            return;
        }

        if ($data['isAdminHidden'] == 1 && $this->_accessLevel < ACCESS_LEVEL_MULTI_SA)
        {
            $this->listByView('This candidate is hidden - only a CATS Administrator can unlock the candidate.');
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

        /* Format "can relocate" status. */
        if ($data['canRelocate'] == 1)
        {
            $data['canRelocate'] = 'Yes';
        }
        elseif ($data['canRelocate'] == 0)
        {
            $data['canRelocate'] = 'No';
        }
		elseif ($data['canRelocate'] == 2)
        {
            $data['canRelocate'] = "-";
        }

        if ($data['isHot'] == 1)
        {
            $data['titleClass'] = 'jobTitleHot';
        }
        else
        {
            $data['titleClass'] = 'jobTitleCold';
        }

        $attachments = new Attachments($this->_siteID);
        $attachmentsRS = $attachments->getAll(
            DATA_ITEM_CANDIDATE, $candidateID
        );

        foreach ($attachmentsRS as $rowNumber => $attachmentsData)
        {
            /* If profile image is not local, force it to be local. */
            if ($attachmentsData['isProfileImage'] == 1)
            {
                $attachments->forceAttachmentLocal($attachmentsData['attachmentID']);
            }

            /* Show an attachment icon based on the document's file type. */
            $attachmentIcon = strtolower(
                FileUtility::getAttachmentIcon(
                    $attachmentsRS[$rowNumber]['originalFilename']
                )
            );

            $attachmentsRS[$rowNumber]['attachmentIcon'] = $attachmentIcon;

            /* If the text field has any text, show a preview icon. */
            if ($attachmentsRS[$rowNumber]['hasText'])
            {
                $attachmentsRS[$rowNumber]['previewLink'] = sprintf(
                    '<a href="#" onclick="window.open(\'%s?m=candidates&amp;a=viewResume&amp;attachmentID=%s\', \'viewResume\', \'scrollbars=1,width=800,height=760\')"><img width="15" height="15" style="border: none;" src="images/search.gif" alt="(Preview)" /></a>',
                    CATSUtility::getIndexName(),
                    $attachmentsRS[$rowNumber]['attachmentID']
                );
            }
            else
            {
                $attachmentsRS[$rowNumber]['previewLink'] = '&nbsp;';
            }
        }
        $pipelines = new Pipelines($this->_siteID);
        $pipelinesRS = $pipelines->getCandidatePipeline($candidateID);

        $sessionCookie = $_SESSION['CATS']->getCookie();

        /* Format pipeline data. */
        foreach ($pipelinesRS as $rowIndex => $row)
        {
            /* Hot jobs [can] have different title styles than normal
             * jobs.
             */
            if ($row['isHot'] == 1)
            {
                $pipelinesRS[$rowIndex]['linkClass'] = 'jobLinkHot';
            }
            else
            {
                $pipelinesRS[$rowIndex]['linkClass'] = 'jobLinkCold';
            }

            $pipelinesRS[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                $pipelinesRS[$rowIndex]['ownerFirstName'],
                $pipelinesRS[$rowIndex]['ownerLastName'],
                false,
                LAST_NAME_MAXLEN
            );

            $pipelinesRS[$rowIndex]['addedByAbbrName'] = StringUtility::makeInitialName(
                $pipelinesRS[$rowIndex]['addedByFirstName'],
                $pipelinesRS[$rowIndex]['addedByLastName'],
                false,
                LAST_NAME_MAXLEN
            );

            $pipelinesRS[$rowIndex]['ratingLine'] = TemplateUtility::getRatingObject(
                $pipelinesRS[$rowIndex]['ratingValue'],
                $pipelinesRS[$rowIndex]['candidateJobOrderID'],
                $sessionCookie
            );
        }

        $activityEntries = new ActivityEntries($this->_siteID);
        $activityRS = $activityEntries->getAllByDataItem($candidateID, DATA_ITEM_CANDIDATE);
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
        $calendarRS = $candidates->getUpcomingEvents($candidateID);
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
        $extraFieldRS = $candidates->extraFields->getValuesForShow($candidateID);

        /* Add an MRU entry. */
        $_SESSION['CATS']->getMRU()->addEntry(
            DATA_ITEM_CANDIDATE, $candidateID, $data['firstName'] . ' ' . $data['lastName']
        );

        /* Is the user an admin - can user see history? */
        if ($this->_accessLevel < ACCESS_LEVEL_DEMO)
        {
            $privledgedUser = false;
        }
        else
        {
            $privledgedUser = true;
        }

        $EEOSettings = new EEOSettings($this->_siteID);
        $EEOSettingsRS = $EEOSettings->getAll();
        $EEOValues = array();

        /* Make a list of all EEO related values so they can be positioned by index
         * rather than static positioning (like extra fields). */
        if ($EEOSettingsRS['enabled'] == 1)
        {
            if ($EEOSettingsRS['genderTracking'] == 1)
            {
                $EEOValues[] = array('fieldName' => 'Gender', 'fieldValue' => $data['eeoGenderText']);
            }
            if ($EEOSettingsRS['ethnicTracking'] == 1)
            {
                $EEOValues[] = array('fieldName' => 'Ethnicity', 'fieldValue' => $data['eeoEthnicType']);
            }
            if ($EEOSettingsRS['veteranTracking'] == 1)
            {
                $EEOValues[] = array('fieldName' => 'Veteran Status', 'fieldValue' => $data['eeoVeteranType']);
            }
            if ($EEOSettingsRS['disabilityTracking'] == 1)
            {
                $EEOValues[] = array('fieldName' => 'Disability Status', 'fieldValue' => $data['eeoDisabilityStatus']);
            }
        }

        $questionnaire = new Questionnaire($this->_siteID);
        $questionnaires = $questionnaire->getCandidateQuestionnaires($candidateID);

        $this->_template->assign('active', $this);
        $this->_template->assign('questionnaires', $questionnaires);
        $this->_template->assign('data', $data);
        $this->_template->assign('isShortNotes', $isShortNotes);
        $this->_template->assign('attachmentsRS', $attachmentsRS);
        $this->_template->assign('pipelinesRS', $pipelinesRS);
        $this->_template->assign('activityRS', $activityRS);
        $this->_template->assign('calendarRS', $calendarRS);
        $this->_template->assign('extraFieldRS', $extraFieldRS);
        $this->_template->assign('candidateID', $candidateID);
        $this->_template->assign('isPopup', $isPopup);
        $this->_template->assign('EEOSettingsRS', $EEOSettingsRS);
        $this->_template->assign('EEOValues', $EEOValues);
        $this->_template->assign('privledgedUser', $privledgedUser);
        $this->_template->assign('sessionCookie', $_SESSION['CATS']->getCookie());

        if (!eval(Hooks::get('CANDIDATE_SHOW'))) return;

        $this->_template->display('./modules/candidates/Show.tpl');
    }

    /*
     * Called by handleRequest() to process loading the add page.
     *
     * The user could have already added a resume to the system
     * before this page is displayed.  They could have indicated
     * that they want to use a bulk resume, or a text resume
     * stored in the  session.  These ocourances are looked
     * for here, and the Add.tpl file displays the results.
     */
    private function add($contents = '', $fields = array())
    {
        $candidates = new Candidates($this->_siteID);

        /* Get possible sources. */
        $sourcesRS = $candidates->getPossibleSources();
        $sourcesString = ListEditor::getStringFromList($sourcesRS, 'name');

        /* Get extra fields. */
        $extraFieldRS = $candidates->extraFields->getValuesForAdd();

        /* Get passed variables. */
        $preassignedFields = $_GET;
        if (count($fields) > 0)
        {
            $preassignedFields = array_merge($preassignedFields, $fields);
        }

        /* Get preattached resume, if any. */
        if ($this->isRequiredIDValid('attachmentID', $_GET))
        {
            $associatedAttachment = $_GET['attachmentID'];

            $attachments = new Attachments($this->_siteID);
            $associatedAttachmentRS = $attachments->get($associatedAttachment);

            /* Show an attachment icon based on the document's file type. */
            $attachmentIcon = strtolower(
                FileUtility::getAttachmentIcon(
                    $associatedAttachmentRS['originalFilename']
                )
            );

            $associatedAttachmentRS['attachmentIcon'] = $attachmentIcon;

            /* If the text field has any text, show a preview icon. */
            if ($associatedAttachmentRS['hasText'])
            {
                $associatedAttachmentRS['previewLink'] = sprintf(
                    '<a href="#" onclick="window.open(\'%s?m=candidates&amp;a=viewResume&amp;attachmentID=%s\', \'viewResume\', \'scrollbars=1,width=800,height=760\')"><img width="15" height="15" style="border: none;" src="images/popup.gif" alt="(Preview)" /></a>',
                    CATSUtility::getIndexName(),
                    $associatedAttachmentRS['attachmentID']
                );
            }
            else
            {
                $associatedAttachmentRS['previewLink'] = '&nbsp;';
            }
        }
        else
        {
            $associatedAttachment = 0;
            $associatedAttachmentRS = array();
        }

		/* get preuploaded photo if any */
		
        $associatedResumePhoto = isset($_GET['resumePhotoID']) ? $_GET['resumePhotoID'] : '';
        $associatedResumePhotoType = isset($_GET['resumePhotoType']) ? $_GET['resumePhotoType'] : '';
		if(strlen($associatedResumePhoto)>0)
			$photo64 = base64_encode($_SESSION['CATS']->retrieveData($associatedResumePhoto));
		else
			$photo64 = "";
			
        /* Get preuploaded resume text, if any */
        if ($this->isRequiredIDValid('resumeTextID', $_GET, true))
        {
            $associatedTextResume = $_SESSION['CATS']->retrieveData($_GET['resumeTextID']);
        }
        else
        {
            $associatedTextResume = false;
        }

        /* Get preuploaded resume file (unattached), if any */
        if ($this->isRequiredIDValid('resumeFileID', $_GET, true))
        {
            $associatedFileResume = $_SESSION['CATS']->retrieveData($_GET['resumeFileID']);
            $associatedFileResume['id'] = $_GET['resumeFileID'];
            $associatedFileResume['attachmentIcon'] = strtolower(
                FileUtility::getAttachmentIcon(
                    $associatedFileResume['filename']
                )
            );
        }
        else
        {
            $associatedFileResume = false;
        }

        $EEOSettings = new EEOSettings($this->_siteID);
        $EEOSettingsRS = $EEOSettings->getAll();


        if (!eval(Hooks::get('CANDIDATE_ADD'))) return;

        /* If parsing is not enabled server-wide, say so. */
        if (!LicenseUtility::isParsingEnabled())
        {
            $isParsingEnabled = false;
        }
        /* For CATS Toolbar, if e-mail has been sent and it wasn't set by
         * parser, it's toolbar and it needs the old format.
         */
        else if (!isset($preassignedFields['email']))
        {
            $isParsingEnabled = true;
        }
        else if (empty($preassignedFields['email']))
        {
            $isParsingEnabled = true;
        }
        else if (isset($preassignedFields['isFromParser']) && $preassignedFields['isFromParser'])
        {
            $isParsingEnabled = true;
        }
        else
        {
            $isParsingEnabled = false;
        }

        if (is_array($parsingStatus = LicenseUtility::getParsingStatus()) &&
            isset($parsingStatus['parseLimit']))
        {
            $parsingStatus['parseLimit'] = $parsingStatus['parseLimit'] - 1;
        }
		
        $this->_template->assign('parsingStatus', $parsingStatus);
        $this->_template->assign('isParsingEnabled', $isParsingEnabled);
        $this->_template->assign('contents', $contents);
        $this->_template->assign('extraFieldRS', $extraFieldRS);
        $this->_template->assign('active', $this);
        $this->_template->assign('subActive', 'Add Candidate');
        $this->_template->assign('sourcesRS', $sourcesRS);
        $this->_template->assign('sourcesString', $sourcesString);
        $this->_template->assign('preassignedFields', $preassignedFields);
        $this->_template->assign('associatedAttachment', $associatedAttachment);
        $this->_template->assign('associatedAttachmentRS', $associatedAttachmentRS);
        $this->_template->assign('associatedTextResume', $associatedTextResume);
        $this->_template->assign('associatedFileResume', $associatedFileResume);
		$this->_template->assign('associatedResumePhoto', $associatedResumePhoto);
		$this->_template->assign('associatedResumePhotoType', $associatedResumePhotoType);
		$this->_template->assign('photo64', $photo64);
        $this->_template->assign('EEOSettingsRS', $EEOSettingsRS);
        $this->_template->assign('isModal', false);
		
        /* REMEMBER TO ALSO UPDATE JobOrdersUI::addCandidateModal() IF
         * APPLICABLE.
         */
        $this->_template->display('./modules/candidates/Add.tpl');
    }

    public function checkParsingFunctions()
    {
        if (LicenseUtility::isParsingEnabled())
        {
            if (isset($_POST['documentText'])) $contents = $_POST['documentText'];
            else $contents = '';

            // Retain all field data since this isn't done over AJAX (yet)
            $fields = array(
                'firstName'       => $this->getTrimmedInput('firstName', $_POST),
                'middleName'      => $this->getTrimmedInput('middleName', $_POST),
                'lastName'        => $this->getTrimmedInput('lastName', $_POST),
                'email1'          => $this->getTrimmedInput('email1', $_POST),
                'email2'          => $this->getTrimmedInput('email2', $_POST),
                'phoneHome'       => $this->getTrimmedInput('phoneHome', $_POST),
                'phoneCell'       => $this->getTrimmedInput('phoneCell', $_POST),
                'phoneWork'       => $this->getTrimmedInput('phoneWork', $_POST),
                'address'         => $this->getTrimmedInput('address', $_POST),
                'city'            => $this->getTrimmedInput('city', $_POST),
                'state'           => $this->getTrimmedInput('state', $_POST),
                'zip'             => $this->getTrimmedInput('zip', $_POST),
                'source'          => $this->getTrimmedInput('source', $_POST),
                'keySkills'       => $this->getTrimmedInput('keySkills', $_POST),
                'currentEmployer' => $this->getTrimmedInput('currentEmployer', $_POST),
                'currentPay'      => $this->getTrimmedInput('currentPay', $_POST),
                'desiredPay'      => $this->getTrimmedInput('desiredPay', $_POST),
                'notes'           => $this->getTrimmedInput('notes', $_POST),
                'canRelocate'     => $this->getTrimmedInput('canRelocate', $_POST),
                'webSite'         => $this->getTrimmedInput('webSite', $_POST),
                'bestTimeToCall'  => $this->getTrimmedInput('bestTimeToCall', $_POST),
                'gender'          => $this->getTrimmedInput('gender', $_POST),
                'race'            => $this->getTrimmedInput('race', $_POST),
                'veteran'         => $this->getTrimmedInput('veteran', $_POST),
                'disability'      => $this->getTrimmedInput('disability', $_POST),
                'documentTempFile'=> $this->getTrimmedInput('documentTempFile', $_POST),
                'isFromParser'    => true
            );

            /**
             * User is loading a resume from a document. Convert it to a string and paste the contents
             * into the textarea field on the add candidate page after validating the form.
             */
            if (isset($_POST['loadDocument']) && $_POST['loadDocument'] == 'true')
            {
                // Get the upload file from the post data
                $newFileName = FileUtility::getUploadFileFromPost(
                    $this->_siteID, // The site ID
                    'addcandidate', // Sub-directory of the site's upload folder
                    'documentFile'  // The DOM "name" from the <input> element
                );

                if ($newFileName !== false)
                {
                    // Get the relative path to the file (to perform operations on)
                    $newFilePath = FileUtility::getUploadFilePath(
                        $this->_siteID, // The site ID
                        'addcandidate', // The sub-directory
                        $newFileName
                    );

                    $documentToText = new DocumentToText();
                    $doctype = $documentToText->getDocumentType($newFilePath);

                    if ($documentToText->convert($newFilePath, $doctype))
                    {
                        $contents = $documentToText->getString();
                        if ($doctype == DOCUMENT_TYPE_DOC)
                        {
                            $contents = str_replace('|', "\n", $contents);
                        }

                        // Remove things like _rDOTr for ., etc.
                        $contents = DatabaseSearch::fulltextDecode($contents);
                    }
                    else
                    {
                        $contents = @file_get_contents($newFilePath);
                        $fields['binaryData'] = true;
                    }

                    // Save the short (un-pathed) name
                    $fields['documentTempFile'] = $newFileName;

                    if (isset($_COOKIE['CATS_SP_TEMP_FILE']) && ($oldFile = $_COOKIE['CATS_SP_TEMP_FILE']) != '' &&
                        strcasecmp($oldFile, $newFileName))
                    {
                        // Get the safe, old file they uploaded and didn't use (if exists) and delete
                        $oldFilePath = FileUtility::getUploadFilePath($this->_siteID, 'addcandidate', $oldFile);

                        if ($oldFilePath !== false)
                        {
                            @unlink($oldFilePath);
                        }
                    }

                    // Prevent users from creating more than 1 temp file for single parsing (sp)
                    setcookie('CATS_SP_TEMP_FILE', $newFileName, time() + (60*60*24*7));
                }

                if (isset($_POST['parseDocument']) && $_POST['parseDocument'] == 'true' && $contents != '')
                {
                    // ...
                }
                else
                {
                    return array($contents, $fields);
                }
            }

            /**
             * User is parsing the contents of the textarea field on the add candidate page.
             */
            if (isset($_POST['parseDocument']) && $_POST['parseDocument'] == 'true' && $contents != '')
            {
                $pu = new ParseUtility();
                if ($res = $pu->documentParse('untitled', strlen($contents), '', $contents))
                {
                    if (isset($res['first_name'])) $fields['firstName'] = $res['first_name']; else $fields['firstName'] = '';
                    if (isset($res['last_name'])) $fields['lastName'] = $res['last_name']; else $fields['lastName'] = '';
                    $fields['middleName'] = '';
                    if (isset($res['email_address'])) $fields['email1'] = $res['email_address']; else $fields['email1'] = '';
                    $fields['email2'] = '';
                    if (isset($res['us_address'])) $fields['address'] = $res['us_address']; else $fields['address'] = '';
                    if (isset($res['city'])) $fields['city'] = $res['city']; else $fields['city'] = '';
                    if (isset($res['state'])) $fields['state'] = $res['state']; else $fields['state'] = '';
                    if (isset($res['zip_code'])) $fields['zip'] = $res['zip_code']; else $fields['zip'] = '';
                    if (isset($res['phone_number'])) $fields['phoneHome'] = $res['phone_number']; else $fields['phoneHome'] = '';
                    $fields['phoneWork'] = $fields['phoneCell'] = '';
                    if (isset($res['skills'])) $fields['keySkills'] = str_replace("\n", ' ', str_replace('"', '\'\'', $res['skills']));
                }

                return array($contents, $fields);
            }
        }

        return false;
    }

    /*
     * Called by handleRequest() to process saving / submitting the add page.
     */
    private function onAdd()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        if (is_array($mp = $this->checkParsingFunctions()))
        {
            return $this->add($mp[0], $mp[1]);
        }
		

        $candidateID = $this->_addCandidate(false);
		
        if ($candidateID <= 0)
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to add candidate.');
        }

        CATSUtility::transferRelativeURI(
            'm=candidates&a=show&candidateID=' . $candidateID
        );
    }

    /*
     * Called by handleRequest() to process loading the edit page.
     */
    private function edit()
    {
        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID = $_GET['candidateID'];
		
		//added by Allan, 2/9/2012
		//so only the current candidate id can be edited if current user is a CANDIDATE itself
		if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {
			if(intval($_SESSION['CATS']->getCandidateID()) != $candidateID) {
				CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
			}
		}
		
        $candidates = new Candidates($this->_siteID);
        $data = $candidates->getForEditing($candidateID);

        /* Bail out if we got an empty result set. */
        if (empty($data))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'The specified candidate ID could not be found.');
        }

        if ($data['isAdminHidden'] == 1 && $this->_accessLevel < ACCESS_LEVEL_MULTI_SA)
        {
            $this->listByView('This candidate is hidden - only a CATS Administrator can unlock the candidate.');
            return;
        }

        $users = new Users($this->_siteID);
        $usersRS = $users->getSelectList();

        /* Add an MRU entry. */
        $_SESSION['CATS']->getMRU()->addEntry(
            DATA_ITEM_CANDIDATE, $candidateID, $data['firstName'] . ' ' . $data['lastName']
        );

        /* Get extra fields. */
        $extraFieldRS = $candidates->extraFields->getValuesForEdit($candidateID);

        /* Get possible sources. */
        $sourcesRS = $candidates->getPossibleSources();
        $sourcesString = ListEditor::getStringFromList($sourcesRS, 'name');

        /* Is current source a possible source? */
        // FIXME: Use array search functions!
        $sourceInRS = false;
        foreach ($sourcesRS as $sourceData)
        {
            if ($sourceData['name'] == $data['source'])
            {
                $sourceInRS = true;
            }
        }

        if ($this->_accessLevel == ACCESS_LEVEL_DEMO)
        {
            $canEmail = false;
        }
        else
        {
            $canEmail = true;
        }

        $emailTemplates = new EmailTemplates($this->_siteID);
        $statusChangeTemplateRS = $emailTemplates->getByTag(
            'EMAIL_TEMPLATE_OWNERSHIPASSIGNCANDIDATE'
        );
        if ($statusChangeTemplateRS['disabled'] == 1)
        {
            $emailTemplateDisabled = true;
        }
        else
        {
            $emailTemplateDisabled = false;
        }

        /* Date format for DateInput()s. */
        if ($_SESSION['CATS']->isDateDMY())
        {
            $data['dateAvailableMDY'] = DateUtility::convert(
                '-', $data['dateAvailable'], DATE_FORMAT_DDMMYY, DATE_FORMAT_MMDDYY
            );
        }
        else
        {
            $data['dateAvailableMDY'] = $data['dateAvailable'];
        }

        if (!eval(Hooks::get('CANDIDATE_EDIT'))) return;

        $EEOSettings = new EEOSettings($this->_siteID);
        $EEOSettingsRS = $EEOSettings->getAll();

        $this->_template->assign('active', $this);
        $this->_template->assign('data', $data);
        $this->_template->assign('title', $data['title']);
        $this->_template->assign('usersRS', $usersRS);
        $this->_template->assign('extraFieldRS', $extraFieldRS);
        $this->_template->assign('sourcesRS', $sourcesRS);
        $this->_template->assign('sourcesString', $sourcesString);
        $this->_template->assign('sourceInRS', $sourceInRS);
        $this->_template->assign('candidateID', $candidateID);
        $this->_template->assign('canEmail', $canEmail);
        $this->_template->assign('EEOSettingsRS', $EEOSettingsRS);
        $this->_template->assign('emailTemplateDisabled', $emailTemplateDisabled);
        $this->_template->display('./modules/candidates/Edit.tpl');
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

        $candidates = new Candidates($this->_siteID);

        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_POST))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
            return;
        }
		/************************************************************************
		*		Created by: Ryan Barril
		*		Date: Fri. May 31, 2013
		************************************************************************/
		if(isset($_POST['spec'])){
			$spec_arr = $_POST['spec'];
			$yr_arr = isset($_POST['yr']) ? $_POST['yr'] : array();
			$role_arr = isset($_POST['role']) ? $_POST['role'] : array();
			$key_str = '';
			foreach($spec_arr as $key => $val){
				$val = str_replace(':','&#58;',str_replace(',','&#44;',$val));
				if( isset($yr_arr[$key]) && !empty($yr_arr[$key]) ){
					foreach($yr_arr[$key] as $k => $v){
						$yr_str = isset($yr_arr[$key][$k]) ? str_replace(':','&#58;',str_replace(',','&#44;',$v)) : '';
						$role_str = isset($role_arr[$key][$k]) ? str_replace(':','&#58;',str_replace(',','&#44;',$role_arr[$key][$k])) : '';
						$key_str .= $val.':'.$role_str.':'.$yr_str.',';
					}
				} else {
					$key_str .= $val.'::,';
				}
			}
			$key_str = substr($key_str,0,-1);
		}
		/***********************************************************************/
        /* Bail out if we don't have a valid owner user ID. */
        if (!$this->isOptionalIDValid('owner', $_POST))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid owner user ID.');
        }

        /* Bail out if we received an invalid availability date; if not, go
         * ahead and convert the date to MySQL format.
         */
        $dateAvailable = $this->getTrimmedInput('dateAvailable', $_POST);
        if (!empty($dateAvailable))
        {
            if (!DateUtility::validate('-', $dateAvailable, DATE_FORMAT_MMDDYY))
            {
                CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this, 'Invalid availability date.');
            }

            /* Convert start_date to something MySQL can understand. */
            $dateAvailable = DateUtility::convert(
                '-', $dateAvailable, DATE_FORMAT_MMDDYY, DATE_FORMAT_YYYYMMDD
            );
        }

        $formattedPhoneHome = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phoneHome', $_POST)
        );
        if (!empty($formattedPhoneHome))
        {
            $phoneHome = $formattedPhoneHome;
        }
        else
        {
            $phoneHome = $this->getTrimmedInput('phoneHome', $_POST);
        }

        $formattedPhoneCell = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phoneCell', $_POST)
        );
        if (!empty($formattedPhoneCell))
        {
            $phoneCell = $formattedPhoneCell;
        }
        else
        {
            $phoneCell = $this->getTrimmedInput('phoneCell', $_POST);
        }

        $formattedPhoneWork = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phoneWork', $_POST)
        );
        if (!empty($formattedPhoneWork))
        {
            $phoneWork = $formattedPhoneWork;
        }
        else
        {
            $phoneWork = $this->getTrimmedInput('phoneWork', $_POST);
        }

        $candidateID = $_POST['candidateID'];
        $owner       = $_POST['owner'];

        /* Can Relocate */
        //$canRelocate = $this->isChecked('canRelocate', $_POST);
		$canRelocate = $this->getTrimmedInput('canRelocate', $_POST);

        $isHot = $this->isChecked('isHot', $_POST);

        /* Change ownership email? */
        if ($this->isChecked('ownershipChange', $_POST) && $owner > 0)
        {
            $candidateDetails = $candidates->get($candidateID);

            $users = new Users($this->_siteID);
            $ownerDetails = $users->get($owner);

            if (!empty($ownerDetails))
            {
                $emailAddress = $ownerDetails['email'];

                /* Get the change status email template. */
                $emailTemplates = new EmailTemplates($this->_siteID);
                $statusChangeTemplateRS = $emailTemplates->getByTag(
                    'EMAIL_TEMPLATE_OWNERSHIPASSIGNCANDIDATE'
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
                    '%CANDOWNER%',
                    '%CANDFIRSTNAME%',
                    '%CANDFULLNAME%',
                    '%CANDCATSURL%'
                );
                $replacementStrings = array(
                    $ownerDetails['fullName'],
                    $candidateDetails['firstName'],
                    $candidateDetails['firstName'] . ' ' . $candidateDetails['lastName'],
                    '<a href="http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=candidates&amp;a=show&amp;candidateID=' . $candidateID . '">'.
                        'http://' . $_SERVER['HTTP_HOST'] . substr($_SERVER['REQUEST_URI'], 0, strpos($_SERVER['REQUEST_URI'], '?')) . '?m=candidates&amp;a=show&amp;candidateID=' . $candidateID . '</a>'
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

        $isActive        = $this->isChecked('isActive', $_POST);
        $firstName       = $this->getTrimmedInput('firstName', $_POST);
        $middleName      = $this->getTrimmedInput('middleName', $_POST);
        $lastName        = $this->getTrimmedInput('lastName', $_POST);
        $title	         = $this->getTrimmedInput('title', $_POST);
        $email1          = $this->getTrimmedInput('email1', $_POST);
        $email2          = $this->getTrimmedInput('email2', $_POST);
        $address         = $this->getTrimmedInput('address', $_POST);
        $city            = $this->getTrimmedInput('city', $_POST);
        $state           = $this->getTrimmedInput('state', $_POST);
        $zip             = $this->getTrimmedInput('zip', $_POST);
        $source          = $this->getTrimmedInput('source', $_POST);
        // $keySkills       = $this->getTrimmedInput('keySkills', $_POST);
        $keySkills       = $key_str;
        $currentEmployer = $this->getTrimmedInput('currentEmployer', $_POST);
        $currentPay      = $this->getTrimmedInput('currentPay', $_POST);
        $desiredPay      = $this->getTrimmedInput('desiredPay', $_POST);
        $notes           = $this->getTrimmedInput('notes', $_POST);
        $webSite         = $this->getTrimmedInput('webSite', $_POST);
        $bestTimeToCall  = $this->getTrimmedInput('bestTimeToCall', $_POST);
        $gender          = $this->getTrimmedInput('gender', $_POST);
        $race            = $this->getTrimmedInput('race', $_POST);
        $veteran         = $this->getTrimmedInput('veteran', $_POST);
        $disability      = $this->getTrimmedInput('disability', $_POST);
		$country         = $this->getTrimmedInput('country', $_POST);
		$skype_id        = $this->getTrimmedInput('skype_id', $_POST);
		$contact_type    = $this->getTrimmedInput('contact_type', $_POST);
		$eligibility     = $this->getTrimmedInput('eligibility', $_POST);
		$communication     = $this->getTrimmedInput('communication', $_POST);
		$crclassification  = $this->getTrimmedInput('crclassification', $_POST);
		$jobzone  = $this->getTrimmedInput('jobzone', $_POST);
		
        /* Candidate source list editor. */
        $sourceCSV = $this->getTrimmedInput('sourceCSV', $_POST);

        /* Bail out if any of the required fields are empty. */
        if (empty($firstName) || empty($lastName))
        {
            CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this, 'Required fields are missing.');
        }

        if (!eval(Hooks::get('CANDIDATE_ON_EDIT_PRE'))) return;

        /* Update the candidate record. */
        $updateSuccess = $candidates->update(
            $candidateID,
            $isActive,
            $firstName,
            $middleName,
            $lastName,
            $title,
            $email1,
            $email2,
            $phoneHome,
            $phoneCell,
            $phoneWork,
            $address,
            $city,
            $state,
            $zip,
            $source,
            $keySkills,
            $dateAvailable,
            $currentEmployer,
            $canRelocate,
            $currentPay,
            $desiredPay,
            $notes,
            $webSite,
            $bestTimeToCall,
            $owner,
            $isHot,
            $email,
            $emailAddress,
            $gender,
            $race,
            $veteran,
            $disability,
			$country,
			$skype_id,
			$contact_type,
			$eligibility,
			$communication,
			$crclassification,
			$jobzone
        );
        if (!$updateSuccess)
        {
            CommonErrors::fatal(COMMONERROR_RECORDERROR, $this, 'Failed to update candidate.');
        }

        /* Update extra fields. */
        $candidates->extraFields->setValuesOnEdit($candidateID);

        /* Update possible source list */
        $sources = $candidates->getPossibleSources();
        $sourcesDifferences = ListEditor::getDifferencesFromList(
            $sources, 'name', 'sourceID', $sourceCSV
        );

        $candidates->updatePossibleSources($sourcesDifferences);

        if (!eval(Hooks::get('CANDIDATE_ON_EDIT_POST'))) return;

        CATSUtility::transferRelativeURI(
            'm=candidates&a=show&candidateID=' . $candidateID
        );
    }
	

    /*
     * Called by handleRequest() to process deleting a candidate.
     */
    private function onDelete()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_DELETE)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID = $_GET['candidateID'];

        if (!eval(Hooks::get('CANDIDATE_DELETE'))) return;

        $candidates = new Candidates($this->_siteID);
        $candidates->delete($candidateID);

        /* Delete the MRU entry if present. */
        $_SESSION['CATS']->getMRU()->removeEntry(
            DATA_ITEM_CANDIDATE, $candidateID
        );

        CATSUtility::transferRelativeURI('m=candidates&a=listByView');
    }
	
	
	private function zipLookUp()
    {        
        $country 	= $this->getTrimmedInput('country', $_GET);
        $state  	= $this->getTrimmedInput('state', $_GET);
		$city  		= $this->getTrimmedInput('city', $_GET);
		$ajax_mode	= intval($this->getTrimmedInput('ajax', $_GET));

        /* Execute the search. */
        $search = new SearchCandidates($this->_siteID);
		$mode = "";
		if(strlen($city)>0) {
			//enumerate zips
			$rs = $search->get_zip_codes($country, $state, $city);
			$mode = "zipcodes";
		} elseif(strlen($state)>0 || $state=="all") {
			//enumerate cities
			$rs = $search->get_cities($country, $state);
			$mode = "cities";
		} elseif(strlen($country)>0) {
			//enumerate states, or if single state only, proceed to enumerate cities
			$solo_state = false;
			$rs = $search->get_states($country);
			$mode = "states";			
		} else {
			//enumerate countries
			$rs = $search->get_countries();
			$mode = "countries";
		}
		
		if($ajax_mode == 0) {
			$this->_template->assign('rs', $rs);
			//$this->_template->assign('mode', $mode);        
			$this->_template->display('./modules/candidates/ZipLookup.tpl');
		} else {
			//$output = "<option value=\"_".$mode."\">(select)</option>";			
			$output = "";
			foreach($rs as $rowindex => $row) {
				$output .= ("<option value=\"".$row["value"]."\">".$row["text"]."</option>");	
			}
			echo $output;
			exit();
		}
    }
	
	private function emailSearchSendEmail() 
	{
		/* Get list of candidates. */
        if (isset($_REQUEST['candidateIDArrayStored']) && $this->isRequiredIDValid('candidateIDArrayStored', $_REQUEST, true))
        {
            $candidateIDArray = $_SESSION['CATS']->retrieveData($_REQUEST['candidateIDArrayStored']);
        }
        else if($this->isRequiredIDValid('candidateID', $_REQUEST))
        {
            $candidateIDArray = array($_REQUEST['candidateID']);
        }
        else if ($candidateIDArray === array())
        {
            $dataGrid = DataGrid::getFromRequest();

            $candidateIDArray = $dataGrid->getExportIDs();
        }

        if (!is_array($candidateIDArray))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid variable type.');
            return;
        }
		
		/* Bail out if we don't have a valid job order ID. */
        if (!$this->isRequiredIDValid('jobOrderID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid job order ID.');
        }
		//$candidateIDArray
		$jobOrderID 	= $_REQUEST['jobOrderID'];
		$stage 			= $_REQUEST['stage'];
		$email_body 	= $_POST['email_body'];
		$email_subject 	= $_POST['subject'];
		
		//check for overrides
		if(isset($_POST['stage_override'])) {
			$stage	= $_POST['stage_override'];
		}
		$jobOrderTitle = "";
		if(isset($_REQUEST['jobOrderTitle'])) {
			$jobOrderTitle = $_REQUEST['jobOrderTitle'];
		}
		if(isset($_POST['email_subject'])) {
			$email_subject	= $_POST['email_subject'];
		}
		
		if(intval($stage) == 0) { //EDIT STAGE
			$this->_template->assign('candidateIDArray', $candidateIDArray);
        	$this->_template->assign('candidateIDArrayStored', $_SESSION['CATS']->storeData($candidateIDArray));
			$this->_template->assign('jobOrderTitle', $jobOrderTitle);
			$this->_template->assign('subject', $email_subject);
			$this->_template->assign('emailTemplate', $email_body);			
			$this->_template->assign('stage', 0);			
			$this->_template->assign('jobOrderID', $jobOrderID);
			
        	$this->_template->display('./modules/candidates/EmailForJobSearchModal.tpl');
			
		} elseif(intval($stage) == 1) { //PREVIEW MODE STAGE
			//TODO: Formulate test email here			
			//      Use First Candidate
			
			$actual_email_body	= "";
			$actual_recipient	= "";
			
			$actual_email_body	= $this->SendSearchEmail($candidateIDArray, $jobOrderID, $email_body, $email_subject, 1);
				        			
			$this->_template->assign('stage', 1);			
			$this->_template->assign('jobOrderID', $jobOrderID);
			$this->_template->assign('email_subject', $email_subject);			
			$this->_template->assign('email_body', $email_body);			
			$this->_template->assign('actual_email_body', $actual_email_body);
			$this->_template->assign('actual_recipient', $actual_recipient);			
			$this->_template->assign('jobOrderTitle', $jobOrderTitle);
        	$this->_template->assign('candidateIDArray', $candidateIDArray);
        	$this->_template->assign('candidateIDArrayStored', $_SESSION['CATS']->storeData($candidateIDArray));
			
        	$this->_template->display('./modules/candidates/EmailForJobSearchModal.tpl');
		} elseif(intval($stage) == 2) {  //SEND EMAIL STAGE			
			//normal email send
			$jobOrderTitle	= "Email Result";
			$is_finished    = 1;
			$email_result_text	= "";
			
			$emails_sent	= $this->SendSearchEmail($candidateIDArray, $jobOrderID, $email_body, $email_subject, 0);
			
			$this->_template->assign('jobOrderID', $jobOrderID);
			$this->_template->assign('stage', 2);
			$this->_template->assign('email_body', $email_body);
			$this->_template->assign('email_subject', $email_subject);
			
			//temp
			$email_result_text = $emails_sent." emails sent.";
			
			$this->_template->assign('is_finished', $is_finished);
			$this->_template->assign('jobOrderTitle', $jobOrderTitle);			
			$this->_template->assign('email_result_text', $email_result_text);
			
        	$this->_template->display('./modules/candidates/EmailForJobSearchModal.tpl');
		}
	}
	
	
	private function SendSearchEmail($candidateIDArray, $jobOrderID, $email_template, $email_subject, $preview_mode) {
		$activityEntries = new ActivityEntries($this->_siteID);
		$jobOrders = new JobOrders($this->_siteID);
		$joborder_data = $jobOrders->get($jobOrderID);
		$candidates = new Candidates($this->_siteID);
		$stringsToFind = array(
				'%CANDFULLNAME%',
				'%JBODTITLE%',
				'%JBODCLIENT%',
				'%JBODCATSURL%',
				'%SITENAME%',
				'%DATETIME%',
				'%JBODID%',
				'%JBODOWNER%'
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
		
		if($preview_mode == 0) {
			//initialize mailer and settings if we're not in preview mode
			$users = new Users(CATS_ADMIN_SITE);
        	$automatedUser = $users->getAutomatedUser();
			$userID	= $automatedUser['userID'];
			$mailer = new Mailer($this->_siteID, $userID);
		}
		
		$site_name = $_SESSION['CATS']->getSiteName();
		if ($_SESSION['CATS']->isDateDMY()) {
            $dateFormat = 'd-m-y';
		} else {
            $dateFormat = 'm-d-y';
		}
		$curr_datetime = DateUtility::getAdjustedDate($dateFormat . ' g:i A');
		
		foreach($candidateIDArray as $candidate_id) {
			$candidate_count++;
			$candidate_data = $candidates->get($candidate_id);
			//old
			/* 
			$replacementStrings = array(
				$candidate_data["candidateFullName"],
				$joborder_data["title"],
				$joborder_data["companyName"],
				'http://' . $_SERVER['HTTP_HOST'] . substr($uri, 0, strpos($uri, '?')) . '?m=joborders&amp;a=show&amp;jobOrderID=' . $joborder_data['jobOrderID'] . '',
				$site_name,
				$curr_datetime,
				$joborder_data["jobOrderID"],
				$joborder_data["ownerFullName"]
			); */
			
			//new sample - http://96.45.190.9/cats/careers/index.php?p=showJob&ID=191
			$replacementStrings = array(
				$candidate_data["candidateFullName"],
				$joborder_data["title"],
				$joborder_data["companyName"],
				'http://clearroad.it/cats/careers/index.php?p=showJob&amp;ID=' . $joborder_data['jobOrderID'] . '',
				$site_name,
				$curr_datetime,
				$joborder_data["jobOrderID"],
				$joborder_data["ownerFullName"]
			);
			$actual_email_body = str_replace(
				$stringsToFind,
				$replacementStrings,
				$email_template
			);
			if($preview_mode == 1) {
				if($candidate_count == 1) return $actual_email_body;
			} else {
				//actually send email here
				$destination	= $candidate_data["email1"];
				$mailerStatus = $mailer->sendToOne(array($destination, ''), $email_subject, $actual_email_body, true);
				$activityID = $activityEntries->add(
								$candidate_id,
								DATA_ITEM_CANDIDATE,
								400,
								'Emailed candidate.',
								$this->_userID,
								$joborder_data["jobOrderID"]
							);				
				$email_sent++;
			}
		}
		//return actual number of emails sent
		return $email_sent;
	}
	
	
    private function emailForJobSearch($candidateIDArray = array())
    {
        /* Get list of candidates. */
        if (isset($_REQUEST['candidateIDArrayStored']) && $this->isRequiredIDValid('candidateIDArrayStored', $_REQUEST, true))
        {
            $candidateIDArray = $_SESSION['CATS']->retrieveData($_REQUEST['candidateIDArrayStored']);
        }
        else if($this->isRequiredIDValid('candidateID', $_REQUEST))
        {
            $candidateIDArray = array($_REQUEST['candidateID']);
        }
        else if ($candidateIDArray === array())
        {
            $dataGrid = DataGrid::getFromRequest();

            $candidateIDArray = $dataGrid->getExportIDs();
        }

        if (!is_array($candidateIDArray))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid variable type.');
            return;
        }
		
		/* Bail out if we don't have a valid job order ID. */
        if (!$this->isRequiredIDValid('jobOrderID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid job order ID.');
        }
		$jobOrderID = $_REQUEST['jobOrderID'];
		$jobOrderTitle = $_REQUEST['jobOrderTitle'];

        /* Validate each ID */
        foreach ($candidateIDArray as $index => $candidateID)
        {
            if (!$this->isRequiredIDValid($index, $candidateIDArray))
            {
                echo('&'.$candidateID.'>');

                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
                return;
            } else {
				//Added by Allan, 2/10/2012
				//only allow candidate id parameter of the current candidate
				/*
				if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {
					if(intval($_SESSION['CATS']->getCandidateID()) != intval($candidateID)) {
						CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
						return;						
					}
				}
				*/
			}
        }

        /* Bail out to prevent an error if the POST string doesn't even contain
         * a field named 'wildCardString' at all.
         */
       
        /* Execute the search. */
        //$search = new SearchJobOrders($this->_siteID);
		//$rs = $search->byTitle($query, 'title', 'ASC', true);
		      

        //$this->_template->assign('rs', $rs);
        //$this->_template->assign('isFinishedMode', false);
        //$this->_template->assign('isResultsMode', $resultsMode);
		//GOBACK
		$emailTemplates = new EmailTemplates($this->_siteID);
        $candidatesEmailTemplateRS = $emailTemplates->getByTag(
            'EMAIL_TEMPLATE_JOBSEARCHEMAIL'
        );
		if (empty($candidatesEmailTemplateRS) ||
            empty($candidatesEmailTemplateRS['textReplaced']))
        {
            $emailTemplate = '';
            $emailDisabled = $candidatesEmailTemplateRS['disabled'];
        }
        else
        {
            $emailTemplate = $candidatesEmailTemplateRS['textReplaced'];
            $emailDisabled = $candidatesEmailTemplateRS['disabled'];
        }
		/*
		$stringsToFind = array(
            '%DATETIME%',
            '%CANDFULLNAME%',
            '%JBODTITLE%',
			'%JBODCLIENT%',
			'%JBODCATSURL%'
        );
		*/
		//
		$this->_template->assign('is_finished', 0);
		$this->_template->assign('stage', 0);
		$this->_template->assign('jobOrderID', $jobOrderID);
		$this->_template->assign('subject', "URGENT: ".$jobOrderTitle);
		$this->_template->assign('jobOrderTitle', $jobOrderTitle);
		$this->_template->assign('emailTemplate', $emailTemplate);
        $this->_template->assign('candidateIDArray', $candidateIDArray);
        $this->_template->assign('candidateIDArrayStored', $_SESSION['CATS']->storeData($candidateIDArray));
        $this->_template->display('./modules/candidates/EmailForJobSearchModal.tpl');
    }	
	
	
	private function emailForJobSearchSelectJob($candidateIDArray = array())
    {
        /* Get list of candidates. */
		if(intval($_GET["onlySelected"])==1) {
            foreach ($_GET as $key => $value)
            {
                if (!strstr($key, 'checked_'))
                {
                    continue;
                }

                $candidateIDArray[] = str_replace('checked_', '', $key);
            }
		}
		else if (isset($_REQUEST['candidateIDArrayStored']) && $this->isRequiredIDValid('candidateIDArrayStored', $_REQUEST, true))
        {
            $candidateIDArray = $_SESSION['CATS']->retrieveData($_REQUEST['candidateIDArrayStored']);
        }
        else if($this->isRequiredIDValid('candidateID', $_REQUEST))
        {
            $candidateIDArray = array($_REQUEST['candidateID']);
        }
        else if ($candidateIDArray === array())
        {
            $dataGrid = DataGrid::getFromRequest();

            $candidateIDArray = $dataGrid->getExportIDs();
        }
				
        if (!is_array($candidateIDArray))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid variable type.');
            return;
        }

        /* Validate each ID */
        foreach ($candidateIDArray as $index => $candidateID)
        {
            if (!$this->isRequiredIDValid($index, $candidateIDArray))
            {
                echo('&'.$candidateID.'>');

                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
                return;
            } else {
				//Added by Allan, 2/10/2012
				//only allow candidate id parameter of the current candidate
				/*
				if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {
					if(intval($_SESSION['CATS']->getCandidateID()) != intval($candidateID)) {
						CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
						return;						
					}
				}
				*/
			}
        }

        /* Bail out to prevent an error if the POST string doesn't even contain
         * a field named 'wildCardString' at all.
         */
        if (!isset($_POST['wildCardString']) && isset($_POST['mode']))
        {
            CommonErrors::fatal(COMMONERROR_WILDCARDSTRING, $this, 'No wild card string specified.');
        }

        $query = $this->getTrimmedInput('wildCardString', $_POST);
        $mode  = $this->getTrimmedInput('mode', $_POST);

        /* Execute the search. */
        $search = new SearchJobOrders($this->_siteID);
        switch ($mode)
        {
            case 'searchByJobTitle':
                $rs = $search->byTitle($query, 'title', 'ASC', true);
                $resultsMode = true;
                break;

            case 'searchByCompanyName':
                $rs = $search->byCompanyName($query, 'title', 'ASC', true);
                $resultsMode = true;
                break;

            default:
                $rs = $search->recentlyModified('DESC', true, 5);
                $resultsMode = false;
                break;
        }

        $pipelines = new Pipelines($this->_siteID);
        $pipelinesRS = $pipelines->getCandidatePipeline($candidateIDArray[0]);

        foreach ($rs as $rowIndex => $row)
        {
            if (ResultSetUtility::findRowByColumnValue($pipelinesRS,
                'jobOrderID', $row['jobOrderID']) !== false && count($candidateIDArray) == 1)
            {
                $rs[$rowIndex]['inPipeline'] = true;
            }
            else
            {
                $rs[$rowIndex]['inPipeline'] = false;
            }

            /* Convert '00-00-00' dates to empty strings. */
            $rs[$rowIndex]['startDate'] = DateUtility::fixZeroDate(
                $row['startDate']
            );

            if ($row['isHot'] == 1)
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkHot';
            }
            else
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkCold';
            }

            $rs[$rowIndex]['recruiterAbbrName'] = StringUtility::makeInitialName(
                $row['recruiterFirstName'],
                $row['recruiterLastName'],
                false,
                LAST_NAME_MAXLEN
            );

            $rs[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                $row['ownerFirstName'],
                $row['ownerLastName'],
                false,
                LAST_NAME_MAXLEN
            );
        }

        if (!eval(Hooks::get('CANDIDATE_ON_CONSIDER_FOR_JOB_SEARCH'))) return;

        $this->_template->assign('rs', $rs);
        $this->_template->assign('isFinishedMode', false);
        $this->_template->assign('isResultsMode', $resultsMode);
        $this->_template->assign('candidateIDArray', $candidateIDArray);
        $this->_template->assign('candidateIDArrayStored', $_SESSION['CATS']->storeData($candidateIDArray));
        $this->_template->display('./modules/candidates/ConsiderSearchEmailModal.tpl');
    }
	
    /*
     * Called by handleRequest() to handle processing an "Add to a Job Order
     * Pipeline" search and displaying the results in the modal dialog, or
     * to show the initial dialog.
     */
    private function considerForJobSearch($candidateIDArray = array())
    {
        /* Get list of candidates. */
		//first check if only selected candidates from the grid will be included
		if(intval($_GET["onlySelected"])==1) {
            foreach ($_GET as $key => $value)
            {
                if (!strstr($key, 'checked_'))
                {
                    continue;
                }

                $candidateIDArray[] = str_replace('checked_', '', $key);
            }
		}
		else if (isset($_REQUEST['candidateIDArrayStored']) && $this->isRequiredIDValid('candidateIDArrayStored', $_REQUEST, true))
        {
            $candidateIDArray = $_SESSION['CATS']->retrieveData($_REQUEST['candidateIDArrayStored']);
        }
        else if($this->isRequiredIDValid('candidateID', $_REQUEST))
        {
            $candidateIDArray = array($_REQUEST['candidateID']);
        }
        else if ($candidateIDArray === array())
        {
            $dataGrid = DataGrid::getFromRequest();

            $candidateIDArray = $dataGrid->getExportIDs();
        }

        if (!is_array($candidateIDArray))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid variable type.');
            return;
        }
		
		//die(print_r($_GET));
		//die(print_r($candidateIDArray));
		
		
        /* Validate each ID */
        foreach ($candidateIDArray as $index => $candidateID)
        {
            if (!$this->isRequiredIDValid($index, $candidateIDArray))
            {
                echo('&'.$candidateID.'>');

                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
                return;
            } else {
				//Added by Allan, 2/10/2012
				//only allow candidate id parameter of the current candidate
				/*
				if(intval($_SESSION['CATS']->getAccessLevel()) == ACCESS_LEVEL_CANDIDATE) {
					if(intval($_SESSION['CATS']->getCandidateID()) != intval($candidateID)) {
						CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
						return;						
					}
				}
				*/
			}
        }

        /* Bail out to prevent an error if the POST string doesn't even contain
         * a field named 'wildCardString' at all.
         */
        if (!isset($_POST['wildCardString']) && isset($_POST['mode']))
        {
            CommonErrors::fatal(COMMONERROR_WILDCARDSTRING, $this, 'No wild card string specified.');
        }

        $query = $this->getTrimmedInput('wildCardString', $_POST);
        $mode  = $this->getTrimmedInput('mode', $_POST);

        /* Execute the search. */
        $search = new SearchJobOrders($this->_siteID);
        switch ($mode)
        {
            case 'searchByJobTitle':
                $rs = $search->byTitle($query, 'title', 'ASC', true);
                $resultsMode = true;
                break;

            case 'searchByCompanyName':
                $rs = $search->byCompanyName($query, 'title', 'ASC', true);
                $resultsMode = true;
                break;

            default:
                $rs = $search->recentlyModified('DESC', true, 5);
                $resultsMode = false;
                break;
        }

        $pipelines = new Pipelines($this->_siteID);
        $pipelinesRS = $pipelines->getCandidatePipeline($candidateIDArray[0]);

        foreach ($rs as $rowIndex => $row)
        {
            if (ResultSetUtility::findRowByColumnValue($pipelinesRS,
                'jobOrderID', $row['jobOrderID']) !== false && count($candidateIDArray) == 1)
            {
                $rs[$rowIndex]['inPipeline'] = true;
            }
            else
            {
                $rs[$rowIndex]['inPipeline'] = false;
            }

            /* Convert '00-00-00' dates to empty strings. */
            $rs[$rowIndex]['startDate'] = DateUtility::fixZeroDate(
                $row['startDate']
            );

            if ($row['isHot'] == 1)
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkHot';
            }
            else
            {
                $rs[$rowIndex]['linkClass'] = 'jobLinkCold';
            }

            $rs[$rowIndex]['recruiterAbbrName'] = StringUtility::makeInitialName(
                $row['recruiterFirstName'],
                $row['recruiterLastName'],
                false,
                LAST_NAME_MAXLEN
            );

            $rs[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                $row['ownerFirstName'],
                $row['ownerLastName'],
                false,
                LAST_NAME_MAXLEN
            );
        }

        if (!eval(Hooks::get('CANDIDATE_ON_CONSIDER_FOR_JOB_SEARCH'))) return;

        $this->_template->assign('rs', $rs);
        $this->_template->assign('isFinishedMode', false);
        $this->_template->assign('isResultsMode', $resultsMode);
        $this->_template->assign('candidateIDArray', $candidateIDArray);
        $this->_template->assign('candidateIDArrayStored', $_SESSION['CATS']->storeData($candidateIDArray));
        $this->_template->display('./modules/candidates/ConsiderSearchModal.tpl');
    }

    /*
     * Called by handleRequest() to process adding a candidate to a pipeline
     * in the modal dialog.
     */
    private function onAddToPipeline()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid job order ID. */
        if (!$this->isRequiredIDValid('jobOrderID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid job order ID.');
        }

        if (isset($_GET['candidateID']))
        {
            /* Bail out if we don't have a valid candidate ID. */
            if (!$this->isRequiredIDValid('candidateID', $_GET))
            {
                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
            }

            $candidateIDArray = array($_GET['candidateID']);
        }
        else
        {
            if (!isset($_REQUEST['candidateIDArrayStored']) || !$this->isRequiredIDValid('candidateIDArrayStored', $_REQUEST, true))
            {
                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidateIDArrayStored parameter.');
                return;
            }

            $candidateIDArray = $_SESSION['CATS']->retrieveData($_REQUEST['candidateIDArrayStored']);

            if (!is_array($candidateIDArray))
            {
                CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid variable type.');
                return;
            }

            /* Validate each ID */
            foreach ($candidateIDArray as $index => $candidateID)
            {
                if (!$this->isRequiredIDValid($index, $candidateIDArray))
                {
                    echo ($dataItemID);

                    CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
                    return;
                }
            }
        }


        $jobOrderID  = $_GET['jobOrderID'];

        if (!eval(Hooks::get('CANDIDATE_ADD_TO_PIPELINE_PRE'))) return;

        $pipelines = new Pipelines($this->_siteID);
        $activityEntries = new ActivityEntries($this->_siteID);

        /* Drop candidate ID's who are already in the pipeline */
        $pipelinesRS = $pipelines->getJobOrderPipeline($jobOrderID);

        foreach($pipelinesRS as $data)
        {
            $arrayPos = array_search($data['candidateID'], $candidateIDArray);
            if ($arrayPos !== false)
            {
                unset($candidateIDArray[$arrayPos]);
            }
        }

        /* Add to pipeline */
        foreach($candidateIDArray as $candidateID)
        {
            if (!$pipelines->add($candidateID, $jobOrderID, $this->_userID))
            {
                CommonErrors::fatalModal(COMMONERROR_RECORDERROR, $this, 'Failed to add candidate to pipeline.');
            }
			/*
            $activityID = $activityEntries->add(
                $candidateID,
                DATA_ITEM_CANDIDATE,
                400,
                'Added candidate to pipeline.',
                $this->_userID,
                $jobOrderID
            );
			*/
            if (!eval(Hooks::get('CANDIDATE_ADD_TO_PIPELINE_POST_IND'))) return;
        }

        if (!eval(Hooks::get('CANDIDATE_ADD_TO_PIPELINE_POST'))) return;

        $this->_template->assign('isFinishedMode', true);
        $this->_template->assign('jobOrderID', $jobOrderID);
        $this->_template->assign('candidateIDArray', $candidateIDArray);
        $this->_template->display(
            './modules/candidates/ConsiderSearchModal.tpl'
        );
    }

    private function addActivityChangeStatus()
    {
        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        /* Bail out if we don't have a valid job order ID. */
        if (!$this->isOptionalIDValid('jobOrderID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid job order ID.');
        }

        $selectedJobOrderID = $_GET['jobOrderID'];
        $candidateID        = $_GET['candidateID'];

        $candidates = new Candidates($this->_siteID);
        $candidateData = $candidates->get($candidateID);

        /* Bail out if we got an empty result set. */
        if (empty($candidateData))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this);
            return;
            /*$this->fatalModal(
                'The specified candidate ID could not be found.'
            );*/
        }

        $pipelines = new Pipelines($this->_siteID);
        $pipelineRS = $pipelines->getCandidatePipeline($candidateID);

        $statusRS = $pipelines->getStatusesForPicking();

        if ($selectedJobOrderID != -1)
        {
            $selectedStatusID = ResultSetUtility::getColumnValueByIDValue(
                $pipelineRS, 'jobOrderID', $selectedJobOrderID, 'statusID'
            );
        }
        else
        {
            $selectedStatusID = -1;
        }

        /* Get the change status email template. */
        $emailTemplates = new EmailTemplates($this->_siteID);
        $statusChangeTemplateRS = $emailTemplates->getByTag(
            'EMAIL_TEMPLATE_STATUSCHANGE'
        );
        if (empty($statusChangeTemplateRS) ||
            empty($statusChangeTemplateRS['textReplaced']))
        {
            $statusChangeTemplate = '';
            $emailDisabled = '1';
        }
        else
        {
            $statusChangeTemplate = $statusChangeTemplateRS['textReplaced'];
            $emailDisabled = $statusChangeTemplateRS['disabled'];
        }

        /* Replace e-mail template variables. '%CANDSTATUS%', '%JBODTITLE%',
         * '%JBODCLIENT%' are replaced by JavaScript.
         */
        $stringsToFind = array(
            '%CANDOWNER%',
            '%CANDFIRSTNAME%',
            '%CANDFULLNAME%'
        );
        $replacementStrings = array(
            $candidateData['ownerFullName'],
            $candidateData['firstName'],
            $candidateData['firstName'] . ' ' . $candidateData['lastName'],
            $candidateData['firstName'],
            $candidateData['firstName']
        );
        $statusChangeTemplate = str_replace(
            $stringsToFind,
            $replacementStrings,
            $statusChangeTemplate
        );

        /* Are we in "Only Schedule Event" mode? */
        $onlyScheduleEvent = $this->isChecked('onlyScheduleEvent', $_GET);

        $calendar = new Calendar($this->_siteID);
        $calendarEventTypes = $calendar->getAllEventTypes();

        if (!eval(Hooks::get('CANDIDATE_ADD_ACTIVITY_CHANGE_STATUS'))) return;

        if (SystemUtility::isSchedulerEnabled() && !$_SESSION['CATS']->isDemo())
        {
            $allowEventReminders = true;
        }
        else
        {
            $allowEventReminders = false;
        }

        $this->_template->assign('candidateID', $candidateID);
        $this->_template->assign('pipelineRS', $pipelineRS);
        $this->_template->assign('statusRS', $statusRS);
        $this->_template->assign('selectedJobOrderID', $selectedJobOrderID);
        $this->_template->assign('selectedStatusID', $selectedStatusID);
        $this->_template->assign('allowEventReminders', $allowEventReminders);
        $this->_template->assign('userEmail', $_SESSION['CATS']->getEmail());
        $this->_template->assign('calendarEventTypes', $calendarEventTypes);
        $this->_template->assign('statusChangeTemplate', $statusChangeTemplate);
        $this->_template->assign('onlyScheduleEvent', $onlyScheduleEvent);
        $this->_template->assign('emailDisabled', $emailDisabled);
        $this->_template->assign('isFinishedMode', false);
        $this->_template->assign('isJobOrdersMode', false);
        $this->_template->display(
            './modules/candidates/AddActivityChangeStatusModal.tpl'
        );
    }

    private function onAddActivityChangeStatus()
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

        $this->_addActivityChangeStatus(false, $regardingID);
    }

    /*
     * Called by handleRequest() to process removing a candidate from the
     * pipeline for a job order.
     */
    private function onRemoveFromPipeline()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_DELETE)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        /* Bail out if we don't have a valid job order ID. */
        if (!$this->isRequiredIDValid('jobOrderID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid job order ID.');
        }

        $candidateID = $_GET['candidateID'];
        $jobOrderID  = $_GET['jobOrderID'];

        if (!eval(Hooks::get('CANDIDATE_REMOVE_FROM_PIPELINE_PRE'))) return;

        $pipelines = new Pipelines($this->_siteID);
        $pipelines->remove($candidateID, $jobOrderID);

        if (!eval(Hooks::get('CANDIDATE_REMOVE_FROM_PIPELINE_POST'))) return;

        CATSUtility::transferRelativeURI(
            'm=candidates&a=show&candidateID=' . $candidateID
        );
    }

    /*
     * Called by handleRequest() to process loading the search page.
     */
    private function search()
    {
        $savedSearches = new SavedSearches($this->_siteID);
        $savedSearchRS = $savedSearches->get(DATA_ITEM_CANDIDATE);

        if (!eval(Hooks::get('CANDIDATE_SEARCH'))) return;

        $this->_template->assign('wildCardString', '');
        $this->_template->assign('savedSearchRS', $savedSearchRS);
        $this->_template->assign('active', $this);
        $this->_template->assign('subActive', 'Search Candidates');
        $this->_template->assign('isResultsMode', false);
        $this->_template->assign('isResumeMode', false);
        $this->_template->assign('resumeWildCardString', '');
        $this->_template->assign('keySkillsWildCardString', '');
        $this->_template->assign('fullNameWildCardString', '');
        $this->_template->assign('phoneNumberWildCardString', '');
        $this->_template->assign('mode', '');
        $this->_template->display('./modules/candidates/Search.tpl');
    }

    /*
     * Called by handleRequest() to process displaying the search results.
     */
    private function onSearch()
    {
        /* Bail out to prevent an error if the GET string doesn't even contain
         * a field named 'wildCardString' at all.
         */
		 /* Execute the search. */
         $search = new SearchCandidates($this->_siteID);
		 
		 $index = -1;
		 if(isset($_GET["query_list"]))
		 	$query_array = $_GET["query_list"];
		 elseif(isset($_POST["query_list"]))
		 	$query_array = $_POST["query_list"];
			
		 //print_r($query_array);
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
			/*if(substr($filter_line_phrase, 0, 12) != "[KEY SKILLS]") {
			
			} else {
			
			}*/
		  $filter_column = '';
		  $dblquote_counter = 2;
			for($i=0; $i<strlen($query_line); $i++) {
				if(substr($query_line, $i, 1) == "[") {
					$begin_phrase = true;
					$dblquote_counter = 2;
				} elseif(substr($query_line, $i, 1) == "\"") {
					$dblqoute_count++;				
				} 
				
				if(substr($query_line, $i, 1) == "]") {
					$filter_column = $curr_filter;
					//if($filter_column == '[KEY SKILLS'){
					//	$dblquote_counter = 4;
					//}
				}
				
				if($begin_phrase == true) {
					$curr_filter .= substr($query_line, $i, 1);
				}
				if($dblqoute_count == $dblquote_counter) {
					$query_lines_array[] = $curr_filter;
					$curr_filter = "";
					$begin_phrase = false;
					$dblqoute_count = 0;
				}
			}
		 
		 // print_r($query_line);		 
		 //die("<p>END</p>");
		 
		 $query_line_attachment = "";
		 $actual_mode = "regular";
		 $resume_keywords = "";
		 $criteria_count = 0;
		 $single_resume_text = "";
		 foreach($query_lines_array as $filter_line_phrase) {			 
		 	 $filter_line_phrase_orig = $filter_line_phrase;			 
			 if(substr($filter_line_phrase, 0, 10) == "[LOCATION]") {
				 //e.g., [LOCATION] Is Within 0 kilometers From ZIP Code "1235"
				 // $field_parts = split(" Is Within ", $filter_line_phrase);
				 $field_parts = explode(" Is Within ", $filter_line_phrase);
				 $field_name = trim($field_parts[0]);
				 // left is: 0 kilometers From ZIP Code "1235"
				 $field_parts[1] = str_replace("From ZIP Code ", "", $field_parts[1]);
				 // left is: 0 kilometers "1235"
				 $value_field_parts = explode(" ", $field_parts[1]);
				 $location_distance = $value_field_parts[0];
				 $location_distance_unit = $value_field_parts[1];
				 $location_zip_code = "";
				 for($i=2; $i<count($value_field_parts); $i++) {
					 $location_zip_code .= $value_field_parts[$i];
				 }
				 $location_zip_code = strtolower(str_replace(" ","",str_replace("\"","", trim($location_zip_code))));
				 
			 } else if(substr($filter_line_phrase, 0, 16) == "[DATE AVAILABLE]") {
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
				 $field_value = trim(str_replace('"',"",$field_parts[1]));
			 } else {
				 $filter_line_phrase = str_replace("Contains The Word", "LIKE", $filter_line_phrase);
				 $field_parts = explode(" LIKE ", $filter_line_phrase);
				 $field_name = trim($field_parts[0]);
				 $field_value = strtolower(str_replace("\"","", trim($field_parts[1])));
			 }
			 $translated_filter_phrase = "";
			 $criteria_count++;
			 $b_resume_criteria = false;
		 
			 
			 switch($field_name) {
				case "[DATE AVAILABLE]":
					$translated_filter_phrase = "(candidate.date_available ".$numeric_operator." '".$field_value."' OR candidate.date_available IS NULL)";
					break;
					 
				case "[LOCATION]":
					//$inclusive_zip_codes = $location_distance." ".$location_distance_unit. " ".$location_zip_code;
					$inclusive_zip_codes_array = $search->get_inclusive_zipcodes($location_distance, $location_distance_unit, $location_zip_code);
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
					$translated_filter_phrase = "LOWER(REPLACE(candidate.zip,' ','')) IN (".$inclusive_zip_codes.")";					
					break;
				case "[CITY]":
					$translated_filter_phrase = "LOWER(candidate.city) LIKE \"%".$field_value."%\"";
					break;
				case "[STATE]":
					$translated_filter_phrase = "LOWER(candidate.state) LIKE \"%".$field_value."%\"";
					break;
				case "[COUNTRY]":
					$translated_filter_phrase = "LOWER(candidate.country) LIKE \"%".$field_value."%\"";
					break;
				case "[COMPANY]":
					$translated_filter_phrase = "LOWER(candidate.current_employer) LIKE \"%".$field_value."%\"";
					break;
				case "[CURRENT EMPLOYER]":
					$translated_filter_phrase = "LOWER(candidate.current_employer) LIKE \"%".$field_value."%\"";
					break;
				case "[PHONE]":
					$translated_filter_phrase = "
					       REPLACE(REPLACE(REPLACE(REPLACE(candidate.phone_home, '-', ''),'.', ''),')', ''),'(', '') LIKE \"%".$field_value."%\"
                        OR REPLACE(REPLACE(REPLACE(REPLACE(candidate.phone_cell, '-', ''),'.', ''),')', ''),'(', '') LIKE \"%".$field_value."%\"";
					break;
				case "[KEY SKILLS]":
					$field_spec_str = '';
					if(strpos( $filter_line_phrase,"with roles of") !== false) $field_value = '*';
					 if(strpos( $filter_line_phrase,"with roles of") !== false) {
						$field_value_str = str_replace(" with roles of ", ":", $filter_line_phrase);
						$field_value_sub = explode(' LIKE ',$field_value_str);
						$field_value = str_replace('"',"",$field_value_sub[1]);
						
						$field_value_arr = explode(':',$field_value);
						$field_spec = $field_value_arr[0];
						$field_role = $field_value_arr[1];
						$field_spec_str = " OR LOWER(candidate.key_skills) LIKE \"%".strtolower(trim($field_spec)).":%\"";
						$field_spec_str .= " OR LOWER(candidate.key_skills) LIKE \"%:".strtolower(trim($field_role))."%\"";
						$translated_filter_phrase = "LOWER(candidate.key_skills) LIKE \"%".strtolower(trim($field_value))."%\"".$field_spec_str;
					 } else {
						$translated_filter_phrase = "LOWER(candidate.key_skills) LIKE \"%".strtolower(trim($field_value))."%\"";					 
					 }
					break;
				case "[FULL NAME]":
					$translated_filter_phrase = " 
					       LOWER(CONCAT(candidate.first_name, ' ', candidate.last_name)) LIKE \"%".$field_value."%\"
                        OR LOWER(CONCAT(candidate.last_name, ' ', candidate.first_name)) LIKE \"%".$field_value."%\"
                        OR LOWER(CONCAT(candidate.last_name, ', ', candidate.first_name)) LIKE \"%".$field_value."%\"";
					break;
				case "[COMMUNICATION]":
					$translated_filter_phrase = "candidate.communication LIKE \"%".$field_value."%\"";
					break;
				case "[ELIGIBILITY]":
					$translated_filter_phrase = "candidate.eligibility LIKE \"%".$field_value."%\"";
					break;
				case "[TARGET JOB ZONE]":
					$translated_filter_phrase = "candidate.jobzone LIKE \"%".$field_value."%\"";
					break;
				case "[PREFERRED TERMS]":
					$translated_filter_phrase = "(candidate.terms LIKE \"%".$field_value."%\" OR candidate.contact_type LIKE \"%".$field_value."%\")";
					break;
				case "[CR CLASSIFICATION]":
					$translated_filter_phrase = "candidate.crclassification LIKE \"%".$field_value."%\"";
					break;
				case "[RESUME ATTACHMENT]":
					//die("before rs");
					$rs_text = $search->get_attachment_ids_str($field_value);				
					//die($rs_text);
				
					$translated_filter_phrase = $rs_text;
					$single_resume_text = "";
					//$translated_filter_phrase = "attachment.text like \"%".$field_value."%\"";
					//$translated_filter_phrase = "attachment.text REGEXP [[:<:]]".$field_value."[[:>:]]";
					/*
					if(strlen($single_resume_text)>0) $single_resume_text .=" ";
					$single_resume_text .= $field_value;
					
					if(strlen($resume_keywords)>0) $resume_keywords .= " ";
					$resume_keywords .= $field_value;
					*/
					
					$actual_mode = "resume";
					$b_resume_criteria = true;
					break;				
			 }
			 //echo "<p>Translating {".$filter_line_phrase_orig."} With {".$translated_filter_phrase."} in {".$query_line."}</p>";
			 if($b_resume_criteria == true) {
				//echo("<p>{".$filter_line_phrase_orig."} vs {".$query_line."}</p>");
				/*$query_line = str_replace("AND  (".$filter_line_phrase_orig. ")", "", $query_line);
				$query_line = str_replace("AND  ( ".$filter_line_phrase_orig. ")", "", $query_line);
			 	$query_line = str_replace("AND (".$filter_line_phrase_orig. ")", "", $query_line);
				$query_line = str_replace("AND ( ".$filter_line_phrase_orig. ")", "", $query_line);
				$query_line = str_replace("OR  (".$filter_line_phrase_orig. ")", "", $query_line);
				$query_line = str_replace("OR  ( ".$filter_line_phrase_orig. ")", "", $query_line);				
				$query_line = str_replace("OR (".$filter_line_phrase_orig. ")", "", $query_line);
				$query_line = str_replace("OR ( ".$filter_line_phrase_orig. ")", "", $query_line);				
				
				$query_line = str_replace("(".$filter_line_phrase_orig. ") AND", "", $query_line);
				$query_line = str_replace("( ".$filter_line_phrase_orig. ") AND", "", $query_line);
				$query_line = str_replace("(".$filter_line_phrase_orig. ") OR", "", $query_line);
				$query_line = str_replace("( ".$filter_line_phrase_orig. ") OR", "", $query_line);				
				
				$query_line = str_replace("AND  ".$filter_line_phrase_orig. "", "", $query_line);				
				$query_line = str_replace("OR  ".$filter_line_phrase_orig. "", "", $query_line);
				$query_line = str_replace("AND ".$filter_line_phrase_orig. "", "", $query_line);				
				$query_line = str_replace("OR ".$filter_line_phrase_orig. "", "", $query_line);
				$query_line = str_replace("".$filter_line_phrase_orig. " AND", "", $query_line);
				$query_line = str_replace("".$filter_line_phrase_orig. " OR", "", $query_line);*/
				// $query_line = str_replace("".$filter_line_phrase_orig. "", "1", $query_line);				
				$query_line = str_replace($filter_line_phrase_orig, "(".$translated_filter_phrase.")", $query_line);
			 } else {
			 	$query_line = str_replace($filter_line_phrase_orig, "(".$translated_filter_phrase.")", $query_line);
			 }
			 
			
		 }
	
		/*
		die("<p>THIS FUNCTION IN PROGRESS - Allan</p>
		     <p>Test Dump</p>
			 <p>".$query_line."</p>".
			 "<p>".$filter_line_phrase."</p>");
		 
        if (!isset($_GET['wildCardString']))
        {
            $this->listByView('No wild card string specified.');
            return;
        }
		*/
				
		if(trim($query_line )== "" && strlen($single_resume_text)==0) {
			$this->listByView('No wild card string specified.');
            return;
		}
		//die("{".$query_line."} vs {".$single_resume_text."}");
        //$query = trim($_GET['wildCardString']);
		$query = $query_line;
		// die($query);
				
        /* Initialize stored wildcard strings to safe default values. */
        $resumeWildCardString      = '';
        $keySkillsWildCardString   = '';
        $phoneNumberWildCardString = '';
        $fullNameWildCardString    = '';

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
            CANDIDATES_PER_PAGE, $currentPage, $this->_siteID
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

        $candidates = new Candidates($this->_siteID);

        /* Get our current searching mode. */
        $mode = $this->getTrimmedInput('mode', $_GET);

        //die("actual mode:".$actual_mode);
		
        //switch ($mode)
		
		//die("[".$actual_mode."]");
		
		switch ($actual_mode)
        {
			case 'regular':												
				$rs = $search->byMultiple($query, $sortBy, $sortDirection);				
				//die("query executed by multiple");
				//print_r($rs);
				//die("<p>END</p>");
                foreach ($rs as $rowIndex => $row) {
                    if (!empty($row['ownerFirstName'])) {
                        $rs[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                            $row['ownerFirstName'],
                            $row['ownerLastName'],
                            false,
                            LAST_NAME_MAXLEN
                        );
                    } else {
                        $rs[$rowIndex]['ownerAbbrName'] = 'None';
                    }
					//$candidateIDArray[] = $row['candidateID'];
                    $rsResume = $candidates->getResumes($row['candidateID']);
                    if (isset($rsResume[0])) {
                        $rs[$rowIndex]['resumeID'] = $rsResume[0]['attachmentID'];
                    }
                }				
                $isResumeMode = false;
                $fullNameWildCardString = $query;
				break;
			/*	
			case 'searchByCity':
                $rs = $search->byCity($query, $sortBy, $sortDirection);
                foreach ($rs as $rowIndex => $row) {
                    if (!empty($row['ownerFirstName'])) {
                        $rs[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                            $row['ownerFirstName'],
                            $row['ownerLastName'],
                            false,
                            LAST_NAME_MAXLEN
                        );
                    } else {
                        $rs[$rowIndex]['ownerAbbrName'] = 'None';
                    }
                    $rsResume = $candidates->getResumes($row['candidateID']);
                    if (isset($rsResume[0])) {
                        $rs[$rowIndex]['resumeID'] = $rsResume[0]['attachmentID'];
                    }
                }
                $isResumeMode = false;
                $fullNameWildCardString = $query;
                break;
			
			case 'searchByState':
                $rs = $search->byState($query, $sortBy, $sortDirection);
                foreach ($rs as $rowIndex => $row) {
                    if (!empty($row['ownerFirstName'])) {
                        $rs[$rowIndex]['ownerAbbrName'] = StringUtility::makeInitialName(
                            $row['ownerFirstName'],
                            $row['ownerLastName'],
                            false,
                            LAST_NAME_MAXLEN
                        );
                    } else {
                        $rs[$rowIndex]['ownerAbbrName'] = 'None';
                    }
                    $rsResume = $candidates->getResumes($row['candidateID']);
                    if (isset($rsResume[0])) {
                        $rs[$rowIndex]['resumeID'] = $rsResume[0]['attachmentID'];
                    }
                }
                $isResumeMode = false;
                $fullNameWildCardString = $query;
                break;
					
            case 'searchByFullName':
                $rs = $search->byFullName($query, $sortBy, $sortDirection);
                foreach ($rs as $rowIndex => $row)
                {
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

                    $rsResume = $candidates->getResumes($row['candidateID']);
                    if (isset($rsResume[0]))
                    {
                        $rs[$rowIndex]['resumeID'] = $rsResume[0]['attachmentID'];
                    }
                }

                $isResumeMode = false;

                $fullNameWildCardString = $query;
                break;

            case 'searchByKeySkills':
                $rs = $search->byKeySkills($query, $sortBy, $sortDirection);

                foreach ($rs as $rowIndex => $row)
                {
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

                    $rsResume = $candidates->getResumes($row['candidateID']);
                    if (isset($rsResume[0]))
                    {
                        $rs[$rowIndex]['resumeID'] = $rsResume[0]['attachmentID'];
                    }
                }

                $isResumeMode = false;

                $keySkillsWildCardString = $query;

                break;

            case 'phoneNumber':
                $rs = $search->byPhone($query, $sortBy, $sortDirection);

                foreach ($rs as $rowIndex => $row)
                {
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

                    $rsResume = $candidates->getResumes($row['candidateID']);
                    if (isset($rsResume[0]))
                    {
                        $rs[$rowIndex]['resumeID'] = $rsResume[0]['attachmentID'];
                    }
                }

                $isResumeMode = false;

                $phoneNumberWildCardString = $query;
                break;
			*/
			case 'resume':
			case 'searchByResume':			
				//clean query variable for empty queries
				/*
				$unclean = true;
				while($unclean == true) {
					$query = trim($query);
					$query = str_replace("()", "", $query);
					if(stripos($query,"()") >=0) {
						$unclean = true;	
					}
				}
				*/
				//die($query);
				//die($single_resume_text);
                $searchPager = new SearchByResumePager(
                    20,
                    $currentPage,
                    $this->_siteID,
                    $query,
                    $sortBy,
                    $sortDirection,
					$single_resume_text
                );
				/*
                $baseURL = 'm=candidates&amp;a=search&amp;getback=getback&amp;mode=searchByResume&amp;wildCardString='
                    . urlencode($query)
                    . '&amp;searchByResume=Search';
				*/
				$query_lists= "";
				for($i=0; $i<count($query_array); $i++) {
					$query_lists .= ("&amp;query_list%5B%5D=".urlencode($query_array[$i]));
		 		}
		 
				$baseURL = 'm=candidates&amp;a=search&amp;getback=getback&amp;mode=searchByResume'
                    . $query_lists
                    . '&amp;searchByResume=Search';
                $searchPager->setSortByParameters(
                    $baseURL, $sortBy, $sortDirection
                );

                $rs = $searchPager->getPage();

                $currentPage = $searchPager->getCurrentPage();
                $totalPages  = $searchPager->getTotalPages();

                $pageStart = $searchPager->getThisPageStartRow() + 1;

                if (($searchPager->getThisPageStartRow() + 20) <= $searchPager->getTotalRows())
                {
                    $pageEnd = $searchPager->getThisPageStartRow() + 20;
                }
                else
                {
                    $pageEnd = $searchPager->getTotalRows();
                }

                foreach ($rs as $rowIndex => $row)
                {
					/*
                    $rs[$rowIndex]['excerpt'] = SearchUtility::searchExcerpt(
                        $query, $row['text']
                    );
					*/
					$rs[$rowIndex]['excerpt'] = SearchUtility::searchExcerpt(
                        $resume_keywords, $row['text']
                    );
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
					//$candidateIDArray[] = $row['candidateID'];
                }

                $isResumeMode = true;

                $this->_template->assign('active', $this);
                $this->_template->assign('currentPage', $currentPage);
                $this->_template->assign('pageStart', $pageStart);
                $this->_template->assign('totalResults', $searchPager->getTotalRows());
                $this->_template->assign('pageEnd', $pageEnd);
                $this->_template->assign('totalPages', $totalPages);

                $resumeWildCardString = $query;
                break;
				
            default:
                $this->listByView('Invalid search mode.');
                return;
                break;
        }
		
		/*
		    $dataGrid = DataGrid::getFromRequest();

            $candidateIDs = $dataGrid->getExportIDs();

            // Validate each ID 
            foreach ($candidateIDs as $index => $candidateID)
            {
                if (!$this->isRequiredIDValid($index, $candidateIDs))
                {
                    CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
                    return;
                }
            }
		*/
		/*
		$dataGrid = DataGrid::getFromRequest();
		$candidateIDs = $dataGrid->getExportIDs();
		print_r($candidateIDs);
		die("<p>testing</p>");
		*/
		
		$candidateIDArray =  ResultSetUtility::getColumnValues($rs, 'candidateID');
		$candidateIDArrayStored = $_SESSION['CATS']->storeData($candidateIDArray);
		
		//goback_latest
        $candidateIDs = implode(',', $candidateIDArray);
        $exportForm = ExportUtility::getForm(
            DATA_ITEM_CANDIDATE, $candidateIDs, 32, 9
        );

        if (!eval(Hooks::get('CANDIDATE_ON_SEARCH'))) return;

        /* Save the search. */
        $savedSearches = new SavedSearches($this->_siteID);
        $savedSearches->add(
            DATA_ITEM_CANDIDATE,
            $query_line_orig,
            $_SERVER['REQUEST_URI'],
            false
        );
        $savedSearchRS = $savedSearches->get(DATA_ITEM_CANDIDATE);
		
		//print_r($rs);
		//die("<p>END</p>");
		
        $this->_template->assign('savedSearchRS', $savedSearchRS);
        $this->_template->assign('exportForm', $exportForm);
        $this->_template->assign('active', $this);
        $this->_template->assign('rs', $rs);
        $this->_template->assign('pager', $searchPager);
        $this->_template->assign('isResultsMode', true);
        $this->_template->assign('isResumeMode', $isResumeMode);
		$this->_template->assign('query_array', $query_array);
		$this->_template->assign('candidateIDArray', $candidateIDArray);
		$this->_template->assign('candidateIDArrayStored', $candidateIDArrayStored);
        //$this->_template->assign('wildCardString', $query);
		$this->_template->assign('wildCardString', '');
        $this->_template->assign('resumeWildCardString', $resumeWildCardString);
        $this->_template->assign('keySkillsWildCardString', $keySkillsWildCardString);
        $this->_template->assign('fullNameWildCardString', $fullNameWildCardString);
        $this->_template->assign('phoneNumberWildCardString', $phoneNumberWildCardString);
        $this->_template->assign('mode', $mode);
        $this->_template->display('./modules/candidates/Search.tpl');		
    }

    /*
     * Called by handleRequest() to process showing a resume preview.
     */
    private function viewResume()
    {
        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('attachmentID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid attachment ID.');
        }

        $attachmentID = $_GET['attachmentID'];

        /* Get the search string. */
        $query = $this->getTrimmedInput('wildCardString', $_GET);

        /* Get resume text. */
        $candidates = new Candidates($this->_siteID);
        $data = $candidates->getResume($attachmentID);

        if (!empty($data))
        {
            /* Keyword highlighting. */
            $data['text'] = SearchUtility::makePreview($query, $data['text']);
        }

        if (!eval(Hooks::get('CANDIDATE_VIEW_RESUME'))) return;

        $this->_template->assign('active', $this);
        $this->_template->assign('data', $data);
        $this->_template->display('./modules/candidates/ResumeView.tpl');
    }

    private function addEditImage()
    {
        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID = $_GET['candidateID'];

        $attachments = new Attachments($this->_siteID);
        $attachmentsRS = $attachments->getAll(
            DATA_ITEM_CANDIDATE, $candidateID
        );

        if (!eval(Hooks::get('CANDIDATE_ADD_EDIT_IMAGE'))) return;

        $this->_template->assign('isFinishedMode', false);
        $this->_template->assign('candidateID', $candidateID);
        $this->_template->assign('attachmentsRS', $attachmentsRS);
        $this->_template->display(
            './modules/candidates/CreateImageAttachmentModal.tpl'
        );
    }

    /*
     * Called by handleRequest() to process creating an attachment.
     */
    private function onAddEditImage()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatalModal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_POST))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID = $_POST['candidateID'];

        if (!eval(Hooks::get('CANDIDATE_ON_ADD_EDIT_IMAGE_PRE'))) return;

        $attachmentCreator = new AttachmentCreator($this->_siteID);
        $attachmentCreator->createFromUpload(
            DATA_ITEM_CANDIDATE, $candidateID, 'file', true, false
        );

        if ($attachmentCreator->isError())
        {
            CommonErrors::fatalModal(COMMONERROR_FILEERROR, $this, $attachmentCreator->getError());
            return;
            //$this->fatalModal($attachmentCreator->getError());
        }

        if (!eval(Hooks::get('CANDIDATE_ON_ADD_EDIT_IMAGE_POST'))) return;

        $this->_template->assign('isFinishedMode', true);
        $this->_template->assign('candidateID', $candidateID);
        $this->_template->display(
            './modules/candidates/CreateImageAttachmentModal.tpl'
        );
    }

    /*
     * Called by handleRequest() to process loading the create attachment
     * modal dialog.
     */
    private function createAttachment()
    {
        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID = $_GET['candidateID'];

        if (!eval(Hooks::get('CANDIDATE_CREATE_ATTACHMENT'))) return;

        $this->_template->assign('isFinishedMode', false);
        $this->_template->assign('candidateID', $candidateID);
        $this->_template->display(
            './modules/candidates/CreateAttachmentModal.tpl'
        );
    }

    /*
     * Called by handleRequest() to process creating an attachment.
     */
    private function onCreateAttachment()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_EDIT)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_POST))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        /* Bail out if we don't have a valid resume status. */
        if (!$this->isRequiredIDValid('resume', $_POST, true) ||
            $_POST['resume'] < 0 || $_POST['resume'] > 1)
        {
            CommonErrors::fatalModal(COMMONERROR_RECORDERROR, $this, 'Invalid resume status.');
        }

        $candidateID = $_POST['candidateID'];

        if ($_POST['resume'] == '1')
        {
            $isResume = true;
        }
        else
        {
            $isResume = false;
        }

        if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_PRE'))) return;

        $attachmentCreator = new AttachmentCreator($this->_siteID);
        $attachmentCreator->createFromUpload(
            DATA_ITEM_CANDIDATE, $candidateID, 'file', false, $isResume
        );

        if ($attachmentCreator->isError())
        {
            CommonErrors::fatalModal(COMMONERROR_FILEERROR, $this, $attachmentCreator->getError());
            return;
            //$this->fatalModal($attachmentCreator->getError());
        }

        if ($attachmentCreator->duplicatesOccurred())
        {
            $this->fatalModal(
                'This attachment has already been added to this candidate.'
            );
        }

        $isTextExtractionError = $attachmentCreator->isTextExtractionError();
        $textExtractionErrorMessage = $attachmentCreator->getTextExtractionError();
        $resumeText = $attachmentCreator->getExtractedText();

        if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_POST'))) return;

        $this->_template->assign('resumeText', $resumeText);
        $this->_template->assign('isFinishedMode', true);
        $this->_template->assign('candidateID', $candidateID);
        $this->_template->display(
            './modules/candidates/CreateAttachmentModal.tpl'
        );
    }

    /*
     * Called by handleRequest() to process deleting an attachment.
     */
    private function onDeleteAttachment()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_DELETE)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid attachment ID. */
        if (!$this->isRequiredIDValid('attachmentID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid attachment ID.');
        }

        /* Bail out if we don't have a valid candidate ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        $candidateID  = $_GET['candidateID'];
        $attachmentID = $_GET['attachmentID'];

        if (!eval(Hooks::get('CANDIDATE_ON_DELETE_ATTACHMENT_PRE'))) return;

        $attachments = new Attachments($this->_siteID);
        $attachments->delete($attachmentID);

        if (!eval(Hooks::get('CANDIDATE_ON_DELETE_ATTACHMENT_POST'))) return;

        CATSUtility::transferRelativeURI(
            'm=candidates&a=show&candidateID=' . $candidateID
        );
    }

    //TODO: Document me.
    //Only accessable by MSA users - hides this job order from everybody by
    private function administrativeHideShow()
    {
        if ($this->_accessLevel < ACCESS_LEVEL_MULTI_SA)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Invalid user level for action.');
        }

        /* Bail out if we don't have a valid joborder ID. */
        if (!$this->isRequiredIDValid('candidateID', $_GET))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid Job Order ID.');
        }

        /* Bail out if we don't have a valid status ID. */
        if (!$this->isRequiredIDValid('state', $_GET, true))
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX, $this, 'Invalid state ID.');
        }

        $candidateID = $_GET['candidateID'];

        // FIXME: Checkbox?
        $state = (boolean) $_GET['state'];

        $candidates = new Candidates($this->_siteID);
        $candidates->administrativeHideShow($candidateID, $state);

        CATSUtility::transferRelativeURI('m=candidates&a=show&candidateID='.$candidateID);
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

            if ($resultSet[$rowIndex]['submitted'] == 1)
            {
                $resultSet[$rowIndex]['iconTag'] = '<img src="images/job_orders.gif" alt="" width="16" height="16" title="Submitted for a Job Order" />';
            }
            else
            {
                $resultSet[$rowIndex]['iconTag'] = '<img src="images/mru/blank.gif" alt="" width="16" height="16" />';
            }

            if ($resultSet[$rowIndex]['attachmentPresent'] == 1)
            {
                $resultSet[$rowIndex]['iconTag'] .= '<img src="images/paperclip.gif" alt="" width="16" height="16" title="Attachment Present" />';
            }
            else
            {
                $resultSet[$rowIndex]['iconTag'] .= '<img src="images/mru/blank.gif" alt="" width="16" height="16" />';
            }


            if (empty($resultSet[$rowIndex]['keySkills']))
            {
                $resultSet[$rowIndex]['keySkills'] = '&nbsp;';
            }
            else
            {
                $resultSet[$rowIndex]['keySkills'] = htmlspecialchars(
                    $resultSet[$rowIndex]['keySkills']
                );
            }

            /* Truncate Key Skills to fit the column width */
            if (strlen($resultSet[$rowIndex]['keySkills']) > self::TRUNCATE_KEYSKILLS)
            {
                $resultSet[$rowIndex]['keySkills'] = substr(
                    $resultSet[$rowIndex]['keySkills'],
                    0,
                    self::TRUNCATE_KEYSKILLS
                ) . "...";
            }
        }

        return $resultSet;
    }

    /**
     * Adds a candidate. This is factored out for code clarity.
     *
     * @param boolean is modal window
     * @param string module directory
     * @return integer candidate ID
     */
    private function _addCandidate($isModal, $directoryOverride = '')
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

        /* Modal override for fatal() calls. */
        if ($isModal)
        {
            $fatal = 'fatalModal';
        }
        else
        {
            $fatal = 'fatal';
        }

        /* Bail out if we received an invalid availability date; if not, go
         * ahead and convert the date to MySQL format.
         */
        $dateAvailable = $this->getTrimmedInput('dateAvailable', $_POST);
        if (!empty($dateAvailable))
        {
            if (!DateUtility::validate('-', $dateAvailable, DATE_FORMAT_MMDDYY))
            {
                $this->$fatal('Invalid availability date.', $moduleDirectory);
            }

            /* Convert start_date to something MySQL can understand. */
            $dateAvailable = DateUtility::convert(
                '-', $dateAvailable, DATE_FORMAT_MMDDYY, DATE_FORMAT_YYYYMMDD
            );
        }

        $formattedPhoneHome = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phoneHome', $_POST)
        );
        if (!empty($formattedPhoneHome))
        {
            $phoneHome = $formattedPhoneHome;
        }
        else
        {
            $phoneHome = $this->getTrimmedInput('phoneHome', $_POST);
        }

        $formattedPhoneCell = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phoneCell', $_POST)
        );
        if (!empty($formattedPhoneCell))
        {
            $phoneCell = $formattedPhoneCell;
        }
        else
        {
            $phoneCell = $this->getTrimmedInput('phoneCell', $_POST);
        }

        $formattedPhoneWork = StringUtility::extractPhoneNumber(
            $this->getTrimmedInput('phoneWork', $_POST)
        );
        if (!empty($formattedPhoneWork))
        {
            $phoneWork = $formattedPhoneWork;
        }
        else
        {
            $phoneWork = $this->getTrimmedInput('phoneWork', $_POST);
        }

        /* Can Relocate */
        $canRelocate = $this->isChecked('canRelocate', $_POST);

        $lastName        = $this->getTrimmedInput('lastName', $_POST);
        $middleName      = $this->getTrimmedInput('middleName', $_POST);
        $firstName       = $this->getTrimmedInput('firstName', $_POST);
        $title		     = $this->getTrimmedInput('title', $_POST);
        $email1          = $this->getTrimmedInput('email1', $_POST);
        $email2          = $this->getTrimmedInput('email2', $_POST);
        $address         = $this->getTrimmedInput('address', $_POST);
        $city            = $this->getTrimmedInput('city', $_POST);
        $state           = $this->getTrimmedInput('state', $_POST);
        $zip             = $this->getTrimmedInput('zip', $_POST);
        $source          = $this->getTrimmedInput('source', $_POST);
        $keySkills       = $this->getTrimmedInput('keySkills', $_POST);
        $currentEmployer = $this->getTrimmedInput('currentEmployer', $_POST);
        $currentPay      = $this->getTrimmedInput('currentPay', $_POST);
        $desiredPay      = $this->getTrimmedInput('desiredPay', $_POST);
        $notes           = $this->getTrimmedInput('notes', $_POST);
        $webSite         = $this->getTrimmedInput('webSite', $_POST);
        $bestTimeToCall  = $this->getTrimmedInput('bestTimeToCall', $_POST);
        $gender          = $this->getTrimmedInput('gender', $_POST);
        $race            = $this->getTrimmedInput('race', $_POST);
        $veteran         = $this->getTrimmedInput('veteran', $_POST);
        $disability      = $this->getTrimmedInput('disability', $_POST);
		$skype_id      	 = $this->getTrimmedInput('skype_id', $_POST);
		$contact_type  	 = $this->getTrimmedInput('contact_type', $_POST);
		$eligibility 	 = $this->getTrimmedInput('eligibility', $_POST);
		$crclassification 	 = $this->getTrimmedInput('crclassification', $_POST);
		$communication  	 = $this->getTrimmedInput('communication', $_POST);
		$jobzone		  	 = $this->getTrimmedInput('jobzone', $_POST);
		
	
        /* Candidate source list editor. */
        $sourceCSV = $this->getTrimmedInput('sourceCSV', $_POST);

        /* Text resume. */
        $textResumeBlock = $this->getTrimmedInput('textResumeBlock', $_POST);
        $textResumeFilename = $this->getTrimmedInput('textResumeFilename', $_POST);

        /* File resume. */
        $associatedFileResumeID = $this->getTrimmedInput('associatedbFileResumeID', $_POST);

        /* Bail out if any of the required fields are empty. */
        if (empty($firstName) || empty($lastName))
        {
            CommonErrors::fatal(COMMONERROR_MISSINGFIELDS, $this);
        }

        if (!eval(Hooks::get('CANDIDATE_ON_ADD_PRE'))) return;

        $candidates = new Candidates($this->_siteID);
        $candidateID = $candidates->add(
            $firstName,
            $middleName,
            $lastName,
			$title,
            $email1,
            $email2,
            $phoneHome,
            $phoneCell,
            $phoneWork,
            $address,
            $city,
            $state,
            $zip,
            $source,
            $keySkills,
            $dateAvailable,
            $currentEmployer,
            $canRelocate,
            $currentPay,
            $desiredPay,
            $notes,
            $webSite,
            $bestTimeToCall,
            $this->_userID,
            $this->_userID,
            $gender,
            $race,
            $veteran,
            $disability,
			'', 
			$skype_id,
			$contact_type,
			'',
			$eligibility,
			$crclassification,
			$communication,
			$jobzone
        );

        if ($candidateID <= 0)
        {
            return $candidateID;
        }

        /* Update extra fields. */
        $candidates->extraFields->setValuesOnEdit($candidateID);

        /* Update possible source list. */
        $sources = $candidates->getPossibleSources();
        $sourcesDifferences = ListEditor::getDifferencesFromList(
            $sources, 'name', 'sourceID', $sourceCSV
        );
        $candidates->updatePossibleSources($sourcesDifferences);

        /* Associate an exsisting resume if the user created a candidate with one. (Bulk) */
        if (isset($_POST['associatedAttachment']))
        {
            $attachmentID = $_POST['associatedAttachment'];

            $attachments = new Attachments($this->_siteID);
            $attachments->setDataItemID($attachmentID, $candidateID, DATA_ITEM_CANDIDATE);
        }

        /* Attach a resume if the user uploaded one. (http POST) */
        /* NOTE: This function cannot be called if parsing is enabled */
        else if (isset($_FILES['file']) && !empty($_FILES['file']['name']))
        {
            if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_PRE'))) return;

            $attachmentCreator = new AttachmentCreator($this->_siteID);
            $attachmentCreator->createFromUpload(
                DATA_ITEM_CANDIDATE, $candidateID, 'file', false, true
            );

            if ($attachmentCreator->isError())
            {
                CommonErrors::fatal(COMMONERROR_FILEERROR, $this, $attachmentCreator->getError());
            }


            if ($attachmentCreator->duplicatesOccurred())
            {
                $this->listByView(
                    'This attachment has already been added to this candidate.'
                );
                return;
            }

            $isTextExtractionError = $attachmentCreator->isTextExtractionError();
            $textExtractionErrorMessage = $attachmentCreator->getTextExtractionError();

            // FIXME: Show parse errors!

            if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_POST'))) return;
        }

        /**
         * User has loaded and/or parsed a resume. The attachment is saved in a temporary
         * file already and just needs to be attached. The attachment has also successfully
         * been DocumentToText converted, so we know it's a good file.
         */
        else if (LicenseUtility::isParsingEnabled())
        {
            /**
             * Description: User clicks "browse" and selects a resume file. User doesn't click
             * upload. The resume file is STILL uploaded.
             * Controversial: User uploads a resume, parses, etc. User selects a new file with
             * "Browse" but doesn't click "Upload". New file is accepted.
             * It's technically correct either way, I'm opting for the "use whats in "file"
             * box over what's already uploaded method to avoid losing resumes on candidate
             * additions.
             */
            $newFile = FileUtility::getUploadFileFromPost($this->_siteID, 'addcandidate', 'documentFile');

            if ($newFile !== false)
            {
                $newFilePath = FileUtility::getUploadFilePath($this->_siteID, 'addcandidate', $newFile);

                $tempFile = $newFile;
                $tempFullPath = $newFilePath;
            }
            else
            {
                $attachmentCreated = false;

                $tempFile = false;
                $tempFullPath = false;

                if (isset($_POST['documentTempFile']) && !empty($_POST['documentTempFile']))
                {
                    $tempFile = $_POST['documentTempFile'];
                    // Get the path of the file they uploaded already to attach
                    $tempFullPath = FileUtility::getUploadFilePath(
                        $this->_siteID,   // ID of the containing site
                        'addcandidate',   // Sub-directory in their storage
                        $tempFile         // Name of the file (not pathed)
                    );
                }
            }

            if ($tempFile !== false && $tempFullPath !== false)
            {
                if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_PRE'))) return;

                $attachmentCreator = new AttachmentCreator($this->_siteID);
                $attachmentCreator->createFromFile(
                    DATA_ITEM_CANDIDATE, $candidateID, $tempFullPath, $tempFile, '', true, true
                );

                if ($attachmentCreator->isError())
                {
                    CommonErrors::fatal(COMMONERROR_FILEERROR, $this, $attachmentCreator->getError());
                }


                if ($attachmentCreator->duplicatesOccurred())
                {
                    $this->listByView(
                        'This attachment has already been added to this candidate.'
                    );
                    return;
                }

                $isTextExtractionError = $attachmentCreator->isTextExtractionError();
                $textExtractionErrorMessage = $attachmentCreator->getTextExtractionError();

                if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_POST'))) return;

                // Remove the cleanup cookie since the file no longer exists
                setcookie('CATS_SP_TEMP_FILE', '');

                $attachmentCreated = true;
            }

            if (!$attachmentCreated && isset($_POST['documentText']) && !empty($_POST['documentText']))
            {
                // Resume was pasted into the form and not uploaded from a file

                if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_PRE'))) return;

                $attachmentCreator = new AttachmentCreator($this->_siteID);
                $attachmentCreator->createFromText(
                    DATA_ITEM_CANDIDATE, $candidateID, $_POST['documentText'], 'MyResume.txt', true
                );

                if ($attachmentCreator->isError())
                {
                    CommonErrors::fatal(COMMONERROR_FILEERROR, $this, $attachmentCreator->getError());
                }

                if ($attachmentCreator->duplicatesOccurred())
                {
                    $this->listByView(
                        'This attachment has already been added to this candidate.'
                    );
                    return;
                }

                if (!eval(Hooks::get('CANDIDATE_ON_CREATE_ATTACHMENT_POST'))) return;
            }
        }

        /* Create a text resume if the user posted one. (automated tool) */
        else if (!empty($textResumeBlock))
        {
            $attachmentCreator = new AttachmentCreator($this->_siteID);
            $attachmentCreator->createFromText(
                DATA_ITEM_CANDIDATE, $candidateID, $textResumeBlock, $textResumeFilename, true
            );

            if ($attachmentCreator->isError())
            {
                CommonErrors::fatal(COMMONERROR_FILEERROR, $this, $attachmentCreator->getError());
                return;
                //$this->fatal($attachmentCreator->getError());
            }
            $isTextExtractionError = $attachmentCreator->isTextExtractionError();
            $textExtractionErrorMessage = $attachmentCreator->getTextExtractionError();

            // FIXME: Show parse errors!
        }
				
		//TODO-LATEST: attach photo id here if posted
		if(strlen($_POST["resumePhotoID"]."") > 0) {
			$item_id = intval($_POST["resumePhotoID"]);
			$photo_data = $_SESSION['CATS']->retrieveData($item_id);
						
			$tempFullPath = CATS_TEMP_DIR;
			$tempFile = FileUtility::makeRandomFilename() . ".". strtolower($_POST['resumePhotoType']);
			$fullfilename = $tempFullPath . "/" . $tempFile;
			
			if (file_put_contents($fullfilename, $photo_data) === false) {
				//an error ocurred while saving photo data to temporary file and folder				
			} else {			
				$attachmentCreator = new AttachmentCreator($this->_siteID);
				$attachmentCreator->createFromFile(
					DATA_ITEM_CANDIDATE, $candidateID, $fullfilename, false, $tempFile, false, true, true
				);
			}
		}
		
        if (!eval(Hooks::get('CANDIDATE_ON_ADD_POST'))) return;

        return $candidateID;
    }

    /**
     * Processes an Add Activity / Change Status form and displays
     * candidates/AddActivityChangeStatusModal.tpl. This is factored out
     * for code clarity.
     *
     * @param boolean from joborders module perspective
     * @param integer "regarding" job order ID or -1
     * @param string module directory
     * @return void
     */
    private function _addActivityChangeStatus($isJobOrdersMode, $regardingID,
        $directoryOverride = '')
    {
        $notificationHTML = '';

        $pipelines = new Pipelines($this->_siteID);
        $statusRS = $pipelines->getStatusesForPicking();

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
        if (!$this->isRequiredIDValid('candidateID', $_POST))
        {
            CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
        }

        /* Do we have a valid status ID. */
        if (!$this->isOptionalIDValid('statusID', $_POST))
        {
            $statusID = -1;
        }
        else
        {
            $statusID = $_POST['statusID'];
        }

        $candidateID = $_POST['candidateID'];

        if (!eval(Hooks::get('CANDIDATE_ON_ADD_ACTIVITY_CHANGE_STATUS_PRE'))) return;

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

            // FIXME: Move this to a highlighter-method? */
            if (strpos($activityNote, 'Status change: ') === 0)
            {
                foreach ($statusRS as $data)
                {
                    $activityNote = StringUtility::replaceOnce(
                        $data['status'],
                        '<span style="color: #ff6c00;">' . $data['status'] . '</span>',
                        $activityNote
                    );
                }
            }

            /* Add the activity entry. */
            $activityEntries = new ActivityEntries($this->_siteID);
            $activityID = $activityEntries->add(
                $candidateID,
                DATA_ITEM_CANDIDATE,
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

        if ($regardingID <= 0 || $statusID == -1)
        {
            $statusChanged = false;
            $oldStatusDescription = '';
            $newStatusDescription = '';
        }
        else
        {
            $data = $pipelines->get($candidateID, $regardingID);

            /* Bail out if we got an empty result set. */
            if (empty($data))
            {
                $this->fatalModal(
                    'The specified pipeline entry could not be found.'
                );
            }

            $validStatus = ResultSetUtility::findRowByColumnValue(
                $statusRS, 'statusID', $statusID
            );

            /* If the status is invalid or unchanged, don't mess with it. */
            if ($validStatus === false || $statusID == $data['status'])
            {
                $oldStatusDescription = '';
                $newStatusDescription = '';
                $statusChanged = false;
            }
            else
            {
                $oldStatusDescription = $data['status'];
                $newStatusDescription = ResultSetUtility::getColumnValueByIDValue(
                    $statusRS, 'statusID', $statusID, 'status'
                );

                if ($oldStatusDescription != $newStatusDescription)
                {
                    $statusChanged = true;
                }
                else
                {
                    $statusChanged = false;
                }
            }

            if ($statusChanged && $this->isChecked('triggerEmail', $_POST))
            {
                $customMessage = $this->getTrimmedInput('customMessage', $_POST);

                // FIXME: Actually validate the e-mail address?
                if (empty($data['candidateEmail']))
                {
                    $email = '';
                    $notificationHTML = '<p><span class="bold">Error:</span> An e-mail notification'
                        . ' could not be sent to the candidate because the candidate'
                        . ' does not have a valid e-mail address.</p>';
                }
                else if (empty($customMessage))
                {
                    $email = '';
                    $notificationHTML = '<p><span class="bold">Error:</span> An e-mail notification'
                        . ' will not be sent because the message text specified was blank.</p>';
                }
                else if ($this->_accessLevel == ACCESS_LEVEL_DEMO)
                {
                    $email = '';
                    $notificationHTML = '<p><span class="bold">Error:</span> Demo users can not send'
                        . ' E-Mails.  No E-Mail was sent.</p>';
                }
                else
                {
                    $email = $data['candidateEmail'];
                    $notificationHTML = '<p>An e-mail notification has been sent to the candidate.</p>';
                }
            }
            else
            {
                $email = '';
                $customMessage = '';
                $notificationHTML = '<p>No e-mail notification has been sent to the candidate.</p>';
            }

            /* Set the pipeline entry's status, but don't send e-mails for now. */
            $pipelines->setStatus(
                $candidateID, $regardingID, $statusID, $email, $customMessage
            );

            /* If status = placed, and open positions > 0, reduce number of open positions by one. */
            if ($statusID == PIPELINE_STATUS_PLACED && is_numeric($data['openingsAvailable']) && $data['openingsAvailable'] > 0)
            {
                $jobOrders = new JobOrders($this->_siteID);
                $jobOrders->updateOpeningsAvailable($regardingID, $data['openingsAvailable'] - 1);
            }
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
            $duration = $this->getTrimmedInput('duration', $_POST);;

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
                    $this->fatalModal(
                        'Invalid meridiem value.', $moduleDirectory
                    );
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
                CommonErrors::fatalModal(COMMONERROR_MISSINGFIELDS, $this);
                return;
                /*$this->fatalModal(
                    'Required fields are missing.', $moduleDirectory
                );*/
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
                $candidateID, DATA_ITEM_CANDIDATE, $eventJobOrderID, $title,
                $duration, $reminderEnabled, $reminderEmail, $reminderTime,
                $publicEntry, $_SESSION['CATS']->getTimeZoneOffset()
            );

            if ($eventID <= 0)
            {
                $this->fatalModal(
                    'Failed to add calendar event.', $moduleDirectory
                );
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

        if (!$statusChanged && !$activityAdded && !$eventScheduled)
        {
            $changesMade = false;
        }
        else
        {
            $changesMade = true;
        }

        if (!eval(Hooks::get('CANDIDATE_ON_ADD_ACTIVITY_CHANGE_STATUS_POST'))) return;

        $this->_template->assign('candidateID', $candidateID);
        $this->_template->assign('regardingID', $regardingID);
        $this->_template->assign('oldStatusDescription', $oldStatusDescription);
        $this->_template->assign('newStatusDescription', $newStatusDescription);
        $this->_template->assign('statusChanged', $statusChanged);
        $this->_template->assign('activityAdded', $activityAdded);
        $this->_template->assign('activityDescription', $activityNote);
        $this->_template->assign('activityType', $activityTypeDescription);
        $this->_template->assign('eventScheduled', $eventScheduled);
        $this->_template->assign('eventHTML', $eventHTML);
        $this->_template->assign('notificationHTML', $notificationHTML);
        $this->_template->assign('onlyScheduleEvent', $onlyScheduleEvent);
        $this->_template->assign('changesMade', $changesMade);
        $this->_template->assign('isFinishedMode', true);
        $this->_template->assign('isJobOrdersMode', $isJobOrdersMode);
        $this->_template->display(
            './modules/candidates/AddActivityChangeStatusModal.tpl'
        );
    }

    /*
     * Sends mass emails from the datagrid
     */
    private function onEmailCandidates()
    {
        if ($this->_accessLevel == ACCESS_LEVEL_DEMO)
        {
            CommonErrors::fatal(COMMONERROR_PERMISSION, $this, 'Sorry, but demo accounts are not allowed to send e-mails.');
        }

        if (isset($_POST['postback']))
        {
            $emailTo = $_POST['emailTo'];
            $emailSubject = $_POST['emailSubject'];
            $emailBody = $_POST['emailBody'];

            $tmpDestination = explode(', ', $emailTo);
            $destination = array();
            foreach($tmpDestination as $emailDest)
            {
                $destination[] = array($emailDest, $emailDest);
            }

            $mailer = new Mailer(CATS_ADMIN_SITE);
            // FIXME: Use sendToOne()?
            $mailerStatus = $mailer->send(
                array($_SESSION['CATS']->getEmail(), $_SESSION['CATS']->getEmail()),
                $destination,
                $emailSubject,
                $emailBody,
                true,
                true
            );

            $this->_template->assign('active', $this);
            $this->_template->assign('success', true);
            $this->_template->assign('success_to', $emailTo);
            $this->_template->display('./modules/candidates/SendEmail.tpl');
        }
        else
        {
            $dataGrid = DataGrid::getFromRequest();

            $candidateIDs = $dataGrid->getExportIDs();

            /* Validate each ID */
            foreach ($candidateIDs as $index => $candidateID)
            {
                if (!$this->isRequiredIDValid($index, $candidateIDs))
                {
                    CommonErrors::fatalModal(COMMONERROR_BADINDEX, $this, 'Invalid candidate ID.');
                    return;
                }
            }

            $db_str = implode(", ", $candidateIDs);

            $db = DatabaseConnection::getInstance();

            $rs = $db->getAllAssoc(sprintf(
                'SELECT candidate_id, email1, email2 '
                . 'FROM candidate '
                . 'WHERE candidate_id IN (%s)',
                $db_str
            ));

            //$this->_template->assign('privledgedUser', $privledgedUser);
            $this->_template->assign('active', $this);
            $this->_template->assign('success', false);
            $this->_template->assign('recipients', $rs);
            $this->_template->display('./modules/candidates/SendEmail.tpl');
        }
    }

    private function onShowQuestionnaire()
    {
        $candidateID = isset($_GET[$id='candidateID']) ? $_GET[$id] : false;
        $title = isset($_GET[$id='questionnaireTitle']) ? urldecode($_GET[$id]) : false;
        $printOption = isset($_GET[$id='print']) ? $_GET[$id] : '';
        $printValue = !strcasecmp($printOption, 'yes') ? true : false;

        if (!$candidateID || !$title)
        {
            CommonErrors::fatal(COMMONERROR_BADINDEX);
        }

        $candidates = new Candidates($this->_siteID);
        $cData = $candidates->get($candidateID);

        $questionnaire = new Questionnaire($this->_siteID);
        $qData = $questionnaire->getCandidateQuestionnaire($candidateID, $title);

        $attachment = new Attachments($this->_siteID);
        $attachments = $attachment->getAll(DATA_ITEM_CANDIDATE, $candidateID);
        if (!empty($attachments))
        {
            $resume = $candidates->getResume($attachments[0]['attachmentID']);
            $this->_template->assign('resumeText', str_replace("\n", "<br \>\n", htmlentities(DatabaseSearch::fulltextDecode($resume['text']))));
            $this->_template->assign('resumeTitle', htmlentities($resume['title']));
        }

        $this->_template->assign('active', $this);
        $this->_template->assign('candidateID', $candidateID);
        $this->_template->assign('title', $title);
        $this->_template->assign('cData', $cData);
        $this->_template->assign('qData', $qData);
        $this->_template->assign('print', $printValue);

        $this->_template->display('./modules/candidates/Questionnaire.tpl');
    }
}

?>
