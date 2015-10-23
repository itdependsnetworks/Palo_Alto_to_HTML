#!/usr/bin/perl

# <@LICENSE>
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# </@LICENSE>

# Maintained by Ken Celenza, ken.celenza@gmail.com


my $dir = $0;
$dir =~ s/pa\.pl$//;

my @config =();
open(FILE, "$dir" . "config.txt") or die("Unable to open file");
        @config = <FILE>;
close FILE;

my $webroot = ();
my $scriptroot = ();

foreach my $line (@config){
        my @configsplit = split (/,/,$line);
        if ($configsplit[0] eq 'webroot'){
                $webroot = $configsplit[1];
                $webroot =~ s/\n|\r//g;
        }
        elsif ($configsplit[0] eq 'scriptroot'){
                $scriptroot = $configsplit[1];
                $scriptroot =~ s/\n|\r//g;
        }
}

# use warnings;
 use Data::Dumper;
 use XML::Simple;
 use CGI qw(:standard);


my ($vsys,$view,$xls,$cgi,$globalhist,$legacy,$fwname,$rule_tracker,$search,$st,$fm,$ci) = ();
my (@config,%config_hash)= ();
my ($col_history,$col_description,$col_name,$col_tag,$col_from,$col_source,$col_sourceip,$col_sourceuser,$col_to,$col_dst,$col_dstip,$col_app,$col_service,$col_serviceval,$col_action,$col_profile,$col_option,$cols)= ();
my $global_count = 0;
my ($s1, $s2, $s3, $s4, $s5, $s6, $s7, $s8, $s9, $s10, $s11, $s12, $s13, $s14, $s15, $s16, $s17, $s18, $s19, $s20, $s21, ) =();

open(FILE, "$scriptroot/config.txt") or die("Unable to open file");
@config = <FILE>;
close FILE;

foreach my $line (@config){
	my @splitline = split(/,/,$line);
	chomp($splitline[1]);
	if ($splitline[1]){
		$config_hash{$splitline[0]} = $splitline[1];
	}
}

$col_name = $config_hash{'col_name'};
$col_description = $config_hash{'col_description'};
$col_tag = $config_hash{'col_tag'};
$col_from = $config_hash{'col_from'};
$col_source = $config_hash{'col_source'};
$col_sourceip = $config_hash{'col_sourceip'};
$col_sourceuser = $config_hash{'col_sourceuser'};
$col_to = $config_hash{'col_to'};
$col_dst = $config_hash{'col_dst'};
$col_dstip = $config_hash{'col_dstip'};
$col_app = $config_hash{'col_app'};
$col_service = $config_hash{'col_service'};
$col_serviceval = $config_hash{'col_serviceval'};
$col_action = $config_hash{'col_action'};
$col_profile = $config_hash{'col_profile'};
$col_option = $config_hash{'col_option'};
$col_history = 1 if $history;


	my $cgi = new CGI;
	print $cgi->header;

	$fw = param('fw');
	$fwname = param('fwname');
	$vsys = param('vsys');
	$vsys = 'vsys1' if !$vsys;
	$view = param('view');
	$view = 'regular' if !$view;
	$xls = param('xls');
	$cols = param('cols');
	$showall = param('showall');
	$globalhist = param('globalhist');
	$legacy = param('legacy');
	$history = param('history');
	$rule_tracker = param('rule_tracker');
	$search = param('search');
	$st = param('st');
	$fm = param('fm');
	$ci = param('ci');
	$s1 = param('s1');
	$s2 = param('s2');
	$s3 = param('s3');
	$s4 = param('s4');
	$s5 = param('s5');
	$s6 = param('s6');
	$s7 = param('s7');
	$s8 = param('s8');
	$s9 = param('s9');
	$s10 = param('s10');
	$s11 = param('s11');
	$s12 = param('s12');
	$s13 = param('s13');
	$s14 = param('s14');
	$s15 = param('s15');
	$s16 = param('s16');
	$s17 = param('s17');
	$s18 = param('s18');
	$s19 = param('s19');
	$s20 = param('s20');
	$s21 = param('s21');

	if ($ARGV[0]){
		$globalhist = $ARGV[0];
		$history = $ARGV[1];
		$xls = $ARGV[2];
		$fwname = $ARGV[3];
	}



	$col_name = "0" if !$col_name;
	$col_description = "0" if !$col_description;
	$col_tag = "0" if !$col_tag;
	$col_from = "0" if !$col_from;
	$col_source = "0" if !$col_source;
	$col_sourceip = "0" if !$col_sourceip;
	$col_sourceuser = "0" if !$col_sourceuser;
	$col_to = "0" if !$col_to;
	$col_dst = "0" if !$col_dst;
	$col_dstip = "0" if !$col_dstip;
	$col_app = "0" if !$col_app;
	$col_service = "0" if !$col_service;
	$col_serviceval =  "0" if !$col_serviceval;
	$col_action = "0" if !$col_action;
	$col_profile = "0" if !$col_profile;
	$col_option = "0" if !$col_option;
	$col_history = "0" if !$col_history;


	@cols = split(undef,$cols);

	unshift @cols, 1;
	my @keywords = $cgi->param;
	if ($cols){
#	foreach my $line (@cols){
		$col_name = $cols[1];
		$col_description = $cols[2];
		$col_tag = $cols[3];
		$col_from = $cols[4];
		$col_source = $cols[5];
		$col_sourceip = $cols[6];
		$col_sourceuser = $cols[7];
		$col_to = $cols[8];
		$col_dst = $cols[9];
		$col_dstip = $cols[10];
		$col_app = $cols[11];
		$col_service = $cols[12];
		$col_serviceval =  $cols[13];
		$col_action = $cols[14];
		$col_profile = $cols[15];
		$col_option = $cols[16];
		$col_history = $cols[17];





=begin
		$col_name = param('col_name') if $line eq 'col_name';
		$col_description = param('col_description') if $line eq 'col_description';
		$col_tag = param('col_tag') if $line eq 'col_tag';
		$col_from = param('col_from') if $line eq 'col_from';
		$col_source = param('col_source') if $line eq 'col_source';
		$col_sourceip = param('col_sourceip') if $line eq 'col_sourceip';
		$col_sourceuser = param('col_sourceuser') if $line eq 'col_sourceuser';
		$col_to = param('col_to') if $line eq 'col_to';
		$col_dst = param('col_dst') if $line eq 'col_dst';
		$col_dstip = param('col_dstip') if $line eq 'col_dstip';
		$col_app = param('col_app') if $line eq 'col_app';
		$col_service = param('col_service') if $line eq 'col_service';
		$col_serviceval = param('col_serviceval') if $line eq 'col_serviceval';
		$col_action = param('col_action') if $line eq 'col_action';
		$col_profile = param('col_profile') if $line eq 'col_profile';
		$col_option = param('col_option') if $line eq 'col_option';
		$col_history = param('col_history') if !$history;
=cut
		shift @cols;
#	}
	}
	else {
		$cols .= $col_name;
		$cols .= $col_description;
		$cols .= $col_tag;
		$cols .= $col_from;
		$cols .= $col_source;
		$cols .= $col_sourceip;
		$cols .= $col_sourceuser;
		$cols .= $col_to;
		$cols .= $col_dst;
		$cols .= $col_dstip;
		$cols .= $col_app;
		$cols .= $col_service;
		$cols .= $col_serviceval;
		$cols .= $col_action;
		$cols .= $col_profile;
		$cols .= $col_option;
		
	}
	if ($showall ){
		($col_name,$col_description,$col_tag,$col_from,$col_source,$col_sourceip,$col_sourceuser,$col_to,$col_dst,$col_dstip,$col_app,$col_service,$col_serviceval,$col_action,$col_profile,$col_option) = (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
	}
my $col_name_search = $s1 ;
my $col_description_search = $s2 ;
my $col_tag_search = $s3 ;
my $col_from_search = $s4 ;
my $col_source_search = $s5 ;
my $col_sourceip_search = $s6 ;
my $col_sourceuser_search = $s7 ;
my $col_to_search = $s8 ;
my $col_dst_search = $s9 ;
my $col_dstip_search = $s10 ;
my $col_app_search = $s11 ;
my $col_service_search = $s12 ;
my $col_serviceval_search = $s13 ;
my $col_action_search = $s14 ;
my $col_profile_search = $s15 ;
my $col_option_search = $s16 ;

my $col_bgroup_search = $s18;
my $col_bapp_search = $s19;
my $col_breason_search = $s20;
my $col_flags_search = $s21;


my $col_name_search_set = 1 if $col_name_search; 
my $col_description_search_set = 1 if $col_description_search;
my $col_tag_search_set = 1 if $col_tag_search;
my $col_from_search_set = 1 if $col_from_search;
my $col_source_search_set = 1 if $col_source_search;
my $col_sourceip_search_set = 1 if $col_sourceip_search; 
my $col_sourceuser_search_set = 1 if $col_sourceuser_search; 
my $col_to_search_set = 1 if $col_to_search;
my $col_dst_search_set = 1 if $col_dst_search;
my $col_dstip_search_set = 1 if $col_dstip_search;
my $col_app_search_set = 1 if $col_app_search;
my $col_service_search_set = 1 if $col_service_search;
my $col_serviceval_search_set = 1 if $col_serviceval_search; 
my $col_action_search_set = 1 if $col_action_search;
my $col_profile_search_set = 1 if $col_profile_search;
my $col_option_search_set = 1 if $col_option_search;

my $col_bgroup_search_set = 1 if $col_bgroup_search;
my $col_bapp_search_set = 1 if $col_bapp_search;
my $col_breason_search_set = 1 if $col_breason_search;
my $col_flags_search_set = 1 if $col_flags_search;





my $rule_tracker_search = $fw;

my @all_fw =();
open(FILE, "$scriptroot/fw.txt") or die("Unable to open file");
@all_fw = <FILE>;
close FILE;

my @all_fw_out =();
foreach my $all_fw (@all_fw){
        my @split = split(/,/,$all_fw);
        push @all_fw_out, $split[0];
	chomp($split[3]);
        if ($split[3] && $split[0] eq $fw){$rule_tracker_search = $split[3];}
}

my $col_num = $col_history + $col_description + $col_name + $col_tag + $col_from + $col_source + $col_sourceip + $col_sourceuser + $col_to + $col_dst + $col_dstip + $col_app + $col_service + $col_serviceval + $col_action + $col_profile + $col_option;
#$fw = 'amc-fw01';
my $src_col_span = $col_from + $col_source + $col_sourceip + $col_sourceuser;
my $dst_col_span = $col_to + $col_dst + $col_dstip;

my $xml = new XML::Simple(ForceArray => [vsys , rule ,  prerule , postrule]);
my ($inbound_rules,$timestamp) = ();

if (!$fwname){
	$fwname = $fw;
}

my ($mysqlip,$mysql_username, $mysql_password, $special_case1,%bgroup_hash,%bapp_hash,%breason_hash,%flags_hash,$push_col_head,$push_col_head_search,$push_col_head_xls,$push_col_head_htm)=();

if ($rule_tracker){


	my $module = "DBI";
	eval("use $module;");

	$mysqlip = $config_hash{'mysql_server'};
	$mysqldb = $config_hash{'mysql_db'};
	$mysql_username = $config_hash{'mysql_username'};
	$mysql_password = $config_hash{'mysql_password'};
	
	my $select_query = ();
	$select_query = "select bgroup,bapp,breason,rule_numbers from rule_tracker where firewall = \"$rule_tracker_search\"";
	if ($fw eq $config_hash{'special_case1_fw'} && ($vsys eq $config_hash{'special_case1_vsys1'} || $vsys eq $config_hash{'special_case1_vsys2'})){
		$special_case1 = 1;
		$select_query = 'select bgroup,bapp,breason,rule_numbers,internet,global,management,db,files from rule_tracker';
	}
#	print "$config_hash{'special_case1_fw'} -- $config_hash{'special_case1_vsys1'} $config_hash{'special_case1_vsys2'} ;$fw * $vsys- $special_case1 ^$select_query";

	my $dbh=DBI->connect("DBI:mysql:database=$mysqldb;host=$mysqlip","$mysql_username","$mysql_password") or print "$DBI::db_errstr\n";
	my $query=$dbh->quote($site);
	my $arrayref=$dbh->selectall_arrayref("$select_query") or print "$DBI::db_errstr now \n";
	$dbh->disconnect;


	for my $row (@$arrayref) {
		my ($bgroup,$bapp,$breason,$rule_numbers,$internet,$global,$management,$db,$files)=();
	        ($bgroup,$bapp,$breason,$rule_numbers,$internet,$global,$management,$db,$files)=@$row if $special_case1;
	        ($bgroup,$bapp,$breason,$rule_numbers)=@$row if !$special_case1;

	        my @all_rules = split(/,/,$rule_numbers);
	        my $flags = ();
		
		if ($special_case1){
		        $flags .= 'I-' if $internet;
		        $flags .= 'G-' if $global;
		        $flags .= 'M-' if $management;
		        $flags .= 'D-' if $db;
	        	$flags .= 'F-' if $files;
		
			chop($flags);
		}
	        foreach my $rule (@all_rules){
	                $rule =~ s/^\s//g;
	                $rule =~ s/\s$//g;
			if ($rule){
		                $bgroup_hash{$rule} = $bgroup;
		                $bapp_hash{$rule} = $bapp;
		                $breason_hash{$rule} = $breason;
		                $flags_hash{$rule} = $flags if $special_case1;
			}
	        }
	}
	$col_num++;
	$col_num++;
	$col_num++;
	$col_num++ if $special_case1;
	$push_col_head = "<th></th>";
	$push_col_head .= "<th></th>";
	$push_col_head .= "<th></th>";
	$push_col_head .= "<th></th>" if $special_case1;
	$push_col_head_xls = "<th>group</a></th>\n";
	$push_col_head_xls .= "<th>bapp</a></th>\n";
	$push_col_head_xls .= "<th>business reason</a></th>\n";
	$push_col_head_xls .= "<th>flags</a></th>\n" if $special_case1;
	$push_col_head_htm .=  "<th><a href=\"" . &format_column('col_bgroup') . "\">group</a></th>\n";
	$push_col_head_htm .=  "<th><a href=\"" . &format_column('col_bapp') . "\">bapp</a></th>\n";
	$push_col_head_htm .=  "<th><a href=\"" . &format_column('col_breason') . "\">breason</a></th>\n";
	$push_col_head_htm .= "<th><a href=\"" . &format_column('col_flags') . "\">flags</a></th>\n" if $special_case1;
	$push_col_head_search .= "<th><input size=10 type=\"text\" name=\"s18\" value=\"$col_bgroup_search\"></th>\n";
	$push_col_head_search .= "<th><input size=10 type=\"text\" name=\"s19\" value=\"$col_bapp_search\"></th>\n";
	$push_col_head_search .= "<th><input size=10 type=\"text\" name=\"s20\" value=\"$col_breason_search\"></th>\n";
	$push_col_head_search .= "<th><input size=10 type=\"text\" name=\"s21\" value=\"$col_flags_search\"></th>\n" if $special_case1;

}



if ($globalhist && $history){
        $inbound_rules = $xml->XMLin("$scriptroot/globalxml/$fwname.xml");#$string);
}
elsif ($history){
        $inbound_rules = $xml->XMLin("$scriptroot/xml/$fwname-history.xml");#$string);
}
elsif ($fw){
	$inbound_rules = $xml->XMLin("$scriptroot/xml/$fwname.xml");#$string);
	my $epoch_timestamp = (stat("$scriptroot/xml/$fwname.xml"))[9];
	$timestamp       = localtime($epoch_timestamp);
}
my %xml_ok = % $inbound_rules;



foreach $key (keys( % {$xml_ok{'vsys'}} ) ) {
	push @num_vsys, $key;
	#print "$key";
}
@num_vsys = sort { $a <=> $b } @num_vsys;

#         <link rel="stylesheet" href="html/fw.css"  type="text/css" />
#         <link rel="stylesheet" href="images/menu/menub.css"  type="text/css" />
my $model = $xml_ok{'info'}{'model'};
my $appver = $xml_ok{'info'}{'appver'};

my (@print_array,@menu_header) = ();
my $header1 = ' 
   <HTML>
      <HEADER>
         <TITLE>Palo Alto Firewall to HTML  </TITLE>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
';
my $filename = "$webroot/html/fw.css";
open my $fh, '<', $filename or die "error opening $filename: $!";
my $style = do { local $/; <$fh> };

my $header2 = '
         <link rel="stylesheet" href="html/menu.css"  type="text/css" />
';
my $header3 = '
      </HEADER>
   <BODY BGCOLOR=WHITE>
';
#my $header4 ='
push @menu_header,'
<table border="1" bordercolor="#B3CFEC" width="100%" height="100" cellpadding=0 cellspacing=0>
   <tr bgcolor=#316989>
      <td heigth=100>
         <font size=5 color=#000000>&nbsp;Palo Alto Firewall to HTML</font></td>
   </tr>';
my $ucfw = uc($fw) . ":"  if $fw;
$ucfw .= $vsys . ":" if $vsys ne 'vsys1';
push @menu_header,"<tr bgcolor=#316989><td><font size=\"4\"><b>$ucfw</b></font> Updated: $timestamp Model: $model Appver: $appver</td></tr>" if !$history;
push @menu_header, "<tr bgcolor=#316989><td>&nbsp&nbsp&nbsp&nbsp&nbsp <b>Key::</b> &nbsp&nbsp&nbsp&nbsp&nbsp Change Old: <img src=\"./images/yellow_led.gif\" title=\"Old\">" if $history;
push @menu_header, "&nbsp&nbsp&nbsp&nbsp&nbsp Change New: <img src=\"./images/green_led.png\" title=\"New\">" if $history;
push @menu_header, "&nbsp&nbsp&nbsp&nbsp&nbsp Added: <img src=\"./images/add.png\" title=\"Added\">" if $history;
push @menu_header, "&nbsp&nbsp&nbsp&nbsp&nbsp Removed: <img src=\"./images/delete.png\" title=\"Removed\"></td></tr>" if $history;
push @menu_header,'</table>';
push @menu_header, '<ul id="nav">' . "\n";
push @menu_header, ' <li class=top><a href="#">Firewalls</a>' . "\n";
my $fwcount = @all_fw_out;
if ($fwcount < 10) {
	push @menu_header,  ' <ul>' . "\n";
	foreach my $all_fw (@all_fw_out) {
		push @menu_header, '    <li><a href=' . "\"?fw=$all_fw\">" . $all_fw . '</a></li>' . "\n" ;
	}
	push @menu_header, '  </ul>' . "\n";
}
else {
	push @menu_header,  ' <ul>' . "\n";
#	unshift @all_fw_out, 'Place_holder';
	for (my $i=0; $i < $fwcount; $i++) {
		my $modnum = 12;
		my $mod = $i % $modnum;
		my $modnum1 = $modnum - 1;
		if ($i == 0){
#			push @menu_header, '<ul>' . "\n";
			push @menu_header, "<li><a href=\"#\">$all_fw_out[0] - $all_fw_out[$modnum1]</a>" . "\n";
#			push @menu_header, '<ul id="droprightMenu">' . "\n";
			push @menu_header, '<ul>' . "\n";
#			push @menu_header, '<div>' . "\n";
		}
		elsif ($mod == 0){
			push @menu_header, '</ul>' . "\n";
#			push @menu_header, '</div>' . "\n";
			push @menu_header, '</li>' . "\n";
			my $plus = $i + $modnum1;
			if ($plus >= $fwcount){
				$plus = $fwcount - 1;
			}
			push @menu_header, "<li><a href=\"#\">$all_fw_out[$i] - $all_fw_out[$plus]</a>" . "\n";
#			push @menu_header, '<ul id="droprightMenu">' . "\n";
			push @menu_header, '<ul>' . "\n";
#			push @menu_header, '<div>' . "\n";
			
		}
		
		$all_fw = $all_fw_out[$i];
#			push @menu_header, '<ul>' . "\n";
		push @menu_header, '    <li><a href=' . "\"?fw=$all_fw\">" . $all_fw . '</a></li>'  . "\n";
#			push @menu_header, '</ul>' . "\n";
	}
	push @menu_header, '  </ul>' . "\n";
#			push @menu_header, '</div>' . "\n";
	push @menu_header, '</li>' . "\n";
	push @menu_header, '  </ul>' . "\n";
#	shift @all_fw;
}

push @menu_header, '  
 </li>
 <li class=top><a href="#">Vsys</a>
  <ul>' . "\n";
foreach my $num_vsys (@num_vsys) {
	my $vsysname = $xml_ok{'info'}{"$num_vsys"};
	$vsysname = " [$vsysname]" if $vsysname;

	push @menu_header, '    <li><a href=' . "\"?fw=$fw&fwname=$fwname&vsys=$num_vsys\">" . "$num_vsys$vsysname" . '</a></li>' . "\n";
}
push @menu_header, '
  </ul>';
push @menu_header, ' <li class=top><a href="#">View</a>
  <ul>'. "\n";
push @menu_header, '    <li><a href=' . "\"?fw=$fw&fwname=$fwname&vsys=$vsys&view=regular\">" .  'Regular</a></li>'. "\n" ;
push @menu_header, '    <li><a href=' . "\"?fw=$fw&fwname=$fwname&vsys=$vsys&view=tag\">" .  'Tag</a></li>' . "\n";
push @menu_header, '    <li><a href=' . "\"?fw=$fw&fwname=$fwname&vsys=$vsys&view=zone\">" .  'Zone</a></li>'. "\n";
push @menu_header, '  </ul>';
if (!$history){
	my $add = "&rule_tracker=$rule_tracker&" if $rule_tracker;
	push @menu_header, '<li class=top><a href=' . "\"?fw=$fw&fwname=$fwname&vsys=$vsys&view=$view&xls=1$add\">" . 'XLS</a></li>'. "\n";
}
elsif ($history && $globalhist){
	push @menu_header, '<li class=top><a href=' . "\"?globalhist=1&history=1&fwname=$fwname&xls=1\">" . 'XLS</a></li>'. "\n";
}
elsif ($history){
	push @menu_header, '<li class=top><a href=' . "\"?fw=$fw&vsys=$vsys&history=1&xls=1\">" . 'XLS</a></li>'. "\n";
}
push @menu_header, '<li class=top><a href=' . "\"?fw=$fw&fwname=$fwname&vsys=$vsys&view=$view&showall=1\">" . 'Showall</a></li>'. "\n" ;
push @menu_header, '<li class=top><a href=' . "\"?fw=$fw&legacy=1\">" . 'Past Configs</a></li>' . "\n";
push @menu_header, '<li class=top><a href=' . "\"?fw=$fw&vsys=$vsys&history=1\">" . 'History</a></li>' . "\n";
push @menu_header, '<li class=top><a href=' . "\"?globalhist=1\">" . 'Global History</a></li>' . "\n";
push @menu_header, '<li class=top><a href=' . "\"?fw=$fw&vsys=$vsys&search=1&rule_tracker=$rule_tracker\">" . 'Search</a></li>' . "\n";
push @menu_header, '<li class=top><a href=' . "\"./runnow.pl?fw=$fw\">" . 'Update</a></li>' . "\n" if $fw;
push @menu_header, '<li class=top><a href=' . "\"?fw=$fw&vsys=$vsys&rule_tracker=1\">" . 'Rule Tracker</a></li>' . "\n" ;
push @menu_header, '<li class=top><a href=' . "\"./mate/rule_tracker.php?fw=$rule_tracker_search\">" . 'Rule Tracker Database</a></li>'. "\n" if $rule_tracker;
push @menu_header, '
 </li>
</ul>
 </li>
<br>
<br>';

#push @print_array,  '<table style="table-layout:fixed;width:1200px;border:15pt">';


my @rules_array = ('prerule','rule','postrule');

if ($legacy){
	opendir my($dh), "$scriptroot/xml" or die "Couldn't open dir '$scriptroot/xml': $!";
	my @files = readdir $dh;
	closedir $dh;

	foreach my $file1 (@files) {
		(my $file = $file1) =~ s/\.[^.]+$//;
		if ($file =~ /$fw-/){
			push @print_array, '<li><a href='  . "\"?fw=$fw&fwname=$file\"> $file" . '</a></li>';
		}	
	}
	
}
elsif ($globalhist && !$fwname){
        opendir my($dh), "$scriptroot/globalxml" or die "Couldn't open dir '$scriptroot/globalxml': $!";
        my @files = readdir $dh;
        closedir $dh;

        foreach my $file1 (@files) {
                (my $file = $file1) =~ s/\.[^.]+$//;
                if ($file =~ /$fw-/){
                        push @print_array, '<li><a href='  . "\"?globalhist=1&history=1&fwname=$file\"> $file" . '</a></li>';
                }
        }

}
else{

push @print_array,  '<table class="rules">';
push @print_array,  "<tbody align=\"center\">\n";
if ($history){
&push_header();
#	foreach my $rule_type (@rules_array){ 
		my @rulenum =();
			foreach $key (keys( % {$xml_ok{'vsys'}{$vsys}{'count'}} ) ) {
				$key =~ s/R//g;
				push @rulenum, $key;
			}
			my @rulenum1 = sort { $a <=> $b } @rulenum;
		my $count = ();
		foreach my $rulenum (@rulenum1){
			$rulenum = "R". $rulenum;
			&xml_get_rule_values(2,$rule_type,$rulenum,$count);
			$count++;

		}
#	}
}
elsif ($view eq 'regular'){
&push_header();
	my ($hold_rule_type,$send_border,$rulenotset,$preruleset) =();
	foreach my $rule_type (@rules_array){ 
		my @rulenum =();
			foreach $key (keys( % {$xml_ok{'vsys'}{$vsys}{$rule_type}} ) ) {
				push @rulenum, $key;
			}
			@rulenum = sort { $a <=> $b } @rulenum;
		if ($rule_type eq 'rule' && $hold_rule_type eq 'prerule' && @rulenum){
			$send_border = 1;
		}
		elsif ($rule_type eq 'postrule' && @rulenum && $rulenotset && $preruleset){
			$send_border = 1;
		}
		elsif ($rule_type eq 'postrule' && $hold_rule_type eq 'rule' && @rulenum){
			$send_border = 1;
		}
		elsif ($rule_type eq 'rule' && $hold_rule_type eq 'prerule' && !@rulenum){
			$rulenotset = 1;
		}
		elsif ($rule_type eq 'prerule' && @rulenum){
			$preruleset = 1;
		}
		foreach my $rulenum (@rulenum){
			&xml_get_rule_values(1,$rule_type,$rulenum,0,$send_border);
			$send_border = "";
		}
		$hold_rule_type = $rule_type if @rulenum;
	}
}
elsif ($view eq 'tag'){
	my (@tag_rule,@getuniq) = ();
	my ($hold_rule_type,$send_border,$rulenotset,$preruleset) =();
	foreach my $rule_type (@rules_array){ 
		my @rulenum =();
                foreach my $current_rulename (keys( % {$xml_ok{'vsys'}{$vsys}{$rule_type}} ) ) {
                        push @rulenum, $current_rulename;
		
                }
       	        @rulenum = sort { $a <=> $b } @rulenum;
		foreach my $rulenum (@rulenum){
			my $tag = $xml_ok{'vsys'}{$vsys}{$rule_type}{$rulenum}{'entry'}{'tag'};
			my @tag = split(/,/,$tag);
			foreach my $current_tag (@tag){
				push @tag_rule, "$rulenum,$rule_type,$current_tag,$send_border";
				push @getuniq, $current_tag;
			}
		}
	}
	my @getuniq1 = &uniq(@getuniq);
	my $count = 1;
	foreach my $uniqtag (@getuniq1){
		&push_header();
		&push_tag_header($uniqtag);
		foreach my $tag_rule (@tag_rule){
			my @splittag = split(/,/,$tag_rule);
			my $rulenum = $splittag[0];
			my $rule_type = $splittag[1];
			my $current_tag = $splittag[2];
			my $send_border = $splittag[3];
#	                if ($rule_type eq 'postrule' && $rulenotset && $preruleset){
#	                        $send_border = 1;
#	                }
#			if ($rule_type eq 'rule'){
#				$rulenotset = 1;
#				print "Cow $rulenotset";
#			}
			if ($uniqtag eq $current_tag){
=begin
				if ($rule_type eq 'rule' && $hold_rule_type eq 'prerule'){
					$send_border = 1;
		                        $rulenotset = 0;
					print "$preruleset himbb";
				}
		                elsif ($rule_type eq 'postrule' && $rulenotset && $preruleset){
		                        $send_border = 1;
					print "$preruleset himxx";
		                }
				elsif ($rule_type eq 'postrule' && $hold_rule_type eq 'rule'){
					$send_border = 1;
				}
		                elsif ($rule_type eq 'rule' && $hold_rule_type eq 'prerule'){
		                        $rulenotset = 0;
					print "$preruleset him";
		                }
	        	        elsif ($rule_type eq 'prerule' ){
		                        $preruleset = 1;	
					print "$preruleset her";
		                }
	        	        elsif ($rule_type eq 'rule' ){
		                        $rulenotset = 0;	
					print "$preruleset is rul now";
		                }
=cut
	
				if ($rule_type eq 'rule' && $hold_rule_type eq 'prerule'){
					$send_border = 1;
				}
				elsif ($rule_type eq 'postrule' && $hold_rule_type eq 'rule'){
					$send_border = 1;
				}
				elsif ($rule_type eq 'postrule' && $hold_rule_type eq 'prerule' ){
					$send_border = 1;
				}
				&xml_get_rule_values(1,$rule_type,$rulenum,$count,$send_border);	
				$count++;
				$send_border = "";
			}
			$hold_rule_type = $rule_type;
		}
	}
}
elsif ($view eq 'zone'){
        my (@zone_rule,@getuniq,%fromto_hash,@check_array) = ();
	my ($hold_rule_type,$send_border,$rulenotset,$preruleset) =();
        foreach my $rule_type (@rules_array){
                my @rulenum =();
                foreach my $current_rulename (keys( % {$xml_ok{'vsys'}{$vsys}{$rule_type}} ) ) {
                        push @rulenum, $current_rulename;

                }
                @rulenum = sort { $a <=> $b } @rulenum;
                foreach my $rulenum (@rulenum){
                        my $from = $xml_ok{'vsys'}{$vsys}{$rule_type}{$rulenum}{'entry'}{'from'};
                        my @from = split(/,/,$from);
                        my $to = $xml_ok{'vsys'}{$vsys}{$rule_type}{$rulenum}{'entry'}{'to'};
                        my @to = split(/,/,$to);
			foreach my $current_from (@from ){
				foreach my $current_to (@to){
					push @check_array, "$current_from,$current_to,$rule_type,$rulenum,$send_border";
					push @getuniq, $to;
					push @getuniq, $from;
				}
				$hold_rule_type = $rule_type;
			}
                }
        }
	my ($start) = ();
	my $count = 1;
        my @getuniq1 = &uniq(@getuniq);
        foreach my $from_uniq (@getuniq1){
		foreach my $to_uniq (@getuniq1){
			$start = ();
			foreach my $line (@check_array){
				my @splitline = split(/,/,$line);
				$now_from = $splitline[0];
				$now_to = $splitline[1];
				$rule_type = $splitline[2];
				$rulenum = $splitline[3];
				if ($from_uniq eq $now_from && $to_uniq eq $now_to || 'any' eq $now_from && 'any' eq $now_to  && $start || 'any' eq $now_from && $to_uniq eq $now_to && $start || $from_uniq eq $now_from && 'any' eq $now_to && $start){
					&push_header() if !$start;
					&push_zone_header($from_uniq,$to_uniq) if !$start;
					if ($rule_type eq 'rule' && $hold_rule_type eq 'prerule'){
						$send_border = 1;
					}
					elsif ($rule_type eq 'postrule' && $hold_rule_type eq 'rule'){
						$send_border = 1;
					}
					elsif ($rule_type eq 'postrule' && $hold_rule_type eq 'prerule' ){
						$send_border = 1;
					}
					&xml_get_rule_values(1,$rule_type,$rulenum,$count,$send_border);
					$start = 1;
					$send_border = "";
					$count++;
				}
				$hold_rule_type = $rule_type;


			}
		}
	}
}

push @print_array, '</table>';
}

push @print_array, '<br><br>';
push @print_array, '</body>';
push @print_array, '</html>';
#foreach $line (@print_header_array){
#	print "$line";
#}
print $header1;
print $style;
print $header2;
print $header3;
#print $header4;
#print $header3;
foreach $line (@menu_header){
	print "$line";
}
#print '<a href=' . "\"./xml/$fw.xls\">" .  'Download</a>' if $xls;
my $link = '<a href=' . "\"./xls/$fw-$vsys-$view.xls\">" .  'Download</a>';
#foreach $line (@print_close_array){
#	print "$line";
#}
if ($xls && $fw ){
	$link = '<a href=' . "\"./xls/$fw.xls\">" .  'Download</a>';
	print $link;
	open FILE1, ">$webroot/xls/$fw.xls" or die $!;
	        print FILE1 "$header1";
	        print FILE1 "$style";
	        print FILE1 "$header3";
	        print FILE1 "@print_array";
	close FILE1;
}
elsif ($xls && $fwname && $globalhist ){
	$link = '<a href=' . "\"./xls/$fwname.xls\">" .  'Download</a>';
	print $link;
	open FILE1, ">$webroot/xls/$fwname.xls" or die $!;
	        print FILE1 "$header1";
	        print FILE1 "$style";
	        print FILE1 "$header3";
	        print FILE1 "@print_array";
	close FILE1;
}
foreach $line (@print_array){
	print "$line";
}

sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}

sub push_zone_header {
	my $source = shift;
	my $destination = shift;

	push @print_array,  "<tr class=\"header2\">";
	push @print_array,  "<th colspan=\"$col_num\">" . "From $source to $destination" .'</th>';
	push @print_array,  "</tr>";
}

sub push_tag_header {
	my $tag = shift;

	push @print_array,  "<tr class=\"header2\">";
	push @print_array,  "<th colspan=\"$col_num\">" . "Tag $tag" .'</th>';
	push @print_array,  "</tr>";
}

sub push_header {




push @print_array,  "<tr class=\"header\">";
push @print_array,  "<th></th>" if $history;
push @print_array,  "<th></th>" if $col_name;
push @print_array,  "<th></th>" if $col_description;
push @print_array,  "<th></th>" if $col_tag;
push @print_array,  "<th colspan=\"" . $src_col_span . "\">Source</th>" if $src_col_span;
push @print_array,  "<th colspan=\"" . $dst_col_span. "\">Destination</th>" if $dst_col_span;
push @print_array,  "<th></th>" if $col_app;
push @print_array,  "<th></th>" if $col_service;
push @print_array,  "<th></th>" if $col_serviceval;
push @print_array,  "<th></th>" if $col_action;
push @print_array,  "<th></th>" if $col_profile;
push @print_array,  "<th></th>" if $col_option;
push @print_array,  "<th></th>" if $history;
push @print_array,  $push_col_head if $rule_tracker;
push @print_array,  "</tr>";

if ($xls){
push @print_array,  "<tr class=\"header\">";
push @print_array,  "<th>change</a></th>\n" if $history;
push @print_array,  "<th>name</a></th>\n" if $col_name;
push @print_array,  "<th>description</a></th>\n" if $col_description;
push @print_array,  "<th>tag</a></th>\n" if $col_tag;
push @print_array,  "<th>from</a></th>\n" if $col_from;
push @print_array,  "<th>source</a></th>\n" if $col_source;
push @print_array,  "<th>src ip</a></th>\n" if $col_sourceip;
push @print_array,  "<th>src user</a></th>\n" if $col_sourceuser;
#push @print_array,  "<th>hip_profiles</th>\n" if $col_dst;
push @print_array,  "<th>to</a></th>\n" if $col_to;
push @print_array,  "<th>destination</a></th>\n" if $col_dst;
push @print_array,  "<th>dst ip</a></th>\n" if $col_dstip;
push @print_array,  "<th>application</a></th>\n" if $col_app;
push @print_array,  "<th>service</a></th>\n" if $col_service;
push @print_array,  "<th>service value</a></th>\n" if $col_serviceval;
#push @print_array,  "<th>category</th>\n";
push @print_array,  "<th>action</a></th>\n" if $col_action;
push @print_array,  "<th>profile</a></th>\n" if $col_profile;
push @print_array,  "<th>options</a></th>\n" if $col_option;
push @print_array,  "<th>date</a></th>\n" if $history;
push @print_array,  $push_col_head_xls if $rule_tracker;
push @print_array,  "</tr>";
}
else {
push @print_array,  "<tr class=\"header\">";
push @print_array,  "<th><a href=\"" . &format_column('col_history') . "\">change</a></th>\n" if $history;
push @print_array,  "<th><a href=\"" . &format_column('col_name') . "\">name</a></th>\n" if $col_name;
push @print_array,  "<th><a href=\"" . &format_column('col_description') . "\">description</a></th>\n" if $col_description;
push @print_array,  "<th><a href=\"" . &format_column('col_tag') . "\">tag</a></th>\n" if $col_tag;
push @print_array,  "<th><a href=\"" . &format_column('col_from') . "\">from</a></th>\n" if $col_from;
push @print_array,  "<th><a href=\"" . &format_column('col_source') . "\">source</a></th>\n" if $col_source;
push @print_array,  "<th><a href=\"" . &format_column('col_sourceip') . "\">src ip</a></th>\n" if $col_sourceip;
push @print_array,  "<th><a href=\"" . &format_column('col_sourceuser') . "\">src user</a></th>\n" if $col_sourceuser;
#push @print_array,  "<th>hip_profiles</th>\n";
push @print_array,  "<th><a href=\"" . &format_column('col_to') . "\">to</a></th>\n" if $col_to;
push @print_array,  "<th><a href=\"" . &format_column('col_dst') . "\">destination</a></th>\n" if $col_dst;
push @print_array,  "<th><a href=\"" . &format_column('col_dstip') . "\">dst ip</a></th>\n" if $col_dstip;
push @print_array,  "<th><a href=\"" . &format_column('col_app') . "\">application</a></th>\n" if $col_app;
push @print_array,  "<th><a href=\"" . &format_column('col_service') . "\">service</a></th>\n" if $col_service;
push @print_array,  "<th><a href=\"" . &format_column('col_serviceval') . "\">service value</a></th>\n" if $col_serviceval;
#push @print_array,  "<th>category</th>\n";
push @print_array,  "<th><a href=\"" . &format_column('col_action') . "\">action</a></th>\n" if $col_action;
push @print_array,  "<th><a href=\"" . &format_column('col_profile') . "\">profile</a></th>\n" if $col_profile;
push @print_array,  "<th><a href=\"" . &format_column('col_option') . "\">options</a></th>\n" if $col_option;
push @print_array,  "<th><a href=\"" . &format_column('col_date') . "\">date</a></th>\n" if $history;
push @print_array,  $push_col_head_htm if $rule_tracker;
push @print_array,  "</tr>";
}
#my $search = 1;
if ($search) {
my $cicheck = 'checked="1"' if $ci;
my $fmcheck = 'checked="1"' if $fm;
push @print_array, "<form action=\"./pa.pl\" method=\"GET\" name=\"session\">\n";
push @print_array, "<th colspan=\"$col_num\" align=left>";
push @print_array, 'Match: <input type="radio" name="st" value="any">Any <input type="radio" name="st" checked="checked" value="all">All';
push @print_array, '&nbsp&nbsp || Case Sensitve: <input type="checkbox" value=1 ' . $cicheck . ' name="ci">';
push @print_array, '&nbsp&nbsp || Match Full Line: <input type="checkbox" value=1 ' . $fmcheck . ' name="fm">';
push @print_array, "&nbsp&nbsp ||  XLS: <input type=\"checkbox\" name=xls>";
push @print_array, "&nbsp&nbsp&nbsp&nbsp<input type=\"submit\" value=\"Submit\" />" ;
push @print_array, '</th>';
push @print_array, "<input hidden name=fw value=$fw>";
push @print_array, "<input hidden name=vsys value=$vsys>";
push @print_array, "<input hidden name=view value=$view>";
push @print_array, "<input hidden name=rule_tracker value=$rule_tracker>";
push @print_array, "<input hidden name=cols value=\"$cols\">";
push @print_array, "<input hidden name=search value=$search>";
#push @print_array, "<input hidden name=xls value=$xls>";

push @print_array,  "<tr class=\"header\">";
#push @print_array,  "<th>First name: <input type=\"text\" name=\"s1\"></th>\n" if $history;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s1\" value=\"$col_name_search\"></th>\n" if $col_name;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s2\" value=\"$col_description_search\"></th>\n" if $col_description;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s3\" value=\"$col_tag_search\"></th>\n" if $col_tag;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s4\" value=\"$col_from_search\"></th>\n" if $col_from;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s5\" value=\"$col_source_search\"></th>\n" if $col_source;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s6\" value=\"$col_sourceip_search\"></th>\n" if $col_sourceip;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s7\" value=\"$col_sourceuser_search\"></th>\n" if $col_sourceuser;
#push @print_array,  "<th>hip_profiles</th>\n";
push @print_array,  "<th><input size=10 type=\"text\" name=\"s8\" value=\"$col_to_search\"></th>\n" if $col_to;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s9\" value=\"$col_dst_search\"></th>\n" if $col_dst;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s10\" value=\"$col_dstip_search\"></th>\n" if $col_dstip;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s11\" value=\"$col_app_search\"></th>\n" if $col_app;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s12\" value=\"$col_service_search\"></th>\n" if $col_service;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s13\" value=\"$col_serviceval_search\"></th>\n" if $col_serviceval;
#push @print_array,  "<th>category</th>\n";
push @print_array,  "<th><input size=3 type=\"text\" name=\"s14\" value=\"$col_action_search\"></th>\n" if $col_action;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s15\" value=\"$col_profile_search\"></th>\n" if $col_profile;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s16\" value=\"$col_option_search\"></th>\n" if $col_option;
push @print_array,  "<th><input size=10 type=\"text\" name=\"s17\" value=></th>\n" if $history;
push @print_array,  $push_col_head_search if $rule_tracker;
push @print_array,  "</tr>";
}




}


sub xml_get_rule_values {

		my $get_type = shift;
                my $current_rule_type = shift;
                my $current_rulenum = shift;
                my $current_count = shift;
                my $send_border = shift;
	
		
#print "$current_rule_type - $current_rulenum - count-$current_count  - $send_border<br>\n";
		my ($fw_current_name,$name,$description, $tag, $to, $schedule, $negate_source, $source_address_out, $source_address_value_out, $destination_address_out, $destination_address_value_out, $from, $negate_destination, $log_start, $log_end, $log_setting, $source_user, $application, $service_out, $service_value_out, $action, $virus, $vulnerability, $spyware, $url_filtering, $data_filtering, $file_blocking, $group, $disabled, $qos, $change ) = (); 
		if ($get_type == 1){
                     $name = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'name'};
                     $current_fw_name = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'current_fw_name'} if $globalhist;
                     $current_vsys = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'current_vsys'} if $globalhist;
                     $description = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'description'};
                     $tag = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'tag'};
                     $to = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'to'};
                     $schedule = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'schedule'};
                     $negate_source = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'negate_source'};
                     $source_address_out = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'source_address_out'};
                     $source_address_value_out = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'source_address_value_out'};
                     $destination_address_out = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'destination_address_out'};
                     $destination_address_value_out = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'destination_address_value_out'};
                     $from = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'from'};
                     $negate_destination = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'negate_destination'};
                     $log_start = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'log_start'};
                     $log_end = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'log_end'};
                     $log_setting = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'log_setting'};
                     $source_user = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'source_user'};
                     $application = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'application'};
                     $service_out = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'service_out'};
                     $service_value_out = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'service_value_out'};
                     $action = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'action'};
                     $virus = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'virus'};
                     $vulnerability = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'vulnerability'};
                     $spyware = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'spyware'};
                     $url_filtering = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'url_filtering'};
                     $data_filtering = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'data_filtering'};
                     $file_blocking = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'file_blocking'};
                     $group = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'group'};
                     $disabled = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'disabled'};
                     $qos = $xml_ok{'vsys'}{$vsys}{$current_rule_type}{$current_rulenum}{'entry'}{'qos'};
		}
                elsif ($get_type == 2){
		     $name = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'name'};
                     $current_fw_name = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'current_fw_name'} if $globalhist;
                     $current_vsys = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'current_vsys'} if $globalhist;
                     $description = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'description'};
                     $tag = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'tag'};
                     $to = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'to'};
                     $schedule = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'schedule'};
                     $negate_source = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'negate_source'};
                     $source_address_out = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'source_address_out'};
                     $source_address_value_out = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'source_address_value_out'};
                     $destination_address_out = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'destination_address_out'};
                     $destination_address_value_out = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'destination_address_value_out'};
                     $from = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'from'};
                     $negate_destination = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'negate_destination'};
                     $log_start = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'log_start'};
                     $log_end = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'log_end'};
                     $log_setting = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'log_setting'};
                     $source_user = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'source_user'};
                     $application = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'application'};
                     $service_out = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'service_out'};
                     $service_value_out = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'service_value_out'};
                     $action = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'action'};
                     $virus = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'virus'};
                     $vulnerability = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'vulnerability'};
                     $spyware = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'spyware'};
                     $url_filtering = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'url_filtering'};
                     $data_filtering = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'data_filtering'};
                     $file_blocking = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'file_blocking'};
                     $group = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'group'};
                     $disabled = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'disabled'};
                     $qos = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'qos'};
                     $change = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'change'};
                     $date = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'date'};

                     $tag_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'tag_mismatch'};
                     $desc_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'desc_mismatch'};
                     $from_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'from_mismatch'};
                     $source_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'source_mismatch'};
                     $srcuser_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'srcuser_mismatch'};
                     $to_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'to_mismatch'};
                     $destination_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'destination_mismatch'};
                     $app_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'app_mismatch'};
                     $service_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'service_mismatch'};
                     $action_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'action_mismatch'};
                     $options_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'options_mismatch'};
                     $profile_mismatch = $xml_ok{'vsys'}{$vsys}{'count'}{$current_rulenum}{'entry'}{'entry'}{'profile_mismatch'};

		#	print "$name, $tag, $to, $schedule, $negate_source, $source_address_out, $source_address_value_out, $destination_address_out, $destination_address_value_out,";
                }



#push @print_array, "$return_name $return_tag \n";
#	return ($return_name , $return_tag, $return_to , $return_negate_source , $return_source_address_out , $return_source_address_value_out , $return_destination_address_out , $return_destination_address_value_out , $return_from , $return_negate_destination, $return_log_start , $return_log_end , $return_source_user , $return_application , $return_service_out , $return_service_value_out , $return_action);


                if ($rule_tracker) {
                        $bapp = $bapp_hash{$description};
                        $breason = $breason_hash{$description};
                        $bgroup = $bgroup_hash{$description};
                        $flags = $flags_hash{$description} if $special_case1;

                        @bgroup = &format_output($bgroup);
                        @breason = &format_output($breason);
                        @bapp = &format_output($bapp);
                        @flags = &format_output($flags) if $special_case1;
                }

                my @schedule = ();
                $schedule[0] = $schedule;
                my @qos = ();
                $qos[0] = $qos;
                my @name = &format_output($name);
		my @current_fw_name = &format_output($current_fw_name);
		my @current_vsys = &format_output($current_vsys);
                my @change = &format_output($change);
                my @tag =  &format_output($tag);
                my @description = &format_output($description);
                my @from =  &format_output($from);
                my @negate_source = &format_output($negate_source);
                my @source_address_out = &format_output($source_address_out);
                my @source_address_value_out =  &format_output($source_address_value_out);
                my @source_user = &format_output($source_user);
#                &format_output($hip_profiles2);
                my @to =  &format_output($to);
                my @negate_destination = &format_output($negate_destination);
                my @destination_address_out = &format_output($destination_address_out);
                my @destination_address_value_out = &format_output($destination_address_value_out);
                my @application_out = &format_output($application);
                my @service_out = &format_output($service_out);
                my @service_value_out = &format_output($service_value_out);
#                &format_output($category);
                my @action = &format_output($action);
                my @log_start = &format_output($log_start);
                my @log_end = &format_output($log_end);
                my @log_setting = &format_output($log_setting);
                my @spyware = &format_output($spyware);
                my @virus = &format_output($virus);
                my @vulnerability = &format_output($vulnerability);
                my @url_filtering = &format_output($url_filtering);
                my @data_filtering = &format_output($data_filtering);
                my @file_blocking = &format_output($file_blocking);
                my @group = &format_output($group);
                my @date = &format_output($date);

		my @option_out = ();
		push @option_out, @log_start;
		push @option_out, @log_end;
		push @option_out, @log_setting;
		my @profile_out = ();
		push @profile_out, @spyware;
		push @profile_out, @virus;
		push @profile_out, @vulnerability;
		push @profile_out, @url_filtering;
		push @profile_out, @data_filtering;
		push @profile_out, @file_blocking;
#                &format_output($virus $spyware $vuln );
#                &format_output($spyware);
#                &format_output($vuln);
#                &format_output($log_set);
#                &format_output($target);
#                &format_output($option);
#                 "<td>$option</td>\n";

=begin
		my ($found_tag,$found_from)=();
		my $match_tag = 'standard';
		if ($match_tag && grep /$match_tag/, @tag) {
			$found_tag = 1;;
		}
		my $match_from = 'Blueco';
		if ($match_from && grep /$match_from/, @from) {
			$found_from =1;
		}
=cut

		my ($found_name, $found_description, $found_tag, $found_from, $found_source, $found_sourceip, $found_sourceuser, $found_to, $found_dst, $found_dstip, $found_app, $found_service, $found_serviceval, $found_action, $found_profile, $found_option,$found_bgroup,$found_breason,$found_bapp,$found_flags) =();

		my ($caseInsentiveFullLineMatch,$caseSentiveFullLineMatch,$caseInsentivePartialLineMatch,$caseSentivePartialLineMatch)=();

		if ($ci & $fm){
			$caseSentiveFullLineMatch = 1;
		}
		elsif (!$ci & $fm){
			$caseInsentiveFullLineMatch = 1;
		}
		elsif (($ci) & !($fm)){
			$caseSentivePartialLineMatch = 1;
		}
		elsif (!$ci & !$fm){
			$caseInsentivePartialLineMatch = 1;
		}

                if (
			($col_name_search_set && $caseSentivePartialLineMatch && grep /$col_name_search/, @name) ||
			($col_name_search_set && $caseInsentivePartialLineMatch && grep /$col_name_search/i, @name) ||
			($col_name_search_set && $caseSentiveFullLineMatch && grep /^$col_name_search$/, @name) ||
			($col_name_search_set && $caseInsentiveFullLineMatch && grep /^$col_name_search$/i, @name)
		 ) {
                        $found_name  = 1;
                }	
                if (
			($col_description_search_set && $caseSentivePartialLineMatch && grep /$col_description_search/, @description) ||
			($col_description_search_set && $caseInsentivePartialLineMatch && grep /$col_description_search/i, @description) ||
			($col_description_search_set && $caseSentiveFullLineMatch && grep /^$col_description_search$/, @description) ||
			($col_description_search_set && $caseInsentiveFullLineMatch && grep /^$col_description_search$/i, @description)
		 ) {
                        $found_description  = 1;
                }	
                if (
			($col_tag_search_set && $caseSentivePartialLineMatch && grep /$col_tag_search/, @tag) ||
			($col_tag_search_set && $caseInsentivePartialLineMatch && grep /$col_tag_search/i, @tag) ||
			($col_tag_search_set && $caseSentiveFullLineMatch && grep /^$col_tag_search$/, @tag) ||
			($col_tag_search_set && $caseInsentiveFullLineMatch && grep /^$col_tag_search$/i, @tag)
		 ) {
                        $found_tag  = 1;
                }	
                if (
			($col_from_search_set && $caseSentivePartialLineMatch && grep /$col_from_search/, @from) ||
			($col_from_search_set && $caseInsentivePartialLineMatch && grep /$col_from_search/i, @from) ||
			($col_from_search_set && $caseSentiveFullLineMatch && grep /^$col_from_search$/, @from) ||
			($col_from_search_set && $caseInsentiveFullLineMatch && grep /^$col_from_search$/i, @from)
		 ) {
                        $found_from  = 1;
                }	
                if (
			($col_source_search_set && $caseSentivePartialLineMatch && grep /$col_source_search/, @source_address_out) ||
			($col_source_search_set && $caseInsentivePartialLineMatch && grep /$col_source_search/i, @source_address_out) ||
			($col_source_search_set && $caseSentiveFullLineMatch && grep /^$col_source_search$/, @source_address_out) ||
			($col_source_search_set && $caseInsentiveFullLineMatch && grep /^$col_source_search$/i, @source_address_out)
		 ) {
                        $found_source  = 1;
                }	
                if (
			($col_sourceip_search_set && $caseSentivePartialLineMatch && grep /$col_sourceip_search/, @source_address_value_out) ||
			($col_sourceip_search_set && $caseInsentivePartialLineMatch && grep /$col_sourceip_search/i, @source_address_value_out) ||
			($col_sourceip_search_set && $caseSentiveFullLineMatch && grep /^$col_sourceip_search$/, @source_address_value_out) ||
			($col_sourceip_search_set && $caseInsentiveFullLineMatch && grep /^$col_sourceip_search$/i, @source_address_value_out)
		 ) {
                        $found_sourceip  = 1;
                }	
                if (
			($col_sourceuser_search_set && $caseSentivePartialLineMatch && grep /$col_sourceuser_search/, @source_user) ||
			($col_sourceuser_search_set && $caseInsentivePartialLineMatch && grep /$col_sourceuser_search/i, @source_user) ||
			($col_sourceuser_search_set && $caseSentiveFullLineMatch && grep /^$col_sourceuser_search$/, @source_user) ||
			($col_sourceuser_search_set && $caseInsentiveFullLineMatch && grep /^$col_sourceuser_search$/i, @source_user)
		 ) {
                        $found_sourceuser  = 1;
                }	
                if (
			($col_to_search_set && $caseSentivePartialLineMatch && grep /$col_to_search/, @to) ||
			($col_to_search_set && $caseInsentivePartialLineMatch && grep /$col_to_search/i, @to) ||
			($col_to_search_set && $caseSentiveFullLineMatch && grep /^$col_to_search$/, @to) ||
			($col_to_search_set && $caseInsentiveFullLineMatch && grep /^$col_to_search$/i, @to)
		 ) {
                        $found_to  = 1;
                }	
                if (
			($col_dst_search_set && $caseSentivePartialLineMatch && grep /$col_dst_search/, @destination_address_out) ||
			($col_dst_search_set && $caseInsentivePartialLineMatch && grep /$col_dst_search/i, @destination_address_out) ||
			($col_dst_search_set && $caseSentiveFullLineMatch && grep /^$col_dst_search$/, @destination_address_out) ||
			($col_dst_search_set && $caseInsentiveFullLineMatch && grep /^$col_dst_search$/i, @destination_address_out)
		 ) {
                        $found_dst  = 1;
                }	
                if (
			($col_dstip_search_set && $caseSentivePartialLineMatch && grep /$col_dstip_search/, @destination_address_value_out) ||
			($col_dstip_search_set && $caseInsentivePartialLineMatch && grep /$col_dstip_search/i, @destination_address_value_out) ||
			($col_dstip_search_set && $caseSentiveFullLineMatch && grep /^$col_dstip_search$/, @destination_address_value_out) ||
			($col_dstip_search_set && $caseInsentiveFullLineMatch && grep /^$col_dstip_search$/i, @destination_address_value_out)
		 ) {
                        $found_dstip  = 1;
                }	
                if (
			($col_app_search_set && $caseSentivePartialLineMatch && grep /$col_app_search/, @application_out) ||
			($col_app_search_set && $caseInsentivePartialLineMatch && grep /$col_app_search/i, @application_out) ||
			($col_app_search_set && $caseSentiveFullLineMatch && grep /^$col_app_search$/, @application_out) ||
			($col_app_search_set && $caseInsentiveFullLineMatch && grep /^$col_app_search$/i, @application_out)
		 ) {
                        $found_app  = 1;
                }	
                if (
			($col_service_search_set && $caseSentivePartialLineMatch && grep /$col_service_search/, @service_out) ||
			($col_service_search_set && $caseInsentivePartialLineMatch && grep /$col_service_search/i, @service_out) ||
			($col_service_search_set && $caseSentiveFullLineMatch && grep /^$col_service_search$/, @service_out) ||
			($col_service_search_set && $caseInsentiveFullLineMatch && grep /^$col_service_search$/i, @service_out)
		 ) {
                        $found_service  = 1;
                }	
                if (
			($col_serviceval_search_set && $caseSentivePartialLineMatch && grep /$col_serviceval_search/, @service_out_val) ||
			($col_serviceval_search_set && $caseInsentivePartialLineMatch && grep /$col_serviceval_search/i, @service_out_val) ||
			($col_serviceval_search_set && $caseSentiveFullLineMatch && grep /^$col_serviceval_search$/, @service_out_val) ||
			($col_serviceval_search_set && $caseInsentiveFullLineMatch && grep /^$col_serviceval_search$/i, @service_out_val)
		 ) {
                        $found_serviceval  = 1;
                }	
                if (
			($col_action_search_set && $caseSentivePartialLineMatch && grep /$col_action_search/, @action) ||
			($col_action_search_set && $caseInsentivePartialLineMatch && grep /$col_action_search/i, @action) ||
			($col_action_search_set && $caseSentiveFullLineMatch && grep /^$col_action_search$/, @action) ||
			($col_action_search_set && $caseInsentiveFullLineMatch && grep /^$col_action_search$/i, @action)
		 ) {
                        $found_action  = 1;
                }	
                if (
			($col_profile_search_set && $caseSentivePartialLineMatch && grep /$col_profile_search/, @profile_out) ||
			($col_profile_search_set && $caseInsentivePartialLineMatch && grep /$col_profile_search/i, @profile_out) ||
			($col_profile_search_set && $caseSentiveFullLineMatch && grep /^$col_profile_search$/, @profile_out) ||
			($col_profile_search_set && $caseInsentiveFullLineMatch && grep /^$col_profile_search$/i, @profile_out)
		 ) {
                        $found_profile  = 1;
                }	
                if (
			($col_option_search_set && $caseSentivePartialLineMatch && grep /$col_option_search/, @option_out) ||
			($col_option_search_set && $caseInsentivePartialLineMatch && grep /$col_option_search/i, @option_out) ||
			($col_option_search_set && $caseSentiveFullLineMatch && grep /^$col_option_search$/, @option_out) ||
			($col_option_search_set && $caseInsentiveFullLineMatch && grep /^$col_option_search$/i, @option_out)
		 ) {
                        $found_option  = 1;
                }	
                if (
			($col_bgroup_search_set && $caseSentivePartialLineMatch && grep /$col_bgroup_search/, @bgroup) ||
			($col_bgroup_search_set && $caseInsentivePartialLineMatch && grep /$col_bgroup_search/i, @bgroup) ||
			($col_bgroup_search_set && $caseSentiveFullLineMatch && grep /^$col_bgroup_search$/, @bgroup) ||
			($col_bgroup_search_set && $caseInsentiveFullLineMatch && grep /^$col_bgroup_search$/i, @bgroup)
		 ) {
                        $found_bgroup  = 1;
                }	
                if (
			($col_bapp_search_set && $caseSentivePartialLineMatch && grep /$col_bapp_search/, @bapp) ||
			($col_bapp_search_set && $caseInsentivePartialLineMatch && grep /$col_bapp_search/i, @bapp) ||
			($col_bapp_search_set && $caseSentiveFullLineMatch && grep /^$col_bapp_search$/, @bapp) ||
			($col_bapp_search_set && $caseInsentiveFullLineMatch && grep /^$col_bapp_search$/i, @bapp)
		 ) {
                        $found_bapp  = 1;
                }	
                if (
			($col_breason_search_set && $caseSentivePartialLineMatch && grep /$col_breason_search/, @breason) ||
			($col_breason_search_set && $caseInsentivePartialLineMatch && grep /$col_breason_search/i, @breason) ||
			($col_breason_search_set && $caseSentiveFullLineMatch && grep /^$col_breason_search$/, @breason) ||
			($col_breason_search_set && $caseInsentiveFullLineMatch && grep /^$col_breason_search$/i, @breason)
		 ) {
                        $found_breason  = 1;
                }	
                if (
			($col_flags_search_set && $caseSentivePartialLineMatch && grep /$col_flags_search/, @flags) ||
			($col_flags_search_set && $caseInsentivePartialLineMatch && grep /$col_flags_search/i, @flags) ||
			($col_flags_search_set && $caseSentiveFullLineMatch && grep /^$col_flags_search$/, @flags) ||
			($col_flags_search_set && $caseInsentiveFullLineMatch && grep /^$col_flags_search$/i, @flags)
		 ) {
                        $found_flags  = 1;
                }	


		my $found = ();
		if (
			($st eq 'all') &&
			($col_name_search_set && $found_name || !$col_name_search_set) &&
			($col_description_search_set && $found_description || !$col_description_search_set) &&
			($col_tag_search_set && $found_tag || !$col_tag_search_set) &&
			($col_from_search_set && $found_from || !$col_from_search_set) &&
			($col_source_search_set && $found_source || !$col_source_search_set) &&
			($col_sourceip_search_set && $found_sourceip || !$col_sourceip_search_set) &&
			($col_sourceuser_search_set && $found_sourceuser || !$col_sourceuser_search_set) &&
			($col_to_search_set && $found_to || !$col_to_search_set) &&
			($col_dst_search_set && $found_dst || !$col_dst_search_set) &&
			($col_dstip_search_set && $found_dstip || !$col_dstip_search_set) &&
			($col_app_search_set && $found_app || !$col_app_search_set) &&
			($col_service_search_set && $found_service || !$col_service_search_set) &&
			($col_serviceval_search_set && $found_serviceval || !$col_serviceval_search_set) &&
			($col_action_search_set && $found_action || !$col_action_search_set) &&
			($col_profile_search_set && $found_profile || !$col_profile_search_set) &&
			($col_option_search_set && $found_option || !$col_option_search_set) && 
			($col_bgroup_search_set && $found_bgroup || !$col_bgroup_search_set) &&
			($col_bapp_search_set && $found_bapp || !$col_bapp_search_set) &&
			($col_breason_search_set && $found_breason || !$col_breason_search_set) &&
			($col_flags_search_set && $found_flags || !$col_flags_search_set) 
  	
		){
			$found = 1;
		}
		elsif (
			($st eq 'any') &&(
                        ($col_name_search_set && $found_name ) ||
                        ($col_description_search_set && $found_description ) ||
                        ($col_tag_search_set && $found_tag ) ||
                        ($col_from_search_set && $found_from ) ||
                        ($col_source_search_set && $found_source ) ||
                        ($col_sourceip_search_set && $found_sourceip ) ||
                        ($col_sourceuser_search_set && $found_sourceuser ) ||
                        ($col_to_search_set && $found_to ) ||
                        ($col_dst_search_set && $found_dst ) ||
                        ($col_dstip_search_set && $found_dstip ) ||
                        ($col_app_search_set && $found_app ) ||
                        ($col_service_search_set && $found_service ) ||
                        ($col_serviceval_search_set && $found_serviceval ) ||
                        ($col_action_search_set && $found_action ) ||
                        ($col_profile_search_set && $found_profile ) ||
                        ($col_option_search_set && $found_option ) ||
                        ($col_bgroup_search_set && $found_bgroup ) ||
                        ($col_bapp_search_set && $found_bapp ) ||
                        ($col_breason_search_set && $found_breason ) ||
                        ($col_flags_search_set && $found_flags ))
		){
			$found = 1;
		}






		if ( ($found) || (!$st)){
		$global_count++;
		
		my (@log_out) = ();
		if ($xls){
	                if ($log_start[0] eq 'yes' || $log_end eq 'yes'){
	                        my $alt = ();
	                        if ($log_start[0] eq 'yes'){
	                	        $alt .= 'Log Start';
	                        }
	                        if ($log_end[0] eq 'yes'){
	        	                $alt .= ' Log End';
	                        }
		                $log_out[0] = "$alt ";
	                }
			if ($schedule[0]) {$schedule[0] = "Schedule: $schedule[0] "}
			if ($qos[0]) {$qos[0] = "Qos: $qos[0] "}
			if ($spyware[0]) {$spyware[0] = "Spyware: $spyware[0] "}
			if ($virus[0]) {$virus[0] = "Antivirus: $virus[0] "}
			if ($vulnerability[0]) {$vulnerability[0] = "Vulnerability: $vulnerability[0] "}
			if ($url_filtering[0]) {$url_filtering[0] = "URL: $url_filtering[0] "}
			if ($data_filtering[0]) {$data_filtering[0] = "Data: $data_filtering[0] "}
			if ($file_blocking[0]) {$file_blocking[0] = "File: $file_blocking[0] "}
			if ($group[0]) {$group[0] = "Profile Group: $group[0] "}
		}

		my $img_class = ();
		if (!$xls){
			if ($disabled eq 'yes'){
				$img_class = 'class=dsbld';
			}
			if ($action[0] eq 'allow') {$action[0] = "<img $img_class src=\"./images/allow.png\">"}
			elsif ($action[0] eq 'deny') {$action[0] = "<img $img_class src=\"./images/deny.png\">"}

			if ($qos[0]) {$qos[0] = "<img $img_class src=\"./images/qos.png\"  alt=\"QoS: $qos[0]\" title=\"QoS: $qos[0]\">"}
			if ($schedule[0]) {$schedule[0] = "<img $img_class src=\"./images/schedule.gif\"  alt=\"Schedule: $schedule[0]\" title=\"Schedule: $schedule[0]\">"}
			if ($spyware[0]) {$spyware[0] = "<img $img_class src=\"./images/spyware.gif\"  alt=\"Anti-Spyware Profiles: $spyware[0]\" title=\"Anti-Spyware Profiles: $spyware[0]\">"}
			if ($virus[0]) {$virus[0] = "<img $img_class src=\"./images/virus.gif\"  alt=\"Antivirus Profiles: $virus[0]\" title=\"Antivirus Profiles: $virus[0] \">"}
			if ($vulnerability[0]) {$vulnerability[0] = "<img $img_class src=\"./images/vulnerability.gif\"  alt=\"Vulnerability Protection Profiles: $vulnerability[0]\" title=\"Vulnerability Protection Profiles:$vulnerability[0]\">"}
			if ($url_filtering[0]) {$url_filtering[0] = "<img $img_class src=\"./images/url_filter.gif\"  alt=\"URL Filtering Profile: $url_filtering[0]\" title=\"URL Filtering Profile: $url_filtering[0]\">"}
			if ($data_filtering[0]) {$data_filtering[0] = "<img $img_class src=\"./images/dlp_data_filter.gif\"  alt=\"Data Filtering Profile: $data_filtering[0]\" title=\"Data Filtering Profile: $data_filtering[0]\">"}
			if ($file_blocking[0]) {$file_blocking[0] = "<img $img_class src=\"./images/fileblocking.gif\"  alt=\"File Blocking Profile: $file_blocking[0]\" title=\"File Blocking Profile: $file_blocking[0]\">"}
			if ($group[0]) {$group[0] = "<img $img_class src=\"./images/profile_group.gif\"  alt=\"Profile Group: $group[0]\" title=\"Profile Group: $group[0]\">"}
			if ($source_user[0] ne 'any') {$source_user[0] = "<img $img_class src=\"./images/user.gif\">$source_user[0]"}

			if ($log_start[0] eq 'yes' || $log_end eq 'yes'){
				my $alt = ();
				if ($log_start[0] eq 'yes'){
					$alt .= 'Log Start';
				}
				if ($log_end[0] eq 'yes'){
					$alt .= ' Log End';
				}
				$log_out[0] = "<img $img_class src=\"./images/log.gif\" alt=\"$alt\" title=\"$alt\">";
			}
			if ($log_setting[0]){
				$log_setting[0] = "<img $img_class src=\"./images/log_fwd.gif\" alt=\"$log_setting[0]\" title=\"$log_setting[0]\">";
			}
		}
                my ($i,$hold_group,@service_value_out_final,@service_out_final,@service_class) = ();
                foreach my $current_service (@service_out){
                        if ($current_service =~ /(.+->)(.+)/){
                                my $group = $1;
                                if ($group ne $hold_group){
                                        push @service_out_final, "<img $img_class src=\"./images/service_group.gif\">$group" if !$xls;
                                        push @service_out_final, "$group" if $xls;
                                        push @service_class, 'bolder';
                                        push @service_value_out_final, '';
                                }
                                push @service_out_final, "&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/service_group.gif\">$2" if !$xls;
                                push @service_out_final, "&nbsp;&nbsp;&nbsp;$2" if $xls;
                                push @service_class, 'italics';
                                push @service_value_out_final, $service_value_out[$i];
                                $hold_group = $group;

                        }
			elsif ($current_service eq 'any'){
				push @service_out_final, "$current_service";
				push @service_value_out_final, $service_value_out[$i];
                                push @service_class, '';
			}
                        else {
				push @service_out_final, "<img $img_class src=\"./images/service.gif\">$current_service" if !$xls;
                                push @service_out_final, "$current_service" if $xls;
                                push @service_value_out_final, $service_value_out[$i];
                                push @service_class, '';
                        }
                        $i++;
                }

                my ($i,$hold_group,@application_out_final,@application_class) = ();
                foreach my $current_application (@application_out){
                        if ($current_application =~ /(.+->)(.+)/){
                                my $group = $1;
                                if ($group ne $hold_group){
                                        push @application_out_final, "<img $img_class src=\"./images/application_group.gif\">$group" if !$xls;
                                        push @application_out_final, "$group" if $xls;
                                        push @application_class, 'bolder';
                                }
                                push @application_out_final, "&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/application_group.gif\">$2" if !$xls;
                                push @application_out_final, "&nbsp;&nbsp;&nbsp;$2" if $xls;
                                push @application_class, 'italics';
                                $hold_group = $group;

                        }
                        elsif ($current_application eq 'any'){
                                push @application_out_final, "$current_application";
                                push @application_class, '';
                        }
                        else {
                                push @application_out_final, "<img $img_class src=\"./images/application.gif\">$current_application" if !$xls;
                                push @application_out_final, "$current_application" if $xls;
                                push @application_class, '';
                        }
                        $i++;
                }




		my ($i,$hold_group,@source_address_value_out_final,@source_address_out_final,@source_address_class) = ();
		foreach my $src_address (@source_address_out){
                        if ($src_address =~ /(.+->)(.+->)(.+)/){
                                my $group = $1;
                                my $subgroup = $2;
                                if ($group ne $hold_group){
                                        push @source_address_out_final, "<img $img_class src=\"./images/address_group.gif\">$group" if !$xls;
                                        push @source_address_out_final, "$group" if $xls;
                                        push @source_address_value_out_final, '';
                                        push @source_address_class, 'bolder';
                                }
                                if ($subgroup ne $subhold_group){
                                        push @source_address_out_final, "&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/address_group.gif\">$subgroup" if !$xls;
                                        push @source_address_out_final, "&nbsp;&nbsp;&nbsp;$subgroup" if $xls;
                                        push @source_address_value_out_final, '';
                                        push @source_address_class, 'bolder';
                                }
                                push @source_address_out_final, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/address_group.gif\">$3" if !$xls;
                                push @source_address_out_final, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$3" if $xls;
                                push @source_address_value_out_final, $source_address_value_out[$i];
                                push @source_address_class, 'italics';
                                $hold_group = $group;
                                $subhold_group = $subgroup;

                        }
			elsif ($src_address =~ /(.+->)(.+)/){
				my $group = $1;
				if ($group ne $hold_group){
					push @source_address_out_final, "<img $img_class src=\"./images/address_group.gif\">$group" if !$xls;
					push @source_address_out_final, "$group" if $xls;
					push @source_address_value_out_final, '';
                                        push @source_address_class, 'bolder';
				}
				push @source_address_out_final, "&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/address_group.gif\">$2" if !$xls;
				push @source_address_out_final, "&nbsp;&nbsp;&nbsp;$2" if $xls;
				push @source_address_value_out_final, $source_address_value_out[$i];
                                push @source_address_class, 'italics';
				$hold_group = $group;

			}
			elsif ($src_address eq 'any'){
				push @source_address_out_final, "$src_address";
				push @source_address_value_out_final, $source_address_value_out[$i];
                                push @source_address_class, '';
			}
			else {
				push @source_address_out_final, "<img $img_class src=\"./images/address.gif\"> $src_address" if !$xls;
				push @source_address_out_final, "$src_address" if $xls;
				push @source_address_value_out_final, $source_address_value_out[$i];
                                push @source_address_class, '';
			}
			$i++;
		}

                my ($i,$hold_group,@destination_address_value_out_final,@destination_address_out_final,@destination_address_class) = ();
                foreach my $dst_address (@destination_address_out){
                        if ($dst_address =~ /(.+->)(.+->)(.+)/){
                                my $group = $1;
                                my $subgroup = $2;
                                if ($group ne $hold_group){
                                        push @destination_address_out_final, "<img $img_class src=\"./images/address_group.gif\">$group" if !$xls;
                                        push @destination_address_out_final, "$group" if $xls;
                                        push @destination_address_value_out_final, '';
                                        push @destination_address_class, 'bolder';
                                }
                                if ($subgroup ne $subhold_group){
                                        push @destination_address_out_final, "&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/address_group.gif\">$subgroup" if !$xls;
                                        push @destination_address_out_final, "&nbsp;&nbsp;&nbsp;$subgroup" if $xls;
                                        push @destination_address_value_out_final, '';
                                        push @destination_address_class, 'bolder';
                                }
                                push @destination_address_out_final, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/address_group.gif\">$3" if !$xls;
                                push @destination_address_out_final, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$3" if $xls;
                                push @destination_address_value_out_final, $destination_address_value_out[$i];
                                push @destination_address_class, 'italics';
                                $hold_group = $group;
                                $subhold_group = $subgroup;

                        }
                        elsif ($dst_address =~ /(.+->)(.+)/){
                                my $group = $1;
                                if ($group ne $hold_group){
                                        push @destination_address_out_final, "<img $img_class src=\"./images/address_group.gif\">$group" if !$xls;
                                        push @destination_address_out_final, "   $group" if $xls;
                                        push @destination_address_value_out_final, '';
                                	push @destination_address_class, 'bolder';
                                }
                                push @destination_address_out_final, "&nbsp;&nbsp;&nbsp;<img $img_class src=\"./images/address_group.gif\"> $2" if !$xls;
                                push @destination_address_out_final, "&nbsp;&nbsp;&nbsp;$2" if $xls;
                                push @destination_address_value_out_final, $destination_address_value_out[$i];
                              	push @destination_address_class, 'italics';
                                $hold_group = $group;

                        }
                        elsif ($dst_address eq 'any'){
                                push @destination_address_out_final, "$dst_address";
                                push @destination_address_value_out_final, $destination_address_value_out[$i];
                              	push @destination_address_class, '';
                        }
                        else {
                                push @destination_address_out_final, "<img $img_class src=\"./images/address.gif\"> $dst_address" if !$xls;
                                push @destination_address_out_final, "$dst_address" if $xls;
                                push @destination_address_value_out_final, $destination_address_value_out[$i];
                              	push @destination_address_class, '';

                        }
                        $i++;
                }


		my @check_array_num = ();
		$check_array_num[0] = @name;
		$check_array_num[1] = @tag;
		$check_array_num[2] = @from;
		$check_array_num[3] = @negate_source;
		$check_array_num[4] = @source_address_out_final;
		$check_array_num[5] = @source_address_value_out_final;
		$check_array_num[6] = @source_user;
		$check_array_num[7] = @to;
		$check_array_num[8] = @negate_destination;
		$check_array_num[9] = @destination_address_out_final;
		$check_array_num[10] = @destination_address_value_out_final;
		$check_array_num[11] = @application_out_final;
		$check_array_num[12] = @service_out_final;
		$check_array_num[13] = @service_value_out_final;
		$check_array_num[14] = @action;
		$check_array_num[15] = @log_start;
		$check_array_num[16] = @log_end;
		my @count_array = sort { $a <=> $b } @check_array_num;
		my $long_element =  $count_array[-1];
		$long_element--;
		

		for($i = 0; $i <= $long_element; $i++) { 
	                my ($current_tr_class,$pan,$oddeveni,$bottop,$classdisabled) = ();
	                if ($current_rule_type eq 'prerule' || $current_rule_type eq 'postrule'){
				$pan = "panoramaPushed";
			}

	                if ( $global_count % 2 == 0 ){
				$oddeven = '';
			}
=begin
	                if ($current_count && $current_count % 2 == 0 ){
				$oddeven = '';
			}
	                elsif (!$current_count && $current_rulenum % 2 == 0 ){
				$oddeven = '';
			}
#	                elsif ($current_count  == 0 && $current_rulenum ){
#				$oddeven = '';
#
			}
=cut
			else {
				$oddeven = 'Alternate';
			}
	                if ($i == 0 && $long_element == 0){
			        $bottop = "None";
				if ($send_border == 1) {
					$bottop = "None1";
				}
	                }
	                elsif ($i == 0){
	                	$bottop = "Top";
				if ($send_border == 1) {
					$bottop = "Top1";
				}
	                }
	                elsif ($i == $long_element){
		                $bottop = "Bottom";
	                }
	                else {
	                	$bottop = "";
	                }
			if ($disabled eq 'yes'){
				$classdisabled = 'Disabled';
			}
			$current_tr_class = "$pan". "$oddeven" . "Row" . "$bottop" . "$classdisabled" ;
			#$current_tr_class = "header";
	
			my ($source_class,$source_class_address,$destination_class,$destination_class_address,$tagclass,$desc_class,$from_class,$srcuser_class,$to_class,$app_class,$service_class,$service_class_value,$action_class,$options_class,$profile_class) = ();
			if ($negate_source[0] eq 'yes'){
				$source_class =  'strike';
				$source_class_address =  'strike';
			}
			if ($negate_destination[0] eq 'yes'){
				$destination_class =  'strike';
				$destination_class_address =  'strike';
			}
#			$source_address_class[$i] .= $source_class;
#			$destination_address_class[$i] .= $destination_class;
			$source_class = $source_address_class[$i] . $source_class;
			$destination_class = $destination_address_class[$i] . $destination_class;
			$service_class = $service_class[$i];
			$app_class = $application_class[$i];

			my $underline = "underline";
			$to_class = $underline;
			$from_class = $underline;

			if ($history){
#				if ($get_type == "3"){}
				if ($change[$i] eq 'Old' && !$xls){
					$change[$i] = "<img src=\"./images/yellow_led.gif\" title=\"Old\">";
				}
				elsif ($change[$i] eq 'New' && !$xls){
					$change[$i] = "<img src=\"./images/green_led.png\" title=\"New\">";
				}
				elsif ($change[$i] eq 'Added' && !$xls){
					$change[$i] = "<img src=\"./images/add.png\" title=\"Added\">";
				}
				elsif ($change[$i] eq 'Removed' && !$xls){
					$change[$i] = "<img src=\"./images/delete.png\" title=\"Removed\">";
				}
				if ($change[$i] ne '' && $globalhist){
#					print "$current_fw_name[$i] [$current_vsys[$i]] $current_fw_name $current_vsys[$i]--1<br>\n";
					$change[$i] .= " {$current_fw_name\[$current_vsys\]}";
				}
				$tag_class = 'change' if $tag_mismatch;
				$desc_class = 'change' if $desc_mismatch;
				$from_class = 'change' . $from_class if $from_mismatch;
				$source_class = 'change'. $source_class if $source_mismatch;
				$source_class_address = 'change' . $source_class_address if $source_mismatch;
				$srcuser_class = 'change' . $source_user[$i] if $desc_mismatch;
				$to_class = 'change' . $to_class if $to_mismatch;
				$destination_class = 'change'. $destination_class if $destination_mismatch;
				$destination_class_address = 'change' . $destination_class_address if $destination_mismatch;
				$app_class = 'change' . $application_class[$i] if $app_mismatch;
				$service_class = 'change'. $service_class[$i] if $service_mismatch;
				$service_class_value = 'change' if $service_mismatch;
				$action_class = 'change' if $action_mismatch;
				$options_class = 'change' if $options_mismatch;
				$profile_class = 'change' if $profile_mismatch;
			}

                        if (!$source_class) {$source_class = 'td1';}
                        if (!$source_class_address) {$source_class_address = 'td1';}
                        if (!$destination_class) {$destination_class = 'td1';}
                        if (!$destination_class_address) {$destination_class_address = 'td1';}
                        if (!$tag_class) {$tag_class = 'td1';}
                        if (!$desc_class) {$desc_class = 'td1';}
                        if (!$from_class) {$from_class = 'td1';}
                        if (!$srcuser_class) {$srcuser_class = 'td1';}
                        if (!$to_class) {$to_class = 'td1';}
                        if (!$app_class) {$app_class = 'td1';}
                        if (!$service_class) {$service_class = 'td1';}
                        if (!$service_class_value) {$service_class_value = 'td1';}
                        if (!$action_class) {$action_class = 'td1';}
                        if (!$options_class) {$options_class = 'td1';}
                        if (!$profile_class) {$profile_class = 'td1';}


			my @print_array1 = ();
=begin
			push @print_array1, "<tr class=$current_tr_class>\n";
			push @print_array1, "<td>$change[$i]</td>\n" if $history;
			push @print_array1, "<td>$name[$i]</td>\n" if $col_name;
			push @print_array1, "<td>$description[$i]</td>\n" ;#if $col_description;
			push @print_array1, "<td>$tag[$i]</td>\n" if $col_tag;
			push @print_array1, "<td class=underline>$from[$i]</td>\n" if $col_from;
			push @print_array1, "<td class=$source_address_class[$i]>$source_address_out_final[$i]</td>\n" if $col_source;
			push @print_array1, "<td class=$source_class>$source_address_value_out_final[$i]</td>\n" if $col_sourceip;
			push @print_array1, "<td>$source_user[$i]</td>\n" if $col_sourceuser;
			push @print_array1, "<td class=underline>$to[$i]</td>\n" if $col_to;
			push @print_array1, "<td class=$destination_address_class[$i]>$destination_address_out_final[$i]</td>\n" if $col_dst;
			push @print_array1, "<td class=$destination_class>$destination_address_value_out_final[$i]</td>\n" if $col_dstip;
			push @print_array1, "<td class=$application_class[$i]>$application_out_final[$i]</td>\n" if $col_app;
			push @print_array1, "<td class=$service_class[$i]>$service_out_final[$i]</td>\n" if $col_service;
			push @print_array1, "<td class=change>$service_value_out_final[$i]</td>\n" if $col_serviceval;
			push @print_array1, "<td>$action[$i]</td>\n"  if $col_action;
			push @print_array1, "<td>$group[$i]$virus[$i]$spyware[$i]$vulnerability[$i]$url_filtering[$i]$file_blocking[$i]$data_filtering[$i]</td>\n" if $col_profile;
			push @print_array1, "<td>$log_out[$i]$log_setting[$i]$schedule[$i]$qos[$i]</td>\n"  if $col_option;
			push @print_array1, "<td>$date[$i]</td>\n" if $history;
=cut
			push @print_array1, "<tr class=$current_tr_class>\n";
			push @print_array1, "<td class=td1>$change[$i]</td>\n" if $history;
			push @print_array1, "<td class=td1>$name[$i]</td>\n" if $col_name;
			push @print_array1, "<td class=$desc_class>$description[$i]</td>\n" if $col_description;
			push @print_array1, "<td class=$tag_class>$tag[$i]</td>\n" if $col_tag;
			push @print_array1, "<td class=$from_class>$from[$i]</td>\n" if $col_from;
			push @print_array1, "<td class=$source_class>$source_address_out_final[$i]</td>\n" if $col_source;
			push @print_array1, "<td class=$source_class_address>$source_address_value_out_final[$i]</td>\n" if $col_sourceip;
			push @print_array1, "<td class=$srcuser_class>$source_user[$i]</td>\n" if $col_sourceuser;
			push @print_array1, "<td class=$to_class>$to[$i]</td>\n" if $col_to;
			push @print_array1, "<td class=$destination_class>$destination_address_out_final[$i]</td>\n" if $col_dst;
			push @print_array1, "<td class=$destination_class_address>$destination_address_value_out_final[$i]</td>\n" if $col_dstip;
			push @print_array1, "<td class=$app_class>$application_out_final[$i]</td>\n" if $col_app;
			push @print_array1, "<td class=$service_class>$service_out_final[$i]</td>\n" if $col_service;
			push @print_array1, "<td class=$service_class_value>$service_value_out_final[$i]</td>\n" if $col_serviceval;
			push @print_array1, "<td class=$action_class>$action[$i]</td>\n"  if $col_action;
			push @print_array1, "<td class=$profile_class>$group[$i]$virus[$i]$spyware[$i]$vulnerability[$i]$url_filtering[$i]$file_blocking[$i]$data_filtering[$i]</td>\n" if $col_profile;
			push @print_array1, "<td class=$options_class>$log_out[$i]$log_setting[$i]$schedule[$i]$qos[$i]</td>\n"  if $col_option;
			push @print_array1, "<td class=td1>$date[$i]</td>\n" if $history;
                        push @print_array1, "<td class=td1>$bgroup[$i]</td>\n" if $rule_tracker;
                        push @print_array1, "<td class=td1>$bapp[$i]</td>\n" if $rule_tracker;
                        push @print_array1, "<td class=td1>$breason[$i]</td>\n" if $rule_tracker;
                        push @print_array1, "<td class=td1>$flags[$i]</td>\n" if $special_case1;


			push @print_array1, "</tr>\n";

			push @print_array, @print_array1;
		}
	}

}

sub format_output {
	my $input = shift;
	my @split_comma = ();
	my $input_formatted = ();
	if ($input =~ /,udp/ || $input =~ /,tcp/){
		$input =~ s/,tcp/ tcp/g;
		$input =~ s/,udp/ udp/g;
		$input =~ s/,$//g;
		@split_comma = split(/ /,$input);
	}
	elsif  ($input =~ /,/){
		@split_comma = split(/,/,$input);
	}
	else {
		$split_comma[0] = $input;

	}

	return @split_comma; 



}

sub format_column {
	my $change = shift;

	my $col_history1 = $col_history; 
	my $col_name1 = $col_name; 
	my $col_description1 = $col_description; 
	my $col_tag1 =  $col_tag;  
	my $col_from1 = $col_from; 
	my $col_source1 = $col_source; 
	my $col_sourceip1 =$col_sourceip;
	my $col_sourceuser1 = $col_sourceuser; 
	my $col_to1 = $col_to; 
	my $col_dst1 =  $col_dst;  
	my $col_dstip1 = $col_dstip; 
	my $col_app1 =  $col_app;  
	my $col_service1 = $col_service; 
	my $col_serviceval1 =$col_serviceval;
	my $col_action1 = $col_action; 
	my $col_profile1 = $col_profile; 
	my $col_option1 = $col_option; 


	$col_name1 = '0' if $change eq 'col_name';
	$col_description1 = '0' if $change eq 'col_description';
	$col_tag1 = '0' if $change eq 'col_tag';
	$col_from1 = '0' if $change eq 'col_from';
	$col_source1 = '0' if $change eq 'col_source';
	$col_sourceip1 = '0' if $change eq 'col_sourceip';
	$col_sourceuser1 = '0' if $change eq 'col_sourceuser';
	$col_to1 = '0' if $change eq 'col_to';
	$col_dst1 = '0' if $change eq 'col_dst';
	$col_dstip1 = '0' if $change eq 'col_dstip';
	$col_app1 = '0' if $change eq 'col_app';
	$col_service1 = '0' if $change eq 'col_service';
	$col_serviceval1 = '0' if $change eq 'col_serviceval';
	$col_action1 = '0' if $change eq 'col_action';
	$col_profile1 = '0' if $change eq 'col_profile';
	$col_option1 = '0' if $change eq 'col_option';

	my $cols1 =();
	$cols1 .= $col_name1;
	$cols1 .= $col_description1;
	$cols1 .= $col_tag1;
	$cols1 .= $col_from1;
	$cols1 .= $col_source1;
	$cols1 .= $col_sourceip1;
	$cols1 .= $col_sourceuser1;
	$cols1 .= $col_to1;
	$cols1 .= $col_dst1;
	$cols1 .= $col_dstip1;
	$cols1 .= $col_app1;
	$cols1 .= $col_service1;
	$cols1 .= $col_serviceval1;
	$cols1 .= $col_action1;
	$cols1 .= $col_profile1;
	$cols1 .= $col_option1;

	my $return = ();
	if ($history){
		$return = "?fw=$fw&fwname=$fwname&vsys=$vsys&history=1&";
	}
	else{
		$return = "?fw=$fw&fwname=$fwname&vsys=$vsys&view=$view&search=$search&rule_tracker=$rule_tracker&";
	}
	$return .= "cols=$cols1";

=begin	
	$return .= "col_name=$col_name1&col_description=$col_description1&col_tag=$col_tag1&col_from=$col_from1&".
	"col_source=$col_source1&col_sourceip=$col_sourceip1&" .
	"col_sourceuser=$col_sourceuser1&col_to=$col_to1&" .
	"col_dst=$col_dst1&col_dstip=$col_dstip1&col_app=$col_app1&" .
	"col_service=$col_service1&col_serviceval=$col_serviceval1&" .
	"col_action=$col_action1&col_profile=$col_profile1&col_option=$col_option1";
=cut
	return $return;
}
