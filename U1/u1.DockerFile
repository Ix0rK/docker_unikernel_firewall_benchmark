FROM alpine:3.14
RUN apk add --update --no-cache python3
RUN python3 -m ensurepip

ADD ./U1/u1.py ./u1.py
RUN mkdir logs
ENTRYPOINT python3 u1.py

HEALTHCHECK CMD netstat -an | grep 20433 > /dev/null; if [ 0 != $? ]; then exit 1; fi;
HEALTHCHECK CMD netstat -an | grep 20022 > /dev/null; if [ 0 != $? ]; then exit 1; fi;
