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
$dir =~ s/checkxml\.pl$//;

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


use REST::Client;

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;


my $fw = $ARGV[0];
my $check = $ARGV[1];
my $vsys = $ARGV[2];


my $actionshow ='type=config&action=show';
my $actionget = 'type=config&action=get';
my $actionop = 'type=op&action=get';

if (!$vsys){
	$vsys = 'vsys1';
}
my @all_fw =();
open(FILE, "$scriptroot/fw.txt") or die("Unable to open file");
        @all_fw = <FILE>;
close FILE;

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
if (!$authkey){
	$authkey = "Insert Perm Key Here";
}


my ($xpath, $action)= ();
if ($check == 1){
        $xpath = "devices/entry/vsys/entry[\@name='$vsys']/rulebase/security/rules";
	$action = $actionshow;
}
elsif ($check == 2){
$xpath = "/config/panorama/vsys/entry[\@name='$vsys']/pre-rulebase/security/rules";
#	$xpath = "/config/panorama/vsys";
        $action = $actionget;
}
elsif ($check == 3){
        $xpath = "/config/panorama/vsys/entry[\@name='$vsys']/pre-rulebase/security/rules";
        $action = $actionget;
}
elsif ($check == 4){
        $xpath = "/config/panorama/vsys/entry[\@name='$vsys']/post-rulebase/security/rules";
        $action = $actionget;
}
elsif ($check == 5){
        $xpath = "/config/panorama/vsys/entry[\@name='$vsys']/address";
        $action = $actionget;
}
elsif ($check == 6){
        $xpath = "/config/panorama/vsys/entry[\@name='$vsys']/address-group";
        $action = $actionget;
}
elsif ($check == 7){
        $xpath = "/config/panorama/vsys/entry[\@name='$vsys']/service";
        $action = $actionget;
}
elsif ($check == 8){
        $xpath = "/config/panorama/vsys/entry[\@name='$vsys']/service-group";
        $action = $actionget;
}
elsif ($check == 9){
        $xpath = "/config/panorama/vsys/entry[\@name='$vsys']/application-group";
        $action = $actionget;
}
elsif ($check == 10){
        $xpath = "devices/entry/vsys/entry[\@name='$vsys']/service";
        $action = $actionshow;
}
elsif ($check == 11){
        $xpath = "devices/entry/vsys/entry[\@name='$vsys']/service-group";
        $action = $actionshow;
}
elsif ($check == 12){
        $xpath = "devices/entry/vsys/entry[\@name='$vsys']/address";
        $action = $actionshow;
}
elsif ($check == 13){
        $xpath = "devices/entry/vsys/entry[\@name='$vsys']/address-group";
        $action = $actionshow;
}
elsif ($check == 14){
        $xpath = "devices/entry/vsys/entry[\@name='$vsys']/application-group";
        $action = $actionshow;
}
elsif ($check == 15){
        $xpath = "devices/entry/vsys/entry[\@name='$vsys']/schedule";
        $action = $actionshow;
}
elsif ($check == 16){
        $xpath = "/config/shared/service";
        $action = $actionshow;
}
elsif ($check == 17){
        $xpath = "/config/shared/service-group";
        $action = $actionshow;
}
elsif ($check == 18){
        $xpath = "/config/shared/address";
        $action = $actionshow;
}
elsif ($check == 19){
        $xpath = "/config/shared/address-group";
        $action = $actionshow;
}
elsif ($check == 20){
        $xpath = "/config/shared/application-group";
        $action = $actionshow;
}
elsif ($check == 21){
        $xpath = "/config/predefined/service";
        #$action = $actionshow;
        $action = $actionget;
}
elsif ($check == 22){
	$xpath = '&cmd=<show><system><info></info></system></show>';
	$action = $actionop;
}
elsif ($check == 23){
        $xpath = "/config/predefined/threats/vulnerability";
        $action = $actionget;
}
elsif ($check == 24){
        $xpath = "devices/entry/vsys";
        $action = $actionshow;
}
elsif ($check == 25){
	$xpath = '&cmd=<show><counter></counter></show>';
	$action = $actionop;
}
elsif ($check == 26){
        $xpath = "/config/predefined";
        $action = $actionget;
}

#print "$xpath";
#exit();
my $restapi = 'esp/restapi.esp';
my $client = REST::Client->new();

my $restcombine =  "https://$fwconnect/$restapi?$action&key=$authkey&xpath=$xpath\n";
print "$restcombine\n";
my $getxml = $client->GET("$restcombine");
my $convert_xml = $client->responseContent();

 $convert_xml =~ s/>/>\n/g;
print $convert_xml;

