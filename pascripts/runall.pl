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
my $xml = new XML::Simple(ForceArray => [vsys , rule ,  prerule , postrule]);

my $time = localtime;

my $dir = $0;
$dir =~ s/runall\.pl$//;

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


my @all_fw =();
open(FILE, "$scriptroot/fw.txt") or die("Unable to open file");
        @all_fw = <FILE>;
close FILE;

my $authkey = ();
my $print_out = ();
foreach my $all_fw (@all_fw){
        my @splitfw = split(/,/,$all_fw);
        my $current_fw = $splitfw[0];
	print "$current_fw\n";
		`$scriptroot/xmlformatter.pl $current_fw`;
my $exit_val = $? >> 8;
print $exit_val . "\n";
	if ($exit_val != 0){
		$print_out .= "$time : $current_fw\n"
	}

}
open(my $fh, '>>', "$scriptroot/report.txt");
print $fh $print_out;
close $fh;

