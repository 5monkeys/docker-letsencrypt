#!/usr/bin/env sh
set -e

# Generate certificates if not exists, i.e. first time
if [ ! -d "/etc/letsencrypt/challenge" ]; then
  if [ ${LETSENCRYPT_DOMAINS} ]; then
    echo "Generating certficates..."
    certbot certonly \
      --agree-tos \
      --no-eff-email \
      --webroot \
      --webroot-path /etc/letsencrypt/challenge \
      --email ${LETSENCRYPT_EMAIL} \
      --domains ${LETSENCRYPT_DOMAINS} && \
    rm /etc/letsencrypt/ssl.conf
  else
    echo "WARNING: Missing LETSENCRYPT_DOMAINS env var, skipping cert gen."
  fi
fi

# Generate snakeoil certificate
if [ ! -d "/etc/letsencrypt/snakeoil" ]; then
    echo "Generating snakeoil certificate..."
    mkdir -p /etc/letsencrypt/snakeoil
    openssl req \
        -new \
        -nodes \
        -x509 \
        -days 3650 \
        -subj "/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd" \
        -out /etc/letsencrypt/snakeoil/cert.pem \
        -keyout /etc/letsencrypt/snakeoil/key.pem
fi

# Generate nginx include conf
if [ ! -f "/etc/letsencrypt/ssl.conf" ]; then
  privkey=/etc/letsencrypt/snakeoil/key.pem
  fullchain=$(find /etc/letsencrypt/live -name fullchain.pem 2> /dev/null | head -1)

  if [ ${fullchain} ]; then
    privkey=$(dirname ${fullchain})/privkey.pem
  else
    fullchain=/etc/letsencrypt/snakeoil/cert.pem
  fi

  echo "Generating nginx config..."
  echo "ssl_certificate    ${fullchain};" > /etc/letsencrypt/ssl.conf
  echo "ssl_certificate_key ${privkey};" >> /etc/letsencrypt/ssl.conf
fi

exec "$@"
