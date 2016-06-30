<?php
   require_once('../sync-config.php');	
   require_once("../config.php");   
   require_once('../lib/DocumentToText.php');
   require_once('../_linkedin_tool/sync_database.php');
   require_once('../_linkedin_tool/common.php');

   $post_values = var_export($_POST, true);
   //$post_values = "TEST VALUE";
   
   save_comments($post_values);
?>