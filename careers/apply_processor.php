<?php
   require_once('../sync-config.php');	
   require_once("../config.php");   
   require_once('../lib/DocumentToText.php');
   require_once('../_linkedin_tool/sync_database.php');
   require_once('../_linkedin_tool/common.php');
    
	
	// access raw HTTP POST data	
	$post_body = file_get_contents('php://input');
	$application = json_decode($post_body);
	
	//Single Properties 	
	$firstname		= $application->person->firstName;
	$lastname		= $application->person->lastName;	
	$headline		= $application->person->headline;
	$summary_text	= $application->summary;
    $cover_letter	= $application->coverLetter;		
	$location		= $application->person->location->name;
	$public_profile	= $application->person->publicProfileUrl;
	$email_address	= $application->person->emailAddress;
	$honor			= $application->person->honors;
	
	$pad = str_repeat(" ",5);
	
	//Positions
	$positions		= "";
	foreach($application->person->positions->values as $position) {
		$positions	.= ($pad.$position->title ."\n".
		                $pad.$position->company->name . "\n" . 
		                $pad.month2text($position->startDate->month) . ", " . $position->startDate->year . "\n" .
		                $pad.$position->summary . "\n\n");
	}
	$positions		= str_replace("â?", $pad."-", $positions);
	
	//Skills
	$skills			= "";
	foreach($application->person->skills->values as $skill) {
		if(strlen($skills)>0) $skills .= ",";
		$skills		.= $skill->name;
	}
	if(strlen($skills)>0) $skills .= ($pad.$skills."\n\n");
	
	//Educations
	$educations		= "";
	foreach($application->person->educations->values as $education) {
		$educations	.= ($pad.$education->schoolName . "\n" . 
		                $pad.month2text($education->startDate->month) . " " . $education->startDate->year . " to " .
						month2text($education->endDate->month) . " " . $education->endDate->year . "\n" .
		                $pad.$education->degree . "\n" . 
						$pad.$education->fieldOfStudy . "\n" . 
						$pad.$education->activities . "\n\n");
	}
	
	//Patents
	$patents		= "";
	foreach($application->person->patents->values as $patent) {
		$patents	= $pad.$patent->title . "\n" . 
		              $pad.month2text($patent->{date}->month) . " " . $patent->{date}->day . ", " . $patent->{date}->year . "\n\n";
	}
	
	//Languages
	$languages		= "";
	foreach($application->person->languages->values as $language) {
		if(strlen($languages)>0) $languages .= ",";
		$languages	.= $language->language->name;
	}
	if(strlen($languages)>0) $languages .= ($pad.$languages."\n\n");
	
	//Publications
	$publications	= "";
	foreach($application->person->publications->values as $publication) {
		$publications .= $pad.$publication->title . "\n" . 
		                 $pad.month2text($publication->{date}->month) . " " . $publication->{date}->day . ", " . $publication->{date}->year . "\n\n";
	}
	
	//Recommendations
	$recommendations = "";
	foreach($application->person->recommendationsReceived->values as $recommendation) {
		$recommendations	=	$pad.$recommendation->recommendationText . "\n" . 
		                        $pad.$recommendation->recommender->firstName . " " .$recommendation->recommender->lastName . "\n\n";
	}
	
	//INDIVIDUAL POST FIELDS
	$post_id			= $application->job->id;
	$post_candidateid	= "-1";
	$post_firstName		= $application->person->firstName;
	$post_lastName		= $application->person->lastName;
	$post_email			= $application->person->emailAddress;
	$post_emailconfirm	= $application->person->emailAddress;
	$post_address		= $application->person->location->name;
	$post_city			= ""; //not available
	$post_state			= ""; //not available
	$post_zip			= $application->person->location->postalCode;
	$post_phone			= "-";
	foreach($application->person->phoneNumbers as $phone) {
		$post_phone			= var_export($phone[0]->phoneNumber, true);	
		break;
	}	
	$post_keySkills		= $skills;
	$post_source		= "LinkedIn.com";
	$post_file			= "";
	$post_extraNotes	= $application->person->summary;
	
	//Build Resume Text
	//TODO: Build Resume Text
	
	$resume_text	= ($firstname . " " . $lastname . "\n" . 
	                   $headline . "\n" . 
					   $location . "\n" . 
					   $email_address . "\n" . 
					   $post_phone . "\n" . 
					   $summary_text . "\n" . 
					   $cover_letter . "\n");
					   
    //Positions					  
	if(strlen($positions)>0) 
		$resume_text .= "\n\nPositions\n".$positions;
	//Skills					  
	if(strlen($skills)>0) 
		$resume_text .= "\n\nSkills\n".$skills;
	//Educations
	if(strlen($educations)>0) 
		$resume_text .= "\n\nEducations\n".$educations;
	//Patents
	if(strlen($patents)>0) 
		$resume_text .= "\n\nPatents\n".$patents;
	//Languages
	if(strlen($languages)>0) 
		$resume_text .= "\n\nLanguages\n".$languages;
	//Publications
	if(strlen($publications)>0) 
		$resume_text .= "\n\nPublications\n".$publications;
	//Recommendations
	if(strlen($recommendations)>0) 
		$resume_text .= "\n\nRecommendations\n".$recommendations;
	
	//create resume text	
	$resume_file = "../temp/resume_file.txt";
	$fh = fopen($resume_file, 'w');
	fwrite($fh, $resume_text);
	fclose($fh);
	
	$post_file_path = "@".$resume_file;
	//$post_file_path = "".$resume_file;
	  
	//fill post values
	$post_array = array(
		"ID"				=> $post_id,
		"candidateID"		=> $post_candidateid,
		"firstName"			=> $post_firstName,
		"lastName"			=> $post_lastName,
		"email"				=> $post_email,
		"emailconfirm"		=> $post_emailconfirm,
		"address"			=> $post_address,
		"city"				=> $post_city,
		"state"				=> $post_state,
		"zip"				=> $post_zip,
		"phone"				=> $post_phone,
		"keySkills"			=> $post_keySkills,
		"source"			=> $post_source,
		"file"				=> $post_file_path,
		"extraNotes"		=> $post_extraNotes
	);
	
	
	$post_url = "http://www.clearroad.it/cats/index.php?m=careers&p=onApplyToJobOrder";
	//$post_url = "http://www.clearroad.it/cats/careers/post_test.php";
	
	//now do post upload
	$ch = curl_init();
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_VERBOSE, 0);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible;)");	
    curl_setopt($ch, CURLOPT_URL, $post_url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post_array); 
    $response = curl_exec($ch);
	
	//delete temporary resume text file
	@unlink($resume_file);
?>