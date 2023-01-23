FROM osvunikernel/osv-ubuntu-20.10-builder-base

COPY ./U3 ./U3
WORkDIR /git-repos/osv/U3
RUN capstan package compose --pull-missing u3-test
RUN capstan run u3-test
