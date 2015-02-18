# python-2.7

FROM debian:jessie

# Install into the system the tools necessary to build apache and python.
RUN rm -r /var/lib/apt/lists/* && apt-get update && \
	apt-get install -y ca-certificates locales libssl1.0.0 curl gcc file \
		libc6-dev libssl-dev make xz-utils zlib1g-dev libbz2-dev \
		libsqlite3-dev libpcre++0 libpcre++-dev python-pip \
		python-virtualenv virtualenv --no-install-recommends && \
		rm -r /var/lib/apt/lists/*

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8

# Get buildout installed under /build
RUN mkdir -p /build && virtualenv /build/env
COPY requirements.txt /build/
WORKDIR /build
RUN (PATH=/build/env/bin:$PATH; \
	pip install -U -r requirements.txt && buildout init)

# Install apache and python under /whiskey
COPY buildout.cfg /build/
RUN PATH=/build/env/bin:$PATH buildout -v -v

# Cleanup the stuff that was only needed temporarily.
WORKDIR /
RUN rm -rf /build
RUN apt-get purge -y python.* libpython.* virtualenv

# Get pip installed in our new python location (under /whiskey)
ENV PATH /whiskey/python/bin:$PATH
RUN curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python && \
	pip install virtualenv

# Remove stuff that would just bloat our image.
RUN find /whiskey/python/lib \
	\( -type d -and -name test -or -name tests \) -or \
	\( -type f -and -name '*.pyc' -or -name '*.pyo' \) | \
	xargs -r rm -rf

# Store scripts that may be used to start a shell or in an 'onbuild' image.
COPY build.sh /whiskey/python/bin/mod_wsgi-docker-build
COPY common.sh /whiskey/python/bin/mod_wsgi-docker-common
COPY start.sh /whiskey/python/bin/mod_wsgi-docker-start
COPY shell.sh /whiskey/python/bin/mod_wsgi-docker-shell
COPY vars.sh /whiskey/python/bin/mod_wsgi-docker-vars

ENV PYTHONHASHSEED=random WSGI_RUN_USER=www-data WSGI_RUN_GROUP=www-data

WORKDIR /app
