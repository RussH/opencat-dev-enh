<?php 
/*
 * CATS
 * Messaging Datagrid
 *
 * CATS Version: 0.8.0 (Jhelum)
 *
 * Copyright (C) 2005 - 2007 Cognizo Technologies, Inc.
 *
 *
 * The contents of this file are subject to the CATS Public License
 * Version 1.1a (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.catsone.com/. Software distributed under the License is
 * distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * rights and limitations under the License.
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
 * $Id: dataGrids.php 3096 2007-09-25 19:27:04Z brian $
 */
 
include_once('./lib/Messaging.php');
include_once('./lib/Hooks.php');

class MessagingListByViewDataGrid extends MessagingDataGrid
{
    public function __construct($siteID, $parameters, $misc)
    {
        /* Pager configuration. */
        $this->_tableWidth = 915;
        $this->_defaultAlphabeticalSortBy = 'subject';
        $this->ajaxMode = false;
        $this->showExportCheckboxes = true; //BOXES WILL NOT APPEAR UNLESS SQL ROW exportID IS RETURNED!
        $this->showActionArea = true;
        $this->showChooseColumnsBox = true;
        $this->allowResizing = true;

        $this->defaultSortBy = 'dateCreatedSort';
        $this->defaultSortDirection = 'DESC';
   
        $this->_defaultColumns = array( 
            array('name' => 'Subject', 'width' => 150),
            array('name' => 'Status', 'width' => 40),
            array('name' => 'Date Created', 'width' => 150),
            array('name' => 'Date Sent', 'width' => 150),
            array('name' => 'Modified By', 'width' => 150),
        );
   
        parent::__construct("messaging:messagingListByViewDataGrid", 
                             $siteID, $parameters, $misc
                        );
    }
    

    /**
     * Adds more options to the action area on the pager.  Overloads 
     * DataGrid Inner Action Area function.
     *
     * @return html innerActionArea commands.
     */    
    public function getInnerActionArea()
    {
        $html = '';

        // $html .= $this->getInnerActionAreaItemPopup('Add Messages', CATSUtility::getIndexName().'?m=lists&amp;a=addToListFromDatagridModal&amp;dataItemType='.DATA_ITEM_MESSAGING, 450, 350);
		// $html .= $this->getInnerActionAreaItem('Delete', CATSUtility::getIndexName().'?m=export&amp;a=exportByDataGrid','this is a list');
        $html .= '<div id="Delete" style="float:left; width: 100px;">Delete</div><div style="float:right; width:95px;"><a href="javascript:void(0);" id="deleteSelected">Selected</a></div>'; 
		

        $html .= parent::getInnerActionArea();

        return $html;

    }
}

class MessagingavedListByViewDataGrid extends MessagingDataGrid
{
    public function __construct($siteID, $parameters, $misc)
    {
        /* Pager configuration. */
        $this->_tableWidth = 915;
        $this->_defaultAlphabeticalSortBy = 'subject';
        $this->ajaxMode = false;
        $this->showExportCheckboxes = true; //BOXES WILL NOT APPEAR UNLESS SQL ROW exportID IS RETURNED!
        $this->showActionArea = true;
        $this->showChooseColumnsBox = true;
        $this->allowResizing = true;

        $this->defaultSortBy = 'dateCreatedSort';
        $this->defaultSortDirection = 'DESC';
   
        $this->_defaultColumns = array( 
            array('name' => 'Subject', 'width' => 10),
            array('name' => 'Status', 'width' => 80),
            array('name' => 'Date Created', 'width' => 80),
            array('name' => 'Date Sent', 'width' => 135),
            array('name' => 'Modified By', 'width' => 135),
        );
   
        parent::__construct("messaging:messagingavedListByViewDataGrid", 
                             $siteID, $parameters, $misc
                        );
    }
    

    /**
     * Adds more options to the action area on the pager.  Overloads 
     * DataGrid Inner Action Area function.
     *
     * @return html innerActionArea commands.
     */    
    public function getInnerActionArea()
    {
        $html = '';

        // $html .= $this->getInnerActionAreaItemPopup('Add Messages', CATSUtility::getIndexName().'?m=lists&amp;a=addToListFromDatagridModal&amp;dataItemType='.DATA_ITEM_CONTACT, 450, 350);
        // $html .= $this->getInnerActionAreaItemPopup('Add Messages', CATSUtility::getIndexName().'?m=lists&amp;a=addToListFromDatagridModal&amp;dataItemType='.DATA_ITEM_CONTACT, 450, 350);
        // $html .= $this->getInnerActionAreaItemPopup('Add Messages', CATSUtility::getIndexName().'?m=lists&amp;a=addToListFromDatagridModal&amp;dataItemType='.DATA_ITEM_CONTACT, 450, 350);
        // $html .= $this->getInnerActionAreaItem('Delete', CATSUtility::getIndexName().'?m=export&amp;a=exportByDataGrid');
        $html .= '<div id="Delete" style="float:left; width: 100px;">Delete</div><div style="float:right; width:95px;"><a href="javascript:void(0);" id="deleteSelected">Selected</a></div>'; 

        $html .= parent::getInnerActionArea();

        return $html;

    }
}

?>
