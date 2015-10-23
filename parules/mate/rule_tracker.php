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
require_once('Common.php');
require_once('php/lang/LangVars-en.php');
require_once('php/AjaxTableEditor.php');
class Example1 extends Common
{
	var $Editor;
	
	function displayHtml()
	{
		$fw1 = $_GET["fw"];

		if ($fw1){
			echo "<a href=\"./rule_tracker.php\">Clear Filter</a>";
		}
		else {
		}		
		?>
			<br />
	
			<div align="left" style="position: relative;"><div id="ajaxLoader1"><img src="images/ajax_loader.gif" alt="Loading..." /></div></div>
			
			<br />
			
			<div id="historyButtonsLayer" align="left">
			</div>
	
			<div id="historyContainer">
				<div id="information">
				</div>
		
				<div id="titleLayer" style="padding: 2px; font-weight: bold; font-size: 18px; text-align: center;">
				</div>
		
				<div id="tableLayer" align="center">
				</div>
				
				<div id="recordLayer" align="center">
				</div>		
				
				<div id="searchButtonsLayer" align="center">
				</div>
			</div>
			
			<script type="text/javascript">
				trackHistory = false;
				var ajaxUrl = '<?php echo $this->getAjaxUrl(); ?>';
				toAjaxTableEditor('update_html','');
			</script>
		<?php
	}
	
	function initiateEditor()
	{
/*		$tableColumns['id'] = array('display_text' => 'ID', 'perms' => 'TVQSXO');
		$tableColumns['first_name'] = array('display_text' => 'First Name', 'perms' => 'EVCTAXQSHO');
		$tableColumns['last_name'] = array('display_text' => 'Last Name', 'perms' => 'EVCTAXQSHO');
		$tableColumns['email'] = array('display_text' => 'Email', 'perms' => 'EVCTAXQSHO');
		$tableColumns['department'] = array('display_text' => 'Department', 'perms' => 'EVCTAXQSHO', 'select_array' => array('Accounting' => 'Accounting', 'Marketing' => 'Marketing', 'Sales' => 'Sales', 'Production' => 'Production')); 
		$tableColumns['hire_date'] = array('display_text' => 'Hire Date', 'perms' => 'EVCTAXQSHO', 'display_mask' => 'date_format(hire_date,"%d %M %Y")', 'order_mask' => 'employees.hire_date', 'calendar' => '%d %B %Y','col_header_info' => 'style="width: 250px;"');
		
		$tableName = 'employees';
		$primaryCol = 'id';
		$errorFun = array(&$this,'logError');
		$permissions = 'EAVIDQCSXHO';
		
		$this->Editor = new AjaxTableEditor($tableName,$primaryCol,$errorFun,$permissions,$tableColumns);
		$this->Editor->setConfig('tableInfo','cellpadding="1" width="1000" class="mateTable"');
		$this->Editor->setConfig('orderByColumn','first_name');
		$this->Editor->setConfig('addRowTitle','Add Employee');
		$this->Editor->setConfig('editRowTitle','Edit Employee');
		//$this->Editor->setConfig('iconTitle','Edit Employee');
		$this->Editor->setConfig('viewQuery',true);*/
#               echo $fw;
		$fw1 = $_GET['fw'];
		

		$tableColumns['id'] = array( 'perms' => 'VQS');
		$tableColumns['bgroup'] = array('display_text' => 'Group', 'perms' => 'EVCTAXQS' );
		$tableColumns['requestor'] = array('display_text' => 'Requestor', 'perms' => 'EVCTAXQS');
		$tableColumns['push_date'] = array('display_text' => 'Date', 'perms' => 'EVCTAXQS');
		$tableColumns['reference'] = array('display_text' => 'Reference', 'perms' => 'EVCTAXQS');
		$tableColumns['bapp'] = array('display_text' => 'Business App', 'perms' => 'EVCTAXQS', 'table_fun' => array(&$this,'changeBr'));
		$tableColumns['breason'] = array('display_text' => 'Business Reason', 'perms' => 'EVCTAXQS', 'table_fun' => array(&$this,'changeBr'));
		$tableColumns['notes'] = array('display_text' => 'Notes', 'perms' => 'EVCTAXQS', 'table_fun' => array(&$this,'changeBr'));
		$tableColumns['rule_numbers'] = array('display_text' => 'Rules', 'perms' => 'EVCTAXQS');
		if ($fw1){
			$tableColumns['firewall'] = array('display_text' => 'Firewall', 'perms' => 'EVCTAXQS', 'data_filters' => array('filters' => array("= '".$_GET['fw']."'"), 'criteria' => 'any') );
		}
		else {
			$tableColumns['firewall'] = array('display_text' => 'Firewall', 'perms' => 'EVCTAXQS');
		}		

		$tableName = 'rule_tracker';
		$primaryCol = 'id';
		$errorFun = array(&$this,'logError');

		$permissions = 'EAVIDQCSX';
		
		require_once('php/AjaxTableEditor.php');
		$this->Editor = new AjaxTableEditor($tableName,$primaryCol,$errorFun,$permissions,$tableColumns);
		$this->Editor->setConfig('tableInfo','cellpadding="1" class="mateTable"'); # width="800"
		$this->Editor->setConfig('tableTitle','Rule Tracker Comments');
		$this->Editor->setConfig('orderByColumn','id');
		$this->Editor->setConfig('addRowTitle','Add Rule Tracker Info');
		$this->Editor->setConfig('editRowTitle','Edit Rule Tracker Info');
		//$this->Editor->setConfig('viewQuery',true);

	}
	
	
	function Example1()
	{
#               var $fw = $_GET["fw"];
#		echo "$fw";
		if(isset($_POST['json']))
		{
			session_start();
			// Initiating lang vars here is only necessary for the logError, and mysqlConnect functions in Common.php. 
			// If you are not using Common.php or you are using your own functions you can remove the following line of code.
			$this->langVars = new LangVars();
			$this->mysqlConnect();
			if(ini_get('magic_quotes_gpc'))
			{
				$_POST['json'] = stripslashes($_POST['json']);
			}
			if(function_exists('json_decode'))
			{
				$data = json_decode($_POST['json']);
			}
			else
			{
				require_once('php/JSON.php');
				$js = new Services_JSON();
				$data = $js->decode($_POST['json']);
			}
			if(empty($data->info) && strlen(trim($data->info)) == 0)
			{
				$data->info = '';
			}
			$this->initiateEditor();
			$this->Editor->main($data->action,$data->info);
			if(function_exists('json_encode'))
			{
				echo json_encode($this->Editor->retArr);
			}
			else
			{
				echo $js->encode($this->Editor->retArr);
			}
		}
		else if(isset($_GET['mate_export']))
		{
         /*   session_start();
            ob_start();
            $this->mysqlConnect();
            $this->initiateEditor();
            echo $this->Editor->exportInfo();
            header("Cache-Control: no-cache, must-revalidate");
            header("Pragma: no-cache");
            header("Content-type: application/x-msexcel");
            header('Content-Type: text/csv');
            header('Content-Disposition: attachment; filename="'.$this->Editor->tableName.'.csv"');
            exit();*/
                               session_start();
                        ob_start();
                        $fdate = date("m-d-y",time());
                        $export_file = "Rules_Tracker_";
                        $export_file .= $fdate;
                        $export_file .= ".xls";
                        ini_set('zlib.output_compression','Off');
                        header('Pragma: public');
                        header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");                  // Date in the past
                        header('Last-Modified: '.gmdate('D, d M Y H:i:s') . ' GMT');
                        header('Cache-Control: no-store, no-cache, must-revalidate');     // HTTP/1.1
                        header('Cache-Control: pre-check=0, post-check=0, max-age=0');    // HTTP/1.1
                        header ("Pragma: no-cache");
                        header("Expires: 0");
                        header('Content-Transfer-Encoding: none');
                        header('Content-Type: application/vnd.ms-excel;');                 // This should work for IE & Opera
                        header("Content-type: application/x-msexcel");                    // This should work for the rest
                        header('Content-Disposition: attachment; filename="'.$export_file.'"');

                        echo "<head>\n";
                        echo "<title>Rule Tracker</title>\n";
                        echo "</head>\n";
                        echo "<html>\n";
                        echo "\n";

                        echo '<h1>Rule Tracker</h1>';

                        echo "<TABLE  BORDER=\"1\"> <TBODY>";
                        echo "
			<TH>Group</TH>
			<TH>Requestor</TH>
			<TH>Date</TH>	
			<TH>Reference</TH>
			<TH>Application</TH>	
			<TH>Business Reason</TH>
			<TH>Notes</TH>
			<TH>Rules</TH>	
                       ";

                        $this->mysqlConnect();
                        $this->initiateEditor();
                        echo $this->Editor->exportInfo();
                        echo"\n</TBODY></TABLE>";
                        exit();
		}



        
		else
		{
			$this->displayHeaderHtml();
			$this->displayHtml();
			$this->displayFooterHtml();
		}
	}
}
$lte = new Example1();
?>
