#stage1: build stage:- install dependencies and download source code
FROM php:8.1-apache AS builder

#set non-interactive mode for package installation
ENV DEBIAN_FRONTEND = noninteractive

#install system dependencies

RUN apt-get update && apt-get install -y -- no-install-recommends\
apt-utils\wget\fping\snmp\snmpd\
rrdtool\whois\mtr-tiny\ipmitool\
graphviz\imagemagick\mariadb-client\libapache2-mod-php\php-mysql\
php-gd\php-json\php-bcmath\php-mbstring\php-opache\php-curl\php-pear\
python3\python3-mysqldb\python3-pymysql\&& rm -rf /var/lib/apt/lists/*

#Install Observium CE
WORKDIR /opt
RUN wget http://www.observium.org/observium-community-latest.tar.gz && \
tar -zxvf observium-community-latest.tar.gz && \
mv observium-community-* observium && \
rm observium-community-latest.tar.gz

#stage2: Final Stage:- creating a lean production image
FROM php:8.1-apache

ENV DEBIAN_FRONTEND = noninteractive

#copy only necessary files from the builder stage

COPY --from=builder /usr/bin/fping /usr/bin/fping
COPY --from=builder /usr/bin/snmpget /usr/bin/snmpget
COPY --from=builder /usr/bin/snmpwalk /usr/bin/snmpwalk
COPY --from=builder /usr/bin/snmpbulkwalk /usr/bin/snmpbulkwalk
COPY --from=builder /usr/bin/rrdtool /usr/bin/rrdtool
COPY --from=builder /usr/bin/mysql /usr/bin/mysql
COPY --from=builder /usr/bin/python3 /usr/bin/python3
COPY --from=builder /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages

#install minimal runtime packages

RUN apt-get update && apt-get install -y --no-install-recommends\libmysqlclient21\librrd8\libsnmp40 \
&&rm -rf /var/lib/apt/lists/*

#Configure Apache
COPY <<EOF /etc/apache2/sites-available/000-default.Configure
<virtualHost *:80>
    DocumentRoot /opt/observium/html
    <Directory /opt/observium/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    <virtualHost>
    EOF

    RUN a2enmod rewrite

    #Create directores for persistent data 
    RUN mkdir -p /opt/observium/rrd /opt/observium/logs && \
    chown -R www-data:www-data /opt/observium/rrd /opt/observium/logs

    # Copy custom entrypoitn script
    COPY docker-entrypoitn.sh /usr/locval/bin
    RUN chmod +x /usr/local/bin/docker-entrypoint.sh

    # Expose Apache port 80

    EXPOSE 80

    # Set entrypoint
    ENTRYPOINT ["docker-entrypoitn.sh"]
    CMD ["apache2-foreground"]


