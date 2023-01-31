FROM osvunikernel/osv-ubuntu-20.10-builder-base
COPY ./U1 ./U1
COPY ./U2 ./U2
COPY ./U3 ./U3
COPY ./F1 ./F1

WORKDIR /git-repos/osv/U1
RUN capstan package compose --pull-missing u1-osv-rsx217
WORKDIR /git-repos/osv/U2
RUN capstan package compose --pull-missing u2-osv-rsx217
WORKDIR /git-repos/osv/U3
RUN capstan package compose --pull-missing u3-osv-rsx217
WORKDIR /git-repos/osv/F1
RUN capstan package compose --pull-missing f1-osv-rsx217
