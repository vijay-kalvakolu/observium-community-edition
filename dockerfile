# ---- Builder Stage ----
# This stage installs build dependencies and compiles the required PHP extensions.
FROM php:8.1-apache-bookworm AS builder

# Install build-time dependencies for PHP extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libsnmp-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libonig-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli snmp gd mbstring bcmath


# ---- Final Stage ----
# This stage builds the final, lean image for production.
FROM php:8.1-apache-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        default-mysql-client \
        snmp \
        fping \
        graphviz \
        rrdtool \
        whois \
        ipmitool \
        python3 python3-pymysql \
        wget unzip git cron \
        libfreetype6 libjpeg62-turbo libpng16-16 libonig5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy compiled PHP extensions and their configuration from the builder stage
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

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
RUN a2enmod rewrite

# Configure PHP
RUN { echo 'display_errors = On'; echo 'error_reporting = E_ALL'; } > /usr/local/etc/php/conf.d/99-observium.ini

# Expose Apache
EXPOSE 80

# Set up entrypoint script for Apache and cron
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]