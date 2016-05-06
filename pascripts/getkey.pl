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

use REST::Client;

my $fw = $ARGV[0];
my $username = $ARGV[1];
my $password = $ARGV[2];

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

my $restapi = 'esp/restapi.esp';
my $client = REST::Client->new( );
$client->getUseragent()->ssl_opts( SSL_verify_mode => 0 );

my $restcombine =  "https://$fw/$restapi?type=keygen&user=$username&password=$password";
print "$restcombine\n\n";

my $getxml = $client->GET("$restcombine");
my $convert_xml = $client->responseContent();

if ($convert_xml =~ /<key>(.+)<\/key>/){
	print "$1";
}
print "\n";
