FROM symkat/fly-mojo-base:latest

USER app

ENV PATH                "/home/app/perl5/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
ENV PERL5LIB            "/home/app/perl5/lib/perl5"
ENV PERL_MB_OPT         "--install_base \"/home/app/perl5\""
ENV PERL_MM_OPT         "INSTALL_BASE=/home/app/perl5"
ENV PERL_LOCAL_LIB_ROOT "/home/app/perl5"

COPY --chown=app:app . /home/app/src

RUN cd /home/app/src/DB; \
    dzil build; \
    cpanm --verbose Fly-WorkSpace-DB-*.tar.gz ;\
    dzil clean

RUN cd /home/app/src/Web; \
    cpanm --verbose --installdeps . ;\
    cpanm --verbose --installdeps . ;\
    cpanm --verbose --installdeps .

CMD [ "sleep", "inf" ]
