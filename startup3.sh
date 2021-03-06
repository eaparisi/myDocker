#!/bin/bash

cp /root/pw.txt /root/pw_old.txt
echo $ROOTPASS > /root/pw.txt
echo "root:$(cat /root/pw.txt)" | chpasswd

if [ ! -f /var/lib/mysql/dbdev ]; then

    mysql_install_db

    /usr/bin/mysqld_safe &
    sleep 5s

    mysql --user=root --password=$(cat /root/pw_old.txt) -e "CREATE DATABASE IF NOT EXISTS asatejDB DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    mysql --user=root --password=$(cat /root/pw_old.txt) -e "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY '$(cat /root/pw.txt)' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    mysql --user=root --password=$(cat /root/pw_old.txt) -e "UPDATE user SET Password=PASSWORD('$(cat /root/pw.txt)') WHERE User='root'; FLUSH PRIVILEGES;"

    killall mysqld
    sleep 5s
fi

/usr/bin/mysqld_safe &
sleep 5s

sed -i "s/desa.com.ar/$MYDOMAIN/g" /etc/apache2/sites-available/myvhost.conf
a2ensite myvhost.conf

sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php5/apache2/php.ini

service apache2 restart

/usr/sbin/sshd -D &
wait ${!}
