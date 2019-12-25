FROM ubuntu:18.04

RUN apt update && apt install -y apache2 
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && service apache2 restart 




#RUN service mysql restart && service apache2 restart

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install tzdata

#RUN echo "nameserver 8.8.8.8" |  tee /etc/resolv.conf > /dev/null

RUN apt-get update && apt-get -y upgrade 
RUN apt-get install -y mariadb-server mariadb-client  
RUN service mysql restart 
COPY ./mysql_secure_installation.sh .
RUN ls
RUN bash mysql_secure_installation.sh

RUN apt-get install -y software-properties-common
RUN add-apt-repository --yes ppa:ondrej/php && apt-get update

RUN apt install -y php7.1 libapache2-mod-php7.1 php7.1-common \
    php7.1-gmp php7.1-curl php7.1-soap php7.1-bcmath \
    php7.1-intl php7.1-mbstring php7.1-xmlrpc php7.1-mcrypt \
    php7.1-mysql php7.1-gd php7.1-xml php7.1-cli php7.1-zip

RUN rm -rf /etc/php/7.1/apache2/php.ini

COPY ./php.ini /etc/php/7.1/apache2/php.ini


RUN service apache2 restart
#RUN service mysql restart && service apache2 restart


COPY ./createmysql.sh .
RUN bash createmysql.sh

RUN mkdir /root/.composer 
COPY ./Magento-Starter/auth.json /root/.composer/auth.json
RUN ls /root/.composer

RUN apt install -y curl git 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir var/www/html/magento2/
COPY ./Magento-Starter /var/www/html/magento2/
#RUN cp /var/www/html/index.html /var/www/html/magento2


#RUN chmod -R 755 /var/www/html/magento2/
 
RUN service mysql restart && service apache2 restart && cd /var/www/html/magento2 && bin/magento setup:install \
    --db-host=localhost --db-name=magento --db-user=magento2user --db-password=abcd1234 \
    --admin-firstname=Admin --admin-lastname=User --admin-email=admin@example.com \
    --admin-user=admin --admin-password=admin123\
    --language=en_US --currency=USD --timezone=Asia/Karachi --use-rewrites=1

RUN chown -R www-data:www-data /var/www/html/magento2/
RUN chmod -R 755 /var/www/html/magento2/


COPY ./magento2.conf /etc/apache2/sites-available/magento2.conf
RUN a2ensite magento2.conf
RUN a2enmod rewrite

CMD service mysql restart
CMD service apache2 restart

