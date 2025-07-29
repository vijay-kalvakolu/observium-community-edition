FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Apache, PHP, and dependencies
RUN apt-get update && \
    apt-get install -y apache2 mysql-client php php-mysql php-snmp php-gd \
    php-xml php-mbstring php-curl php-bcmath php-opcache php-pear \
    snmp fping graphviz rrdtool whois ipmitool \
    python3 python3-pymysql python3-mysqldb wget unzip git cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up the web root
WORKDIR /opt/observium

# Copy the application (assumes build context is repo root)
COPY . /opt/observium

# Set permissions for application files
RUN chown -R www-data:www-data /opt/observium

# Make scripts executable
RUN chmod +x scripts/*.sh scripts/*.php

# Configure Apache
COPY observium.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite && \
    sed -i 's/display_errors = Off/display_errors = On/' /etc/php/8.1/apache2/php.ini && \
    sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php/8.1/apache2/php.ini

# Expose Apache
EXPOSE 80

# Set up entrypoint script for Apache and cron
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]