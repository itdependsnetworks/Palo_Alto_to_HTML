<?php
/*
 * Mysql Ajax Table Editor
 *
 * Copyright (c) 2008 Chris Kitchen <info@mysqlajaxtableeditor.com>
 * All rights reserved.
 *
 * See COPYING file for license information.
 *
 * Download the latest version from
 * http://www.mysqlajaxtableeditor.com
 */
class Common
{		
	
	var $langVars;
	var $dbc;
	
	function mysqlConnect()
	{
		
	        $current_directory =  dirname(__FILE__);
	
	        $plorp = substr(strrchr($current_directory,'/'), 1);
	        $webdir = substr($current_directory, 0, - strlen($plorp));


	        $file_handle = fopen("$webdir". "/config.txt", "r");
	        while (!feof($file_handle)) {
	                $line_of_text = fgets($file_handle);
	                $splitline = explode(",", $line_of_text );
	                if ($splitline[0] == 'scriptroot'){
	                        $scriptroot = rtrim($splitline[1]);
	                }
	                if ($splitline[0] == 'webroot'){
	                        $webroot = rtrim($splitline[1]);
	                }
	
	        }
	
	        fclose($file_handle);

	        $parules_directory = '/scripts/parules/';
	        $file_handle = fopen("$scriptroot/config.txt", "r");
	
	        while (!feof($file_handle)) {
	                $line_of_text = fgets($file_handle);
	                $splitline = explode(",", $line_of_text );
	                if ($splitline[0] == 'mysql_username'){
	                        $mysqlUser = rtrim($splitline[1]);
	                }
	                elseif ($splitline[0] == 'mysql_server'){
	                        $mysqlHost = rtrim($splitline[1]);
	                }
	                elseif ($splitline[0] == 'mysql_db'){
	                        $mysqlDb = rtrim($splitline[1]);
	                }
	                elseif ($splitline[0] == 'mysql_password'){
	                        $mysqlDbPass = rtrim($splitline[1]);
	                }
	        }
	
	        fclose($file_handle);


		if($this->dbc = mysql_connect($mysqlHost, $mysqlUser, $mysqlDbPass)) 
		{	
			if(!mysql_select_db ($mysqlDb))
			{
				$this->logError(sprintf($this->langVars->errNoSelect,$mysqlDb),__FILE__, __LINE__);
			}
		}
		else
		{
			$this->logError($this->langVars->errNoConnect,__FILE__, __LINE__);
		}
	}
	
	function logError($message, $file, $line)
	{
		$message = sprintf($this->langVars->errInScript,$file,$line,$message);
		var_dump($message);
		die;
	}


	function displayHeaderHtml()
	{
		?>
		<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
		"http://www.w3.org/TR/html4/loose.dtd">
		<html>
		<head>
		<title>Rule Tracker</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
			<link href="css/table_styles.css" rel="stylesheet" type="text/css" />
			<link href="css/icon_styles.css" rel="stylesheet" type="text/css" />
			
			<script type="text/javascript" src="js/prototype.js"></script>
			<script type="text/javascript" src="js/scriptaculous-js/scriptaculous.js"></script>
			<script type="text/javascript" src="js/lang/lang_vars-en.js"></script>
			<script type="text/javascript" src="js/ajax_table_editor.js"></script>
			
			<!-- calendar files -->
			<link rel="stylesheet" type="text/css" media="all" href="js/jscalendar/skins/aqua/theme.css" title="win2k-cold-1" /> 
			<script type="text/javascript" src="js/jscalendar/calendar.js"></script>
			<script type="text/javascript" src="js/jscalendar/lang/calendar-en.js"></script>
			<script type="text/javascript" src="js/jscalendar/calendar-setup.js"></script>

		</head>	
		<body>
		<?php
	}	
	
	function displayFooterHtml()
	{
		?>
		</body>
		</html>
		<?php
	}	
	
	function getAjaxUrl()
	{
		$ajaxUrl = $_SERVER['PHP_SELF'];
		if(count($_GET) > 0)
		{
			$queryStrArr = array();
			foreach($_GET as $var => $val)
			{
				$queryStrArr[] = $var.'='.urlencode($val);
			}
			$ajaxUrl .= '?'.implode('&',$queryStrArr);
		}
		return $ajaxUrl;
	}
	
}
?>
