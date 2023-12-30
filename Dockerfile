FROM quay.io/centos/centos:stream9

# Install Apache, PHP, MariaDB, and Supervisor
RUN dnf -y update && \
    dnf -y install 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled crb && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm && \
    dnf -y module switch-to php:remi-8.3 && \
    dnf -y install composer procps-ng httpd php-fpm php-common mariadb-server mariadb supervisor && \
    dnf clean all

# Create required directories
RUN mkdir -p /run/php-fpm && chown -R apache:apache /run/php-fpm

# Initialize MariaDB data directory
RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Copy service files
COPY ./html/* /var/www/html/

# Configure Supervisor to manage services
COPY supervisord.conf /etc/supervisord.conf

# Expose port 80 for the web server
EXPOSE 80

# Start Supervisor as the main process
CMD ["/bin/supervisord","-c","/etc/supervisord.conf"]
