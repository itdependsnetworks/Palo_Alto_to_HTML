Palo_Alto_to_HTML
=================

Script using API to pull down firewall rules and represent them in a webpage. 


###### Version 0.4
###### Maintained by Ken Celenza, ken@celenza.org, itdependsnetworks.com


###### Warning, this program has not been tested and is offered as is This requires you to keep a plain text file of your authkey's, review  your own secuirty process, to evaluate if this is ok
=================

**Install instructions:**

**Prerequisite**

Define a web and script root

You need a user/group that is going to be able to run these scripts and be readable 
by apache. Since apache will read the xml fileand  has to be able to read the images
and css files you untar'd 

```
Install cpan modules:
use REST::Client
use XML::Simple
use CGI 
use Data::Dumper (for troubleshooting)
use DBI (for rule tracking)
```

**Step 1: Move files in respective web and script roots** 
```
e.g.

cd /srv/www/htdocs/parules
mv /tmp/parules /srv/www/htdocs/parules
cd /scripts/pascripts/
mv /tmp/pascripts /scripts/
```

**Step 1a: Set directory permissions**

If you did not untrar or upload with correct owner, you can change it as such:  
chown -R owner:user for all files, using that magic user that is described above
e.g.
```
chown -R scriptuser:apachegroup /srv/www/htdocs/parules
chown -R scriptuser:apachegroup /scripts/pascripts
```

**Step 2: Excute Permissions**

Ensure the below files has proper execute permissions. 

xmlformatter.pl  
runall.pl  
pa.pl  
checkxml.pl  
runnow.pl  
dailyhistory.pl  

e.g.
``` 
cd /scripts/pascripts/
chmod 755 *.pl
cd /srv/www/htdocs/parules/
chmod 755 *.pl
```


**Step 3: Module Check**

Make sure you have modules  
run  
sh checkmodule.sh  

**Step 4: Config Files**

Move Config.tmp.txt to Config.txt in both folders

e.g. 

mv config.tmp.txt config.txt

	- updated config.txt for any columns you don't want showing by default,
		- simply change any 1 to a 0
	- Adjust mysql if using that feature
	- adjust the webroot and scriptroot folders

**Step 5: Get Key**

Get keys by running getkey.pl script

./getkey.pl <device> <username> <password>  
e.g.
```
./getkey.pl test-fw01.example.com admin password
```

**Step 6: Fill out firewall file**

Move fw.tmp.txt to fw.txt  
e.g. 

```
mv fw.tmp.txt fw.txt 
```

With that information populate fw.txt, ensuring there are always
2 commas as depicted in the file. The first column is the name as it shows, 
the next is the device it will connect to (think IP) if different then the
name in the first column

**Step 7: Run Script**
Run runall.pl  
./runall.pl  
This goes through all the FWs listed in fw.txt and creates xml  

**Step 8: CGI config**
Configure CGI to work on your apache  

e.g.
```
<Directory /var/www/html/parules/>
        Options +ExecCGI
        AddHandler cgi-script .cgi .pl
</Directory>
```

visit your website at webroot/pa.pl  
e.g. http://example.com/parules/pa.pl  

**Step 9: Set to Autorun**
Set crontab to run automatically

e.g. 
```
#Cronjob to run fw check for PA devices
0 23 * * * /scripts/pascripts/runall.pl get 2>&1
55 23 * * * /scripts/parules/dailyhistory.pl 2>&1
```

**Step 10: Rule Tracking**

If you want to use the rule_tracking feature, setup sql  

Upload your sql to your mysql server, using included sql file  
e.g.
```
mysql -u root -p[password] [database_name] < rule_tracker.sql
```

Fill out your mysql information in the config file in the script directory.  

The way the rule tracking works is based on an ID that if configured on the 
description field of the configuration matches the same ID in the mysql server, 
with either the firewall name or group as well. You can create a group using 
the fw.txt file and creating a 3rd comma on your grouped entries. This is useful 
if you use panorama and have the same policies across many firewalls. Be aware that
there is no vsys check, so do not overlap ID's between vsys on the same firewall.


e.g. fw.txt
```
site01-fw01,192.168.100.10,asodnaiasphfadsiufhadsoifhdsaf,offices
site02-fw01,,aosdhasiudhasiduhsada,offices
site03-fw01,,aosdhasiudhasiduhsada,offices
site04-fw01,,aosdhasiudhasiduhsada,offices
core01-fw01,,aosdhasiudhasiduhsada
```

In the above example all of the "site" firewalls will be in group offices, wheras
the core will be by itself. 

Under the "Rule Tracker Database" which you can only see after you click "Rule Tracker,"
the "Rules" column matches the description column in the actual config. You can have 
multiple firewall rules applied to one entry, just seperate them with a comma. This way if 
one request requires multiple rules, you can manage it that way. 


