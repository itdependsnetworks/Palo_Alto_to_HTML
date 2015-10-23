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
        }
}

my $ls1 = `ls /scripts/parules/xml/`;

my @lsarray = split(/\n|\r/,$ls1);

foreach my $line (@lsarray){
	if ($line =~ /(.*-fw0\d)-history\.xml/){
		push @history_array, $1;
	}
}

my $count = 0;
push @printout, '<global>';
push @printout, '  <vsys name="vsys1">'. "\n";
foreach my $line (@history_array){
#	print "grep -B 1 'vsys name\\|2015-03-21' /scripts/parules/xml/$line-history.xml | grep -v -- \"^--\$\"\n";
	my $grep = `grep -B 1 'vsys name\\|$date' /scripts/parules/xml/$line-history.xml | grep -v -- \"^--\$\"`;
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


my $catreport = `cat $scriptroot/report.txt | grep "$mon $day"`;
$catreport =~ s/\n|\r/<br>\n/g;
my $cat = ();
my $change = ();
if ($count){
	open FILE, ">$scriptroot/globalxml/global-$date.xml" or die $!;
        	foreach my $line (@printout){
	                print FILE "$line";
	        }
	close FILE;

	`$webroot/pa.pl 1 1 1 global-$date`;
	$cat =`cat $webroot/xls/global-$date.xls`;
	$change = "Change";
}
else {
	$cat = "No Change Made";
	$change = "No Change";
}

my $data = qq{
	$catreport,
	$cat
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

