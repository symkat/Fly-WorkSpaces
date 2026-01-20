FROM debian:12

RUN apt-get update; \
    apt-get install -y git build-essential libpq-dev libssl-dev libz-dev libexpat1-dev cpanminus liblocal-lib-perl \
        postgresql-client postgresql-contrib postgresql python3-psycopg2; \
    useradd -U -s /bin/bash -m app;

ADD cpanfile /home/app/cpanfile
RUN chown -R app:app /home/app/cpanfile;

USER app
WORKDIR /home/app

RUN eval $(perl -Mlocal::lib); \
    echo 'eval $(perl -Mlocal::lib)' >> /home/app/.bashrc; \
    cpanm --verbose --installdeps .; \
    cpanm --verbose --installdeps .; \
    cpanm --verbose --installdeps

CMD sleep inf
