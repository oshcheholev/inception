#!/bin/bash

set -e

# Validate required environment variables
if [ -z "$FTP_USER" ]; then
  echo "ERROR: FTP_USER environment variable not set"
  exit 1
fi

FTP_PASS=$(cat /run/secrets/ftp_password.txt)

# Create vsftpd required directories
install -d -m 0555 /var/run/vsftpd/empty

# Remove user if it already exists, then create it
userdel -rf ${FTP_USER} 2>/dev/null || true
useradd -m ${FTP_USER}
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# give access to WordPress
usermod -d /var/www/html ${FTP_USER}

# ownership
chown -R ${FTP_USER}:${FTP_USER} /var/www/html

# start FTP
exec vsftpd /etc/vsftpd.conf