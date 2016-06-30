<?php
include_once('./lib/Pager.php');
include_once('./lib/EmailTemplates.php');
include_once('./lib/ExtraFields.php');
include_once('./lib/Calendar.php');
include_once('./lib/Contacts.php');

/**
 *	LinkedIn Library
 *	@package    CATS
 *	@subpackage Library
 */
class LinkedIn
{
    private $_db;
    private $_siteID;

    public function __construct($siteID)
    {
        $this->_siteID = $siteID;
        $this->_db = DatabaseConnection::getInstance();
    }
	
	public function checkConnections($arrConnections) {
		for($i=0; $i<count($arrConnections); $i++) {
			// check in contact table
			if (isset($arrConnections[$i]['Last Name']) && !empty($arrConnections[$i]['Last Name'])) {
				$sql = sprintf(
					"SELECT contact_id FROM contact
					WHERE last_name = %s
						AND first_name = %s
						AND site_id = %s",
					$this->_db->makeQueryString($arrConnections[$i]['Last Name']),
					$this->_db->makeQueryString($arrConnections[$i]['First Name']),
					$this->_siteID
				);
				$contact_id = $this->_db->getAssoc($sql);
				$arrConnections[$i]['contact_id'] = $contact_id['contact_id'];
			}
			
			// check in companies table
			if (isset($arrConnections[$i]['Company']) && !empty($arrConnections[$i]['Company'])) {
				$sql = sprintf(
					"SELECT company_id FROM company
					WHERE name = %s
						AND site_id = %s",
					$this->_db->makeQueryString($arrConnections[$i]['Company']),
					$this->_siteID
				);
				$company_id = $this->_db->getAssoc($sql);
				$arrConnections[$i]['company_id'] = $company_id['company_id'];
			}
		}
		return $arrConnections;
	}
}


class LinkedInDataGrid extends DataGrid
{
    protected $_siteID;

	public function __construct($instanceName, $siteID, $parameters, $misc = 0)
    {
        $this->_db = DatabaseConnection::getInstance();
        $this->_siteID = $siteID;
        $this->_assignedCriterion = "";
        $this->_dataItemIDColumn = 'contact_id';
        $this->defaultSortBy = 'contact_id';

        $this->_classColumns = array(
			'In DB' =>     array('select'  => 'contact_id',
                                     'sortableColumn'    => 'contact_id',
                                     'filter'         => 'contact_id'),
			'First_Name' =>     array('select'  => '',
                                     //'sortableColumn'    => 'First_Name',
                                     'filter'         => ''),
			'Last Name' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Suffix' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'E-mail Address' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'E-mail 2 Address' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'E-mail 3 Address' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Street' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Street 2' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Street 3' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business City' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business State' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Postal Code' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Country' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Street' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Street 2' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Street 3' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home City' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home State' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Postal Code' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Country' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Street' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Street 2' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Street 3' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other City' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other State' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Postal Code' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Country' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Company' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Department' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Job Title' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Assistant\'s Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Fax' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Business Phone 2' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Callback' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Car Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Company Main Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Fax' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Home Phone 2' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'ISDN' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Mobile Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Fax' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Phone Pager' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Primary Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Radio Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'TTY/TDD Phone' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Telex' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Assistant\'s Name' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Birthday' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Manager\'s Name' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Notes' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Other Address PO Box' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Spouse' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Web Page' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => ''),
			'Personal Web Page' =>     array('select'  => '',
                                     //'sortableColumn'    => '',
                                     'filter'         => '')
        );
		
        parent::__construct($instanceName, $parameters, $misc);
    }
}
?>