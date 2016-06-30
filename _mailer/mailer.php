<?php
	//die("test");
	
	/* connect to gmail */
	$hostname = '{imap.gmail.com:993/imap/ssl}INBOX';
	//$username = 'remote.allan@gmail.com';
	//$password = 'remote1234';
	$username = 'aching@clearroad.it';
	$password = 'gnihcefs';
	
	if (!function_exists('imap_open')) {
		die("IMAP NOT SUPPORTED");
	}
	
	/* try to connect */
	$inbox = imap_open($hostname,$username,$password) or die('Cannot connect to Gmail: ' . imap_last_error());
	
	/* grab emails */
	$emails = imap_search($inbox,'UNSEEN'); //NEW, ALL
	
	$max_count = 5; //get last 5 emails with attachments
	
	$emails_final = array();
	/* if emails are returned, cycle through each... */
	if($emails) {		
		/* begin output var */
		$output = '';
		
		/* put the newest emails on top */
		rsort($emails);
		$curr_count = 0;
		
		/* for every email... */
		foreach($emails as $email_number) {			
			$has_file_attachment = false;
			$structure_initialized = false;
			
			/* get information specific to this email */			
			$structure = imap_fetchstructure($inbox, $email_number);
			if(isset($structure->parts) && count($structure->parts)) {
				for($i = 0; $i < count($structure->parts); $i++) {
					$attachments[$i] = array(
						'is_attachment' => false,
						'filename' => '',
						'name' => '',
						'attachment' => ''
					);
					if($structure->parts[$i]->ifdparameters) {
						foreach($structure->parts[$i]->dparameters as $object) {
							if(strtolower($object->attribute) == 'filename') {
								$has_file_attachment = true;
								if($structure_initialized == false) {									
									$overview = imap_fetch_overview($inbox,$email_number,0);
									$current_email_struct = array("from"		 => $overview[0]->from,
																  "date"	 	 => $overview[0]->date,
																  "subject"		 => $overview[0]->subject,
																  "flag"		 => ($overview[0]->seen ? 'read' : 'unread'),
																  "attachments"	 => array());			
									$attachments[$i]['is_attachment'] = true;
									$attachments[$i]['filename'] = $object->value;
									$structure_initialized == true;
								}
							}
						}
					}
					if($has_file_attachment == true)  {
						if($structure->parts[$i]->ifparameters) {
							foreach($structure->parts[$i]->parameters as $object) {
								if(strtolower($object->attribute) == 'name') {
									$attachments[$i]['is_attachment'] = true;
									$attachments[$i]['name'] = $object->value;
								}
							}
						}
						
						if($attachments[$i]['is_attachment']) {
							$attachments[$i]['attachment'] = imap_fetchbody($inbox, $email_number, $i+1);
							if($structure->parts[$i]->encoding == 3) { // 3 = BASE64
								$attachments[$i]['attachment'] = base64_decode($attachments[$i]['attachment']);
							}
							elseif($structure->parts[$i]->encoding == 4) { // 4 = QUOTED-PRINTABLE
								$attachments[$i]['attachment'] = quoted_printable_decode($attachments[$i]['attachment']);
							}
						}					
						$current_email_struct["attachments"] = $attachments;
					}
				}
			}
			//$message = imap_fetchbody($inbox,$email_number,2);
			
			/* output the email header information */
			//$output.= '<div class="toggler '.($overview[0]->seen ? 'read' : 'unread').'">';
			//$output.= '<span class="subject">'.$overview[0]->subject.'</span> ';
			//$output.= '<span class="from">'.$overview[0]->from.'</span>';
			//$output.= '<span class="date">on '.$overview[0]->date.'</span>';
			//$output.= '</div>';
			
			/* output the email body */
			//$output.= '<div class="body">'.$message.'</div>';
			if($has_file_attachment == true) {
				$curr_count++;
				$emails_final[$email_number] = $current_email_struct;
			}
			if($curr_count >= $max_count) break;
		}
		
		print_r($emails_final);
	} 
	
	/* close the connection */
	imap_close($inbox);
	

?>