#!/usr/bin/env sh
set -e

# Generate certificates if not exists, i.e. first time
if [ ! -d "/etc/letsencrypt/live" ]; then
  mkdir -p /etc/letsencrypt/challenge

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
    echo "WARNING: Missing env vars LETSENCRYPT_EMAIL and LETSENCRYPT_DOMAINS"
  fi
fi

# Generate nginx include conf
if [ ! -f "/etc/letsencrypt/ssl.conf" ]; then
  fullchain=$(find /etc/letsencrypt/live -name fullchain.pem 2> /dev/null | head -1)

  if [ $fullchain ]; then
    echo "Generating nginx config..."
    privkey=$(dirname ${fullchain})/privkey.pem

    echo "ssl_certificate    ${fullchain};" > /etc/letsencrypt/ssl.conf
    echo "ssl_certificate_key ${privkey};" >> /etc/letsencrypt/ssl.conf
  else
    echo "WARNING: nginx config not generated, no certificate found"
  fi
fi

if [ ! -d "/etc/letsencrypt/snakeoil" ]; then
    echo "Generating snakeoil certificate..."
    mkdir -p /etc/letsencrypt/snakeoil
    openssl req \
        -new \
        -nodes \
        -x509 \
        -days 3650 \
        -subj "/C=AU/ST=Some-State/O=Internet Widgits Pty Ltd" \
        -out /etc/letsencrypt/snakeoil/nginx.crt \
        -keyout /etc/letsencrypt/snakeoil/nginx.key
fi

exec "$@"
