FROM alpine

RUN apk add --no-cache certbot && \
    echo "0 0 * * * /usr/bin/certbot renew > /dev/null" | crontab -u root - && \
    mkdir -p /etc/letsencrypt/challenge

VOLUME /etc/letsencrypt

CMD certbot certonly \
        --agree-tos \
        --no-eff-email \
        --webroot \
        --webroot-path /etc/letsencrypt/challenge \
        --email $LETSENCRYPT_EMAIL \
        --domains $LETSENCRYPT_DOMAINS \
    && crond -f
