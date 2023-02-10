FROM alpine:3.14
RUN apk add --update --no-cache python3
RUN python3 -m ensurepip

ADD ./U2/u2.py ./u2.py
RUN mkdir logs
ENTRYPOINT python3 u2.py

HEALTHCHECK CMD netstat -an | grep 22221 > /dev/null; if [ 0 != $? ]; then exit 1; fi;
