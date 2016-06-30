<?php
/**
 * CATS
 * Specialization Library
 *
 * Copyright (C) 2012 Clear Road IT
 *
 * @package    CATS
 * @subpackage Library
 * @copyright Copyright (C) 2012 Clear Road IT
 * @version    $Id: Specialization.php 3829 2012-2-15 21:17:46Z allan $
 */

define('SPECIALIZATION_ROLE', 1);
define('SPECIALIZATION_SKILLS', 2);

include_once('./lib/Pipelines.php');
include_once('./lib/History.php');
include_once('./lib/Candidates.php');
include_once('./lib/ExtraFields.php');
include_once('lib/DataGrid.php');


/**
 *	Specialization Library
 *	@package    CATS
 *	@subpackage Library
 */
class Specialization
{
    public $_db;
    public $_siteID;

    public function __construct($siteID)
    {
        $this->_siteID = $siteID;
        $this->_db = DatabaseConnection::getInstance();
        $this->extraFields = new ExtraFields($siteID, DATA_ITEM_CONTACT);
    }
	
	//update candidate skills with keywords
	public function update($candidateID, $skill_values, $skillyear_values, $skillprof_values) {
		
		$pskill_values		= str_replace("&spc;", ",", $skill_values);
		$pskillyear_values	= str_replace("&spc;", ",", $skillyear_values);
		$pskillprof_values	= str_replace("&spc;", ",", $skillprof_values);
		
		$candidate			= new Candidates($this->_siteID);
		$result				= $candidate->update_skills($candidateID, $pskill_values, $pskillyear_values, $pskillprof_values);
		
		return true;
	}
	
	//delete candidate skills
	public function delete($candidateID) {
		
	}

	public function delete_entry($data=null) {
		if(!empty($data)) {
			$idList = implode(',',$data);
			$sql = sprintf(
				"DELETE FROM specializations 
				WHERE specializations.id IN (%s)",
				$idList
			 );
			$this->_db->query($sql);
			$sql = sprintf(
				"DELETE FROM roles 
				WHERE roles.specialization_id IN (%s)",
				$idList
			 );
			$this->_db->query($sql);
		}
	}

	public function view_entry($data=array()) {
		$where = isset($data['where']) ? $data['where'] : '';
		$order = isset($data['order']) ? $data['order'] : ' ORDER BY ID ASC';
		$limit = isset($data['limit']) ? $data['limit'] : ' LIMIT 20';
		
		$sql = sprintf("SELECT *
				FROM specializations 
				%s
				%s
				%s",
				$where,
				$order,
				$limit);
		
		return $this->_db->getAllAssoc($sql);
	}

	public function update_entry($data=array()) {
		
	}
	
	//update the keywords master list
	public function update_keywords_master_list($keywords) {
		
	}
    
	//fetches the current candidate skills from the current candidate record
	public function get_skills($candidateID) {
		$candidate			= new Candidates($this->_siteID);
		$candidate_record	= $candidate->get($candidateID);
		
		$skill_texts	= ($candidate_record["skill_texts"]."");
		$skill_years	= ($candidate_record["skill_years"]."");
		$skill_profs	= ($candidate_record["skill_profs"]."");
		
		$result = array("skill_texts"	=> $skill_texts,
		                "skill_years"	=> $skill_years,
						"skill_profs"	=> $skill_profs); 
						
		return $result;
	}
	
	public function get_specializations($keyword) {
		$sql = sprintf(
            "SELECT DISTINCT                 
				master_keyword 
             FROM
                specializations 
             WHERE
                LOWER(specializations.keyword) like %s
            ",
            $this->_db->makeQueryString($keyword.'%') 
        );
		//die($sql);
        $rs = $this->_db->getAllAssoc($sql);
		//print_r($rs);
		//die($sql);
		foreach ($rs as $rowIndex => $row) {
			echo $row["master_keyword"]."|".$row["master_keyword"]."\n";	
		}
	}
	
	public function master_keyword_exists($keyword) {
		$result = false;
		$sql = sprintf(
            "SELECT count(master_keyword) as total_count 
             FROM
                specializations 
             WHERE
                LOWER(specializations.keyword) = %s
            ",
            $this->_db->makeQueryString(strtolower($keyword)) 
        );
        $rs = $this->_db->getAllAssoc($sql);
		foreach($rs as $rowindex => $row) {
			$num_records = intval($row["total_count"]);
		}
		if($num_records > 0) $result = true;
		
		return $result;	
	}
	
	public function add_specialization_keyword($keyword) {
		if($this->master_keyword_exists($keyword)==false) {
			$sql = sprintf(
				"INSERT INTO specializations (
					keyword,
					master_keyword
				)
				VALUES (
					%s,
					%s                
				)",
				$this->_db->makeQueryString($keyword),
				$this->_db->makeQueryString($keyword)
			 );
			 $this->_db->query($sql);
		}
	}
	
	public function addnew_specialization_keyword($keyword,$roles) {
		if($this->master_keyword_exists($keyword)==false) {
			$sql = sprintf(
				"INSERT INTO specializations (
					keyword,
					master_keyword
				)
				VALUES (
					%s,
					%s                
				)",
				$this->_db->makeQueryString($keyword),
				$this->_db->makeQueryString($keyword)
			 );
			$this->_db->query($sql);
			$specialization_id = $this->_db->getLastInsertID();
			$sql = sprintf(
				"INSERT INTO roles (
					data,
					specialization_id
				)
				VALUES (
					%s,
					%s                
				)",
				$this->_db->makeQueryString($roles),
				$this->_db->makeQueryInteger($specialization_id)
			);
			$this->_db->query($sql);
		}
	}
	
	public function roles_exists($id) {
		$result = false;
		$sql = sprintf(
            "SELECT count(role_id) as total_count 
             FROM
                roles 
             WHERE
                specialization_id = %s
            ",
            $this->_db->makeQueryInteger($id) 
        );
        $rs = $this->_db->getAllAssoc($sql);
		foreach($rs as $rowindex => $row) {
			$num_records = intval($row["total_count"]);
		}
		if($num_records > 0) $result = true;
		
		return $result;	
	}

	public function update_specialization_keyword($keyword,$roles,$id = false) {
		// if($this->master_keyword_exists($keyword)==false) {
			$sql = sprintf(
				"UPDATE specializations SET
					keyword = %s,
					master_keyword = %s
				WHERE
					id = %s",
				$this->_db->makeQueryString($keyword),
				$this->_db->makeQueryString($keyword),
				$this->_db->makeQueryInteger($id)
			);
			$this->_db->query($sql);
			
			if($this->roles_exists($id)){
				$sql = sprintf(
					"UPDATE roles SET
						data = %s
					WHERE
						specialization_id = %s",
					$this->_db->makeQueryString($roles),
					$this->_db->makeQueryInteger($id)
				 );
			 } else {
				$sql = sprintf(
					"INSERT INTO roles (
						data,
						specialization_id
					)
					VALUES (
						%s,
						%s                
					)",
					$this->_db->makeQueryString($roles),
					$this->_db->makeQueryInteger($id)
				 );
			 }
			 $this->_db->query($sql);
			 
		// }
	}
	
	
    /**
     * Returns the number of specialization in the system.
     * @return integer Number of Specializations in site.
     */
    public function getCount()
    {
        $sql = "SELECT
					COUNT(*) AS totalContacts
				FROM
					specializations";
        return $this->_db->getColumn($sql, 0, 0);
    }	
	
}

class SpecializationDataGrid extends DataGrid
{
    protected $_siteID;

    public function __construct($instanceName, $siteID, $parameters, $misc = 0)
    {
        $this->_db = DatabaseConnection::getInstance();
        $this->_siteID = $siteID;
        $this->_assignedCriterion = "";
        $this->_dataItemIDColumn = 'specializations.id';

        $this->_classColumns = array(
            'Keyword' =>         array('select'   => 'specializations.keyword AS keyword',
                                     'sortableColumn'     => 'keyword',
                                     'pagerRender'    => 'return \'<a href="'.CATSUtility::getIndexName().'?m=specialization&amp;a=update&amp;id=\'.$rsData[\'id\'].\'">\'.htmlspecialchars($rsData[\'keyword\']).\'</a>\';',
                                     'pagerWidth'    => 200,
                                     'filter'         => 'specializations.keyword'),

            'Master Keyword' =>     array('select'   => 'specializations.master_keyword AS master_keyword',
                                     'sortableColumn'     => 'master_keyword',
                                     'pagerWidth'    => 200,
                                     'filter'         => 'specializations.master_keyword'),
									 
            'Roles' =>  array('select'  => 'roles.data AS roles_data',
                                     'join'     => 'LEFT JOIN roles ON roles.specialization_id = specializations.id',
                                     'pagerRender'    => 'return \'<pre>\'.htmlspecialchars(str_replace(\'rl:\',\'Role: \',str_replace(\'yr:\'," - year/s: ",str_replace(\',\',"\r\n",$rsData[\'roles_data\'])))).\'</pre>\';',
                                     'sortableColumn'    => 'roles_data',
                                     'pagerWidth'   => 480,
                                     'filter'         => 'roles.data'),									 
				);

        /* Extra fields get added as columns here. */
        $specializations = new Specialization($this->_siteID);
        $extraFieldsRS = $specializations->extraFields->getSettings();
        foreach ($extraFieldsRS as $index => $data)
        {
            $fieldName = $data['fieldName'];

            if (!isset($this->_classColumns[$fieldName]))
            {
                $columnDefinition = $specializations->extraFields->getDataGridDefinition($index, $data, $this->_db);

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
		
        $sql = sprintf(
            "SELECT SQL_CALC_FOUND_ROWS %s
				specializations.id AS id,
				specializations.id AS exportID,
				%s
            FROM
                specializations
            %s
            %s
            %s
            %s
            %s
            %s",
            $distinct,
			$selectSQL,
			$joinSQL,
            (strlen($whereSQL) > 0) ? ' WHERE ' . $whereSQL : '',
            $this->_assignedCriterion,
            (strlen($havingSQL) > 0) ? ' HAVING ' . $havingSQL : '',
            $orderSQL,
            $limitSQL
        );

        return $sql;
    }
}

?>
