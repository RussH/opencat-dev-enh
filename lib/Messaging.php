<?php
/**
 * CATS
 * Messaging Library
 *
 * Copyright (C) 2005 - 2007 Cognizo Technologies, Inc.
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
 * @package    CATS
 * @subpackage Library
 * @copyright Copyright (C) 2005 - 2007 Cognizo Technologies, Inc.
 * @version    $Id: Messaging.php 3690 2007-11-26 18:07:17Z brian $
 */

include_once('./lib/Pager.php');
include_once('./lib/EmailTemplates.php');
include_once('./lib/ExtraFields.php');
include_once('./lib/Calendar.php');
include_once('./lib/Contacts.php');
include_once('./lib/Candidates.php');
include_once('./lib/Mailer.php');

/**
 *	Messaging Library
 *	@package    CATS
 *	@subpackage Library
 */
class Messaging
{
    private $_db;
    private $_siteID;
	private $_userID;

    public $extraFields;


    public function __construct($siteID)
    {
        $this->_siteID = $siteID;
        $this->_userID = $_SESSION['CATS']->getUserID();
        $this->_db = DatabaseConnection::getInstance();
        $this->extraFields = new ExtraFields($siteID, DATA_ITEM_CONTACT);
    }


    /**
     * Adds a contact to the database and returns its message ID.
     *
     * @param integer user_id
     * @param string modifiedby_id
     * @param string site_id
     * @param string status
     * @param string message
     * @param string subject
     * @param string date_created
     * @param string date_modified
     * @param string date_sent
     */
	public function add($user_id, $modifiedby_id, $site_id, $status, $message,
        $subject, $contact_list, $contact_group, $sendMessage){
		
        $sql = sprintf(
            "INSERT INTO messaging (
				user_id,
				modifiedby_id,
				site_id,
				status,
				message,
				subject,
				date_created,
				date_modified,
				date_sent,
				contact_list,
				contact_group
            )
            VALUES (
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                NOW(),
                NOW(),
                NOW(),
                %s,
                %s
            )",
            $this->_db->makeQueryInteger($user_id),
            $this->_db->makeQueryInteger($modifiedby_id),
            $this->_db->makeQueryInteger($site_id),
            $this->_db->makeQueryInteger($status),
            $this->_db->makeQueryString($message),
            $this->_db->makeQueryString($subject),
            $this->_db->makeQueryString($contact_list),
            $this->_db->makeQueryString($contact_group)
        );
		
        $queryResult = $this->_db->query($sql);
        if (!$queryResult)
        {
            return -1;
        }

        $messageID = $this->_db->getLastInsertID();
		
		if($sendMessage){
			$message = array( 'subject' => $subject,
							'body' => $message,
							'contactlist' => $contact_list,
							'contactgroup' => $contact_group);
							
			$sendStat = $this->messageSend($messageID,$message);

			$queueStatus = $sendStat ? 2 : 5;
			$queueStatus = $contact_list == '' ? 0 : $queueStatus;
			
			$sql = sprintf(
				"UPDATE
					messaging
				SET
					messaging.status    = %s,
					messaging.date_sent    = NOW()
				WHERE
					messaging.id = %s
				AND
					messaging.site_id = %s",
					$this->_db->makeQueryInteger($queueStatus),
					$this->_db->makeQueryInteger($messageID),
					$this->_db->makeQueryInteger($this->_siteID)
				);
			$queueResult = $this->_db->query($sql);		
		}

        $history = new History($this->_siteID);
        $history->storeHistoryNew(DATA_ITEM_MESSAGING, $messageID);

        return $messageID;
    }

    /**
     * Updates a message.
     *
     * @param integer user_id
     * @param string modifiedby_id
     * @param string site_id
     * @param string status
     * @param string message
     * @param string subject
     * @param string date_created
     * @param string date_modified
     * @param string date_sent
     */
    public function update($messageID, $modifiedby_id, $site_id, $status, $message,
        $subject, $date_sent, $contact_list, $contact_group, $sendMessage){

        $sql = sprintf(
            "UPDATE
                messaging
            SET
				messaging.modifiedby_id  = %s,
                messaging.status    = %s,
                messaging.message    = %s,
                messaging.subject     = %s,
                messaging.date_sent    = %s,
                messaging.date_modified = NOW(),
				messaging.contact_list = %s,
				messaging.contact_group = %s
            WHERE
                messaging.id = %s
            AND
                messaging.site_id = %s",
			$this->_db->makeQueryInteger($modifiedby_id),
            $this->_db->makeQueryInteger($status),
            $this->_db->makeQueryString($message),
            $this->_db->makeQueryString($subject),
            $this->_db->makeQueryString($date_sent),
            $this->_db->makeQueryString($contact_list),
            $this->_db->makeQueryString($contact_group),
            $this->_db->makeQueryInteger($messageID),
            $this->_db->makeQueryInteger($site_id)
        );

        $preHistory = $this->get($messageID);
        $queryResult = $this->_db->query($sql);
        $postHistory = $this->get($messageID);
		
		if($sendMessage){
			$message = array( 'subject' => $subject,
							'body' => $message,
							'contactlist' => $contact_list,
							'contactgroup' => $contact_group);
							
			$sendStat = $this->messageSend($messageID,$message);

			$queueStatus = $sendStat ? 2 : 5;
			$queueStatus = $contact_list == '' ? 0 : $queueStatus;
			
			$sql = sprintf(
				"UPDATE
					messaging
				SET
					messaging.status    = %s,
					messaging.date_sent    = NOW()
				WHERE
					messaging.id = %s
				AND
					messaging.site_id = %s",
					$this->_db->makeQueryInteger($queueStatus),
					$this->_db->makeQueryInteger($messageID),
					$this->_db->makeQueryInteger($this->_siteID)
				);
			$queueResult = $this->_db->query($sql);		
		}
		

		
        if (!$queryResult)
        {
            return false;
        }

        $history = new History($this->_siteID);
        $history->storeHistoryChanges(
            DATA_ITEM_MESSAGING, $messageID, $preHistory, $postHistory
        );

        return true;
    }
	
	
	public function messageSend($id,$message){
		$user_id = $this->_userID;
		$mailer = new Mailer($this->_siteID);
		
		$subject = $message['subject'];
		$body = $message['body'];
		$contactgroup = isset($message['contactgroup']) ? explode(',',$message['contactgroup']) : '';
		
		//$contactlist = isset($contactlist) ? explode(',',$contactlist) : '';
		
		$mergeValue = array( 'search' => array('%currentdate%',
												'%sitename%',
												'%currentusername%',
												'%currentemail%',
												'%contactowner%',
												'%contactfirstname%',
												'%contactlastname%',
												'%contactfullname%',
												'%contactcompanyname%',
												'%catsurl%',
												'%currentemailsignature%'),
							'merge' => array('','','','','','','','','','',''));
		$currentdate = date('M d, Y');
		$sitename = $_SESSION['CATS']->getSiteName();
		$currentusername = $_SESSION['CATS']->getUserName();
		$currentemail = $_SESSION['CATS']->getEmail();
		$currentemailsignature = $this->getEmailSignature();
		$catsurl = 'www.clearroad.it';
		
		$failed = array();
		$const = DATA_ITEM_MESSAGING;
		$contact = new Contacts($this->_siteID);
		$candidate = new Candidates($this->_siteID);
		$list = isset($message['contactlist']) ? explode(',',$message['contactlist']) : '';
		
		foreach($list as $val){
			$d = explode( '.' , $val);
			if ($d[0] == '1') {
				// candidate
				$info = $candidate->get($d[1]);
				
				$const = DATA_ITEM_MESSAGING_CANDIDATE;
				$contactid = $info['candidateID'];
				$contactowner = $info['owner'];
				$contactfirstname = $info['firstName'];
				$contactlastname = $info['lastName'];
				$contactfullname = $info['firstName'].' '.$info['lastName'];
				$contactcompanyname = $info['currentEmployer'];
				$contactemail = isset($info['email1']) && $info['email1'] != '' ? $info['email1'] : $info['email2'] ;
			} else if ($d[0] == '2') {
				// contact
				$info = $contact->get($d[1]);
				
				$const = DATA_ITEM_MESSAGING_CONTACT;
				$contactid = $info['contactID'];
				$contactowner = $info['ownerFullName'];
				$contactfirstname = $info['firstName'];
				$contactlastname = $info['lastName'];
				$contactfullname = $info['firstName'].' '.$info['lastName'];
				$contactcompanyname = $info['companyName'];
				$contactemail = isset($info['email1']) && $info['email1'] != '' ? $info['email1'] : $info['email2'] ;
			}
		
			if($contactemail != ''){
				$mergeValue['merge'] = array($currentdate,
											$sitename,
											$currentusername,
											$currentemail,
											$contactowner,
											$contactfirstname,
											$contactlastname,
											$contactfullname,
											$contactcompanyname,
											$catsurl,
											$currentemailsignature);
				$nbody = str_replace($mergeValue['search'],$mergeValue['merge'],$body);
				$mailerStatus = $mailer->sendToOne(array($contactemail, $contactfullname), 
													$subject, 
													$nbody,
													true);
				if($mailerStatus == false){
					$failed[] = $contactemail;
				}
				
				$activityNote = htmlspecialchars(strip_tags($body));
			
				/* Add the activity entry. */
				$activityEntries = new ActivityEntries($this->_siteID);
				$activityID = $activityEntries->add(
					$contactid,
					$const,
					$activityTypeID,
					$activityNote,
					$this->_userID,
					$regardingID
				);
				$activityTypes = $activityEntries->getTypes();
				$activityTypeDescription = ResultSetUtility::getColumnValueByIDValue(
					$activityTypes, 'typeID', $activityTypeID, 'type'
				);
				
				/* Add activity message */
				$activityEntries->addActivityMessage($activityID, $id);
			} else {
				$failed[] = $val['id'].'-'.$contactemail;
			}
		}
		
		if(!empty($failed)){
			return false;
		} else {			
			return true;
		}
	}
	
	public function getEmailSignature(){
		$user_id = $this->_userID;
		$sql = sprintf("SELECT content
					FROM 
						template
					WHERE
						status < 2
					AND
						user_id = %s
					AND
						site_id = %s
					AND 
						emailsignature = 1
					ORDER BY 
						id DESC
					LIMIT 0, 1",
					$this->_db->makeQueryInteger($user_id),
					$this->_db->makeQueryInteger($this->_siteID)
				);
		$queryResult = $this->_db->getColumn($sql,0,0);
		return $queryResult;
	}
	
	public function updateTemplate($template){

		if(isset($template['signature']) && $template['signature'] == 1) $this->resetTemplateSignature();

		$user_id = $this->_userID;
		$sql = sprintf("UPDATE
					template
				SET
					title = %s,
					content = %s,
					date_modified = NOW(),
					modifiedby_id = %s,
					status = %s,
					shared_list = %s,
					shared_group = %s,
					emailsignature = %s
				WHERE
					id = %s
				AND
					user_id = %s
				AND
					site_id = %s",
				$this->_db->makeQueryString($template['title']),
				$this->_db->makeQueryString($template['content']),
				$this->_db->makeQueryInteger($user_id),
				$this->_db->makeQueryInteger($template['status']),
				$this->_db->makeQueryString($template['sharedlist']),
				$this->_db->makeQueryString($template['sharedgroup']),
				$this->_db->makeQueryInteger($template['signature']),
				$this->_db->makeQueryInteger($template['id']),
				$this->_db->makeQueryInteger($user_id),
				$this->_db->makeQueryInteger($this->_siteID)
			);

        $preHistory = $this->get($template['id']);
        $queryResult = $this->_db->query($sql);
        $postHistory = $this->get($template['id']);

        if (!$queryResult)
        {
            return false;
        }

        $history = new History($this->_siteID);
        $history->storeHistoryChanges(
            DATA_ITEM_TEMPLATE, $messageID, $preHistory, $postHistory
        );

        return true;
	}

	public function addTemplate($template){

		if(isset($template['signature']) && $template['signature'] == 1) $this->resetTemplateSignature();
		
		$user_id = $this->_userID;
		$sql = sprintf("INSERT INTO
				template (
					user_id,
					modifiedby_id,
					title,
					content,
					date_created,
					date_modified,
					status,
					shared_list,
					shared_group,
					emailsignature,
					site_id
				) VALUES (
					%s,
					%s,
					%s,
					%s,
					NOW(),
					NOW(),
					%s,
					%s,
					%s,
					%s,
					%s
				)",
			$this->_db->makeQueryInteger($user_id),
			$this->_db->makeQueryInteger($user_id),
			$this->_db->makeQueryString($template['title']),
			$this->_db->makeQueryString($template['content']),
			$this->_db->makeQueryInteger($template['status']),
			$this->_db->makeQueryString($template['sharedlist']),
			$this->_db->makeQueryString($template['sharedgroup']),
			$this->_db->makeQueryInteger($template['signature']),
			$this->_db->makeQueryInteger($this->_siteID) 
		);
		$queryResult = $this->_db->query($sql);

        if (!$queryResult)
        {
            return -1;
        }

        $templateID = $this->_db->getLastInsertID();

        $history = new History($this->_siteID);
        $history->storeHistoryNew(DATA_ITEM_TEMPLATE, $templateID);

        return $templateID;
	}

	private function resetTemplateSignature(){
		$user_id = $this->_userID;
		$sql = sprintf("UPDATE
					template
				SET
					emailsignature = 0
				WHERE
					user_id = %s
				AND
					site_id = %s",
				$this->_db->makeQueryInteger($user_id),
				$this->_db->makeQueryInteger($this->_siteID)
			);
		$queryResult = $this->_db->query($sql);
	}
	
    public function deleteTemplate($templateID)
    {
		$userID = $this->_userID;
        $sql = sprintf(
            "DELETE FROM
                template
            WHERE
                id = %s
            AND
                user_id = %s
            AND
                site_id = %s",
            $this->_db->makeQueryInteger($templateID),
            $this->_db->makeQueryInteger($userID),
            $this->_db->makeQueryInteger($this->_siteID)
        );
        $this->_db->query($sql);

        // $history = new History($this->_siteID);
        // $history->storeHistoryDeleted(DATA_ITEM_TEMPLATE, $templateID);
    }
	
    public function deleteTemplates($templateIDs)
    {
		$userID = $this->_userID;
        $sql = sprintf(
				"DELETE FROM
					template
				WHERE
					id IN ( %s )
				AND
					user_id = %s
				AND
					site_id = %s",
				$templateIDs,
				$this->_db->makeQueryInteger($userID),
				$this->_db->makeQueryInteger($this->_siteID)
			);
        $this->_db->query($sql);

        // $history = new History($this->_siteID);
        // $history->storeHistoryDeleted(DATA_ITEM_TEMPLATE, $templateIDs);
    }

    public function delete($messageID)
    {
        $sql = sprintf(
            "DELETE FROM
                messaging
            WHERE
                id = %s
            AND
                user_id = %s
            AND
                site_id = %s",
            $this->_db->makeQueryInteger($messageID),
            $this->_db->makeQueryInteger($userID),
            $this->_siteID
        );
        $this->_db->query($sql);

        $history = new History($this->_siteID);
        $history->storeHistoryDeleted(DATA_ITEM_MESSAGING, $messageID);
    }
	
    public function deleteIDs($messageIDs)
    {
		/*$sql = sprintf(
            "DELETE FROM
                messaging
            WHERE
                id IN ( %s )
            AND
                user_id = %s
            AND
                site_id = %s",
            $this->_db->makeQueryInteger($messageIDs),
            $this->_db->makeQueryInteger($userID),
			$this->_db->makeQueryInteger($this->_siteID)
        );*/

		$sql = sprintf(
			"UPDATE
				messaging
			SET
				messaging.status  = 3
			WHERE
				messaging.id IN (%s)
			AND
				messaging.site_id = %s",
				$messageIDs,
				$this->_db->makeQueryInteger($this->_siteID)
			);
		echo $sql;
		$queueResult = $this->_db->query($sql);		
    }
    
    public function getCount($userID)
    {
        $sql = sprintf(
            "SELECT
                COUNT(*) AS totalMessages
            FROM
                messaging
            WHERE
                messaging.site_id = %s AND
				messaging.user_id = %s",
            $this->_siteID,
			$userID
        );

        return $this->_db->getColumn($sql, 0, 0);
    }

    public function getTemplateCount()
    {
		$userID = $this->_userID;
        $sql = sprintf(
            "SELECT
                COUNT(*) AS totalTemplates
            FROM
                template
            WHERE
                site_id = %s AND
				user_id = %s",
            $this->_siteID,
			$userID
        );

        return $this->_db->getColumn($sql, 0, 0);
    }

    public function get($messageID)
    {
        $sql = sprintf(
            "SELECT
                messaging.id AS messagingID,
                messaging.user_id AS ownerID,
				user.user_name AS owner_user_name,
                messaging.modifiedby_id AS modifiedByID,
				user_modif.user_name AS modified_user_name,
                messaging.site_id AS siteID,
                messaging.message AS message,
                messaging.subject AS subject,
                messaging.status AS status,
				messaging.contact_list AS contact_list,
				messaging.contact_group AS contact_group,
                DATE_FORMAT(
                    messaging.date_created, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateCreated,
                DATE_FORMAT(
                    messaging.date_modified, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateModified,
                DATE_FORMAT(
                    messaging.date_sent, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateSent
            FROM
                messaging, user, user as user_modif
            WHERE
				messaging.user_id = user.user_id
			AND
				messaging.modifiedby_id = user_modif.user_id
			AND
                messaging.id = %s
            AND
                messaging.site_id = %s",
            $this->_db->makeQueryInteger($messageID),
            $this->_siteID
        );

        return $this->_db->getAssoc($sql);
    }
	
	public function getTemplate($templateID)
    {
		$userID = $this->_userID;
        $sql = sprintf(
            "SELECT
                id AS templateID,
                user_id AS ownerID,
                modifiedby_id AS modifiedByID,
                site_id AS siteID,
                title AS title,
                content AS content,
                emailsignature AS emailSignature,
                shared_list AS sharedList,
                shared_group AS sharedGroup,
                status AS status,
                DATE_FORMAT(
                    date_created, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateCreated,
                DATE_FORMAT(
                    date_modified, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateModified
            FROM
                template
            WHERE
                id = %s
            AND
                user_id = %s
            AND
                site_id = %s",
            $this->_db->makeQueryInteger($templateID),
            $this->_db->makeQueryInteger($userID),
            $this->_siteID
        );

        return $this->_db->getAssoc($sql);
    }

	public function getAllTemplate()
    {
		$userID = $this->_userID;
        $sql = sprintf(
            "SELECT
                id AS templateID,
                user_id AS ownerID,
                modifiedby_id AS modifiedByID,
                site_id AS siteID,
                title AS title,
                content AS content,
                emailsignature AS emailSignature,
                shared_list AS sharedList,
                shared_group AS sharedGroup,
                status AS status,
                DATE_FORMAT(
                    date_created, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateCreated,
                DATE_FORMAT(
                    date_modified, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateModified
            FROM
                template
            WHERE
                user_id = %s
			AND
				status IN (0,1)
            AND
                site_id = %s",
            $this->_db->makeQueryInteger($userID),
            $this->_siteID
        );

        return $this->_db->getAllAssoc($sql);
    }

    public function getForEditing($messageID)
    {
        $sql = sprintf(
            "SELECT
                messaging.id AS messagingID,
                messaging.user_id AS ownerID,
                messaging.modifiedby_id AS modifiedByID,
                messaging.site_id AS siteID,
                messaging.message AS message,
                messaging.subject AS subject,
                messaging.status AS status,
				messaging.contact_list AS contact_list,
				messaging.contact_group AS contact_group,
                DATE_FORMAT(
                    messaging.date_created, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateCreated,
                DATE_FORMAT(
                    messaging.date_modified, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateModified,
                DATE_FORMAT(
                    messaging.date_sent, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateSent
            FROM
                messaging
            WHERE
                messaging.id = %s
            AND
                messaging.site_id = %s",
            $this->_db->makeQueryInteger($messageID),
            $this->_siteID
        );

        return $this->_db->getAssoc($sql);
    }

    public function getAll($userID = -1)
    {
        if ($userID >= 0)
        {
            $userCriterion = sprintf(
                'AND messaging.user_id = %s ', $userID );
        }
        else
        {
            $userCriterion = '';
        }

        $sql = sprintf(
            "SELECT
                messaging.id AS messagingID,
                messaging.user_id AS ownerID,
                messaging.modifiedby_id AS modifiedByID,
                messaging.site_id AS siteID,
                messaging.message AS message,
                messaging.subject AS subject,
                messaging.status AS status,
                DATE_FORMAT(
                    messaging.date_created, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateCreated,
                DATE_FORMAT(
                    messaging.date_modified, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateModified,
                DATE_FORMAT(
                    messaging.date_sent, '%%M %%d, %%Y (%%h:%%i %%p)'
                ) AS dateSent
            FROM
                messaging
            WHERE
                messaging.site_id = %s 
            %s
            ORDER BY
                messaging.id DESC",
            $this->_siteID,
            $userCriterion
        );

        return $this->_db->getAllAssoc($sql);
    }
	
	public function getEmailListing($userID = -1)
    {
		$cond = sprintf("
					site_id = %s
				AND 
					(NOT email1 = '' OR NOT email2 = '')
				",
				$this->_db->makeQueryInteger($this->_siteID)
			);
		
        if ($userID >= 0)
        {
            $userCriterion = sprintf(
                ' AND owner = %s ', 
				$this->_db->makeQueryInteger($userID)
			);
        }
        else
        {
            $userCriterion = '';
        }
		
		$cond .= $userCriterion;
		
		$alphaCriterion = " AND first_name LIKE 'a%'";
		
		if(isset($_GET['alpha']) && strlen($_GET['alpha'])){
			$alphaCriterion = " AND first_name LIKE '".strtolower(substr($_GET['alpha'],0,1))."%' ";
		}
		
		$cond .= $alphaCriterion;
		
		$page = isset($_GET['page']) && strlen($_GET['page']) ? (int)$_GET['page'] : 1;
		$page = $page * 50;
        $sql = sprintf(
			"SELECT *
			FROM (
					(
						SELECT first_name AS fname, last_name AS lname, email1 AS email1, email2 AS 
							email2, candidate_id AS id, 'candidate' AS dtype 
						FROM `candidate`
						WHERE 
							%s
					)
					UNION (
						SELECT first_name AS fname, last_name AS lname, email1 AS email1, email2 AS 
							email2, contact_id AS id, 'contact' AS dtype 
						FROM `contact`
						WHERE 
							%s
					)
				) AS cons 
			ORDER BY fname ASC, lname ASC
			LIMIT %s, 50",
			$cond,
			$cond,
			$this->_db->makeQueryInteger($page)
        );
		$data = $this->_db->getAllAssoc($sql);
		$total = $this->getSQLCount($sql);
        return array('total' => $total, 'data'=> $data);
    }
	
	public function getSQLCount($sql){
		$offset = strpos($sql,'FROM');
		$from = substr($sql,$offset);
		$offset2 = strpos($from,'LIMIT');
		$sqlStr = "SELECT COUNT(*) AS total ".substr($from,0,$offset2);
		return $this->_db->getColumn($sqlStr, 0, 0);
	}
	
	public function search($search, $flag){
		$subjectStr = '';
		$contactStr = '';

		if($flag['subject'] == true || $flag['subject'] == 1){
			$subjectStr = sprintf(
				" OR subject LIKE %s ",
				$this->_db->makeQueryString("%".$search."%")
			);
		}
		/*
		if($flag['contact'] == true || $flag['contact'] == 1){
			$contactStr = sprintf(
				" OR  (
						SELECT 
							COUNT(*) AS total
						FROM
							contact
						WHERE
							FIND_IN_SET( contact_id, messaging.contact_list )
						AND 
							(
							first_name LIKE %s 
							OR 
							last_name LIKE %s
							)
						) > 0",
				$this->_db->makeQueryString("%".$search."%"),
				$this->_db->makeQueryString("%".$search."%")
				);
		}*/
		
		$sql = sprintf("
			SELECT 
				id AS id,
				contact_list AS contact_list,
				subject AS subject,
				message AS message
			FROM messaging
			WHERE
				site_id = %s
			AND
				( message LIKE %s
			%s
			%s			
			)
			ORDER BY messaging.id DESC
			",
			// $contactValueStr,
			//$this->_db->makeQueryInteger($this->_userID),
			$this->_db->makeQueryInteger($this->_siteID),
			$this->_db->makeQueryString("%".$search."%"),
			$subjectStr,
			$contactStr
			);
		$data = $this->_db->getAllAssoc($sql);
		$total = $this->getSQLCount($sql);
        return array('total' => $total, 'data'=> $data, 'sql' => $sql);
	}
	
	public function getEmailListinginList($userID = -1,$list)
    {
        $userCriterion = '';
        
		if ($userID >= 0)
        {
            $userCriterion = sprintf(
                'AND owner = %s', $userID, $userID
            );
        }
		
		$candidates = '';
		$contacts = '';
		if($list != ''){		
			$nlist = explode(',', $list);
			foreach($nlist as $r) {
				$d = explode('.', $r);
				if($d[0] == 1) {
					// candidate
					$candidates .= $d[1].',';
				} else if($d[0] == 2) {
					// contact
					$contacts .= $d[1].',';
				}
			}
			$candidates = rtrim($candidates,',');
			$contacts = rtrim($contacts,',');
		}
		
		$newlist = array();
		if ($candidates != '') {
			$listCriterion = " AND candidate.candidate_id IN ( $candidates )";
			
			$sql = sprintf(
				"SELECT
					CONCAT('1.', candidate.candidate_id) AS ID,
					candidate.last_name AS lastName,
					candidate.first_name AS firstName,                
					candidate.email1 AS email1,
					candidate.email2 AS email2 
				FROM
					candidate            
				WHERE			    
					candidate.site_id = %s
				%s
				%s
				ORDER BY
					candidate.first_name ASC,
					candidate.last_name ASC
				",
				$this->_siteID,
				$userCriterion,
				$listCriterion
			);
			
			$newlist = $this->_db->getAllAssoc($sql);
		}
		if ($contacts != '') {
			$listCriterion = " AND contact.contact_id IN ( $contacts )";
			
			$sql2 = sprintf(
				"SELECT
					CONCAT('1.', contact.contact_id) AS ID,
					contact.last_name AS lastName,
					contact.first_name AS firstName,                
					contact.email1 AS email1,
					contact.email2 AS email2 
				FROM
					contact            
				WHERE			    
					contact.site_id = %s
				%s
				%s
				ORDER BY
					contact.first_name ASC,
					contact.last_name ASC
				",
				$this->_siteID,
				$userCriterion,
				$listCriterion
			);			
			$newlist = array_merge($newlist, $this->_db->getAllAssoc($sql2));
		}
		return $newlist;
    }

    /**
     * Returns all upcoming calendar events for given contact.
     * see Calendar::getUpcomingEvents.
     *
     * @return array calendar events
     */
    public function getUpcomingEvents($messageID)
    {
        $calendar = new Calendar($this->_siteID);
        return $calendar->getUpcomingEventsByDataItem(
            DATA_ITEM_CONTACT, $messageID
        );
    }

    /**
     * Updates a contact's modified timestamp.
     *
     * @param integer contact ID
     * @return boolean True if successful; false otherwise.
     */
    public function updateModified($messageID)
    {
        $sql = sprintf(
            "UPDATE
                contact
            SET
                date_modified = NOW()
            WHERE
                contact_id = %s
            AND
                site_id = %s",
            $this->_db->makeQueryInteger($messageID),
            $this->_siteID
        );

        return (boolean) $this->_db->query($sql);
    }

    /**
     * Returns an array of job orders data (jobOrderID, title, companyName)
     * for the specified contact ID.
     *
     * @param integer contact ID
     * @return array job orders data
     */
    public function getJobOrdersArray($messageID)
    {
        $sql = sprintf(
            "SELECT
                joborder.joborder_id AS jobOrderID,
                joborder.title AS title,
                company.name AS companyName,
                IF(joborder.contact_id = %s, 1, 0) AS isAssigned
            FROM
                joborder
            LEFT JOIN company
                ON joborder.company_id = company.company_id
            LEFT JOIN contact
                ON company.company_id = contact.company_id
            WHERE
                contact.contact_id = %s
            AND
                joborder.site_id = %s
            ORDER BY
                isAssigned DESC,
                title ASC",
            $this->_db->makeQueryInteger($messageID),
            $this->_db->makeQueryInteger($messageID),
            $this->_siteID
        );

        return $this->_db->getAllAssoc($sql);
     }

    /**
     * Returns the entire contacts list.
     *
     * @return array contacts data
     */
    public function getColdCallList($userID = -1, $companyID = -1)
    {
        if ($userID >= 0)
        {
            $userCriterion = sprintf(
                "AND contact.owner = %s", $userID, $userID
            );
        }
        else
        {
            $userCriterion = '';
        }

        if ($companyID >= 0)
        {
            $companyCriterion = sprintf(
                "AND company.company_id = %s", $companyID
            );
        }
        else
        {
            $companyCriterion = '';
        }

        $sql = sprintf(
            "SELECT
                contact.contact_id AS contactID,
                contact.company_id AS companyID,
                contact.last_name AS lastName,
                contact.first_name AS firstName,
                contact.title AS title,
                contact.phone_work AS phoneWork,
                company.name AS companyName
            FROM
                contact
            LEFT JOIN company
                ON contact.company_id = company.company_id
            WHERE
                contact.phone_work != ''
            AND
                contact.phone_work IS NOT NULL
            AND
                contact.site_id = %s
            AND
                company.site_id = %s
            %s
            %s
            ORDER BY
                company.name ASC,
                contact.first_name ASC,
                contact.last_name ASC",
            $this->_siteID,
            $this->_siteID,
            $userCriterion,
            $companyCriterion
        );

        return $this->_db->getAllAssoc($sql);
    }


    /**
     * Returns department ID for the given company by department name.
     * FIXME:  Shouldn't this be in companies?
     * FIXME:  Why are we passing a database handle in?
     *
     * @param string department name
     * @param integer company ID
     * @param handle database handle
     * @return integer department ID
     */
    public function getDepartmentIDByName($departmentName, $companyID, $db)
    {
        /* (none) always has an ID of 0. */
        if ($departmentName === '(none)')
        {
            return 0;
        }

        $sql = sprintf(
            "SELECT
                company_department_id AS departmentID
             FROM
                company_department
             WHERE
                name = %s
             AND
                company_id = %s
             AND
                site_id = %s",
             $this->_db->makeQueryString($departmentName),
             $companyID,
             $this->_siteID
        );
        $rs = $db->getAssoc($sql);

        if (empty($rs))
        {
            return 0;
        }

        return $rs['departmentID'];
    }
}


class MessagingDataGrid extends DataGrid
{
    protected $_siteID;


    // FIXME: Fix ugly indenting - ~400 character lines = bad.
    public function __construct($instanceName, $siteID, $parameters, $misc = 0)
    {
        $this->_db = DatabaseConnection::getInstance();
        $this->_siteID = $siteID;
        $this->_assignedCriterion = "";
        $this->_dataItemIDColumn = 'messaging.id';
        $this->_classColumns = array(

            'ID' =>         array('select'      => 'messaging.id AS ID',
                                     'filter'     => 'messaging.id',
                                     'pagerWidth'    => 10,
                                     'alphaNavigation' => false,
                                     'pagerOptional'  => false),

            'Subject' =>         array('select'      => 'messaging.subject AS subject',
                                     'filter'     => 'messaging.subject',
                                     'sortableColumn'     => 'subjectSort',
                                     'pagerRender'     => 'return \'<a href="'.CATSUtility::getIndexName().'?m=messaging&amp;a=show&amp;messageID=\'.$rsData[\'messagingID\'].\'">\'.htmlspecialchars($rsData[\'subject\']).\'</a>\';',
                                     'pagerWidth'    => 200,
                                     'alphaNavigation' => true,
                                     'pagerOptional'  => true),

			'Message' =>         array('select'      => 'messaging.message AS message',
                                     'filter'     => 'messaging.message',
                                     'pagerRender'      => 'return substr(strip_tags($rsData[\'message\']),0,50)."..";',
                                     'sortableColumn'     => 'messageSort',
                                     'pagerWidth'    => 200,
                                     'alphaNavigation' => true,
                                     'pagerOptional'  => true),

			'Status' =>         array('select'      => '',
                                     'filter'     => 'messaging.status',
                                     'sortableColumn'     => 'statusSort',
                                     'pagerRender'     => '$statusText = array( 0 => \'Draft\', 1 => \'On Queue\', 2 => \'Sent\', 3 => \'Sent but Deleted\', 4 => \'Draft but Deleted\', 5 => \'Failed\'); return $statusText[$rsData[\'statusSort\']];',
                                     'pagerWidth'    => 200,
                                     'alphaNavigation' => true,
                                     'pagerOptional'  => true),

            'Created' =>       array('select'   => 'DATE_FORMAT(messaging.date_created, \'%M %d, %Y\') AS dateCreated',
                                     'pagerRender'      => 'return $rsData[\'dateCreated\'];',
                                     'sortableColumn'     => 'dateCreatedSort',
                                     'pagerWidth'    => 100,
                                     'filterHaving' => 'DATE_FORMAT(messaging.date_created, \'%M %d, %Y\')'),

            'Modified' =>      array('select'   => 'DATE_FORMAT(messaging.date_modified, \'%M %d, %Y\') AS dateModified',
                                     'pagerRender'      => 'return $rsData[\'dateModified\'];',
                                     'sortableColumn'     => 'dateModifiedSort',
                                     'pagerWidth'    => 100,
                                     'pagerOptional' => true,
                                     'filterHaving' => 'DATE_FORMAT(messaging.date_modified, \'%M %d, %Y\')'),

            'Sent' =>      array('select'   => 'DATE_FORMAT(messaging.date_sent, \'%M %d, %Y\') AS dateSent',
                                     'pagerRender'      => 'return $rsData[\'dateSent\'];',
                                     'sortableColumn'     => 'dateSentSort',
                                     'pagerWidth'    => 100,
                                     'pagerOptional' => true,
                                     'filterHaving' => 'DATE_FORMAT(messaging.date_sent, \'%M %d, %Y\')'),

            'Modified By' =>       array('select'   => 'user.first_name AS ownerFirstName,' .
                                                   'user.last_name AS ownerLastName,' .
                                                   'CONCAT(user.last_name,\', \', user.first_name) AS modifiedBySort',
                                     'join'     => 'LEFT JOIN user AS user ON messaging.modifiedby_id = user.user_id',
                                     // 'filter'    => 'messaging.modifiedby_id',
                                     'sortableColumn'     => 'modifiedBySort',
                                     'pagerWidth'    => 100,
                                     'pagerOptional' => true,
                                     'filterable' => true,
                                     'filterDescription' => 'Modified'),
									 
            'OwnerID' =>       array('select'   => 'user.first_name AS ownerFirstName,' .
                                                   'user.last_name AS ownerLastName,' .
                                                   'CONCAT(user.last_name, user.first_name) AS ownerSort',
                                     'join'     => 'LEFT JOIN user AS user ON messaging.user_id = user.user_id',
                                     'pagerWidth'    => 100,
                                     'pagerOptional' => false,
                                     'filterable' => false,
                                     'filterDescription' => 'Owner')
        );

        /* Extra fields get added as columns here. */
        $messages = new Messaging($this->_siteID);
        $extraFieldsRS = $messages->extraFields->getSettings();
        foreach ($extraFieldsRS as $index => $data)
        {
            $fieldName = $data['fieldName'];

            if (!isset($this->_classColumns[$fieldName]))
            {
                $columnDefinition = $messages->extraFields->getDataGridDefinition($index, $data, $this->_db);

                /* Return false for extra fields that should not be columns. */
                if ($columnDefinition !== false)
                {
                    $this->_classColumns[$fieldName] = $columnDefinition;
                }
            }
        }

        parent::__construct($instanceName, $parameters, $misc);
    }

    /**
     * Returns the sql statment for the pager.
     *
     * @return array clients data
     */
    public function getSQL($selectSQL, $joinSQL, $whereSQL, $havingSQL, $orderSQL, $limitSQL, $distinct = '')
    {
		$statSQL = ' AND ( status = 1 OR status = 2 OR status = 5 ) ';
		if(isset($_GET['stat'])){
			$statVal = $_GET['stat'];
			if($statVal == 0){
				$statSQL = ' AND status = 0 ';
			// } elseif ($statVal == 1){
				// $statSQL = ' AND ( status = 1 OR status = 2 OR status = 5 ) ';
			} elseif ($statVal < 0){
				$statSQL = ' AND ( status = 3 OR status = 4 ) ';
			}
		}
		
        $sql = sprintf(
            "SELECT SQL_CALC_FOUND_ROWS %s
                messaging.id AS messagingID,
                messaging.id AS exportID,
                messaging.date_modified AS dateModifiedSort,
                messaging.date_created AS dateCreatedSort,
                messaging.date_sent AS dateSentSort,
                messaging.subject AS subjectSort,
                messaging.message AS messageSort,
                messaging.status AS statusSort,
                messaging.user_id AS ownerSort,
                messaging.modifiedby_id AS modifiedBySort,
            %s
            FROM
                messaging
			%s
            WHERE
                messaging.site_id = %s
            %s
			%s
            GROUP BY messaging.id
            %s
            %s",
            $distinct,
            $selectSQL,
			$joinSQL,
            $this->_siteID,
            (strlen($whereSQL) > 0) ? ' AND ' . $whereSQL : '',
			$statSQL,
            $orderSQL,
            $limitSQL
        );

        return $sql;
    }
}

?>
