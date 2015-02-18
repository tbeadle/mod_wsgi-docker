FROM mod-wsgi-docker:python3.4

ONBUILD COPY docker/ /whiskey/
ONBUILD RUN mod_wsgi-docker-build

EXPOSE 80
ENTRYPOINT [ "mod_wsgi-docker-start" ]
