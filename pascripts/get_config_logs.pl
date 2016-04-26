#!/usr/bin/perl

 use XML::Simple;
 use MIME::Lite;
 use Time::Local ;
 use REST::Client;
 use Data::Dumper;
 use Date::Calc qw( Add_Delta_YMD );

my $client = REST::Client->new();


my $xml = new XML::Simple(ForceArray => [vsys , rule ,  prerule , postrule]);
my $restapi = 'esp/restapi.esp';

my $time = localtime;

my $year = substr $time, -4, 4;
my $mon = substr $time, 4, 3;
my $day = substr $time, 8, 2;

$day = sprintf("%02d", $day);
my $mon_num = &mon2num($mon);

my $device = $ARGV[1];


my $date = ();
$date = $ARGV[0];
if (!$date){
        $date = "$year-$mon_num-$day";
}
else {
        $mon_num = substr $date, 5,2;
        $day = substr $date, 8,2;
        $mon = &mon2num($mon_num,1);
	$single_day = 1;

	my ( $deltayear, $deltamonth, $deltaday) = ( 0, 0, 1);

	my ( $year1, $mon_num1, $day1 ) =
	 Add_Delta_YMD( $year, $mon_num, $day,
                 $deltayear, $deltamonth, $deltaday );

	$year = $year1;
	$mon_num = $mon_num1;
	$day = $day1;

}

my ( $deltayear, $deltamonth, $deltaday) = ( 0, 0, -1);
my ( $year_min, $month_min, $day_min ) =
  Add_Delta_YMD( $year, $mon_num, $day,
                 $deltayear, $deltamonth, $deltaday );

my $dir = $0;
$dir =~ s/get_config_logs\.pl$//;

my @config =();
open(FILE, "$dir" . "config.txt") or die("Unable to open file");
        @config = <FILE>;
close FILE;


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
        elsif ($configsplit[0] eq 'run_config_devices'){
                $run_config_devices = $configsplit[1];
                $run_config_devices =~ s/\n|\r//g;
                $run_config_devices =~ s/ /,/g;
        }
        elsif ($configsplit[0] eq 'run_config_key'){
                $run_config_key = $configsplit[1];
                $run_config_key =~ s/\n|\r//g;
                $run_config_key =~ s/ /,/g;
        }

}

my @firewalls = split(/,/,$run_config_devices);
my @keys = split(/,/,$run_config_key);

my $authcount = 0;
foreach my $fwconnect (@firewalls){
	my $authkey = $keys[$authcount];
	$authcount++;
	
	my $dir = $0;
	
	$type = 'type=op&cmd=<show><devices><all><%2Fall><%2Fdevices><%2Fshow>';
	my $restcombine =  "https://$fwconnect/$restapi?$type&key=$authkey";
	
	my $serial = $client->GET("$restcombine");
	my $serial_r = $client->responseContent();
	
	#$serial_r =~ s/>/>###/g;
	#print "$serial_r\n";
	#my @arrayserial = split(/###/,$serial_r);
	my @arrayserial = split(/(?<=>)(?=<)/,$serial_r);
	foreach my $line (@arrayserial){
		
		if ($line =~ /<serial>(\d+)<\/serial>/){
			$current_serial = $1;
		}
		if ($line =~ /<hostname>(.+)?<\/hostname>/){
			$current_hostname = $1;
			$serial_hash{$current_serial} = $current_hostname;
	#		print "$current_serial} = $current_hostname\n";
			($current_hostname, $serial_hash) = ();
		}
	
	}
	
	
	$pre_time = "$year_min/$month_min/$day_min" if $single_day;
	$pre_time = "$year/$mon_num/$day" if !$single_day;
	$end_time = "and (receive_time leq '" . "$year/$mon_num/$day" . " 00:00:00')" if $single_day;
	
	my $fin = ();
	while (!$fin && $i < 10){
		$skip = 500 * $ii;
		$type = "type=log&log-type=config&skip=$skip&nlogs=500&query=(receive_time geq '" . $pre_time . " 00:00:00')". $end_time;
		my $restcombine =  "https://$fwconnect/$restapi?$type&key=$authkey";
	#	print "$restcombine\n";
		
	
		my $jobid_get = $client->GET("$restcombine");
		my $jobid_check = $client->responseContent();
	
	
		my $jobid_check_ref = $xml->XMLin($jobid_check);
		my %jobid_check_hash = % $jobid_check_ref;
		my $skip = ();
		
		my $job = $jobid_check_hash{'result'}{'job'};
		
		$type = '?type=log&action=get&job-id=' . "$job";
	
		$i = ();
		while ($i < 10 && !$skip) {
			
			my $restcombine =  "https://$fwconnect/$restapi?$type&key=$authkey";
		
			my $logs_get = $client->GET("$restcombine");
			my $logs_check = $client->responseContent();
			my $logs_check_ref = $xml->XMLin($logs_check);
			my %logs_check_hash = % $logs_check_ref;
			my $status = $logs_check_hash{'result'}{'job'}{'status'};
		
			if ($status eq 'FIN'){
				$total_log = $logs_check_hash{'result'}{'job'}{'cached-logs'};
	#			print "$total_log\n";
				$logs_check1 = $logs_check;
				$logs_check1 =~ s/>\n/>\n###/g;
				my @arraylog = split(/###/,$logs_check1);
				foreach my $line (@arraylog){
			#		print "$line";
					if ($line =~ /<entry logid="(\d+)">/){
						$entry = $1;
						push @logentry, $entry;
					}
					#if ($line =~ /<(\w+|_|-)>(.+)<\/\w+|-|_>/){
					if ($line =~ /<([\w\-]+)>(.+)<\/[\w\-]+>/){
						
						$column = $1;
						$value = $2;
						$entryhash{$entry}{$column} = $value;
			#			print "$column $value \n";
					}
				}
				$skip = 1;
				if (!$total_log || $total_log < 500){
					$fin = 1;
				}
			}
			else {
				sleep(5);
				$i++;
			}
		}
		$ii++;
	}
}

my @columns = ('domain','receive_time','serial','device_name','host','cmd','admin','client','result','before-change-preview','after-change-preview','path','seqno','actionflags','type','subtype','config_ver','time_generated','vsys_id');

my $line = ();
foreach my $column (@columns){
	$line .= $column . ',';
}
print "$line\n";
foreach my $entry (@logentry){
	my $line = ();
	foreach my $column (@columns){
		if ($column eq 'device_name' & !$entryhash{$entry}{$column}){
			$entryhash{$entry}{$column} = $serial_hash{$entryhash{$entry}{'serial'}};
		#	print "K - $entryhash{$entry}{'serial'}  - $entryhash{$entry}{$column} \n";
		}
		$line .= $entryhash{$entry}{$column}. ',';
	}
	print "$line\n";
}


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

