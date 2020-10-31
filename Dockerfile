FROM debian:buster

# Update and install
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install nginx
RUN apt-get -y install wget
RUN apt-get -y install default-mysql-server
RUN apt-get -y install php php-mysql php-fpm php-cli php-mbstring php-zip php-gd

# Copy configs
COPY ./srcs/start.sh /var/
COPY ./srcs/mysql.sh /var/
COPY ./srcs/wordpress.tar.gz /var/
COPY ./srcs/wordpress.sql /var/
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost
COPY ./srcs/wp-config.php /var/www/html/wordpress/

# Install PHPMyAdmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-english.tar.gz
RUN tar xf phpMyAdmin-4.9.1-english.tar.gz && rm -rf phpMyAdmin-4.9.1-english.tar.gz
RUN mv phpMyAdmin-4.9.1-english/ var/www/html/phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin

# Install WordPress
RUN tar xzvf ./var/wordpress.tar.gz
RUN chmod 755 -R wordpress
RUN cp -a wordpress/. var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html
COPY ./srcs/wp-config.php var/www/html/wordpress

# Config nginx
RUN service nginx start
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
RUN rm /etc/nginx/sites-enabled/default

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=RU/ST=Kazan/L=Kazan/O=42/CN=ztawanna' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt
RUN chmod 755 /var/mysql.sh

# Config MySQL
RUN /var/mysql.sh

EXPOSE 80 443

# Start server
CMD bash /var/start.sh
