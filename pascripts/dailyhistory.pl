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


 use XML::Simple;
 use MIME::Lite;
 use Date::Simple qw(date today);
 use Time::Local ;


my $xml = new XML::Simple(ForceArray => [vsys , rule ,  prerule , postrule]);

my $time = localtime;

my $year = substr $time, -4, 4;
my $mon = substr $time, 4, 3;
my $day = substr $time, 8, 2;

$day = sprintf("%02d", $day);
my $month_num = &mon2num($mon);

my $date = ();
$date = $ARGV[0];
if (!$date){
	$date = "$year-$month_num-$day";
}
else {
	$mon_num = substr $date, 5,2;
	$day = substr $date, 8,2;
	$mon = &mon2num($mon_num,1);
	$manual_date = 1;
}

my $dir = $0;
$dir =~ s/dailyhistory\.pl$//;

my @config =();
open(FILE, "$dir" . "config.txt") or die("Unable to open file");
        @config = <FILE>;
close FILE;

my $webroot = ();
my $scriptroot = ();
my ($email_sender,$email_recipient) = ();

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
        elsif ($configsplit[0] eq 'email_sender'){
                $email_sender = $configsplit[1];
                $email_sender =~ s/\n|\r//g;
        }
        elsif ($configsplit[0] eq 'email_recipient'){
                $email_recipient = $configsplit[1];
                $email_recipient =~ s/\n|\r//g;
                $email_recipient =~ s/ /,/g;
        }
        elsif ($configsplit[1]){
		$configsplit[1] =~ s/\n|\r//g;
                $config_hash{$configsplit[0]} = $configsplit[1];
        }
}

#open(FILE, "$scriptroot/config.txt") or die("Unable to open file");
#@config = <FILE>;
#close FILE;
my $track_db = $config_hash{'track_db'};

foreach my $line (@config){
        my @splitline = split(/,/,$line);
        chomp($splitline[1]);
}


my $ls1 = `ls $scriptroot/xml/`;

my @lsarray = split(/\n|\r/,$ls1);

foreach my $line (@lsarray){
	if ($line =~ /(.*)-history\.xml/){
		push @history_array, $1;
	}
}

my $count = 0;
push @printout, '<global>';
push @printout, '  <vsys name="vsys1">'. "\n";
foreach my $line (@history_array){
	my $grep = `grep -B 1 'vsys name\\|$date' $scriptroot/xml/$line-history.xml | grep -v -- \"^--\$\"`;
#	print "$grep";
	my @grep = split(/\n|\r/,$grep);
	my $current_vsys = ();
	my $pushname = ();
	foreach my $grepline (@grep){
		if ($grepline =~ /<vsys name="(.+)">/){
			$current_vsys = $1;
		}
		elsif ($grepline =~ /<entry name=/){
			$pushname = $grepline;
		}
		elsif ($grepline =~ /<entry action.+vulnerability/){
			$rule = $grepline;
		#	$rule = s/" \/>/" current_fw_name="$line" current_vsys="$current_vsys" \/>/g;
			$rule      = substr $rule, 0, -4;
			$rule .= "\" current_fw_name=\"$line\" current_vsys=\"$current_vsys\" \/>";
			$count++;
			push @printout, "    <count name=\"R$count\">". "\n";
#			print $grepline . "\n";
			push @printout, "$pushname" . "\n";
			push @printout, "$rule" . "\n";
			push @printout, "      </entry>". "\n";
			push @printout, '    </count>'. "\n";
		}
	}
}

push @printout, '  </vsys>'. "\n";
push @printout, '</global>';


if ($track_db) {

        my $module = "DBI";
        eval("use $module;");


        $mysqlip = $config_hash{'mysql_server'};
        $mysqldb = $config_hash{'mysql_db'};
        $mysql_username = $config_hash{'mysql_username'};
        $mysql_password = $config_hash{'mysql_password'};


        $select_query = "select rule_numbers from rule_tracker";


        my $dbh=DBI->connect("DBI:mysql:database=$mysqldb;host=$mysqlip","$mysql_username","$mysql_password") or print "$DBI::db_errstr\n";
        my $query=$dbh->quote($site);
        my $arrayref=$dbh->selectall_arrayref("$select_query") or print "$DBI::db_errstr now \n";
        $dbh->disconnect;


        for my $row (@$arrayref) {

		my ($rule_numbers)=@$row;
		my @rulesplit = split (/,/,$rule_numbers);
		foreach my $sqlrule (@rulesplit){
			$sqlrule =~ s/\r|\n|\s//g;
			if ($sqlrule =~ /\d+/){
				push @multirule, "Rule Number $sqlrule used in multiple places on the Rule Tracker DB\n" if $sqlrule_hash{$sqlrule};
				$sqlrule_hash{$sqlrule} = 1;
			}
		}
	}
}


my $ls2 = `ls $scriptroot/rules/`;

my @lsrules = split(/\n|\r/,$ls2);
my %deleterule_hash = %sqlrule_hash;

foreach my $file (@lsrules){
#	print "$scriptroot/rules/$file\n";	
	open(FILE, "$scriptroot/rules/$file") or die("Unable to open file");
	        @rule = <FILE>;
		$device = $file;
		$device =~ s/\.txt?//g;
		push @device, $device;
		my $holdvsys = ();	
		$holdrulenum = ();
		$holddescription = ();
		foreach $rule (@rule){
			my @rulesplit = split ('###',$rule);
			my $vsys = $rulesplit[0];
			my $description = $rulesplit[1];
			my $name = $rulesplit[2];
			$name =~ s/(\n|\r)//g;
			my $rulenum = ();
			if ($vsys ne $holdvsys){
				$holdrulenum = ();
				$holddescription = ();
			}
			if ($description !~ /_\d+$/){
				$wrongrule_hash{$device} = $wrongrule_hash{$device} . "$vsys - $name\n";
			}
			else {
				$rulenum = $description;
				if ($rulenum =~ /_(\d+)$/) {
					$rulenum = $1;
				}
				if ($rulenum <= $holdrulenum){
					$ruleorder_hash{$device} = $ruleorder_hash{$device} . "$vsys - $holddescription is before $description in the rule order\n";
				}
				if (!$sqlrule_hash{$description}){
					$rulenot_found{$device} =  $rulenot_found{$device} . "$vsys -- $description -- $name\n";
				}
				if ($rulenum_check{$description} && $rulenum_check{$description} ne $name){
					push @multirule, "Rule $description is applied to a rule named \"$rulenum_check{$description}\" and \"$name\"\n";
				}
				$rulenum_check{$description} = $name;
				$holdrulenum = $rulenum;
				$holddescription = $description;
				
			}

			if ($deleterule_hash{$description}){
				delete $deleterule_hash{$description};


			}
			$holdvsys = $vsys;
		}
	close FILE;

}

my @ruleleft = keys %deleterule_hash;

foreach my $line (@ruleleft){
	push @multirule, "Rule $line was found in tracker, but not assigned to any rule.\n";

}
$emailprint .= "\n\n";
$emailprint .= join "", @multirule;
foreach my $device (@device){

	if ($ruleorder_hash{$device} || $wrongrule_hash{$device} || $rulenot_found{$device}){
		$emailprint .= "\n\n$device\n";
		$emailprint .= "Incorrect or missing description\n$wrongrule_hash{$device}" if $wrongrule_hash{$device};
		$emailprint .= "Out of order or same rulenum\n$ruleorder_hash{$device}" if $ruleorder_hash{$device};
		$emailprint .= "Rule number not found in Rule Tracker DB\n$rulenot_found{$device}" if $rulenot_found{$device};
	}
}

				
$emailprint =~ s/\n/<br>/g;

my $catreport = `cat $scriptroot/report.txt | grep "$mon $day"`;
$catreport =~ s/\n|\r/<br>\n/g;
my $cat = ();
my $change = ();
if ($count){
	open FILE, ">$scriptroot/globalxml/global-$date.xml" or die $!;
#	open FILE, ">$scriptroot/globalxml/global-2016-03-22.xls.xml" or die $!;
        	foreach my $line (@printout){
	                print FILE "$line";
	        }
	close FILE;

	`$webroot/pa.pl 1 1 1 global-$date` if !$track_db;
	`$webroot/pa.pl 1 1 1 global-$date 1` if $track_db;
	$cat =`cat $webroot/xls/global-$date.xls`;
	$change = "Change";
}
else {
	$cat = "No Change Made";
	$change = "No Change";
}


if ($config_hash{'run_config'}){
	`$scriptroot/get_config_logs.pl > $scriptroot/configlog/Config-Logs-$date.csv` if !$manual_date;
	`$scriptroot/get_config_logs.pl $date > $scriptroot/configlog/Config-Logs-$date.csv` if $manual_date;
}

my $data = qq{
	$catreport,
	$cat,
	$emailprint
};

my $subject   = "Palo Alto Firewall Changes -- $date -- $change";
my $sender    = $email_sender;
my $recipient = $email_recipient;
my $mime = MIME::Lite->new(
    'From'    => $sender,
    'To'      => $recipient,
    'Subject' => $subject,
    'Type'    => 'text/html',
    'Data'    => $data,
);

if ($count){
	$mime->attach(Type => 'application/vnd.ms-excel',
	  Path => "$webroot/xls/global-$date.xls",
	  Id => "global-$date.xls",
	);

	if ($config_hash{'run_config'}){
		$mime->attach(Type => 'application/vnd.ms-excel',
		  Path => "$scriptroot/configlog/Config-Logs-$date.csv",
	 	 Id => "Config-Logs-$date.xls",
		);
	}
}

$mime->send() or die "Failed to send mail\n";


sub mon2num {
        my $mon = shift;
        my $rev = shift;

        my %monhash= ();
        $monhash{"Jan"} = '01';
        $monhash{"Feb"} = '02';
        $monhash{"Mar"} = '03';
        $monhash{"Apr"} = '04';
        $monhash{"May"} = '05';
        $monhash{"Jun"} = '06';
        $monhash{"Jul"} = '07';
        $monhash{"Aug"} = '08';
        $monhash{"Sep"} = '09';
        $monhash{"Oct"} = '10';
        $monhash{"Nov"} = '11';
        $monhash{"Dec"} = '12';

        if ($rev){
                %rev_conv = reverse %monhash;
                return  $rev_conv{$mon};
        }

        my $return = $monhash{$mon};
        return $return;
}

