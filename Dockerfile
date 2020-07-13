FROM ubuntu:14.04

RUN apt-get -y update && apt-get install -y wget perl sshpass libwww-mechanize-perl perl libssl-dev subversion traceroute nmap vim-nox ipcalc libxml-simple-perl apache2 php5 php5-mysql make mysql-client-5.6 libmysqlclient-dev

RUN cpan force install REST::Client XML::Simple CGI Data::Dumper DBI Date::Simple MIME::Lite Date::Calc DBD::mysql

RUN a2enmod cgi php5

RUN echo "<Directory /var/www/html/>" >> /etc/apache2/apache2.conf \
 && echo "  Options +ExecCGI" >> /etc/apache2/apache2.conf \
 && echo "  AddHandler cgi-script .cgi .pl" >> /etc/apache2/apache2.conf \
 && echo "</Directory>" >> /etc/apache2/apache2.conf

COPY ./pascripts/rule_tracker.sql /tmp/

RUN mkdir /scripts
