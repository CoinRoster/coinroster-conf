#!/bin/bash

echo "This installation is to be run after setting up the SQL server. For a step-by-step guide please refer to https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-ubuntu-18-04#step-2-%E2%80%93-installing-mysql-to-manage-site-data"
echo ''
echo "WARNING: this operation will replace the contents of /usr/share/java. You can ignore this if you are using a new server or you are sure that there are no existing java apps."
echo ''

read -p 'Continue? (y/n)  ' continue

if [[ $continue != 'y' ]]; then
    exit 1
fi

# delete java directory and get the tar file from live server
rm -r /usr/share/java

# extract the tar file

tar xzvf ~/coinroster-conf/coinroster.tar.gz

read -sp 'Setting up SQL environment. Please enter the root SQL password: ' sql_pass

# create the coinroster database and set it up using the phpmyadmin script
sudo mysql -u root -p${sql_pass} < ~/coinroster-conf/coinroster/create_db.sql

# check if it ran successfully; error could be internal SQL as well
if [ $? -ne 0 ]; then
    echo "Internal SQL error. Check password"
#    exit 1
fi

sudo mysql -u root -p${sql_pass} coinroster < ~/coinroster-conf/coinroster/coinroster-test.sql

# create /usr/share/java
mkdir /usr/share/java
cp -r ~/coinroster-conf/coinroster /usr/share/java

# replace db user and password config variables
sed -i -e 's/coinrostersql/root/g' /usr/share/java/coinroster.config.txt
sed -i -e "s/crsqlpass/$sql_pass/g" /usr/share/java/coinroster.config.txt

# run the start script, download java if necessary
#sudo apt install openjdk-8-jre-headless

# start auxilary processes
bash /usr/share/java/coinroster.start.sh

# start main process
java -jar /usr/share/java/coinroster.jar

# verify that server is online

echo "Connecting to server..."
read -p "Proceed?" proceed
telnet localhost 27038

# finally, clone html and Node repos

# cd /var/www/html
# git clone https://github.com/CoinRoster/coinroster-html.git

exit 1
