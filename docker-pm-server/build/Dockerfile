FROM python:2.7

RUN mkdir -p /srv/conf && ln -sf /dev/stdout /var/log/pm_server.log

COPY server.py /srv/server.py
COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "/srv/server.py"]
