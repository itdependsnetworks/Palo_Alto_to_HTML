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


umask 003;

my $dir = $0;
$dir =~ s/xmlformatter\.pl$//;

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


#my $detail_time = localtime;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $detail_time = sprintf "%.4d-%.2d-%.2d", $year+1900, $mon+1, $mday;

# use warnings;
 use REST::Client;
 use XML::Simple;
 use Data::Dumper;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

my $fw = $ARGV[0];
my $fwconnect = ();
my $compare = 1;
my $skipaddress_group = ();
my $skipservice_group = ();

my @all_fw =();
open(FILE, "$scriptroot/fw.txt") or die("Unable to open file");
	@all_fw = <FILE>;
close FILE;

my @check_info = ();
my %xml_old =();
my $check_history=();
my %del_check =();
my $highrule = ();
my $historycount = ();
my $historycountnum = ();
my %out_history_hash =();
my $xml_history_in =();
if ($compare){
	opendir my($dh), "$scriptroot/xml" or die "Couldn't open dir '$scriptroot/xml': $!";
	my @files = readdir $dh;
	closedir $dh;
	
	
	foreach my $file1 (@files) {
		(my $file = $file1) =~ s/\.[^.]+$//;
	        if ($file =~ /$fw-/){
			if ($file =~ /.+-(\d{8})/){
				push @sort_file_date, $1;
			}
	        }
	}
	my @file_sorted = reverse sort { $a <=> $b } @sort_file_date; 
	my $latest_file = "$fw-$file_sorted[0].xml";

	my $xml_old = new XML::Simple(ForceArray => [vsys , rule ,  prerule , postrule]);
	my ($inbound_rules,$timestamp) = ();

        eval { $inbound_rules = $xml_old->XMLin("$scriptroot/xml/$latest_file");};
	
	if ($@){
		$compare = ();

	}
	else {
	%xml_old = % $inbound_rules;

	if (-e "$scriptroot/xml/$fw-history.xml"){
		$xml_history_in = new XML::Simple(ForceArray => $fw);
	
		#$xml_history_in = new XML::Simple(ForceArray => [$fw, qr/R\d/,  qr/R\d\d/] );
		#$xml_history_in = new XML::Simple(ForceArray => 1 );
		$out_history_hash = ();
	        $out_history_in = $xml_history_in->XMLin("$scriptroot/xml/$fw-history.xml");
		%out_history_hash = % $out_history_in;
		$check_history = 1;

#print Dumper %out_history_hash;

	}
	foreach $key (keys( % {$xml_old{'vsys'}} ) ) {
	        push @num_vsys, $key;
	}
#		print $num_vsys[0] ."\n";
#	if ($num_vsys[0] !~ /vsys/){
#		$num_vsys[0] = 'vsys1';
#		print $num_vsys[0] ."\n";
#	}

	@num_vsys = sort { $a <=> $b } @num_vsys;
	my @rulenum =();
	my @rules_array = ('prerule','rule','postrule');
        foreach my $vsys (@num_vsys){
		#print "{$fw}{'vsys'}{$vsys}{'count'}\n";
		my @history_num =();
                foreach my $rule_type (@rules_array){
                        foreach $key (keys( % {$xml_old{'vsys'}{$vsys}{$rule_type}} ) ) {
                                push @rulenum, $key;
				
                                my $name_check = $xml_old{'vsys'}{$vsys}{$rule_type}{$key}{'entry'}{'name'}; 
                                #$del_check{"$vsys-$rule_type-$name_check"}='1';
                                $del_check{$vsys}{$rule_type}{$name_check}='1';
                        }
                }
		if ($check_history){
			@history_num = ();
			@history_num1 = ();
	        	foreach $key (keys( % {$out_history_hash{'vsys'}{$vsys}{'count'}} ) ) {
#			foreach my $key (@num_vsys){
		                push @history_num, $key;
#				print $key;
		        }
			foreach my $rnum (@history_num){
				$rnum =~ s/R//g;
				push @history_num1, $rnum;
			}
	        	my @new_history_num = reverse sort { $a <=> $b } @history_num1;
			#$historycount = $new_history_num[0];
#			print "$vsys $new_history_num[0];\n";
			$historycount{$vsys}='R'.$new_history_num[0];
			if (!$new_history_num[0]){
				delete($out_history_hash{'vsys'}{$vsys});
			}

#			print "R$new_history_num[0]\n";
		}
        	my @newrulenum = reverse sort { $a <=> $b } @rulenum;
		#$highrule = $newrulenum[0];
		$highrule{$vsys}=$newrulenum[0];
		

        }
	}

}

#print Dumper %out_history_hash;
#/print Dumper %historycount;
#print Dumper %highrule;
#print Dumper %out_history_hash;
#print Dumper %del_check;
#exit();

my $authkey = ();
foreach my $all_fw (@all_fw){
	my @splitfw = split(/,/,$all_fw);
	my $current_fw = $splitfw[0];
	if ($fw eq $current_fw){
		$fwconnect = $splitfw[1];
		$authkey = $splitfw[2];
		chomp($authkey);
	}
}
if(!$fwconnect){
	$fwconnect = $fw;
}

my $restapi = 'esp/restapi.esp';
my $actionget = 'type=config&action=get';
my $actionshow = 'type=config&action=show';


my $client = REST::Client->new();
my $xml = new XML::Simple;

my (%out_rule_hash, %service, %address, %address_group, %application_group, %service_group, %schedule) = ();
my ($rulebase , $prerulebase , $postrulebase)=();
my @vsys = ();

my $restcombine =  "https://$fwconnect/$restapi?type=config&action=get&key=$authkey" . '&type=op&cmd=<show><system><info></info></system></show>';
#print "$restcombine";
#exit ();
my $vsys_get = $client->GET("$restcombine");
my $vsys_check = $client->responseContent();

my $device_entry_get = &xpath_send($authkey,"devices/entry/vsys",$actionshow);
my $device_entry_ref = $xml->XMLin($device_entry_get);
my %device_entry = % $device_entry_ref;

my $config_panorama_get = &xpath_send($authkey,"/config/panorama/vsys",$actionget);
my $config_panorama_ref = $xml->XMLin($config_panorama_get);
my %config_panorama = % $config_panorama_ref;

my $config_shared_get = &xpath_send($authkey,"/config/shared",$actionshow);
my $config_shared_ref = $xml->XMLin($config_shared_get);
my %config_shared = % $config_shared_ref;

my $config_predefined_service_get = &xpath_send($authkey,'/config/predefined/service',$actionget);
my $config_predefined_service_ref = $xml->XMLin($config_predefined_service_get);
my %config_predefined_service = % $config_predefined_service_ref;

my $config_predefined_rule_get = &xpath_send($authkey,'/config/predefined/default-security-rules',$actionget);
my $config_predefined_rule_ref = $xml->XMLin($config_predefined_rule_get);
my %config_predefined_rule = % $config_predefined_rule_ref;
#print Dumper %config_predefined_rule;

my $predefined_service_ref = $config_predefined_service{'result'}{'service'};
#my $shared_service_ref = $config_shared{'result'}{'shared'}{'service'}{'entry'};
#my $shared_service_group_ref = $config_shared{'result'}{'shared'}{'service-group'}{'entry'};
#my $shared_address_ref = $config_shared{'result'}{'shared'}{'address'}{'entry'};
#my $shared_address_group_ref = $config_shared{'result'}{'shared'}{'address-group'}{'entry'};
#my $shared_application_group_ref = $config_shared{'result'}{'shared'}{'application-group'}{'entry'};
#my $shared_schedule_ref = $config_shared{'result'}{'shared'}{'schedule'}{'entry'};

my $shared_service_ref = $config_shared{'result'}{'shared'}{'service'};
my $shared_service_group_ref = $config_shared{'result'}{'shared'}{'service-group'};
my $shared_address_ref = $config_shared{'result'}{'shared'}{'address'};
my $shared_address_group_ref = $config_shared{'result'}{'shared'}{'address-group'};
my $shared_application_group_ref = $config_shared{'result'}{'shared'}{'application-group'};
my $shared_schedule_ref = $config_shared{'result'}{'shared'}{'schedule'};

my %predefined_service_hash = % $predefined_service_ref;
my %shared_service_hash = % $shared_service_ref;
my %shared_service_group_hash = % $shared_service_group_ref;
my %shared_address_hash = % $shared_address_ref;
my %shared_address_group_hash = % $shared_address_group_ref;
my %shared_application_group_hash = % $shared_application_group_ref;
my %shared_schedule_hash = % $shared_schedule_ref;

my %predefined_service = &service_check(%predefined_service_hash);
my %shared_application_group = &make_application_group(%shared_application_group_hash);
my %shared_service_group = &make_service_group(%shared_service_group_hash);
my %shared_address_group = &make_address_group(%shared_address_group_hash);
my %shared_address = &address_check(%shared_address_hash);
my %shared_service = &service_check(%shared_service_hash);
my %shared_schedule = &schedule_check(%shared_schedule_hash);


my (%rulebase,%prerulebase,%postrulebase) = ();


my $vsys_check_ref = $xml->XMLin($vsys_check);
my %vsys_check_hash = % $vsys_check_ref;
my $multi = $vsys_check_hash{'result'}{'system'}{'multi-vsys'};
if ($multi eq 'on' ){
        foreach $key (keys( % {$device_entry{'result'}{'vsys'}{'entry'}} ) ) {
	#	print "$key\n";
		if ($key =~ /vsys/){
			push @vsys, $key;
		}
        }
	if (!$vsys[0]){
		$vsys[0] = 'vsys1';
		$multi = 'off';	
	}
}
else {
	$vsys[0] = 'vsys1';
}

my $serial = $vsys_check_hash{'result'}{'system'}{'serial'};
my $hostname = $vsys_check_hash{'result'}{'system'}{'hostname'};
my $appver = $vsys_check_hash{'result'}{'system'}{'app-version'};
my $model = $vsys_check_hash{'result'}{'system'}{'model'};

foreach my $vsys (@vsys){
        if ($check_history){
		$historycount = $historycount{$vsys} ;
		if (!$historycount){
			$historycountnum = 0;
			#delete($out_history_hash->{'vsys'}->{$vsys});
			#print "Delte here $vsys\n" if $vsys eq 'vsys2';
			#print Dumper %out_history_hash  if $vsys eq 'vsys2';
			#print "Delte here $vsys\n" ;
			#print Dumper %out_history_hash ;
		}
		$historycountnum = $historycount;
		$historycountnum =~ s/R//g;
		#$historycountnum++;
		#print "$historycount $historycountnum";
	}
	else {
		$historycountnum = 0;
	}

	my ($rulebase_ref,$prerulebase_ref,$postrulebase_ref,$displayname_ref,$displayname) = ();
	(%rulebase,%prerulebase,%postrulebase) = ();
	if ($multi eq 'on'){
		$displayname_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys};
		$rulebase_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys}{'rulebase'}{'security'}{'rules'};
		$service_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys}{'service'};
		$service_group_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys}{'service-group'};
		$address_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys}{'address'};
		$address_group_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys}{'address-group'};
		$application_group_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys}{'application-group'};
		$schedule_ref = $device_entry{'result'}{'vsys'}{'entry'}{$vsys}{'schedule'};
		$prerulebase_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'pre-rulebase'}{'security'}{'rules'};
		$postrulebase_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'post-rulebase'}{'security'}{'rules'};
                $panorama_service_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'service'};
                $panorama_service_group_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'service-group'};
                $panorama_address_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'address'};
                $panorama_address_group_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'address-group'};
                $panorama_application_group_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'application-group'};
                $panorama_schedule_ref = $config_panorama{'result'}{'vsys'}{'entry'}{$vsys}{'schedule'};
	}
	else {
		$rulebase_ref = $device_entry{'result'}{'vsys'}{'entry'}{'rulebase'}{'security'}{'rules'};
		$service_ref = $device_entry{'result'}{'vsys'}{'entry'}{'service'};
		$service_group_ref = $device_entry{'result'}{'vsys'}{'entry'}{'service-group'};
		$address_ref = $device_entry{'result'}{'vsys'}{'entry'}{'address'};
		$address_group_ref = $device_entry{'result'}{'vsys'}{'entry'}{'address-group'};
		$application_group_ref = $device_entry{'result'}{'vsys'}{'entry'}{'application-group'};
		$schedule_ref = $device_entry{'result'}{'vsys'}{'entry'}{'schedule'};
		$prerulebase_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'pre-rulebase'}{'security'}{'rules'};
		$postrulebase_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'post-rulebase'}{'security'}{'rules'};
                $panorama_service_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'service'};
                $panorama_service_group_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'service-group'};
                $panorama_address_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'address'};
                $panorama_address_group_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'address-group'};
                $panorama_application_group_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'application-group'};
                $panorama_schedule_ref = $config_panorama{'result'}{'vsys'}{'entry'}{'schedule'};
	} 

	%rulebase = % $rulebase_ref;
	%prerulebase = % $prerulebase_ref;
#	print Dumper %prerulebase;
	%postrulebase = % $postrulebase_ref;
	%displayname = % $displayname_ref;
	foreach my $key (sort keys %displayname){
		if ($key eq 'display-name'){
			$displayname = $displayname{$key};
		}
	}
	%displayname =();

	my %service_hash = % $service_ref;
	my %service_group_hash = % $service_group_ref;
	my %address_hash = % $address_ref;
	my %address_group_hash = % $address_group_ref;
	my %application_group_hash = % $application_group_ref;
	my %schedule_hash = % $schedule_ref;
        my %panorama_service_hash = % $panorama_service_ref;
        my %panorama_service_group_hash = % $panorama_service_group_ref;
        my %panorama_address_hash = % $panorama_address_ref;
        my %panorama_address_group_hash = % $panorama_address_group_ref;
        my %panorama_application_group_hash = % $panorama_application_group_ref;
        my %panorama_schedule_hash = % $panorama_schedule_ref;

	my %pan_application_group = &make_application_group(%panorama_application_group_hash);
	my %regular_application_group = &make_application_group(%application_group_hash);
	%application_group = ( %pan_application_group , %regular_application_group , %shared_application_group);
	
	my %pan_service_group = &make_service_group(%panorama_service_group_hash);
	my %regular_service_group = &make_service_group(%service_group_hash);
	%service_group = ( %pan_service_group , %regular_service_group , %shared_service_group );

	my %pan_address_group = &make_address_group(%panorama_address_group_hash);
	my %regular_address_group = &make_address_group(%address_group_hash);
	%address_group = ( %pan_address_group , %regular_address_group , %shared_address_group);

#	print Dumper %panorama_address_group_hash;
#	exit();
	
	my %pan_address = &address_check(%panorama_address_hash);
	my %base_address = &address_check(%address_hash);
	%address = (%pan_address, %base_address , %shared_address);

	
	my %pan_service = &service_check(%panorama_service_hash);
	my %base_service = &service_check(%service_hash);
	%service = (%pan_service, %base_service, %predefined_service , %shared_service);

        my %pan_schedule = &schedule_check(%panorama_schedule_hash);
        my %base_schedule = &schedule_check(%schedule_hash);
        %schedule = (%pan_schedule, %base_schedule, %shared_schedule);

	my @pre_rule_order = &get_rule_order($config_panorama_get,'prerule',$vsys);
	my @rule_order = &get_rule_order($device_entry_get,'rule',$vsys);
	my @post_rule_order = &get_rule_order($config_panorama_get,'postrule',$vsys);

	&make_rules('prerule',$vsys,@pre_rule_order);
	&make_rules('rule',$vsys,@rule_order);
	&make_rules('postrule',$vsys,@post_rule_order);
#	print "$vsys\n@pre_rule_order\n";



	#print "Here $vsys now\n";
	if ($compare){
#		push @rules_deleted, $_ for keys %del_check;
	#		print "Check here\n";
		my ($deleted_vsys,$deleted_ruleset,$deleted_name)=();
		my @deleted_ruleset = ('rule','prerule','postrule');
		foreach my $deleted_ruleset ( @deleted_ruleset){

	#		print "$deleted_ruleset\n";
			
			foreach my $deleted_name (keys %{$del_check{$vsys}{$deleted_ruleset}}) {
	#		print "$deleted_name\n";
			$deleted_vsys = $vsys;
			
#		print Dumper %del_check;
#		print "@rules_deleted\n";
#		foreach my $deleted_rule (@rules_deleted){
#			foreach my $line( @rule_types){

#				 ${ (keys %{$del_check{$vsys}{$line}})

#			if ($deleted_rule =~ /(.+?)-(.+?)-(.+$)/){
#				$deleted_vsys = $1;
#				$deleted_ruleset = $2;
#				$deleted_name = $3;
#			}
			#print "$deleted_vsys ** $deleted_ruleset ** $deleted_name\n";
			#if ($deleted_vsys eq $vsys){
			#print "$vsys $deleted_vsys $deleted_ruleset $deleted_name";

                        for  ($count = 1; $count <= $highrule{$vsys}; $count++){
                                my $name_test = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$count}{'entry'}{'name'};
                                if ($name_test eq $deleted_name){
                                        $deleted_rulecount = $count;
                                        last;
                                }
                        }



                        my $deleted_tag = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'tag'} ;
                        my $deleted_description = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'description'} ;
                        my $deleted_from = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'from'} ;
                        my $deleted_negate_source = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'negate_source'} ;
                        my $deleted_source_address_out = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'source_address_out'} ;
                        my $deleted_source_address_value_out = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'source_address_value_out'} ;
                        my $deleted_source_user = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'source_user'} ;
                        my $deleted_to = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'to'} ;
                        my $deleted_negate_destination = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'negate_destination'} ;
                        my $deleted_destination_address_out = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'destination_address_out'} ;
                        my $deleted_destination_address_value_out = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'destination_address_value_out'} ;
                        my $deleted_application = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'application'} ;
                        my $deleted_service_out = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'service_out'} ;
                        my $deleted_service_value_out = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'service_value_out'} ;
                        my $deleted_action = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'action'} ;
                        my $deleted_log_start = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'log_start'} ;
                        my $deleted_log_end = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'log_end'} ;
			my $deleted_log_setting = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'log_setting'} ;
                        my $deleted_spyware = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'spyware'} ;
                        my $deleted_vunerabiity = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'vulnerability'} ;
                        my $deleted_virus = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'virus'} ;
                        my $deleted_ur_fitering = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'url_filtering'} ;
                        my $deleted_group = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'group'} ;
                        my $deleted_data_fitering = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'data_filtering'} ;
                        my $deleted_fie_bocking = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'file_blocking'} ;
                        my $deleted_disabled = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'disabled'} ;
                        my $deleted_schedule_out = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'schedule'} ;
                        my $deleted_qos = $xml_old{'vsys'}{$deleted_vsys}{$deleted_ruleset}{$deleted_rulecount}{'entry'}{'qos'} ;


                        $historycountnum++;
			$historycount =  "R" .$historycountnum;
=begin
			print "Deleted Rule {'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name} {vsys=$vsys}{fw=$fw}{vsys=$deleted_vsys}{ruleset=$deleted_ruleset}{tag=$deleted_tag} {$deleted_from} {neg_src=$deleted_negate_source} {src=$deleted_source_address_out} {src_add=$deleted_source_address_value_out} {src_user=$deleted_source_user} {to=$deleted_to} {neg_dst=$deleted_negate_destination} {dst_add_out=$deleted_destination_address_out} {dst_value_out=$deleted_destination_address_value_out} {app=$deleted_appication} {svc=$deleted_service_out} {svc_val=$deleted_service_value_out} {action=$deleted_action} {log_start=$deleted_log_start} {log_end=$deleted_log_end} {log_setting=$deleted_log_setting} {spy=$deleted_spyware} {vuln=$deleted_vulnerability} {virus=$deleted_virus} {url=$deleted_url_fitering} {group=$deleted_group} {data_filtering=$deleted_data_filtering} {file_block=$deleted_fie_bocking} {disabled=$deleted_disabled} {schedule=$deleted_schedule_out} {qos=$deleted_qos} \n\n";	

print "{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'tag'} = $deleted_tag\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'description'} = $deleted_description\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'from'} = $deleted_from\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'negate_source'} = $deleted_negate_source\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'source_address_out'} = $deleted_source_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'source_address_value_out'} = $deleted_source_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'source_user'} = $deleted_source_user\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'to'} = $deleted_to\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'negate_destination'} = $deleted_negate_destination\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'destination_address_out'} = $deleted_destination_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'destination_address_value_out'} = $deleted_destination_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'application'} = $deleted_application\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'service_out'} = $deleted_service_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'service_value_out'} = $deleted_service_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'action'} = $deleted_action\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'log_start'} = $deleted_log_start\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'log_end'} = $deleted_log_end\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'log_setting'} = $deleted_log_setting\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'spyware'} = $deleted_spyware\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'vulnerability'} = $deleted_vulnerability\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'virus'} = $deleted_virus\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'url_filtering'} = $deleted_url_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'group'} = $deleted_group\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'data_filtering'} = $deleted_data_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'file_blocking'} = $deleted_file_blocking\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'disabled'} = $deleted_disabled\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'schedule'} = $deleted_schedule_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'qos'} = $deleted_qos\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'ruleset'} = $deleted_ruleset\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'change'} = Removed\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'date'} = $detail_time\n";
=cut


                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'tag'} = $deleted_tag;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'description'} = $deleted_description;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'from'} = $deleted_from;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'negate_source'} = $deleted_negate_source;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'source_address_out'} = $deleted_source_address_out;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'source_address_value_out'} = $deleted_source_address_value_out;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'source_user'} = $deleted_source_user;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'to'} = $deleted_to;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'negate_destination'} = $deleted_negate_destination;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'destination_address_out'} = $deleted_destination_address_out;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'destination_address_value_out'} = $deleted_destination_address_value_out;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'application'} = $deleted_application;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'service_out'} = $deleted_service_out;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'service_value_out'} = $deleted_service_value_out;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'action'} = $deleted_action;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'log_start'} = $deleted_log_start;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'log_end'} = $deleted_log_end;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'log_setting'} = $deleted_log_setting;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'spyware'} = $deleted_spyware;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'vulnerability'} = $deleted_vulnerability;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'virus'} = $deleted_virus;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'url_filtering'} = $deleted_url_filtering;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'group'} = $deleted_group;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'data_filtering'} = $deleted_data_filtering;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'file_blocking'} = $deleted_file_blocking;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'disabled'} = $deleted_disabled;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'schedule'} = $deleted_schedule_out;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'qos'} = $deleted_qos;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'ruleset'} = $deleted_ruleset;
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'change'} = "Removed";
                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$deleted_name}{'entry'}{'date'} = $detail_time;
			}


		}
	}
	$out_rule_hash{$fw}{'info'}{$vsys} = $displayname if ($multi eq 'on');

	


}
$out_rule_hash{$fw}{'info'}{'model'} = $model;
$out_rule_hash{$fw}{'info'}{'appver'} = $appver;
$out_rule_hash_ref = \%out_rule_hash;

#print Dumper %out_rule_hash;

#print "OK1\n";
my $xs  = XML::Simple->new(ForceArray => 1, KeepRoot => 1);
my $xml_out = $xs->XMLout($out_rule_hash_ref);

open FILE1, ">$scriptroot/xml/$fw.xml" or die $!;
	print FILE1 "$xml_out";
close FILE1;

open FILE2, ">$scriptroot/serial/$serial.txt" or die $!;
	print FILE2 "$hostname";
close FILE2;


#print "OK2\n";
my $epoch_timestamp = (stat("$scriptroot/xml/$fw.xml"))[9];
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($epoch_timestamp);
my $yyyymmdd = sprintf "%.4d%.2d%.2d", $year+1900, $mon+1, $mday;

open FILE3, ">$scriptroot/xml/$fw-$yyyymmdd.xml" or die $!;
        print FILE3 "$xml_out";
close FILE3;

#$out_history_hash{'info'}{'model'} = $model;
#$out_history_hash{'info'}{'appver'} = $appver;

$out_history_hash_ref = \%out_history_hash;
#print Dumper %out_history_hash;
#print "OK3\n";
my $xml_history_out  = XML::Simple->new(ForceArray => 1, RootName => $fw);
my $xml_out1 = $xml_history_out->XMLout($out_history_hash_ref);

my $fail = ();
foreach my $keys (keys %{$out_history_hash{'vsys'}}){
#	print "$keys\n";
	$fail = 1;

}
#if (!$out_history_hash{'vsys'}{'vsys1'}){
if (!$fail){
	$xml_out1 = "<$fw>\n<vsys name=\"vsys1\">\n</vsys>\n</$fw>";
};
open FILE4, ">$scriptroot/xml/$fw-history.xml" or die $!;
        print FILE4 "$xml_out1";
close FILE4;

open FILE5, ">$scriptroot/rules/$fw.txt" or die $!;
	foreach my $line (@check_info){
	        print FILE5 $line . "\n";
	}
close FILE5;



#print "clean\n";
sub make_service_group {
        my %current_service_group = @_;
        my %return_service_group =( );

        $skipservice_group = ();
        $hash_ref = \%current_service_group;
        &deep_keys_foreach($hash_ref, sub {
        my ($k1, $k2) = @_;
                print "";
        });
#		print Dumper %current_service_group ;
        if ($skipservice_group){
	        if ($current_service_group{'entry'}{'name'}{'members'}) {
	                if ($current_service_group{'entry'}{'members'}[1]){
	                        my $key = $current_service_group{'entry'}{'name'};
	                        my @here = @{$current_service_group{'entry'}{'members'}};
	                        my $out = ();
	                        foreach my $line (@here){
        	                        $out .= "$line,";
	                        }
	                        chomp $out;
	                        $return_service_group{$key} = $out;
	                }
	                else {
	                        $return_service_group{$key} = $current_service_group{'entry'}{'member'}{'member'};
	                }
	
	        }
	        else {
#		print Dumper %current_service_group . "\n";
	                foreach $key (keys( % {$current_service_group{'entry'}} ) ) {
#		print "Here2 $key\n";
	                        if ($current_service_group{'entry'}{$key}{'members'}{'member'}[1]){
                                my @here = @{$current_service_group{'entry'}{$key}{'members'}{'member'}};
	                                my $out = ();
	                                foreach my $line (@here){
	                                        $out .= "$line,";
	                                }
	                                chomp $out;
	                                $return_service_group{$key} = $out;
	                        }
	                        else {
	                                $return_service_group{$key} = $current_service_group{'entry'}{$key}{'members'}{'member'};
	                        }
	                }
	        }
	}
	else {
		if ($current_service_group{'entry'}{'name'}) {
			if ($current_service_group{'entry'}{'member'}[1]){
				my $key = $current_service_group{'entry'}{'name'};
			        my @here = @{$current_service_group{'entry'}{'member'}};
			        my $out = ();
			        foreach my $line (@here){
			                $out .= "$line,";
			        }
			        chomp $out;
			        $return_service_group{$key} = $out;
			}
			else {
			        $return_service_group{$key} = $current_service_group{'entry'}{'member'};
			}
	
		}
		else {
			foreach $key (keys( % {$current_service_group{'entry'}} ) ) {
		                if ($current_service_group{'entry'}{$key}{'member'}[1]){
		                        my @here = @{$current_service_group{'entry'}{$key}{'member'}};
		                        my $out = ();
		                        foreach my $line (@here){
		                                $out .= "$line,";
		                        }
		                        chomp $out;
		                        $return_service_group{$key} = $out;
		                }
		                else {
		                        $return_service_group{$key} = $current_service_group{'entry'}{$key}{'member'};
		                }
			}
	        }
	}
        return %return_service_group;
}

sub make_address_group {
        my %current_address_group = @_;
        my %return_address_group =( );
	$skipaddress_group = ();
	$hash_ref = \%current_address_group;
	&deep_keys_foreach($hash_ref, sub {
	my ($k1, $k2) = @_;
		print "";
	});
#	print Dumper %current_address_group;
#	print "one - $out $current_address_group{'entry'}{'name'}{'static'}{'member'} PRE\n";
	## Additional layer was added (static) have to test for both of them
	if ($skipaddress_group){
		if ($current_address_group{'entry'}{'name'}{'static'}) {
			$skip = 1;
			if ($current_address_group{'entry'}{'static'}{'member'}[1]){
				my $key = $current_address_group{'entry'}{'name'}{'static'};
			        my @here = @{$current_address_group{'entry'}{'static'}{'member'}};
			        my $out = ();
			        foreach my $line (@here){
			                $out .= "$line,";
			        }
			        chomp $out;
	#			print "one - $out $current_address_group{'entry'}{'name'}{'static'}\n";
	#			exit();
			        $return_address_group{$key} = $out;
			}
			else {
			        $return_address_group{$key} = $current_address_group{'entry'}{'static'}{'member'};
	#			print "one-2 - $out $current_address_group{'entry'}{'name'}{'static'}\n";
			}
		}
		else {
			foreach $key (keys( % {$current_address_group{'entry'}} ) ) {
				if ($current_address_group{'entry'}{'member'}{'content'}{$key}{'static'}[1]){
					#$skip = 1;
					my $key = $current_address_group{'entry'}{'name'};
				        my @here = @{$current_address_group{'entry'}{'member'}{'content'}};
				        my $out = ();
				        foreach my $line (@here){
				                $out .= "$line,";
				        }
				        chomp $out;
#						print "two - $out $current_address_group{'entry'}{'name'}";
		#				exit();
				        $return_address_group{$key} = $out;
				}
		                elsif ($current_address_group{'entry'}{$key}{'static'}{'member'}[1]){
					#$skip = 1;
		                        my @here = @{$current_address_group{'entry'}{$key}{'static'}{'member'}};
		                        my $out = ();
		                        foreach my $line (@here){
		                                $out .= "$line,";
		                        }
		                        chomp $out;
#					print "three - $out $current_address_group{'entry'}{'name'}\n";
	#				exit();
		                        $return_address_group{$key} = $out;
		                }
		                else {
					# ($current_address_group{'entry'}{$key}{'static'}{'member'}){
					#$skip = 1;
		                        $return_address_group{$key} = $current_address_group{'entry'}{$key}{'static'}{'member'};
#					print "four - $out $current_address_group{'entry'}{$key}{'static'}{'member'}\n";
		                }
			}
#	                else {
#	                        $return_address_group{$key} = $current_address_group{'entry'}{$key}{'static'}{'member'};
#				print "four - $out $current_address_group{'entry'}{$key}{'static'}{'member'}\n";
#	                }
		}	
	}
	else {
		if ($current_address_group{'entry'}{'name'}) {
			if ($current_address_group{'entry'}{'member'}[1]){
				my $key = $current_address_group{'entry'}{'name'};
			        my @here = @{$current_address_group{'entry'}{'member'}};
			        my $out = ();
			        foreach my $line (@here){
			                $out .= "$line,";
			        }
			        chomp $out;
			        $return_address_group{$key} = $out;
			}
			else {
			        $return_address_group{$key} = $current_address_group{'entry'}{'member'};
			}
		}
		else {
			foreach $key (keys( % {$current_address_group{'entry'}} ) ) {
				if ($current_address_group{'entry'}{'member'}{'content'}[1]){
					my $key = $current_address_group{'entry'}{'name'};
				        my @here = @{$current_address_group{'entry'}{'member'}{'content'}};
				        my $out = ();
				        foreach my $line (@here){
				                $out .= "$line,";
				        }
				        chomp $out;
				        $return_address_group{$key} = $out;
				}
			        elsif ($current_address_group{'entry'}{$key}{'member'}[1]){
			        	my @here = @{$current_address_group{'entry'}{$key}{'member'}};
			                my $out = ();
			                foreach my $line (@here){
			                	$out .= "$line,";
		                        }
		                        chomp $out;
#					print "three - $out $current_address_group{'entry'}{'name'}\n";
#					exit();
		                        $return_address_group{$key} = $out;
		                }
		                else {
		                        $return_address_group{$key} = $current_address_group{'entry'}{$key}{'member'};
		                }
#	        	        else {
#		                        $return_address_group{$key} = $current_address_group{'entry'}{$key}{'member'};
#		                }
		
			}
		}
	}
#	}
#	else {
        return %return_address_group;
}

sub deep_keys_foreach
{
    my ($hashref, $code, $args) = @_;

    while (my ($k, $v) = each(%$hashref)) {
        if ($k eq 'static'){
                $skipaddress_group = 1;
        }
        elsif ($k eq 'members'){
		#print "$k && $v\n\n";
                $skipservice_group = 1;
        }

        my @newargs = defined($args) ? @$args : ();
        push(@newargs, $k);
        if (ref($v) eq 'HASH') {
            &deep_keys_foreach($v, $code, \@newargs);
            $code->(@newargs);
        }
        else {
            $code->(@newargs);
        }
    }
}



sub make_application_group {
        my %current_application_group = @_;
        my %return_application_group =( );
	if ($current_application_group{'entry'}{'name'}) {
		if ($current_application_group{'entry'}{'member'}[1]){
			my $key = $current_application_group{'entry'}{'name'};
		        my @here = @{$current_application_group{'entry'}{'member'}};
		        my $out = ();
		        foreach my $line (@here){
		                $out .= "$line,";
		        }
		        chomp($out);
		        $return_application_group{$key} = $out;
		}
		else {
		        $return_application_group{$key} = $current_application_group{'entry'}{'member'};
		}

	}
	else {
		foreach $key (keys( % {$current_application_group{'entry'}} ) ) {
	                if ($current_application_group{'entry'}{$key}{'member'}[1]){
	                        my @here = @{$current_application_group{'entry'}{$key}{'member'}};
	                        my $out = ();
	                        foreach my $line (@here){
	                                $out .= "$line,";
	                        }
	                        chomp($out);
	                        $return_application_group{$key} = $out;
	                }
	                else {
	                        $return_application_group{$key} = $current_application_group{'entry'}{$key}{'member'};
	                }
		}
        }
        return %return_application_group;
}


sub xpath_send {
	my $key = shift;
	my $xpath = shift;
	my $action = shift;

	$client->GET("https://$fwconnect/$restapi?&$action&key=$authkey&xpath=$xpath");
	my $return= $client->responseContent();
#	print "https://$fwconnect/$restapi?&$action&key=$authkey&xpath=$xpath\n";	
	return $return;
}



sub get_rule_order {
	my $current_rulebase = shift;
	my $current_rulecheck = shift;
	my $current_vsys = shift;
	my @return_rule_order = ();
	my $current_rulecheck1 = ();
#	print "$current_rulebase\n";
	my @get_rule_order = split(/</,$current_rulebase);

                        if ($current_rulecheck eq 'prerule'  ){
					$current_rulecheck1 = 'pre-rulebase';
                        }
                        elsif ($current_rulecheck eq 'postrule'  ){
					$current_rulecheck1 = 'post-rulebase';
                        }
                        elsif ($current_rulecheck eq 'rule'  ){
					$current_rulecheck1 = 'rulebase';
			}


	my ($start,$vsys_check,$rule_start,$last,$check,$check_1,@get_rule_order1,@get_rule_order2,@get_rule_order3) = ();
	if ($multi eq 'on'){
		foreach my $line (@get_rule_order){
#			print "$line-- $current_vsys\n";
			if ($line =~ /entry name=\"$current_vsys\">/ && !$vsys_check ){
				$vsys_check = 1;
			}
			elsif ($vsys_check && $line =~ /entry name=\"vsys/){
				last;
			}
			elsif ($vsys_check){
				push @get_rule_order1, $line;
			}
		}
		$vsys_check = ();
		foreach my $line (@get_rule_order1){
#			print "$line\n";
			if ($line =~ /$current_rulecheck1>/ && !$vsys_check ){
				$vsys_check = 1;
			}
			elsif ($vsys_check && $line =~ /\/$current_rulecheck1>/){
				last;
			}
			elsif ($vsys_check){
				push @get_rule_order2, $line;
			}
		}
		$vsys_check = ();
		foreach my $line (@get_rule_order2){
			if ($line =~ /security>/ && !$vsys_check ){
				$vsys_check = 1;
			}
			elsif ($vsys_check && $line =~ /\/security>/){
				last;
			}
			elsif ($vsys_check){
				push @get_rule_order3, $line;
#				print "$line-$current_vsys-$current_rulecheck\n";
			}
#			if ($line =~ /security>/ ){
#				$vsys_check = 1;
#			}
#			elsif ($vsys_check && $line !~ /\/security>/){
#				print "$line\n";

#				push @get_rule_order2, $line;
#				last;
#			}
		}
		$vsys_check = ();
		foreach my $line (@get_rule_order3){
			if ($line =~ /entry name="(.+?)"/ && !$last){
			        push @return_rule_order, $1;
				#print "$1-$current_vsys-$current_rulecheck\n";
			}
			elsif ($line =~ /\/pre-rulebase>/ && $current_rulecheck eq 'prerule'  ){
                        	$last = 1;
                                last;
                        }
                        elsif ($line =~ /\/post-rulebase>/ && $current_rulecheck eq 'postrule'  ){
                        	$last = 1;
                                last;
                        }
                        elsif ($line =~ /\/rulebase>/ && $current_rulecheck eq 'rule'  ){
	                        $last = 1;
                                last;
        		}

#			if ($line =~ /<security>/ ){
				#$check_1 = 1;
#				$vsys_check = 1;
#			}
#			elsif ($vsys_check && $line !~ /<\/security>/){

#				push @get_rule_order2, $line;
#			}
		}


=begin
			#elsif ($line =~ /security>/ && $check_1 ){
		
			#}
			elsif ($vsys_check){ 
				if ($line =~ /pre-rulebase>/ &&  $current_rulecheck eq 'prerule' ){
					$rule_start = 1;
				}
				elsif ($line =~ /rulebase>/ && $current_rulecheck eq 'rule' ){
					$rule_start = 1;
				}
				elsif ($line =~ /post-rulebase>/ &&  $current_rulecheck eq 'postrule'  ){
					$rule_start = 1;
				}
				elsif ($rule_start){
					if ($line =~ /entry name=\"vsys\d\"/){

						last;
					}
					elsif ($line =~ /security>/  ){
						$check = 1;
					}
					elsif ($check ){
						if ($line =~ /^rules>/  ){
							$start = 1;
						}
						elsif ($start){
							if ($line =~ /entry name="(.+?)"/ && !$last){
								push @return_rule_order, $1;
							}
							if ($line =~ /\/rules>/ || $line =~ /rules\/>/  || $line =~ /\/security>/ || $line =~ /<application-override>/ ||  $line =~ /<nat>/ ){
								$last = 1;
								last;
							}
							elsif ($line =~ /\/pre-rulebase>/ && $current_rulecheck eq 'prerule'  ){
								$last = 1;
								last;
							}
							elsif ($line =~ /\/rulebase>/ && $current_rulecheck eq 'rule'  ){
								$last = 1;
								last;
							}
							elsif ($line =~ /\/post-rulebase>/ && $current_rulecheck eq 'postrule'  ){
								$last = 1;
								last;
							}
						}
					}
				}
			}
		}
=cut
	}

	else {
		foreach my $line (@get_rule_order){
			if ($line =~ /security>/ && $rule_start ){
				$start = 1;
			}
			if ($line =~ /pre-rulebase>/ &&  $current_rulecheck eq 'prerule'  ){
				$rule_start = 1;
			}
			elsif ($line =~ /rulebase>/ && $current_rulecheck eq 'rule' ){
				$rule_start = 1;
			}
			elsif ($line =~ /post-rulebase>/ &&  $current_rulecheck eq 'postrule' ){
				$rule_start = 1;
			}
			if ($line =~ /\/security>/ && 'prerule' && $start ){
				last;
			}
			if ($line =~ /entry name="(.+?)"/ && $start ){
				push @return_rule_order, $1;
			}
		}
	}
#	print "@return_rule_order\n";#-$current_vsys-$current_rulecheck\n";
	return @return_rule_order;
	
}

sub address_check {
	my ( %current_address) = @_;
	my %return_address = ();
	if ($current_address{'entry'}{'name'}){
		my $key = $current_address{'entry'}{'name'};
		if ($current_address{'entry'}{'fqdn'}){
			$return_address{$key}=$current_address{'entry'}{'fqdn'};
		}
		elsif ($current_address{'entry'}{'ip-netmask'}){
			$return_address{$key}=$current_address{'entry'}{'ip-netmask'};
		}
		elsif ($current_address{'entry'}{'ip-range'}){
			$return_address{$key}=$current_address{'entry'}{'ip-range'};
		}
	}
	else {
		foreach $key (keys( % {$current_address{'entry'}} ) ) {
			if ($current_address{'entry'}{$key}{'fqdn'}){
				$return_address{$key}=$current_address{'entry'}{$key}{'fqdn'};
			}
			elsif ($current_address{'entry'}{$key}{'ip-netmask'}){
				$return_address{$key}=$current_address{'entry'}{$key}{'ip-netmask'};
			}
			elsif ($current_address{'entry'}{$key}{'ip-range'}){
				$return_address{$key}=$current_address{'entry'}{$key}{'ip-range'};
			}
		}
	}
	return %return_address;
}


sub service_check {
        my ( %current_service) = @_;
        my %return_service = ();
        if ($current_service{'entry'}{'name'}){
                my $key = $current_service{'entry'}{'name'};
                if ($current_service{'entry'}{'protocol'}{'tcp'}{'port'}){
                        $return_service{$key}="tcp-" . $current_service{'entry'}{'protocol'}{'tcp'}{'port'};
                }
                elsif ($current_service{'entry'}{'protocol'}{'udp'}{'port'}){
                        $return_service{$key}="udp-" . $current_service{'entry'}{'protocol'}{'udp'}{'port'};
                }
        }
        else {
	        foreach $key (keys( % {$current_service{'entry'}} ) ) {
	                if ($current_service{'entry'}{$key}{'protocol'}{'tcp'}{'port'}){
		                $return_service{$key}="tcp-" . $current_service{'entry'}{$key}{'protocol'}{'tcp'}{'port'};
	                }
	                elsif ($current_service{'entry'}{$key}{'protocol'}{'udp'}{'port'}){
	                	$return_service{$key}="udp-" . $current_service{'entry'}{$key}{'protocol'}{'udp'}{'port'};
	        	}
		}
        }	
        return %return_service;
}



sub schedule_check {
        my ( %current_schedule) = @_;
	my @days = ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
        my %return_schedule = ();
        if ($current_schedule{'entry'}{'name'}){
                my $key = $current_schedule{'entry'}{'name'};
		my $hold = ();
		my $holdday = ();
                if ($current_schedule{'entry'}{'non-recurring'}){
                        if ($current_schedule{'entry'}{'non-recurring'}{'member'}[1]){
	                        my @array_check = @{$current_schedule{'entry'}{'non-recurring'}{'member'}};
        	                foreach $key (@array_check){
	                                $hold .= "$key,";
	                        }
	                        chomp($hold);
				$return_schedule{$key} = "non-recurring-$hold"; 
			}
			else {
				$return_schedule{$key} = "non-recurring-" . $current_schedule{'entry'}{'non-recurring'}{'member'};

			}
                }
                elsif ($current_schedule{'entry'}{'recurring'}{'daily'}){
                        if ($current_schedule{'entry'}{'recurring'}{'daily'}{'member'}[1]){
	                        my @array_check = @{$current_schedule{'entry'}{'recurring'}{'daily'}{'member'}};
        	                foreach $key (@array_check){
	                                $hold .= "$key,";
	                        }
	                        chomp($hold);
				$return_schedule{$key} = "daily-$hold"; 
			}
			else {
				$return_schedule{$key} = "daily-" . $current_schedule{'entry'}{'recurring'}{'daily'}{'member'};

			}
                }
                elsif ($current_schedule{'entry'}{'recurring'}{'weekly'}){

#					$return_schedule{$key} = "weekly-$hold"; 
#					$return_schedule{$key} = "weekly-" . $current_schedule{'entry'}{'recurring'}{'weekly'}{'member'};
			foreach my $day (@days){
	                        if ($current_schedule{'entry'}{'recurring'}{'weekly'}{$day}{'member'}[1]){
		                        my @array_check = @{$current_schedule{'entry'}{'recurring'}{'weekly'}{$day}{'member'}};
	        	                foreach $key (@array_check){
		                                $hold .= "$key,";
		                        }
		                        chomp($hold);
					$holdday .= "$day-" . $hold . ',';
				}
                                elsif (ref($current_schedule{'entry'}{'recurring'}{'weekly'}{$day}{'member'}) ne 'ARRAY'){
                                        $holdday .= "$day-" . $current_schedule{'entry'}{'recurring'}{'weekly'}{$day}{'member'} . ',';
                                }
			}
                        chomp($holdday);
			$return_schedule{$key} = "weekly-$holdday";
			
                }
        }
        else {
                foreach $key (keys( % {$current_schedule{'entry'}} ) ) {
			my $hold = ();
			my $holdday = ();
	                if ($current_schedule{'entry'}{$key}{'non-recurring'}){
	                        if ($current_schedule{'entry'}{$key}{'non-recurring'}{'member'}[1]){
		                        my @array_check = @{$current_schedule{'entry'}{$key}{'non-recurring'}{'member'}};
	        	                foreach $key (@array_check){
		                                $hold .= "$key,";
		                        }
		                        chomp($hold);
					$return_schedule{$key} = "non-recurring-$hold"; 
				}
				else {
					$return_schedule{$key} = "non-recurring-" . $current_schedule{'entry'}{$key}{'non-recurring'}{'member'};
	
				}
        	        }
	                elsif ($current_schedule{'entry'}{$key}{'recurring'}{'daily'}){
	                        if ($current_schedule{'entry'}{$key}{'recurring'}{'daily'}{'member'}[1]){
		                        my @array_check = @{$current_schedule{'entry'}{$key}{'recurring'}{'daily'}{'member'}};
	        	                foreach $key (@array_check){
		                                $hold .= "$key,";
		                        }
		                        chomp($hold);
					$return_schedule{$key} = "daily-$hold"; 
				}
				else {
					$return_schedule{$key} = "daily-" . $current_schedule{'entry'}{$key}{'recurring'}{'daily'}{'member'};
	
				}
	                }
	                elsif ($current_schedule{'entry'}{$key}{'recurring'}{'weekly'}){

	                        foreach my $day (@days){
	                                if ($current_schedule{'entry'}{$key}{'recurring'}{'weekly'}{$day}{'member'}[1]){
	                                        my @array_check = @{$current_schedule{'entry'}{$key}{'recurring'}{'weekly'}{$day}{'member'}};
	                                        foreach $key (@array_check){
	                                                $hold .= "$key,";
	                                        }
	                                        chomp($hold);
	                                        $holdday .= "$day-" . $hold . ',';
	                                }
	                                elsif (ref($current_schedule{'entry'}{$key}{'recurring'}{'weekly'}{$day}{'member'}) ne 'ARRAY'){
		                                        $holdday .= "$day-" . $current_schedule{'entry'}{$key}{'recurring'}{'weekly'}{$day}{'member'}  . ',' ;
	                                }
	                        }
                                chomp($holdday);

				$return_schedule{$key} = "weekly-$holdday";
	
			}
                }

        }
        return %return_schedule;
}



sub get_service_value {
	my $service = shift;
	my ($sub_service_out, $sub_value_out) =();
	if ($service_group{$service}){
		my $current_service_group = $service_group{$service};
		my @current_service_group = split(/,/,$current_service_group); 
		foreach my $line (@current_service_group){
			$sub_service_out .= "$service -> $line,";
			$sub_value_out .= "$service{$line},";
		}
		$sub_service_out =~ s/,$//g;
		$sub_value_out =~ s/,$//g;
	}
	elsif ($service{$service}) {
		$sub_service_out = $service;
		$sub_value_out = $service{$service};
	}
	else {
		$sub_service_out = $service;
		$sub_value_out = $service;
	}
	return ($sub_service_out, $sub_value_out);	
}

sub check_application_group {
	my $current_application = shift;
	my  $sub_application_out = ();

	if ($application_group{$current_application}){
                my $current_application_group = $application_group{$current_application};
                my @current_application_group = split(/,/,$current_application_group);
                foreach my $line (@current_application_group){
                        $sub_application_out .= "$current_application -> $line,";
                }
		chomp($sub_application_out);
		#print $sub_application_out . "\n";
        }
	else {
		$sub_application_out = $current_application . ",";
	}
	return $sub_application_out;

}

sub get_address_value {
        my $address = shift;
        my ($sub_address_out, $sub_value_out) =();
        if ($address_group{$address}){
                my $current_address_group = $address_group{$address};
                my @current_address_group = split(/,/,$current_address_group);
#		$counth = 0;
                foreach my $line (@current_address_group){
			# if nested have to do multiple times
			if ($address_group{$line}){
				my $tier_address_group = $address_group{$line};
				my @tier_address_group = split(/,/,$tier_address_group);
				foreach my $tierline (@tier_address_group){
					$sub_address_out .= "$address -> $line -> $tierline,";
					$sub_value_out .= "$address{$tierline},";
#					print "$sub_address_out $sub_value_out $counth\n";
#					$counth++;
				}

			}
			else {
				$sub_address_out .= "$address -> $line,";
				$sub_value_out .= "$address{$line},";
			}
                }
		$sub_address_out =~ s/,$//g;
		$sub_value_out =~ s/,$//g;
        }
        elsif ($address{$address}){
                $sub_address_out = $address;
                $sub_value_out = $address{$address};
        }
	else {
		$sub_address_out = $address;
		$sub_value_out = $address;
	}	
        return ($sub_address_out, $sub_value_out);
}

=begin
sub get_address_value {
        my $address = shift;
        my ($sub_address_out, $sub_value_out) =();
        if ($address_group{$address}){
                my $current_address_group = $address_group{$address};
                my @current_address_group = split(/,/,$current_address_group);
                foreach my $line (@current_address_group){
                        $sub_address_out .= "$address -> $line,";
                        $sub_value_out .= "$address{$line},";
                }
                $sub_address_out =~ s/,$//g;
                $sub_value_out =~ s/,$//g;
        }
        elsif ($address{$address}){
                $sub_address_out = $address;
                $sub_value_out = $address{$address};
        }
        else {
                $sub_address_out = $address;
                $sub_value_out = $address;
        }
        return ($sub_address_out, $sub_value_out);
}

=cut



sub make_rules {
	my $ruleset = shift;
	my $vsys = shift;
	my @current_rules = @_;

	my %any_rules = ();
	if ($ruleset eq 'rule'){
		%any_rules = %rulebase;
	}

	elsif ($ruleset eq 'prerule'){
		%any_rules = %prerulebase;
	}
	elsif ($ruleset eq 'postrule'){
		%any_rules = %postrulebase;
	}

	if ($any_rules{'entry'}{'name'}){
		my $current_name =  $any_rules{'entry'}{'name'};
		delete($any_rules{'entry'}{'name'});
		my %temp = % {$any_rules{'entry'}};
		%any_rules = ();
		$any_rules{'entry'}{$current_name} = \%temp;

	}


	my $rulecount = ();
	foreach my $rule (@current_rules){
		my ($name, $description, $tag, $from, $negate_source, $source, $src_ip, $source_user, $hip_profiles, $to, $negate_destination, $destination, $dst_ip) =();
		my ($application,$service_out,$service_value_out,$category,$action,$log_start,$log_end,$virus,$spyware,$vulnerability,$log_setting,$target,$option)=();
		my ($destination_address_out,$destination_address_value_out,$source_address_out,$source_address_value_out,$url_filtering,$group) =();
		my ($data_filtering,$file_blocking,$schedule,$schedule_out,$qos) = ();
		$name = $rule;
		$rulecount++;

		
		$action = $any_rules{'entry'}{$rule}{'action'};
		$log_start = $any_rules{'entry'}{$rule}{'log-start'};
		$log_end = $any_rules{'entry'}{$rule}{'log-end'};
		$description = $any_rules{'entry'}{$rule}{'description'};
		$log_setting = $any_rules{'entry'}{$rule}{'log-setting'};
		$negate_source = $any_rules{'entry'}{$rule}{'negate-source'};
		$disabled = $any_rules{'entry'}{$rule}{'disabled'};
		$negate_destination = $any_rules{'entry'}{$rule}{'negate-destination'};
		$virus = $any_rules{'entry'}{$rule}{'profile-setting'}{'profiles'}{'virus'}{'member'};
		$spyware = $any_rules{'entry'}{$rule}{'profile-setting'}{'profiles'}{'spyware'}{'member'};
		$vulnerability = $any_rules{'entry'}{$rule}{'profile-setting'}{'profiles'}{'vulnerability'}{'member'};
		$url_filtering = $any_rules{'entry'}{$rule}{'profile-setting'}{'profiles'}{'url-filtering'}{'member'};
		$data_filtering = $any_rules{'entry'}{$rule}{'profile-setting'}{'profiles'}{'data-filtering'}{'member'};
		$file_blocking = $any_rules{'entry'}{$rule}{'profile-setting'}{'profiles'}{'file-blocking'}{'member'};
		$group = $any_rules{'entry'}{$rule}{'profile-setting'}{'group'}{'member'};

		$description =~ s/\s+$//g;
		$description =~ s/\r|\n//g;

		if ($any_rules{'entry'}{$rule}{'qos'}{'marking'}{'ip-dscp'}){
			$qos = "ip-dscp-" . $any_rules{'entry'}{$rule}{'qos'}{'marking'}{'ip-dscp'};
		}
		elsif ($any_rules{'entry'}{$rule}{'qos'}{'marking'}{'ip-precedence'}){
			$qos = "ip-precedence-" . $any_rules{'entry'}{$rule}{'qos'}{'marking'}{'ip-precedence'};
		}


		$schedule = $any_rules{'entry'}{$rule}{'schedule'};
		if ($schedule) {
			$schedule_out = "$schedule-";
			$schedule_out .= $schedule{$schedule};
		}

		# Get the "from" zone  
        	if ( $any_rules{'entry'}{$rule}{'from'}{'member'}[1]){
	                my @array_check = @{$any_rules{'entry'}{$rule}{'from'}{'member'}};
	                foreach $key (@array_check){
	                        $from .= "$key,";
	                }
			chomp($from);
	        }
	        else {
			$from = $any_rules{'entry'}{$rule}{'from'}{'member'};
=begin
#			print "$from\n";
			if (ref($from) eq 'ARRAY' ){
				print "$rule\n";
				print Dumper %any_rules;
				print Dumper $from;
				print "is Array\n";
				my @newarray = @{ $from };
				$from1 = $newarray[0];
				#$from = $any_rules{'entry'}{$rule}{'from'}{'member'}[0];
			print "$from1\n";
			print "@newarray\n";
				#$from =
				exit();
			}
=cut
	        }

		# Get the "to" zone  
        	if ( $any_rules{'entry'}{$rule}{'to'}{'member'}[1]){
	                my @array_check = @{$any_rules{'entry'}{$rule}{'to'}{'member'}};
	                foreach $key (@array_check){
	                        $to .= "$key,";
	                }
			chomp($to);
	        }
	        else {
			$to = $any_rules{'entry'}{$rule}{'to'}{'member'};
	        }

		# Get the "tag"
        	if ( !$any_rules{'entry'}{$rule}{'tag'}{'member'}){
			$tag = "none";	
		}
        	elsif ( $any_rules{'entry'}{$rule}{'tag'}{'member'}[1]){
	                my @array_check = @{$any_rules{'entry'}{$rule}{'tag'}{'member'}};
	                foreach $key (@array_check){
	                        $tag .= "$key ";
	                }
			chop($tag);
	        }
	        else {
			$tag = $any_rules{'entry'}{$rule}{'tag'}{'member'};
	        }

		# Get the "description"
#        	if ( !$any_rules{'entry'}{$rule}{'description'}{'member'}){
#			$description = "";	
#		}
#        	if ( $any_rules{'entry'}{$rule}{'description'}{'member'}[1]){
#	                my @array_check = @{$any_rules{'entry'}{$rule}{'description'}{'member'}};
#	                foreach $key (@array_check){
#	                        $description .= "$key ";
#	                }
#	        }
#	        else {
#			$description = $any_rules{'entry'}{$rule}{'description'}{'member'};
#	        }

		# Get the source user group

		# Get the source user group
        	if ( $any_rules{'entry'}{$rule}{'source-user'}{'member'}[1]){
	                my @array_check = @{$any_rules{'entry'}{$rule}{'source-user'}{'member'}};
	                foreach $key (@array_check){
	                        $source_user .= $key;
	                }
	        }
	        else {
			$source_user = $any_rules{'entry'}{$rule}{'source-user'}{'member'};
			 if (ref($source_user) eq "ARRAY") {
				$source_user = 'any';
			}
	        }
		
		# Get the applications
        	if ( $any_rules{'entry'}{$rule}{'application'}{'member'}[1]){
	                my @array_check = @{$any_rules{'entry'}{$rule}{'application'}{'member'}};
			$application = ();
	                foreach $key (@array_check){
				$application .= &check_application_group($key) ;#. ",";
	                }
			chomp($application); 
	        }
	        else {
			my $key = $any_rules{'entry'}{$rule}{'application'}{'member'};
			$application = &check_application_group($key);
	        }
		
        	if ( $any_rules{'entry'}{$rule}{'service'}{'member'}[1]){
	                my @array_check = @{$any_rules{'entry'}{$rule}{'service'}{'member'}};
			my ($service_out_hold , $service_value_out_hold) =();
	                foreach $key (@array_check){
				($service_out_hold, $service_value_out_hold) = &get_service_value($key);
				$service_out .= "$service_out_hold,";
				$service_value_out .= "$service_value_out_hold,";
	                }
	        }
	        else {
			$service_hold = $any_rules{'entry'}{$rule}{'service'}{'member'};

			($service_out , $service_value_out) = &get_service_value($service_hold);
			
	        }
		$service_out =~ s/,$//g;
		$service_value_out =~ s/,$//g;

                if ( $any_rules{'entry'}{$rule}{'source'}{'member'}[1]){
                        my @array_check = @{$any_rules{'entry'}{$rule}{'source'}{'member'}};
                	my ($source_address_out_hold , $source_address_value_out_hold) =();
                        foreach $key (@array_check){
                                ($source_address_out_hold, $source_address_value_out_hold) = &get_address_value($key);
                                $source_address_out .= "$source_address_out_hold,";
                                $source_address_value_out .= "$source_address_value_out_hold,";
                        }
                }
                else {
                        my $source_address_hold = $any_rules{'entry'}{$rule}{'source'}{'member'};

                        ($source_address_out , $source_address_value_out) = &get_address_value($source_address_hold);

                }
		$source_address_out =~ s/,$//g;
		$source_address_value_out =~ s/,$//g;


                if ( $any_rules{'entry'}{$rule}{'destination'}{'member'}[1]){
                        my @array_check = @{$any_rules{'entry'}{$rule}{'destination'}{'member'}};
                	my ($destination_address_out_hold , $destination_address_value_out_hold) =();
                        foreach $key (@array_check){
                                ($destination_address_out_hold, $destination_address_value_out_hold) = &get_address_value($key);
                                $destination_address_out .= "$destination_address_out_hold,";
                                $destination_address_value_out .= "$destination_address_value_out_hold,";
                        }
                }
                else {
                        my $destination_address_hold = $any_rules{'entry'}{$rule}{'destination'}{'member'};
                        ($destination_address_out , $destination_address_value_out) = &get_address_value($destination_address_hold);
                }
		$destination_address_out =~ s/,$//g;
		$destination_address_value_out =~ s/,$//g;

		push @check_info, "$vsys###$description###$name";
#		print "$vsys - $description - $name\n";
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'tag'} = $tag;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'from'} = $from;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'description'} = $description;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'negate_source'} = $negate_source;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'source_address_out'} = $source_address_out;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'source_address_value_out'} = $source_address_value_out;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'source_user'} = $source_user;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'to'} = $to;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'negate_destination'} = $negate_destination;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'destination_address_out'} = $destination_address_out;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'destination_address_value_out'} = $destination_address_value_out;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'application'} = $application;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'service_out'} = $service_out;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'service_value_out'} = $service_value_out;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'action'} = $action;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'log_start'} = $log_start;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'log_end'} = $log_end;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'log_setting'} = $log_setting;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'spyware'} = $spyware;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'vulnerability'} = $vulnerability;
                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'virus'} = $virus;
		$out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'url_filtering'} = $url_filtering;
		$out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'group'} = $group;
		$out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'data_filtering'} = $data_filtering;
		$out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'file_blocking'} = $file_blocking;
		$out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'disabled'} = $disabled;
		$out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'schedule'} = $schedule_out;
		$out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'qos'} = $qos;
#                $out_rule_hash{$fw}{'vsys'}{$vsys}{$ruleset}{$rulecount}{'entry'}{$name}{'target'} = $target;

		if ($compare ){
			my $old_rulecount =();
			my $current_highrule = $highrule{$vsys};
			for  ($count = 1; $count <= $current_highrule; $count++){
				my $rcount = "R$count";
				my $name_test = $xml_old{'vsys'}{$vsys}{$ruleset}{$count}{'entry'}{'name'};
				if ($name_test eq $name){
#					print "match $remove $name_test";
					$old_rulecount = $count;
#				print "{'vsys'}{$vsys}{$ruleset}{$count}{'entry'}{'action'}($name_test eq $name\n";
					delete($del_check{$vsys}{$ruleset}{$name_test});
					last;
				}	
			}

			if ($old_rulecount){
                                 my $old_tag = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'tag'} ;
                                 my $old_description = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'description'} ;
                                 my $old_from = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'from'} ;
                                 my $old_negate_source = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'negate_source'} ;
                                 my $old_source_address_out = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'source_address_out'} ;
                                 my $old_source_address_value_out = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'source_address_value_out'} ;
                                 my $old_source_user = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'source_user'} ;
                                 my $old_to = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'to'} ;
                                 my $old_negate_destination = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'negate_destination'} ;
                                 my $old_destination_address_out = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'destination_address_out'} ;
                                 my $old_destination_address_value_out = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'destination_address_value_out'} ;
                                 my $old_application = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'application'} ;
                                 my $old_service_out = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'service_out'} ;
                                 my $old_service_value_out = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'service_value_out'} ;
                                 my $old_action = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'action'} ;
                                 my $old_log_start = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'log_start'} ;
                                 my $old_log_end = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'log_end'} ;
                                 my $old_log_setting = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'log_setting'} ;
                                 my $old_spyware = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'spyware'} ;
                                 my $old_vunerabiity = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'vulnerability'} ;
                                 my $old_virus = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'virus'} ;
                                 my $old_url_fitering = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'url_filtering'} ;
                                 my $old_group = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'group'} ;
                                 my $old_data_fitering = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'data_filtering'} ;
                                 my $old_fie_bocking = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'file_blocking'} ;
                                 my $old_disabled = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'disabled'} ;
                                 my $old_schedule_out = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'schedule'} ;
                                 my $old_qos = $xml_old{'vsys'}{$vsys}{$ruleset}{$old_rulecount}{'entry'}{'qos'} ;



			
			#print "$from\n";	
				my $mismatch = ();
				my ($tag_mismatch, $desc_mismatch, $from_mismatch, $source_mismatch, $srcuser_mismatch, $to_mismatch, $destination_mismatch, $app_mismatch, $service_mismatch, $action_mismatch, $options_mismatch, $profile_mismatch) = ();
				if ( $old_tag ne  $tag) { $tag_mismatch = 1;}
				if ( $old_description ne  $description) { $desc_mismatch = 1;}
				if ( $old_from ne  $from) { $from_mismatch = 1;}
				if ( $old_negate_source ne  $negate_source) { $source_mismatch = 1;}
				if ( $old_source_address_out ne  $source_address_out) { $source_mismatch = 1;}
				if ( $old_source_address_value_out ne  $source_address_value_out) { $source_mismatch = 1;}
				if ( $old_source_user ne  $source_user) { $srcuser_mismatch = 1;}
				if ( $old_to ne  $to) { $to_mismatch = 1;}
				if ( $old_negate_destination ne  $negate_destination) { $destination_mismatch = 1;}
				if ( $old_destination_address_out ne  $destination_address_out) { $destination_mismatch = 1;}
				if ( $old_destination_address_value_out ne  $destination_address_value_out) { $destination_mismatch = 1;}
				if ( $old_application ne  $application) { $app_mismatch = 1;}
				if ( $old_service_out ne  $service_out) { $service_mismatch = 1;}
				if ( $old_service_value_out ne  $service_value_out) { $_service_mismatch = 1;}
				if ( $old_action ne  $action) { $action_mismatch = 1;}
				if ( $old_log_start ne  $log_start) { $options_mismatch = 1;}
				if ( $old_log_end ne  $log_end) { $options_mismatch = 1;}
				if ( $old_log_setting ne  $log_setting) { $options_mismatch = 1;}
				if ( $old_spyware ne  $spyware) { $profile_mismatch = 1;}
				if ( $old_vunerabiity ne  $vulnerability) { $profile_mismatch = 1;}
				if ( $old_virus ne  $virus) { $profile_mismatch = 1;}
				if ( $old_url_fitering ne  $url_filtering) { $profile_mismatch = 1;}
				if ( $old_group ne  $group) { $profile_mismatch = 1;}
				if ( $old_data_fitering ne  $data_filtering) { $profile_mismatch = 1;}
				if ( $old_fie_bocking ne  $file_blocking) { $profile_mismatch = 1;}
				if ( $old_disabled ne  $disabled) { $disable_mismatch = 1;}
				if ( $old_schedule_out ne  $schedule_out) { $options_mismatch = 1;}
				if ( $old_qos ne  $qos) { $options_mismatch = 1;}

				$mismatch = ($tag_mismatch + $desc_mismatch + $from_mismatch + $source_mismatch + $srcuser_mismatch + $to_mismatch + $destination_mismatch + $app_mismatch + $service_mismatch + $action_mismatch + $options_mismatch + $profile_mismatch );

				if ($mismatch){
					$historycountnum++;
		                        $historycount =  "R" . $historycountnum;

					#print "Old rule {'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name} {fw=$fw}{vsys=$vsys}{ruleset=$ruleset}{tag=$old_tag} {from=$old_from} {neg_src=$old_negate_source} {neg_src_add=$old_source_address_out} {src_add_out=$old_source_address_value_out} {src_user=$old_source_user} {to=$old_to} {neg_dst=$old_negate_destination} {dst_add=$old_destination_address_out} {dst_val=$old_destination_address_value_out} {app=$old_appication} {svc=$old_service_out} {svc_val=$old_service_value_out} {action=$old_action} {log_start=$old_log_start} {log_end=$old_log_end} {log_setting=$old_log_setting} {spy=$old_spyware} {vuln=$old_vulnerability} {virus=$old_virus} {url=$old_url_fitering} {group=$old_group} {filtering=$old_data_filtering} {file_blocking=$old_fie_blocking} {disable=$old_disabled} {schedule=$old_schedule_out} {qos=$old_qos}  \n\n";
=begin
#print Dumper %out_history_hash;
print "{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag'} = $old_tag\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'description'} = $old_description\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from'} = $old_from\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_source'} = $old_negate_source\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_out'} = $old_source_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_value_out'} = $old_source_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_user'} = $old_source_user\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to'} = $old_to\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_destination'} = $old_negate_destination\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_out'} = $old_destination_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_value_out'} = $old_destination_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'application'} = $old_application\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_out'} = $old_service_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_value_out'} = $old_service_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action'} = $old_action\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_start'} = $old_log_start\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_end'} = $old_log_end\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_setting'} = $old_log_setting\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'spyware'} = $old_spyware\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'vulnerability'} = $old_vulnerability\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'virus'} = $old_virus\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'url_filtering'} = $old_url_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'group'} = $old_group\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'data_filtering'} = $old_data_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'file_blocking'} = $old_file_blocking\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'disabled'} = $old_disabled\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'schedule'} = $old_schedule_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'qos'} = $old_qos\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'ruleset'} = $ruleset\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'change'} = Old\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'date'} = $detail_time\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag_mismatch'} = $tag_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'desc_mismatch'} = $desc_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from_mismatch'} = $from_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_mismatch'} = $source_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'srcuser_mismatch'} = $srcuser_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to_mismatch'} = $to_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_mismatch'} = $destination_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'app_mismatch'} = $app_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_mismatch'} = $service_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action_mismatch'} = $action_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'options_mismatch'} = $options_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'profile_mismatch'} = $profile_mismatch\n";
=cut
#					print "$out_history_hash {'vsys'} {$vsys} {'count'} {$historycount} $historycountnum {'entry'} {$name} {'entry'} {'tag'}\n";
#					print Dumper %out_history_hash;
					#if ($historycountnum == '1'){
				#		delete $out_history_hash{'vsys'}{$vsys};
			#		}

                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag'} = $old_tag;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'description'} = $old_description;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from'} = $old_from;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_source'} = $old_negate_source;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_out'} = $old_source_address_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_value_out'} = $old_source_address_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_user'} = $old_source_user;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to'} = $old_to;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_destination'} = $old_negate_destination;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_out'} = $old_destination_address_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_value_out'} = $old_destination_address_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'application'} = $old_application;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_out'} = $old_service_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_value_out'} = $old_service_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action'} = $old_action;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_start'} = $old_log_start;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_end'} = $old_log_end;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_setting'} = $old_log_setting;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'spyware'} = $old_spyware;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'vulnerability'} = $old_vulnerability;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'virus'} = $old_virus;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'url_filtering'} = $old_url_filtering;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'group'} = $old_group;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'data_filtering'} = $old_data_filtering;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'file_blocking'} = $old_file_blocking;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'disabled'} = $old_disabled;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'schedule'} = $old_schedule_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'qos'} = $old_qos;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'ruleset'} = $ruleset;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'change'} = "Old";
                        		$out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'date'} = $detail_time;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag_mismatch'} = $tag_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'desc_mismatch'} = $desc_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from_mismatch'} = $from_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_mismatch'} = $source_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'srcuser_mismatch'} = $srcuser_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to_mismatch'} = $to_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_mismatch'} = $destination_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'app_mismatch'} = $app_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_mismatch'} = $service_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action_mismatch'} = $action_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'options_mismatch'} = $options_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'profile_mismatch'} = $profile_mismatch;


					$historycountnum++;
		                        $historycount =  "R" .$historycountnum;
=begin
					print "New Rule {'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name} {fw=$fw}{vsys=$vsys}{ruleset=$ruleset}{tag=$tag} {from=$from} {negate_source=$negate_source} {source_add_out=$source_address_out} {source_add_val=$source_address_value_out} {src_user=$source_user} {to=$to} {neg_dst=$negate_destination} {dst_add=$destination_address_out} {dst_add_val_out=$destination_address_value_out} {app=$appication} {svc_out=$service_out} {svc_val_out=$service_value_out} {action=$action} {log_start=$log_start} {log_end=$log_end} {log_setting=$log_setting} {spy=$spyware} {vul=$vulnerabiity} {virus=$virus} {url=$url_fitering} {group=$group} {data_filtering=$data_fitering} {file=$file_blocking} {disabled=$disabled} {schedule=$schedule_out} {qos=$qos} \n\n";
print "{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag'} = $tag\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'description'} = $description\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from'} = $from\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_source'} = $negate_source\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_out'} = $source_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_value_out'} = $source_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_user'} = $source_user\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to'} = $to\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_destination'} = $negate_destination\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_out'} = $destination_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_value_out'} = $destination_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'application'} = $application\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_out'} = $service_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_value_out'} = $service_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action'} = $action\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_start'} = $log_start\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_end'} = $log_end\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_setting'} = $log_setting\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'spyware'} = $spyware\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'vulnerability'} = $vulnerability\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'virus'} = $virus\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'url_filtering'} = $url_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'group'} = $group\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'data_filtering'} = $data_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'file_blocking'} = $file_blocking\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'disabled'} = $disabled\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'schedule'} = $schedule_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'qos'} = $qos\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'ruleset'} = $ruleset\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'change'} = New\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'date'} = $detail_time\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag_mismatch'} = $tag_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'desc_mismatch'} = $desc_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from_mismatch'} = $from_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_mismatch'} = $source_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'srcuser_mismatch'} = $srcuser_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to_mismatch'} = $to_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_mismatch'} = $destination_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'app_mismatch'} = $app_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_mismatch'} = $service_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action_mismatch'} = $action_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'options_mismatch'} = $options_mismatch\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'profile_mismatch'} = $profile_mismatch\n";
=cut

                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag'} = $tag;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'description'} = $description;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from'} = $from;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_source'} = $negate_source;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_out'} = $source_address_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_value_out'} = $source_address_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_user'} = $source_user;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to'} = $to;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_destination'} = $negate_destination;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_out'} = $destination_address_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_value_out'} = $destination_address_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'application'} = $application;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_out'} = $service_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_value_out'} = $service_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action'} = $action;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_start'} = $log_start;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_end'} = $log_end;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_setting'} = $log_setting;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'spyware'} = $spyware;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'vulnerability'} = $vulnerability;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'virus'} = $virus;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'url_filtering'} = $url_filtering;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'group'} = $group;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'data_filtering'} = $data_filtering;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'file_blocking'} = $file_blocking;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'disabled'} = $disabled;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'schedule'} = $schedule_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'qos'} = $qos;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'ruleset'} = $ruleset;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'change'} = "New";
                        		$out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'date'} = $detail_time;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag_mismatch'} = $tag_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'desc_mismatch'} = $desc_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from_mismatch'} = $from_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_mismatch'} = $source_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'srcuser_mismatch'} = $srcuser_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to_mismatch'} = $to_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_mismatch'} = $destination_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'app_mismatch'} = $app_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_mismatch'} = $service_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action_mismatch'} = $action_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'options_mismatch'} = $options_mismatch;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'profile_mismatch'} = $profile_mismatch;

				}
				else {
					#print "Rule OK\n";
				}

			}
			else {
					$historycountnum++;
		                        $historycount =  "R" .$historycountnum;
				print "Created Rule {'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{fw=$fw}{vsys=$vsys}{ruleset=$ruleset}{tag=$tag} {from=$from} {neg_src=$negate_source} {src_out=$source_address_out} {src_add_val=$source_address_value_out} {src_user=$source_user} {to=$to} {neg_dst=$negate_destination} {dst_add=$destination_address_out} {dst_add_val=$destination_address_value_out} {app=$appication} {svc=$service_out} {svc_val=$service_value_out} {action=$action} {log_start=$log_start} {log_end=$log_end} {log_set=$log_setting} {spy=$spyware} {vuln=$vulnerability} {virus=$virus} {url=$url_fitering} {group=$group} {data_filtering=$data_filtering} {file_block=$file_blocking} {disabled=$disabled} {schedule=$schedule_out} {qos=$qos} \n\n";
=begin
print "{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag'} = $tag\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'description'} = $description\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from'} = $from\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_source'} = $negate_source\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_out'} = $source_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_value_out'} = $source_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_user'} = $source_user\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to'} = $to\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_destination'} = $negate_destination\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_out'} = $destination_address_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_value_out'} = $destination_address_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'application'} = $application\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_out'} = $service_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_value_out'} = $service_value_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action'} = $action\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_start'} = $log_start\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_end'} = $log_end\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_setting'} = $log_setting\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'spyware'} = $spyware\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'vulnerability'} = $vulnerability\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'virus'} = $virus\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'url_filtering'} = $url_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'group'} = $group\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'data_filtering'} = $data_filtering\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'file_blocking'} = $file_blocking\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'disabled'} = $disabled\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'schedule'} = $schedule_out\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'qos'} = $qos\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'ruleset'} = $ruleset\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'change'} = Added\n
{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'date'} = $detail_time\n";
=cut


#                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'tag'} = $tag;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'description'} = $description;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'from'} = $from;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_source'} = $negate_source;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_out'} = $source_address_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_address_value_out'} = $source_address_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'source_user'} = $source_user;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'to'} = $to;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'negate_destination'} = $negate_destination;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_out'} = $destination_address_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'destination_address_value_out'} = $destination_address_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'application'} = $application;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_out'} = $service_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'service_value_out'} = $service_value_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'action'} = $action;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_start'} = $log_start;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_end'} = $log_end;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'log_setting'} = $log_setting;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'spyware'} = $spyware;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'vulnerability'} = $vulnerability;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'virus'} = $virus;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'url_filtering'} = $url_filtering;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'group'} = $group;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'data_filtering'} = $data_filtering;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'file_blocking'} = $file_blocking;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'disabled'} = $disabled;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'schedule'} = $schedule_out;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'qos'} = $qos;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'ruleset'} = $ruleset;
                                        $out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'change'} = 'Added';
                        		$out_history_hash{'vsys'}{$vsys}{'count'}{$historycount}{'entry'}{$name}{'entry'}{'date'} = $detail_time;

			}
		}
	}
}

if (1==2){
	#exit 2;
}
