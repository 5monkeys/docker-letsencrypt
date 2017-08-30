FROM alpine

VOLUME /etc/letsencrypt

RUN apk add --no-cache certbot && \
    echo "0 0 * * * /usr/bin/certbot renew > /dev/null" | crontab -u root -

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crond", "-f"]
